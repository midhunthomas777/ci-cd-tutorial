public without sharing class DTSFPART_LWC_Account {

    private static final String STATE_LOCAL_MANUFACTURER_REPRESENTATIVE = 'State/Local Manufacturer Representative';
    private static final String FEDERAL_MANUFACTURER_REPRESENTATIVE = 'Federal Manufacturer Representative';
    private static final String STATE_AND_LOCAL_MANUFACTURER_REPRESENTATIVE_ID = 'State and Local Manufacturer Representative ID';
    private static final String FEDERAL_MANUFACTURER_REPRESENTATIVE_ID = 'Federal Manufacturer Representative ID';

    private static Id getCurrentUserAccount() {
        return DTSFPART_DashboardComponentsController.getCurrentUser().Contact.AccountId;
    }

    private static Id getAccountId(Id accountId) {
        if (String.isBlank(accountId)) {
            return getCurrentUserAccount();
        } else {
            return accountId;
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<Account> getCustomerNumbersByAccountId(Id accountId) {
        try {
            return [
                SELECT Motorola_Customer_Number__c
                FROM Account
                WHERE ParentId =: accountId AND Motorola_Customer_Number__c != ''
            ];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }     
    }

    @AuraEnabled(cacheable=true)
    public static List<Account> getMRCustomerNumbersByAccountId(Id accountId){
        try {
            return [
                SELECT Motorola_Customer_Number__c
                FROM Account
                WHERE Assigned_MR__c =: accountId AND Motorola_Customer_Number__c != '' AND RecordType.DeveloperName = 'Motorola_Customer_Number'
            ];            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<Account> getAssociatedCustomersByAccountId(Id accountId){
        try {
            return [
                SELECT Motorola_Customer_Number__c
                FROM Account
                WHERE ParentId =: accountId AND Motorola_Customer_Number__c != ''
                AND RecordType.DeveloperName = 'Customer'
            ];            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }    

    @AuraEnabled(cacheable=true)
    public static Boolean isMrAccount(Id accountId){
        try {
            Id QueryAccountId = getAccountId(accountId);
            return [
                SELECT Id
                FROM Technology_Specialization__c
                WHERE Account__c =: QueryAccountId
                AND (Community_Type__c =: STATE_LOCAL_MANUFACTURER_REPRESENTATIVE OR Community_Type__c =: FEDERAL_MANUFACTURER_REPRESENTATIVE)
                AND Technology_Specialization_Status__c = 'Active'
            ].size() > 0;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<Partner_Identifier__c> getMrIds(Id accountId) {
        try {
            Id QueryAccountId = getAccountId(accountId);
            return [
                SELECT ID_Number__c, ID_Type__c
                FROM Partner_Identifier__c
                WHERE Account__c =: QueryAccountId
                AND (ID_Type__c =: STATE_AND_LOCAL_MANUFACTURER_REPRESENTATIVE_ID OR ID_Type__c =: FEDERAL_MANUFACTURER_REPRESENTATIVE_ID)
            ];   
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

}