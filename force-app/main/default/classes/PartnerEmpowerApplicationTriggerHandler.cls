public class PartnerEmpowerApplicationTriggerHandler implements ITriggerHandler{
    PartnerEmpowerApplicationHelper partnerEmpowerHelper = new PartnerEmpowerApplicationHelper();
    
    public void BeforeInsert(List<SObject> newItems) {
        List<Empower_Application__c> newPartnerEmpowerApplnList = new List<Empower_Application__c>();
        if(newItems != null) newPartnerEmpowerApplnList = (List<Empower_Application__c>) newItems;
        
        for(Empower_Application__c empowerAppln : newPartnerEmpowerApplnList){
            empowerAppln.Access_Code__c = new Uuid().getValue();
        }
        partnerEmpowerHelper.populateSignatoryEmail(newPartnerEmpowerApplnList);
    }
    
    public void BeforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
        Map<Id,Empower_Application__c> oldAppMap = new Map<Id,Empower_Application__c>();
        if(oldItems != null) oldAppMap = (Map<Id,Empower_Application__c>) oldItems;
        Map<Id,Empower_Application__c> mapEmpApplications = new Map<Id,Empower_Application__c>();
        if(!newItems.isEmpty())mapEmpApplications = (Map<Id,Empower_Application__c>) newItems;
        
        List<User> partnerUsr = [SELECT Id FROM User WHERE Id =: UserInfo.getUserId() and UserType = 'Guest'];
        for(Empower_Application__c appln : mapEmpApplications.values()){
            Empower_Application__c oldAppln  = oldAppMap.get(appln.Id);
            if(!partnerUsr.isEmpty() && oldAppln.Partner_Application_Status__c != NULL){
                appln.addError(System.Label.Resubmit_Approval);
            }
        }
        partnerEmpowerHelper.populateApprovedData(mapEmpApplications.values());
        partnerEmpowerHelper.populateSignatoryEmail(mapEmpApplications.values());        
        partnerEmpowerHelper.validateRejectedReason(mapEmpApplications.values(),oldAppMap);
    }
    
    public void afterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {}
    
    public static Boolean TriggerDisabled = false;
    public Boolean IsDisabled(){
        TriggerSettings__c ts = TriggerSettings__c.getValues('PartnerEmpowerAppTriggerDisabled');
        if (ts != null && ts.IsActive__c)
            return true;
        else
            return TriggerDisabled;
    }
    
    public void BeforeDelete(Map<Id, SObject> oldItems) {}
    public void afterInsert(Map<Id, SObject> newItems) {
       /* Map<Id,Empower_Application__c> newEmpAppMap = new Map<Id,Empower_Application__c>();
       if(newItems != null) newEmpAppMap = (Map<Id,Empower_Application__c>) newItems;
       List<Empower_Application__Share> lstEmpApplnShare = new List<Empower_Application__Share>();
       for( Empower_Application__c emp : newEmpAppMap.values()){
           lstEmpApplnShare.add(new Empower_Application__Share(
               ParentId = emp.Id,
               AccessLevel = 'Edit',
               UserOrGroupId = emp.CreatedById));
       }
       if(!lstEmpApplnShare.isEmpty()){
           insert lstEmpApplnShare;
       }*/
    }
    public void afterDelete(Map<Id, SObject> oldItems) {}
    public void afterUndelete(Map<Id, SObject> oldItems){}
}