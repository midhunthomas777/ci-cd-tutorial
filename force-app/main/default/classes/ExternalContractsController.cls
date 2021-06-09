/**
* @author Accenture
* @date May 2020
* @description Controller for getting the Contracts related data from external system using Mulesoft as Middleware
*/
public without sharing class ExternalContractsController {

    /****************************************************
    *@description Returns Contract List
    *@param accountId id of the account that we want to get contract data
    *@return JSON of Contracts
    */
    @AuraEnabled
    public static String contractList(String accountId) {
        if (GlobalUtility.isLoggedinCustomerCommunityUser() || GlobalUtility.isLoggedinPartnerUser()) {
            HTTPAPIResponse res = MulesoftHelper.callMuleByMetadata(setParams(accountId), null, 'Vesta_Greenfield_Contracts', 'Mulesoft_OAuth');
            if (res.responseStatus == 200 || res.responseStatus == 201) {
                return res.response.getBody();
            } else {
                return 'APIError';
            }
        } else {
            return 'NOACCESS';
        }
    }

    private static String setParams(String accountId){
        User currentUser = [SELECT Id, FederationIdentifier, Contact.AccountId, Contact.Account.MCN_Account_Number__c FROM User WHERE Id = :UserInfo.getUserId()];

        String params = '?oam_session=' + currentUser.FederationIdentifier;
        if (String.isBlank(accountId)) {
            params = params + '&customer_acct_num=' + String.join((Iterable<String>) getMcnNumbers(currentUser.Contact.AccountId), ',');
        } else {
            params = params + '&customer_acct_num=' + String.join((Iterable<String>) getMcnNumbers(accountId), ',');
        }
        system.debug('setParams#######params###### => ' + params);
        return params;
    }

    /*****************************************************
    * @description GET request to get contract detail by contract number
    * @param contractNumber Contract number of the Contract
    * @return JSON of Contract detail
    */
    @AuraEnabled
    public static String contractDetail(String contractNumber) {
        User currentUser = [SELECT FederationIdentifier,Contact.Account.Motorola_Enterprise_ID__c FROM User WHERE Id = :UserInfo.getUserId()];
        String params = '?oam_session=' + currentUser.FederationIdentifier + '&contract_number=' + EncodingUtil.urlEncode(contractNumber, 'UTF-8');
        HTTPAPIResponse res = MulesoftHelper.callMuleByMetadata(params, null, 'Vesta_Greenfield_Contracts', 'Mulesoft_OAuth');
        if (res.responseStatus == 200 || res.responseStatus == 201) {
            return res.response.getBody();
        } else {
            return 'APIError';
        }
    }

    /*****************************************************
    * @description Get list of all MCN numbers for the account
    * @param parentAccountId id of account that we are currently using
    * @return Unique Set of MCN numbers
    */
    private static Set<String> getMcnNumbers(Id parentAccountId) {
        Set<String> mcnNumbers = new Set<String>();
        for(Account mcnAccount: [SELECT Id, Motorola_Customer_Number__c  FROM Account WHERE ParentId = :parentAccountId LIMIT 50000]){
            if(String.isNotBlank(mcnAccount.Motorola_Customer_Number__c)) { mcnNumbers.add(mcnAccount.Motorola_Customer_Number__c ); }
        }
        system.debug('getMcnNumbers#######mcnNumbers###### => ' + mcnNumbers);
        return mcnNumbers;
    }
}