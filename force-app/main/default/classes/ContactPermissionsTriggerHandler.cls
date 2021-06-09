/*  
* Class Name  : ContactPermissionsTriggerHandler
* Description:  This class is used in Contact Permissions with MCNs
*/

public class ContactPermissionsTriggerHandler implements ITriggerHandler{
    public static Boolean TriggerDisabled = false;
    
    public Boolean IsDisabled(){
        if (TriggerSettings__c.getValues('ContactPermissionsTriggerDisabled').IsActive__c) {
            return true;
        } else {
            return TriggerDisabled;
        }
    }
    
    public void BeforeInsert(List<SObject> newItems){}
    public void BeforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems){}
    public void BeforeDelete(Map<Id, SObject> oldItems){}

    public void AfterInsert(Map<Id, SObject> newItems){
        Set<Id> contactIds = new Set<Id>();
        for(Id permissionId: newItems.keySet()){
            contactIds.add(((Contact_Permissions__c) newItems.get(permissionId)).Contact__c);
        }
    }

    public void AfterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems){
        Set<Id> contactIds = new Set<Id>();
        for(Id permissionId: newItems.keySet()){
            if(String.isNotBlank(((Contact_Permissions__c) newItems.get(permissionId)).Contact_MCN_Permissions__c)){
                contactIds.add(((Contact_Permissions__c) newItems.get(permissionId)).Contact__c);
            }
        }
    }
    public void AfterDelete(Map<Id, SObject> oldItems){}
    public void AfterUndelete(Map<Id, SObject> oldItems){}
}