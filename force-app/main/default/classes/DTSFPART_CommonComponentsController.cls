/**
 * @author		Krzysztof Pintscher
 * @created		2020-09-22
 * @description	Provide common data for LWC components
 */

public without sharing class DTSFPART_CommonComponentsController {

    private static final String MULE_OAUTH = 'Mulesoft_OAuth';

    @AuraEnabled
    public static String generateCustomerNumberJson(String customerNumber) {
        try {
            Map<String,String> payload = new Map<String,String>();
            String privateKey = System.Label.Secret_Key_for_OCC_Integration;
            payload.put('customerNumber', customerNumber);
            return JWT.generateAuthToken(payload, privateKey);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static Map<String,Object> getCurrentUserData(){
        try {
            User user = [
                SELECT  ContactId, 
                        Contact.Name,
                        Contact.Contact_Type__c,
                        Contact.Primary_Contact_Type__c,
                        Contact.Persona__c,
                        Contact.Partner_Region__c,
                        Contact.AccountId,
                        Contact.Account.Name,
                        Contact.Account.BillingCountryCode,
                        Contact.Account.Type,
                        Contact.Account.Partner_Primary_Country_Code__c,
                        toLabel(LanguageLocaleKey),
                        LocaleSidKey,
                        Profile.Name,
                        Profile.PermissionsModifyAllData
                FROM User
                WHERE Id =: UserInfo.getUserId() LIMIT 1
            ];

            Map<String,Object> userData = new Map<String,Object>();
            userData.put('contactId', user.Contact.Id);
            userData.put('contactName', user.Contact.Name);
            userData.put('primaryContactType', user.Contact.Primary_Contact_Type__c);
            userData.put('personaType', user.Contact.Persona__c);
            userData.put('partnerRegion', user.Contact.Partner_Region__c);
            userData.put('accountId', user.Contact.AccountId);
            userData.put('accountName', user.Contact.Account.Name);
            userData.put('accountType', user.Contact.Account.Type);
            userData.put('partnerPrimaryCountryCode', user.Contact.Account.Partner_Primary_Country_Code__c);
            userData.put('countryCode', user.Contact.Account.BillingCountryCode);
            userData.put('language', user.LanguageLocaleKey);
            userData.put('languageCode', user.LocaleSidKey);
            userData.put('profile', user.Profile.Name);
            userData.put('isAdmin', user.Profile.PermissionsModifyAllData);
            userData.put('currentLangauge', UserInfo.getLanguage());
            userData.put('userName', UserInfo.getName());
            userData.put('userType', UserInfo.getUserType());
            userData.put('timezone', UserInfo.getTimeZone().getDisplayName());

            return userData;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static String getCustomerCountry() {
        return [ SELECT Id, BillingCountryCode
                 FROM Account
                 WHERE Id =: DTSFPART_DashboardComponentsController.getCurrentUser().Contact.AccountId ]?.BillingCountryCode;
    }

    @AuraEnabled(cacheable=true)
    public static List<Account> getCustomerNumbers(){
        User currentUser = DTSFPART_DashboardComponentsController.getCurrentUser();
        return [
            SELECT Motorola_Customer_Number__c
            FROM Account
            WHERE (Id =: currentUser.Contact.AccountId OR ParentId =: currentUser.Contact.AccountId) AND Motorola_Customer_Number__c != ''
        ];
    }

    @AuraEnabled
    public static Map<String,Object> callMulesoft(String params, String mulesoftAction, String namedCredential, String useFederationId) {
        return callMulesoftGate(params, mulesoftAction, namedCredential, useFederationId);
    }

    @AuraEnabled(cacheable=true)
    public static Map<String,Object> callMulesoftWithCache(String params, String mulesoftAction, String namedCredential, String useFederationId) {
        return callMulesoftGate(params, mulesoftAction, namedCredential, useFederationId);
    }

    // TODO: Make use of DTSFPART_RequestBuilder
    private static Map<String,Object> callMulesoftGate(String params, String mulesoftAction, String namedCredential, String useFederationId) {
        String muleOAuth = String.isNotBlank(namedCredential) ? namedCredential : MULE_OAUTH;
        if (String.isNotBlank(useFederationId)) {
            MulesoftConnector.useFederationId = Boolean.valueOf(useFederationId);
        }
        if (String.isBlank(mulesoftAction)) {
            throw new AuraHandledException('Mulesoft Action is required.');
        }
        Map<String,Object> response = MulesoftConnector.callMulesoft(params, mulesoftAction, muleOAuth);
        
        if (response.get('ok') == true) {
            return response;
        } else {
            throw new AuraHandledException(String.valueOf(response.get('body')));
        }
    }    

    @AuraEnabled
    public static Map<String, Object> callMyViewProxy(String wrapper) {
        try {
            Map<String, Object> untypedWrapper = (Map<String, Object>) JSON.deserializeUntyped(wrapper);
    
            String method = (String) untypedWrapper.get('method');
            Map<String, String> headers = new Map<String, String>();
            if(method.equals('GET')){
                headers.put('Content-Type', '');
            }
    
            String endpoint = (String) untypedWrapper.get('endpoint');
            endpoint = endpoint.replace('?', '&');
            return MulesoftConnector.callMulesoft(new DTSFPART_RequestBuilder('MyView')
                    .customCredentials((String) untypedWrapper.get('credentials'))
                    .withEndpoint(endpoint)
                    .customMethod(method)
                    .withHeaders(headers)
                    .withBody(untypedWrapper.get('body'))
                    .withFederationId()
                    .withOamSession()
                    .withTimeout(120000)
                    .build());
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static Map<String, Object> callMyViewFileProxy(String wrapper, String body, String files){
        try {
            Map<String, String> formBody = (Map<String, String>) JSON.deserialize(body, Map<String, String>.class);
            List<DTSFPART_FileWrapper> filesBase64 = (List<DTSFPART_FileWrapper>) JSON.deserialize(files, DTSFPART_FileWrapper[].class);
            Blob formBlob = DTSFPART_EncodingUtils.encodeForm(formBody, new Map<String, String>(), filesBase64);
    
            Map<String, String> headers = getFormDataHeaders(String.valueOf(formBlob.size()));
    
            Map<String, Object> untypedWrapper = (Map<String, Object>) JSON.deserializeUntyped(wrapper);
            String queryParams = (String) untypedWrapper.get('queryParams');
            Map<String, String> queryParamsMap = String.isBlank(queryParams)?
                    new Map<String, String>():
                    (Map<String, String>) JSON.deserialize(queryParams, Map<String, String>.class);
    
            String endpoint = (String) untypedWrapper.get('endpoint');
            endpoint = endpoint.replace('?', '&');
            return MulesoftConnector.callMulesoft(new DTSFPART_RequestBuilder('MyView')
                    .customCredentials((String) untypedWrapper.get('credentials'))
                    .withEndpoint(endpoint)
                    .customMethod((String) untypedWrapper.get('method'))
                    .withEndpoint(endpoint)
                    .withHeaders(headers)
                    .withQueryParams(queryParamsMap)
                    .withBody((Object) formBlob)
                    .withFederationId()
                    .withTimeout(120000)
                    .build()
            );
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static Map<String, Object> addRemedyAttachment(String wrapper, String body, String files){
        try {
            List<DTSFPART_FileWrapper> filesBase64 = (List<DTSFPART_FileWrapper>) JSON.deserialize(files, DTSFPART_FileWrapper[].class);
            Blob formBlob = DTSFPART_EncodingUtils.encodeForm(new Map<String, String>(), new Map<String, String>{'entry' => body}, filesBase64, true);
    
            Map<String, String> headers = getFormDataHeaders(String.valueOf(formBlob.size()));
    
            Map<String, Object> untypedWrapper = (Map<String, Object>) JSON.deserializeUntyped(wrapper);
            String queryParams = (String) untypedWrapper.get('queryParams');
            Map<String, String> queryParamsMap = String.isBlank(queryParams)?
                    new Map<String, String>():
                    (Map<String, String>) JSON.deserialize(queryParams, Map<String, String>.class);
    
            return MulesoftConnector.callMulesoft(new DTSFPART_RequestBuilder(
                    (String) untypedWrapper.get('metadata'))
                    .withHeaders(headers)
                    .withQueryParams(queryParamsMap)
                    .withBody((Object) formBlob)
                    .withTimeout(120000)
                    .build()
            );
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static String getAccountSubmissionButton(Id accountId) {
        try {
            Account currentAccount = [ SELECT Id, RecordType.DeveloperName, Customer_or_Prospect_Account__r.RecordType.DeveloperName
                                       FROM Account
                                       WHERE Id = :accountId ];
    
            String NONE = 'NONE';
            String NEW_QUOTE = 'NEW_QUOTE';
            String NEW_ORDER = 'NEW_ORDER';
    
            String submissionButton = NONE;
    
            if (currentAccount.RecordType.DeveloperName == 'SoldToAccount') {//Customer
                submissionButton = NEW_QUOTE;
            } else if (currentAccount.RecordType.DeveloperName == 'Partner') {//Partner
                submissionButton = NEW_ORDER;
            } else if (currentAccount.RecordType.DeveloperName == 'Motorola_Customer_Number'
                        && currentAccount.Customer_or_Prospect_Account__r?.RecordType?.DeveloperName == 'Partner') {//MCN & Partner
                submissionButton = NEW_ORDER;
            } else if (currentAccount.RecordType.DeveloperName == 'Motorola_Customer_Number'
                        && currentAccount.Customer_or_Prospect_Account__r?.RecordType?.DeveloperName == 'SoldToAccount') {//MCN & Customer
                submissionButton = NONE;
            }  else if (currentAccount.RecordType.DeveloperName == 'Prospect') {//Prospect
                submissionButton = NEW_QUOTE;
            }
    
            return submissionButton;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    private static Map<String, String> getFormDataHeaders(String fromSize){
        return new Map<String, String> {
                'Content-Type' => DTSFPART_EncodingUtils.getContentType(),
                'Content-Length' => fromSize
        };
    }

    @AuraEnabled(cacheable=true)
    public static List<Technical_Site__c> getSiteReferenceIdsForCaseList(Id accountId) {
        try {
            List<Technical_Site__c> siteReferenceNumbers = [
                SELECT Vesta_Reference_Number__c 
                FROM Technical_Site__c 
                WHERE Site_Usage__c = 'End User' 
                AND Vesta_Reference_Number__c <> null 
                AND (NOT Vesta_Reference_Number__c LIKE '%-%') 
                AND Site_Type__c = 'Currently Served by MSI' 
                AND Center_Type__c <> null 
                AND Account_ID_18__c = :accountId
            ];
            return siteReferenceNumbers;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<System_Relationship__c> getCappNamesForCaseList(Id accountId) {
        try {
            List<System_Relationship__c> cappNames = [
                SELECT CAPP__r.Name 
                FROM System_Relationship__c 
                WHERE CAPP_Record_Type2__c  
                IN ( 'Emergency Call Taking (911)', 'Next Generation Core Services (NGCS)') 
                AND CAPP__r.Service_Provider__r.Partner_Membership_Id__c 
                IN ('3051157', '2691680', '2936328', '3096205') 
                AND Account__r.Id = :accountId
            ];
            return cappNames;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static String getCurrentAccountId(){
        User currentUser = DTSFPART_DashboardComponentsController.getCurrentUser();
        return currentUser.Contact.AccountId;
    }


}