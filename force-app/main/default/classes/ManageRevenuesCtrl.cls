public class ManageRevenuesCtrl {
    
    @AuraEnabled
    public static List<Product2> getProductFamilies(String runRateId){
        return [SELECT Id,Name FROM Product2 WHERE Id IN (SELECT product2Id FROM OpportunityLineItem WHERE Opportunity.Run_Rate_Definition__c =:runRateId) order by Name];//added orderby clause for SF-2087
    }
    
    @AuraEnabled
    public static Run_Rate_Definition__c getRunRateRevenue(String runRateId){
        return [SELECT Id,Revenue_Enabled__c,CurrencyIsoCode FROM Run_Rate_Definition__c WHERE Id =:runRateId];
    }
    
    @AuraEnabled
    public static AsyncApexJob getProgress(String runRateId){
        List<Run_Rate_Definition__c> RRD = [SELECT BatchPorcessId__c FROM Run_Rate_Definition__c WHERE Id =:runRateId];
        if(!RRD.isEmpty()){
            return [SELECT Id, Status, JobItemsProcessed, TotalJobItems, NumberOfErrors FROM AsyncApexJob WHERE ID =: RRD.get(0).BatchPorcessId__c];   
        }
        return NULL;
    }
    
    @AuraEnabled
    public static String getBatchStatus(String runRateId){
        List<Run_Rate_Definition__c> RRD = [SELECT Batch_Status__c FROM Run_Rate_Definition__c WHERE Id =:runRateId];
        if(!RRD.isEmpty()){
            return RRD.get(0).Batch_Status__c;
        }
        return NULL;
    }
    
    @AuraEnabled
    public static String updateRRDBatchStatus(String runRateId, String batchStatus){
        try {
            update new Run_Rate_Definition__c(
                Id = runRateId,
                Batch_Status__c = batchStatus
            );
            return 'SUCCESS';
        } catch (Exception ex) {
            return 'ERROR';
        }
    }    
    //SF-2240
    @AuraEnabled
    public static List<OpportunitylineItem> updateRevenueWithPrice(List<OpportunitylineItem> oppLineItems){
        for(OpportunitylineItem oli : oppLineItems){
            oli.Run_Rate_Revenue_Amount__c = oli.Run_Rate_Revenue_Amount__c;
        }
        update oppLineItems;
        return oppLineItems;
    }
}