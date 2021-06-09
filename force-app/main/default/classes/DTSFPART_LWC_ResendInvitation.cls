/**
 * @author      Paweł Woźniak
 * @created     2020-09-15
 * @updated     2020-11-19
 * @description Call mulesoft API
 * @JIRA        https://jira.mot-solutions.com/browse/DTPART-356
 */

public without sharing class DTSFPART_LWC_ResendInvitation {
    // It must be without sharing otherwise revoke invitation thow insufficient access error.
    // Bug: https://jira.mot-solutions.com/browse/DTPART-624

    private static final String CREDENTIAL_NAME = 'Mulesoft_OAuth';
    private static final String DEV_CREDENTIAL_NAME = 'Mulesoft_DEV';
    private static final String CONNECTION_DETAILS_NAME = 'DTSFPART_Resend_Invitation';
    private static final String REPLACE_C360_ENDPOINT = 'Mulesoft_ReplaceC360EndpointURL';

    @AuraEnabled
    public static boolean resendInvitation(String userEmail){
        try {

            Http httpCallout = new Http();
            HttpRequest request = new HttpRequest();
            String method = '';
            String endPoint_URL = '';

            String requesterEmail = UserInfo.getUserEmail();

            List <Mulesoft__mdt> connectionDetails = [SELECT Id, Content_Type__c, Endpoint__c, Method_Type__c
                                                      FROM Mulesoft__mdt
                                                      WHERE DeveloperName = :CONNECTION_DETAILS_NAME LIMIT 1];

            method = connectionDetails[0].Method_Type__c;
            request.setMethod(method);

            endPoint_URL = connectionDetails[0].Endpoint__c;
            endPoint_URL = endPoint_URL.replace('{UserEmail}', userEmail);
            endPoint_URL = endPoint_URL.replace('{RequesterEmail}', requesterEmail);

            // Chek if we need to replace c360 endpoint as of today it has different endpoint for C360QA which ipact our SIT.
            // Settings are stored in Custom Metadata Types -> Mulesoft -> "Mulesoft_ReplaceC360EndpointURL"
            // For details see bug https://jira.mot-solutions.com/browse/DTPART-489
            
            List <Mulesoft__mdt> replaceC360 = [SELECT Id, Content_Type__c, Endpoint__c, Method_Type__c
                                                FROM Mulesoft__mdt
                                                WHERE DeveloperName = :REPLACE_C360_ENDPOINT LIMIT 1];

            if (!replaceC360.isEmpty() && String.isNotBlank(replaceC360[0].Endpoint__c)) {
                endPoint_URL = endPoint_URL.replace('c360', replaceC360[0].Endpoint__c);
                request.setEndpoint('callout:' + DEV_CREDENTIAL_NAME + '/' + endPoint_URL);
            } else {
                request.setEndpoint('callout:' + CREDENTIAL_NAME + '/' + endPoint_URL);
            }

            HttpResponse response = httpCallout.send(request);

            if (response.getStatusCode() == 200) {
                return true;
            } else {
                LogError.saveHttpError('DTSFPART_LWC_ResendInvitation.resendInvitation()', 'Resend Invitation failed.', request, response);
                return false;
            }
        } catch (Exception e) {
            LogError.saveExceptionPEvent('DTSFPART_LWC_ResendInvitation.resendInvitation()', 'Resending invitation failed', 'User email: ' + userEmail, e);
            throw new AuraHandledException(e.getMessage());
        }

    }

    @AuraEnabled
    public static void revokeInvitation(Contact contact) {
        try {
            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
            message.setTargetObjectId(contact.Id);

            List<EmailTemplate> emailTemplate = [SELECT Id FROM EmailTemplate WHERE DeveloperName = 'Contact_Invitation_Revoke_Notification'];
            if (emailTemplate.isEmpty()) {
                throw new DMLException('Missing email template. Please contact Administrator.');
            }
            message.setTemplateId(emailTemplate.get(0).Id);

            List<Email_Address__mdt> mailAddress = [SELECT Email__c FROM Email_Address__mdt WHERE DeveloperName = 'DTSFPART_Revoke_Invitation'];
            if (mailAddress.isEmpty()) {
                throw new DMLException('Missing Replay To address confguration. Please contact Administrator.');
            }
            message.setReplyTo(mailAddress.get(0).Email__c);

            OrgWideEmailAddress[] owea = [SELECT Id from OrgWideEmailAddress WHERE Address = :mailAddress.get(0).Email__c];
            if(owea.size()>0) {
                message.setOrgWideEmailAddressId(owea.get(0).Id);
            }

            Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage> {message};
            Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);

            delete contact;
        } catch (Exception e) {
            LogError.saveExceptionPEvent('DTSFPART_LWC_ResendInvitation.revokeInvitation()', 'Rovekoing invitation failed', 'Contact: ' + contact.Id, e);
            throw new AuraHandledException(e.getMessage());
        }
    }
}