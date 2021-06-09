public class CommissionSummaryTriggerHandler implements ITriggerHandler	{
    
    public void BeforeInsert(List<SObject> newItems){
        system.debug('######newItems######## => ' + newItems);
        List<Commission_Summary__c> commissions = new List<Commission_Summary__c>();
        Set<String> mrIds = new Set<String>();
        Set<String> custMCNs = new Set<String>();
        for(Commission_Summary__c incomingCS : (List<Commission_Summary__c>)newItems){
            if(String.isNotBlank(incomingCS.AgentMR_ID__c) && String.isNotBlank(incomingCS.Customer_Number__c)) {
                commissions.add(incomingCS);
                mrIds.add(incomingCS.AgentMR_ID__c);
                custMCNs.add(incomingCS.Customer_Number__c);
            }
        }
        Map<String,String> mrIdAccountMap = new Map<String,String>();
        for(Partner_Identifier__c PI : [Select Id,Account__c, ID_Number__c from Partner_Identifier__c where ID_Number__c IN : mrIds]) {
            mrIdAccountMap.put(PI.ID_Number__c, PI.Account__c);
        }
        
        Map<String,Account> custMCNAccountMap = new Map<String,Account>();
        for(Account acct : [Select Id,Motorola_Customer_Number__c,Assigned_MR_Sales_Person__r.Name,Name from Account where Motorola_Customer_Number__c IN : custMCNs]) {
            custMCNAccountMap.put(acct.Motorola_Customer_Number__c, acct);
        }        
        
        for(Commission_Summary__c commissionWithMrId : commissions) {
            String sfPartnerId = mrIdAccountMap.get(commissionWithMrId.AgentMR_ID__c);
            system.debug('######sfPartnerId######## => ' + sfPartnerId);
            Account mcnAccount = custMCNAccountMap.get(commissionWithMrId.Customer_Number__c);
            if(String.isNotBlank(sfPartnerId)) {
                commissionWithMrId.Partner_Account__c = sfPartnerId;
            }
            if(mcnAccount != NULL) {
                commissionWithMrId.MCN_Account__c = mcnAccount.Id;
                commissionWithMrId.Assigned_Sales_Rep__c = mcnAccount.Assigned_MR_Sales_Person__r.Name;
            }
            commissionWithMrId.Order_Entry_Date__c = Date.valueOf(commissionWithMrId.Order_Entry_Date__c);
            system.debug('######commissionWithMrId######## => ' + commissionWithMrId);
        }
    }
    
    public void AfterInsert(Map<Id, SObject> newItems) {}
    public void AfterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems){}
    public void AfterDelete(Map<Id, SObject> oldItems){}
    public Boolean isDisabled(){
        return TriggerSettings__c.getValues('CommissionSummaryTriggerDisabled').IsActive__c;
    }
    public void AfterUndelete(Map<Id, SObject> oldItems){}
    public void BeforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems){}
    public void BeforeDelete(Map<Id, SObject> oldItems){}
}