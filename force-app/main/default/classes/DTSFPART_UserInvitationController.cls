/**
 * @author       Sagar Sindhi
 * @created      2020-09-08
 * @updated      2020-11-20
 * @description  Controller for all backend logic for userInvitation Component. https://jira.mot-solutions.com/browse/DTPART-112
 */
public without sharing class DTSFPART_UserInvitationController {

    private static String MULE_OAUTH;

    @AuraEnabled
    public static String validateUser(Id currentRecordID, String credentialName, Id loggedInUserID, Contact contactRequest) {
        try {
            MULE_OAUTH = credentialName;
            Id currentAccountId = getAccountId(currentRecordID, loggedInUserID);
    
            // retrieve user details on the basis on Email
            List<User> userExisting = [
                SELECT Id, Name, ContactId, IsActive
                FROM User
                WHERE Email =: contactRequest.Email
            ];
    
            // verify if user EXIST with this EMAIL
            if (!userExisting.isEmpty()) {
                return validateIfUserExist(currentAccountId, userExisting);
            } else {
                Boolean contactExistWithoutUser = isContactExistWithoutUser(contactRequest.Email);
                if (!contactExistWithoutUser) {
                    List<MPEContact__c> mpeContact = [
                        SELECT ID, Name, Account__c
                        FROM MPEContact__c
                        WHERE Email__c =: contactRequest.Email 
                        AND Status__c = 'Pending Registration'
                    ];
                    if (!mpeContact.isEmpty()) {
                        return validateIfMPEContactExist(currentAccountId, mpeContact);
                    } else {
                        return validateIfMPEContactNotExist(currentAccountId, contactRequest);
                    }
                } else {
                    return 'CONTACT_EXIST_With_NO_USER';
                }
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    private Static String validateIfUserExist(Id currentAccountId, List<User> userExisting) {
        if (String.isNotEmpty(currentAccountId)) {
            Boolean contactAssociated = isContactAssociated(currentAccountId, userExisting.get(0).ContactId);
            if (contactAssociated) {
                if (userExisting.get(0).IsActive) {
                    return 'USER_EXIST_ON_SAME_ACCOUNT';
                } else {
                    return 'ABORT_DUE_TO_INACTIVE_USER = ' + userExisting.get(0).ContactId;
                }
            } else {
                return 'USER_EXIST_ON_OTHER_ACCOUNT';
            }
        } else {
            return 'USER_EXIST_AND_NO_ACCOUNTID_FOR_CURRENT_USER';
        }
    }

    private Static String validateIfMPEContactExist(Id currentAccountId, List<MPEContact__c> mpeContact) {
        if (String.isNotEmpty(currentAccountId)) {
            Id mpeContactID;
            for (MPEContact__c eachMPEContact: mpeContact) {
                if (eachMPEContact.Account__c.equals(currentAccountId)) {
                    mpeContactID = eachMPEContact.Id;
                    break;
                }
            }
            if (String.isNotBlank(mpeContactID)) {
                return 'MPE_CONTACT_ASSOCIATED =' + mpeContactID;
            } else {
                return 'ABORT_WITH_NO_MPECONTACT_ASSOCIATED';
            }
        } else {
            return 'MPE_CONTACT_EXIST_AND_NO_ACCOUNTID_FOR_CURRENT_USER';
        }
    }

    private Static String validateIfMPEContactNotExist(Id currentAccountId, Contact contactRequest) {
        String c360APIResult = verifyUserWithC360(contactRequest.Email);
        if (c360APIResult.equals('c360_USER_EXIST')) {
            contactRequest.Status__c = 'Registration Completed';
            return createContact(contactRequest, currentAccountId);
        } else if (c360APIResult.equals('c360_USER_DOES_NOT_EXIST')) {
            contactRequest.Status__c = 'Invited';
            return createContact(contactRequest, currentAccountId);
        } else {
            return 'C360_API_Error ' + c360APIResult;
        }
    }

    private static Id getAccountId(Id currentRecordID, Id loggedInUserID) {
        String userType = userinfo.getUserType();
        if(userType.Equals('Standard') && String.isNotBlank(currentRecordID)) {
            String objectName = currentRecordID.getSObjectType().getDescribe().getName();
            if(objectName.Equals('Account')) {
                return currentRecordID;
            }
        } else {
            return getUserAccountID(loggedInUserID);
        }
        return NULL;
    }

    private static Id getUserAccountID(Id loggedInUserID) {
        if (String.isNotBlank(loggedInUserID)) {
            List<User> loggedInUserDetails = [
                SELECT Id, Contact.AccountId
                FROM User
                WHERE Id =: loggedInUserID
            ];
            return loggedInUserDetails.get(0).Contact.AccountId;
        }
        return NULL;
    }

    private static Boolean isContactAssociated(Id currentAccountId, Id userContactID) {
        Integer contacts = [
            SELECT count()
            FROM Contact
            WHERE AccountId =: currentAccountId AND Id =: userContactID
        ]; 
        return contacts == 0 ? false : true;
    }

    private static Boolean isContactExistWithoutUser(String userEmail) {
        Integer contacts = [
            SELECT count()
            FROM Contact
            WHERE
            Email =: userEmail
            AND (RecordType.DeveloperName = 'MPE_Partner_Contact'
            OR RecordType.DeveloperName = 'EMS_Standard_Contact')
        ];
        return contacts == 0 ? false : true;
    }

    private static String verifyUserWithC360(String userEmail) {
        List<Mulesoft__mdt> metaData = [
            SELECT Endpoint__c, Method_Type__c
            FROM Mulesoft__mdt
            WHERE DeveloperName = 'SearchUserWithC360'
        ];
        List<Object> parameters = new List<Object> {userEmail};
        String endPoint_URL = String.format(metaData.get(0).Endpoint__c, parameters);
        Http httpCallout = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('callout:' + MULE_OAUTH + '/' + endPoint_URL);
        request.setMethod(metaData.get(0).Method_Type__c);
        HttpResponse response = httpCallout.send(request);
        if (response.getStatusCode() == 200) {
            return 'c360_USER_EXIST';
        } else if (response.getStatusCode() == 204) {
            return 'c360_USER_DOES_NOT_EXIST';
        } else {
            LogError.saveError('DTSFPART_UserInvitationController.verifyUserWithC360()', '', response.getBody());
            return 'Error = ' + response.getBody();
        }
    }

    @AuraEnabled
    public static String createContact(Contact contactRequest, Id currentAccountId) {
        contactRequest.AccountId = currentAccountId; //Add Current AccountId in the contact Request
        Database.SaveResult contactResult = Database.insert(contactRequest, false);
        if (contactResult.isSuccess()) {
            if (contactRequest.Status__c.equals('Registration Completed')) {
                send_RegistrationNotification(new List<Id>{contactResult.getId()});
            }
            return 'CONTACT_CREATED = ' + contactResult.getId();
        } else {
            Database.Error error = contactResult.getErrors().get(0);
            LogError.saveError('DTSFPART_UserInvitationController.createContact', '', error.getMessage());
            return 'Exception = ' + error.getMessage();
        }
    }

    public static void send_RegistrationNotification(List<Id> contactIds) {
        List<EmailTemplate> template = [
            SELECT Id
            FROM EmailTemplate
            WHERE DeveloperName = 'Registration_Completed_Notification'
        ];
        try {
            EmailMessagingClass.sendEmailMessage(
                contactIds, template.get(0).Id, null, false, null, null, null, true, null
            );
        } catch (Exception e) {
            LogError.saveExceptionPEvent('DTSFPART_UserInvitationController.send_RegistrationNotification', '', '', e);
            throw e;
        }
    }
}