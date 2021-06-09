/*
* Name : PartnerIdentifierTriggerHandler
* Description: PartnerIdentifierTriggerHandler
* Author : Adilraza Shaikh
* Date : 11/1/2020
*/
public class PartnerIdentifierTriggerHandler implements ITriggerHandler{
    public static Boolean TriggerDisabled = false;
    
    public Boolean IsDisabled(){
        if (TriggerSettings__c.getValues('PartnerIdentifierTriggerDisabled').IsActive__c){
            return true;
        }
        else{
            return TriggerDisabled;
        }
    }
    public void BeforeInsert(List<SObject> newItems) {
        
    }
    public void BeforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
        
    }
    public void BeforeDelete(Map<Id, SObject> oldItems) {
        
    }
    public void AfterInsert(Map<Id, SObject> newItems) {
        Map<Id,Partner_Identifier__c> newPartnerIdentifierMap = new Map<Id,Partner_Identifier__c>();
        if(newItems != null) newPartnerIdentifierMap = (Map<Id,Partner_Identifier__c>) newItems;
        
        
        
        Map<String,list<Partner_Identifier__c>> accPartnerMap = new Map<String,list<Partner_Identifier__c>>();
        List<Account> newPartnerIdAccUpdate = new List<Account>();
        List<Account> newPartnerIdAcc = new List<Account>();
        set<id> partnerIdnew = new set<id>();
        list<Partner_Identifier__c> partnerIdListnew = new list<Partner_Identifier__c>();
        list<Partner_Identifier__c> partnerIdList = new list<Partner_Identifier__c>();
        set<id> partnerIdOld = new set<id>();
        list<Partner_Identifier__c> partnerIdListOld = new list<Partner_Identifier__c>();
        
        for(Partner_Identifier__c pi : newPartnerIdentifierMap.values()){
            if(pi.ID_Type__c == 'Motorola Enterprise Number' || pi.ID_Type__c == 'Motorola Customer Number'){
                partnerIdnew.add(pi.account__c);
                partnerIdListnew.add(pi);
            }    
        }
        for(Account acc : [Select Id, Motorola_Enterprise_ID__c,Motorola_Customer_Number__c FROM Account WHERE Id IN: partnerIdnew]){  
            for(Partner_Identifier__c piObj : partnerIdListnew){     
                if(acc.id == piObj.account__c && piObj.ID_Type__c == 'Motorola Enterprise Number'){
                    if(acc.Motorola_Enterprise_ID__c == '' || acc.Motorola_Enterprise_ID__c == null)
                        acc.Motorola_Enterprise_ID__c = piObj.ID_Number__c;
                    else
                        acc.Motorola_Enterprise_ID__c = acc.Motorola_Enterprise_ID__c +';'+piObj.ID_Number__c;
                }        
                
            }
            newPartnerIdAccUpdate.add(acc);          
        }
        
        if(!newPartnerIdAccUpdate.isEmpty()){
              Database.update(newPartnerIdAccUpdate,false) ;
        }
    }
    public void AfterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
        
        
        Map<Id,Partner_Identifier__c> oldPartnerIdentifierMap = new Map<Id,Partner_Identifier__c>();
        if(oldItems != null) oldPartnerIdentifierMap = (Map<Id,Partner_Identifier__c>) oldItems;
        
        Map<Id,Partner_Identifier__c> newPartnerIdentifierMap = new Map<Id,Partner_Identifier__c>();
        if(newItems != null) newPartnerIdentifierMap = (Map<Id,Partner_Identifier__c>) newItems;
        
        
        Map<String,list<Partner_Identifier__c>> accPartnerMap = new Map<String,list<Partner_Identifier__c>>();
        List<Account> newPartnerIdAccUpdate = new List<Account>();
        List<Account> newPartnerIdAcc = new List<Account>();
        set<id> partnerIdnew = new set<id>();
        list<Partner_Identifier__c> partnerIdListnew = new list<Partner_Identifier__c>();
        list<Partner_Identifier__c> partnerIdList = new list<Partner_Identifier__c>();
        set<id> partnerIdOld = new set<id>();
        list<Partner_Identifier__c> partnerIdListOld = new list<Partner_Identifier__c>();
        
        
        
        for(Partner_Identifier__c pi : newPartnerIdentifierMap.values() ){
            if(pi.ID_Type__c == 'Motorola Enterprise Number' || pi.ID_Type__c == 'Motorola Customer Number'){
                partnerIdnew.add(pi.account__c);
            }
        }
        for(Partner_Identifier__c pi : oldPartnerIdentifierMap.values()){
            if(pi.ID_Type__c == 'Motorola Enterprise Number' || pi.ID_Type__c == 'Motorola Customer Number'){
                partnerIdnew.add(pi.account__c);
            }
        } 
        for(Partner_Identifier__c p : [Select id, Account__c, ID_Type__c, ID_Number__c from Partner_Identifier__c where account__c IN:partnerIdnew]){
            partnerIdList.add(p);
        }
        for(Account acc : [Select id, Motorola_Enterprise_ID__c,Motorola_Customer_Number__c from account where id IN:partnerIdnew]){  
            String tempEnt = '';
            String temp = '';
            for(Partner_Identifier__c piObj : partnerIdList){ 
                
                if(acc.id == piObj.account__c && piObj.ID_Type__c == 'Motorola Enterprise Number'){
                    if(tempEnt == '' ||tempEnt == null)
                        tempEnt = piObj.ID_Number__c;
                    else
                        tempEnt = tempEnt +';'+piObj.ID_Number__c;
                }        
                else if(acc.id == piObj.account__c && piObj.ID_Type__c == 'Motorola Customer Number'){
                    if(temp == '' || temp == null)
                        temp = piObj.ID_Number__c;
                    else
                        temp = temp +';'+piObj.ID_Number__c;
                } 
                //   acc.Motorola_Customer_Number__c = temp;
                acc.Motorola_Enterprise_ID__c = tempEnt;
            }
            newPartnerIdAccUpdate.add(acc);   
        }
        if(!newPartnerIdAccUpdate.isEmpty()){
              Database.update(newPartnerIdAccUpdate,false) ;
        }
    }
    public void AfterDelete(Map<Id, SObject> oldItems) {
        
        Map<Id,Partner_Identifier__c> oldPartnerIdentifierMap = new Map<Id,Partner_Identifier__c>();
        if(oldItems != null) oldPartnerIdentifierMap = (Map<Id,Partner_Identifier__c>) oldItems;
        
        
        
        Map<String,list<Partner_Identifier__c>> accPartnerMap = new Map<String,list<Partner_Identifier__c>>();
        List<Account> newPartnerIdAccUpdate = new List<Account>();
        List<Account> newPartnerIdAcc = new List<Account>();
        set<id> partnerIdnew = new set<id>();
        list<Partner_Identifier__c> partnerIdListnew = new list<Partner_Identifier__c>();
        list<Partner_Identifier__c> partnerIdList = new list<Partner_Identifier__c>();
        set<id> partnerIdOld = new set<id>();
        list<Partner_Identifier__c> partnerIdListOld = new list<Partner_Identifier__c>();
        
        for(Partner_Identifier__c pi : oldPartnerIdentifierMap.values()){
            if(pi.ID_Type__c == 'Motorola Enterprise Number' || pi.ID_Type__c == 'Motorola Customer Number'){
                partnerIdnew.add(pi.account__c);
            }
        }
        for(Partner_Identifier__c p : [Select id, Account__c, ID_Type__c, ID_Number__c from Partner_Identifier__c where account__c IN:partnerIdnew]){
            partnerIdList.add(p);
        }
        for(Account acc : [Select id, Motorola_Enterprise_ID__c,Motorola_Customer_Number__c from account where id IN:partnerIdnew]){  
            String tempEnt = '';
            String temp = '';
            for(Partner_Identifier__c piObj : partnerIdList){ 
                
                if(acc.id == piObj.account__c && piObj.ID_Type__c == 'Motorola Enterprise Number'){
                    if(tempEnt == '' ||tempEnt == null)
                        tempEnt = piObj.ID_Number__c;
                    else
                        tempEnt = tempEnt +';'+piObj.ID_Number__c;
                }        
                else if(acc.id == piObj.account__c && piObj.ID_Type__c == 'Motorola Customer Number'){
                    if(temp == '' || temp == null)
                        temp = piObj.ID_Number__c;
                    else
                        temp = temp +';'+piObj.ID_Number__c;
                } 
                // acc.Motorola_Customer_Number__c = temp;
                acc.Motorola_Enterprise_ID__c = tempEnt;
            }
            newPartnerIdAccUpdate.add(acc);
        }   
        if(!newPartnerIdAccUpdate.isEmpty()){
              Database.update(newPartnerIdAccUpdate,false) ;
        }
    }
    public void AfterUndelete(Map<Id, SObject> oldItems) {}
}