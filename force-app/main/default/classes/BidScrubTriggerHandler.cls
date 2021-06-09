public class BidScrubTriggerHandler implements ITriggerHandler{
    public static Boolean TriggerDisabled = false;
    public Boolean IsDisabled(){
        if (TriggerSettings__c.getValues('BidScrubTriggerHandlerDisabled').IsActive__c)
            return true;
        else
            return TriggerDisabled;
    }
    
    public void BeforeInsert(List<SObject> newItems){
        List<Bid_Scrub__c > bidScrubsToUpdate = new List<Bid_Scrub__c >();     
        for(Bid_Scrub__c  eachBSP : (List<Bid_Scrub__c >)newItems) {
            if (String.isBlank(eachBSP.Product_APC__c) &&  String.isBlank(eachBSP.Product_WWAPC__c)) {                
                eachBSP.addError('Could not add this Quote Product, as APC / WWAPC value is required to add a product to the Quote');                
            }else{
                bidScrubsToUpdate.add(eachBSP );
            }            
        }
        if(!bidScrubsToUpdate.isEmpty()) {
            CPQUtility.populateProductFamily(new List<BigMachines__Quote_Product__c>(),bidScrubsToUpdate);
        }
        
    }
    
    public void BeforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems){
        List<Bid_Scrub__c > bidScrubsToUpdate = new List<Bid_Scrub__c >();     
        for(Bid_Scrub__c  eachBSP : (List<Bid_Scrub__c >)newItems.values()) {
            Bid_Scrub__c oldBidScrub = (Bid_Scrub__c) oldItems.get(eachBSP.Id);
            if (String.isBlank(eachBSP.Product_APC__c) &&  String.isBlank(eachBSP.Product_WWAPC__c)) {                
                eachBSP.addError('Could not add this Quote Product, as APC / WWAPC value is required to add a product to the Quote');                
            }else if(eachBSP.Product_APC__c != oldBidScrub.Product_APC__c || eachBSP.Product_WWAPC__c != oldBidScrub.Product_WWAPC__c){
                bidScrubsToUpdate.add(eachBSP );
            }            
        }
        if(!bidScrubsToUpdate.isEmpty()) {
            CPQUtility.populateProductFamily(new List<BigMachines__Quote_Product__c>(),bidScrubsToUpdate);
        }
    }
    
    public void BeforeDelete(Map<Id, SObject> oldItems){}
    
    public void AfterInsert(Map<Id, SObject> newItems){}
    
    public void AfterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems){}
    
    public void AfterDelete(Map<Id, SObject> oldItems){}
    
    public void AfterUndelete(Map<Id, SObject> oldItems){}
    
}