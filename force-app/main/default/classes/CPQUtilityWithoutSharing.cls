public without sharing class CPQUtilityWithoutSharing {
    public static void removeIsPrimaryFromReadOnlyQuote(Id oppId) {
        
    }
    public static String addProductsToOpportunity(Id quoteId,Id oppId) {
        //SF-1448 - Modify Rollup logic
        return CPQUtility.upsertOpportunityLineItems('CPQ',quoteId, oppId,'Button');
        //return RollupOppProductTotalPrice.RollupTotalPrice(quoteId, oppId);
    }
    public static String addProductsToOpportunity(List<Id> quoteIds,Id oppId) {
        return CPQUtility.upsertOpportunityCPQLineItems(quoteIds, oppId);
    }
    public static String removeProductsToOpportunity(Id quoteId,Id oppId) {        
        return RemovefromForecast.DrilldownTotalPrice(quoteId, oppId);
    }    
    public static void updateTC() {
        User usr = [SELECT ContactId FROM user WHERE Id =: UserInfo.getUserId()];
        List<Applications_Access__c> lstApplicationAccess = [SELECT Id,App_Access_Status__c FROM Applications_Access__c
                                                             WHERE App_Name__c =:'CPQ' AND Contact__c =: usr.ContactId];
        if(lstApplicationAccess.size() > 0 && lstApplicationAccess.get(0).App_Access_Status__c == 'T&C'){
            try{
                Applications_Access__c objApplnAccess = new Applications_Access__c();
                objApplnAccess.Id = lstApplicationAccess.get(0).Id;
                objApplnAccess.App_Access_Status__c = 'Active';
                update objApplnAccess;
            }catch(Exception ex){
                system.debug('Exception is...'+ex.getMessage());
            }
        }
    }
    public static void deactivateApplicationAccess(String applicationAccessId){
        if(applicationAccessId!=null){
            try{
            Applications_Access__c Appaccess= new Applications_Access__c();
            Appaccess.Id=applicationAccessId;
            Appaccess.App_Access_Status__c='InActive';
            update Appaccess;
        } catch(Exception ex){
            system.debug('Exception is...'+ex.getMessage());
        } 
        }
        
    }
     public static void reactivateApplicationAccess(String applicationAccessId){
        if(applicationAccessId!=null){
            try{
            Applications_Access__c Appaccess= new Applications_Access__c();
            Appaccess.Id=applicationAccessId;
            Appaccess.App_Access_Status__c=null;
            update Appaccess;
        } catch(Exception ex){
            system.debug('Exception is...'+ex.getMessage());
        } 
        }
        
    }
}