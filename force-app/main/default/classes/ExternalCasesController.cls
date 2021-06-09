/**
* @author Accenture
* @date March 2020
* @description Controller for getting the Cases related data from external system using Mulesoft as Middleware
*/
public with sharing class ExternalCasesController {
    
    /****************************************************
*@description Returns Cases List from Vesta_Snow_Cases
*@param requestParams Map of Params 
*@return JSON of Cases
*/
    @AuraEnabled
    public static String caseList(Map<String,String> requestParams, String accountId) {
        
        if(GlobalUtility.isLoggedinCustomerCommunityUser() || GlobalUtility.isLoggedinPartnerUser()) {
            // current user is a partner user, overwrite whatever is coming from the component with the current user's customer number
            if(String.isBlank(accountId)) {
                // Partner Logged-In and we're getting from UserInfo
                User currentUser = [SELECT Contact.Account.Motorola_Enterprise_ID__c FROM User WHERE Id = : UserInfo.getUserId()];
                requestParams.put('account_param','partner.u_motorola_enterprise_id='+currentUser.Contact.Account.Motorola_Enterprise_ID__c);
            } else { // only when you're on the Account Record
                Account currentAccount = [Select Id,Motorola_Enterprise_ID__c from Account where Id =: accountId LIMIT 1];
                requestParams.put('account_param','partner.u_motorola_enterprise_id='+currentAccount.Motorola_Enterprise_ID__c);
            }
        }

        // add account_param to the query
        requestParams.put('sysparm_query', requestParams.get('account_param')+'^'+requestParams.get('sysparm_query'));
        requestParams.remove('account_param');

        String params = '?'+GlobalUtility.buildHttpUrl(requestParams);
        HTTPAPIResponse res = MulesoftHelper.callMuleByMetadata(params, null, 'Vesta_Snow_Cases', 'Mulesoft');

        if(res.responseStatus == 200 || res.responseStatus == 201) {
            return res.response.getBody();
        } else if ( res.responseStatus == 404 || res.responseStatus == 500 ) {
            // a 404 - Not Found is returned for accounts that have zero cases. return a string
            // that the calling component will intrepret as a result with zero records returned
            return '{ \"result\": []}';
        } else {
            return 'APIError';
        }
    }
    
    /*****************************************************
* @description GET request to get case detail by case number
* @param caseNumber Case number of the Case
* @return JSON of Case detail
*/
    //, String currentAccountId
    @AuraEnabled
    public static String caseDetail(String caseNumber) {
        /*List<Account> accounts = [Select Id from Account where Id =: currentAccountId LIMIT 1];
        if(accounts.isEmpty()) {
            return 'APIError';
        } */
        String  params = '?sysparm_view=extranet_export&sysparm_display_value=true&number='+EncodingUtil.urlEncode(caseNumber, 'UTF-8');
        HTTPAPIResponse res = MulesoftHelper.callMuleByMetadata(params, NULL, 'Vesta_Snow_Cases', 'Mulesoft');
        if(res.responseStatus == 200 || res.responseStatus == 201) {
            return res.response.getBody();
        } else {
            return 'APIError';
        }
    }
}