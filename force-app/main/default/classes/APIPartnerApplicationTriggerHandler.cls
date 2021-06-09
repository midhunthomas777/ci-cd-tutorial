//Class Name APIPartnerApplicationTriggerHandler 
public class APIPartnerApplicationTriggerHandler implements ITriggerHandler{
    
    public Boolean isDisabled(){
        return TriggerSettings__c.getValues('APIPartnerApplicationTriggerDisabled').IsActive__c;
    }
    public void BeforeInsert(List<SObject> newItems) {
        List<API_Partner_Application__c> newAPIPartnerApplnList = new List<API_Partner_Application__c>();
        if(newItems != null) newAPIPartnerApplnList = (List<API_Partner_Application__c>) newItems;
        
        for(API_Partner_Application__c apiAppln : newAPIPartnerApplnList){
            apiAppln.Access_Code__c = new Uuid().getValue();
        } 
    }
    
    public void afterInsert(Map<Id, SObject> newItems) {
        List<API_Partner_Application__c> newAPIPartnerApplnList = new List<API_Partner_Application__c>();
        if(newItems != null) newAPIPartnerApplnList = (List<API_Partner_Application__c>) newItems.values();
        User__c Submitter = User__c.getValues('Salesforce Operations');
        List<Approval.ProcessSubmitRequest> requests = new List<Approval.ProcessSubmitRequest> ();
        for(API_Partner_Application__c apiAppln : newAPIPartnerApplnList){
            Approval.ProcessSubmitRequest approvalRequest = new Approval.ProcessSubmitRequest();
            approvalRequest.setComments('Submitted for approval');
            approvalRequest.setObjectId(apiAppln.Id);
            approvalRequest.setSubmitterId(Submitter.Value__c);
            requests.add(approvalRequest);
        } 
        Approval.ProcessResult[] processResults = null;
        try {
            if (UserInfo.getUserType() == 'Guest' && requests != null)
            // Submit the approval request for the account
            processResults = Approval.process(requests, true);
        }catch (System.DmlException e) {
            System.debug('Exception Is ' + e.getMessage());
        }
    }
    public void BeforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {}
    public void afterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {}
    public void BeforeDelete(Map<Id, SObject> oldItems) {}
    public void afterDelete(Map<Id, SObject> oldItems) {}
    public void afterUndelete(Map<Id, SObject> oldItems){}
}