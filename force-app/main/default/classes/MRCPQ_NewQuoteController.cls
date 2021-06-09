public with sharing class MRCPQ_NewQuoteController {

    @AuraEnabled
    public static String getAccountRecordTypeDeveloperNameWhenUserHasAccessToNewQuota(Id accountId) {

        String accountRecordTypeDeveloperName = getCurrentAccountRecordTypeDeveloperName(accountId);

        if (hasCurrentAccountCustomerOrProspectRecordType(accountRecordTypeDeveloperName)
            && (hasCurrentUserAccessToCreateQuote() || hasCurrentUserValidApplicationAccessToCPQ())) {
                 
            return accountRecordTypeDeveloperName;
        }

        return null;
    }

    private static String getCurrentAccountRecordTypeDeveloperName(Id accountId) {
        List<Account> account =  [ SELECT Id, RecordType.DeveloperName  
                                   FROM Account
                                   WHERE Id = :accountId ];
        if (!account.isEmpty()) {
            return account[0].RecordType.DeveloperName;
        }

        return null;
    }

    private static Boolean hasCurrentAccountCustomerOrProspectRecordType(String accountRecordTypeDeveloperName) {
        return accountRecordTypeDeveloperName == 'SoldToAccount' || accountRecordTypeDeveloperName == 'Prospect';
    }

    private static Boolean hasCurrentUserAccessToCreateQuote() {
        return Schema.sObjectType.BigMachines__Quote__c.isCreateable();
    }
    
    private static Boolean hasCurrentUserValidApplicationAccessToCPQ() {
        return  ![ SELECT Id, App_Name__c, Contact__c, App_Access_Status__c 
                   FROM Applications_Access__c 
                   WHERE App_Name__c = 'CPQ' 
                   AND App_Access_Status__c = 'T&C'
                   AND Contact__c = :DTSFPART_UserInfoService.getCurrentUserContactId() ].isEmpty();
    }

    @AuraEnabled      
    public static Boolean isPartnerUser() {
        return MRCommissionCalculatorController.isPartnerUser();
    }    
}