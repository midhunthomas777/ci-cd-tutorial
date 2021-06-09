public class MRCPQ_AddProductsToOpportunity {
    @AuraEnabled
    public static String addProductsToOppo(String quoteId, String oppId){        
        return CPQUtility.upsertOpportunityLineItems('Button',quoteId,oppId,null);       
    }
    
    @AuraEnabled
    public static String removeProductsToOppo(String quoteId, String oppId){
        return RemovefromForecast.DrilldownTotalPrice(quoteId, oppId);
    }
}