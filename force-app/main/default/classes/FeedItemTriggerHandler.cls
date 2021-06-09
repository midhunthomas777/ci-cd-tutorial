//Daraksha S: Modified FeedItemTriggerHandler class to add DispatchRemedyWorkItem functionality
public class FeedItemTriggerHandler implements ITriggerHandler {
          
    public void beforeInsert(List<SObject> newItems) {} 
    public void beforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {}
    public void afterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems){}
    public void afterInsert(Map<Id, SObject> newItems){
        RemedyIntegrationService.createremedyworkitems(newItems);
        JiraIntegrationService.createJiraWorkitems(newItems);
        ServiceNowIntegrationService.createServiceNowWorkitems(newItems);
        SmartClientIntegrationService.createscworkitems(newItems);
    }
        
    public void beforeDelete(Map<Id, SObject> oldItems) {}
    public void afterDelete(Map<Id, SObject> oldItems){}
    public void afterUndelete(Map<Id, SObject> oldItems) {} 
	
	public Boolean IsDisabled(){
        return TriggerSettings__c.getValues('FeedItemTriggerDisabled').IsActive__c;  
    }
}