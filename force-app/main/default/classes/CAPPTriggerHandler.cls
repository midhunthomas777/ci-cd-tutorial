public class CAPPTriggerHandler implements ITriggerHandler{
    
    public static Boolean TriggerDisabled = false;
    public Boolean isDisabled(){
        if (TriggerSettings__c.getValues('CAPPTriggerHandlerDisabled').IsActive__c){
            return true;
        } else{
            return TriggerDisabled;
        }
    }
    
    public void BeforeInsert(List<SObject> newItems) {
        Map<Id,String> cappRecordTypeMap = new Map<Id,String>();
        List<Customer_Portfolio_Presence__c> cappsList = new List<Customer_Portfolio_Presence__c>();
        if(newItems != null) cappsList = (List<Customer_Portfolio_Presence__c>) newItems;
        
        for(RecordType cappRecordType : [SELECT Id,Name FROM RecordType WHERE SobjectType = 'Customer_Portfolio_Presence__c']){
            cappRecordTypeMap.put(cappRecordType.Id, cappRecordType.Name);
        }
        for(Customer_Portfolio_Presence__c eachCapp : cappsList){
            String RecordTypeName = cappRecordTypeMap.get(eachCapp.RecordTypeId);
            if(String.isNotBlank(RecordTypeName)){
                eachCapp.CAPP_Record_Type__c = RecordTypeName;
            }
        }
    }
    
    public void BeforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
        Map<Id,String> cappRecordTypeMap = new Map<Id,String>();
        Map<Id,Customer_Portfolio_Presence__c> newCAPPMap = new Map<Id,Customer_Portfolio_Presence__c>();
        if(newItems != null) newCAPPMap = (Map<Id,Customer_Portfolio_Presence__c>) newItems;
        
        for(RecordType cappRecordType : [SELECT Id,Name FROM RecordType WHERE SobjectType = 'Customer_Portfolio_Presence__c']){
            cappRecordTypeMap.put(cappRecordType.Id, cappRecordType.Name);
        }
        for(Customer_Portfolio_Presence__c eachCapp : newCAPPMap.values()){
            String RecordTypeName = cappRecordTypeMap.get(eachCapp.RecordTypeId);
            if(String.isNotBlank(RecordTypeName)){
                eachCapp.CAPP_Record_Type__c = RecordTypeName;
            }
        }
    }
    
    public void BeforeDelete(Map<Id, SObject> oldItems) {
        Set<String> cappsToNotBeDeleted = new Set<String>();
        Map<Id,Customer_Portfolio_Presence__c> oldCAPPMap = new Map<Id,Customer_Portfolio_Presence__c>();
        if(oldItems != null) oldCAPPMap = (Map<Id,Customer_Portfolio_Presence__c>) oldItems;
        
        for(AggregateResult ar : [SELECT CAPP__c, count(Id) numberofSR FROM System_Relationship__c Group BY CAPP__c Having 
                                  CAPP__c IN : oldCAPPMap.keySet() AND count(Id) > 1])
        {
            cappsToNotBeDeleted.add(String.valueOf(ar.get('CAPP__c')));
        }
        for(Customer_Portfolio_Presence__c eachCapp : oldCAPPMap.values()){
            if(cappsToNotBeDeleted.contains(eachCapp.Id)){
                eachCapp.addError(System.Label.CAPP_Error);
            }
        }
    }
    
    public void afterInsert(Map<Id, SObject> newItems) {
        Map<Id,Customer_Portfolio_Presence__c> newCAPPMap = new Map<Id,Customer_Portfolio_Presence__c>();
        if(newItems != null){
            newCAPPMap = (Map<Id,Customer_Portfolio_Presence__c>) newItems;  
        } 
        List<Account> accountsToBeUpdated = new List<Account>();
        Set<String> setTempAccIds = new Set<String>(); //SF-2542
        Set<String> setTempMCNs = new Set<String>(); //SF-2542
        Map<Id, Account> mapAccountTemp; //SF-2542
        Map<String, Account> mapMCNAccountTemp = new Map<String, Account>(); //SF-2542
        List<System_Relationship__c> listSystemsToInsert = new List<System_Relationship__c>(); //SF-2542
        system.debug('newCAPPMap>>'+newCAPPMap);
        for(Customer_Portfolio_Presence__c CAPP : newCAPPMap.values()) {
            accountsToBeUpdated.add(new Account(
                Id = CAPP.Customer_Account_18_Digit__c,
                Customer_Portfolio_Presence__c = CAPP.Id
            ));
            //SF-2542 Srikanth 
            if (string.isNotBlank(CAPP.Temporary_MCN__c)){
                setTempMCNs.add(CAPP.Temporary_MCN__c);
            }                        
        }
        //SF-2542 start
        system.debug('setTempMCNs>>'+setTempMCNs);
        if(!setTempMCNs.isEmpty()){            
            for(Account objAccount : [SELECT Id, Name, RecordType.Name, Motorola_Customer_Number__c, Customer_or_Prospect_Account__c
            						 FROM Account WHERE Motorola_Customer_Number__c IN :setTempMCNs 
            						 AND RecordType.DeveloperName = 'Motorola_Customer_Number']){
                if(! mapMCNAccountTemp.containsKey(objAccount.Motorola_Customer_Number__c)) {
                    mapMCNAccountTemp.put(objAccount.Motorola_Customer_Number__c, objAccount);
                }
            }            
        }
        system.debug('mapMCNAccountTemp>>'+mapMCNAccountTemp);
        for(Customer_Portfolio_Presence__c CAPP : newCAPPMap.values()){
            if(! string.isBlank(CAPP.Temporary_Account_ID_18__c)){
                System_Relationship__c objSystem = new System_Relationship__c();
                objSystem.Account__c = CAPP.Temporary_Account_ID_18__c;
                objSystem.CAPP__c = CAPP.Id;
                listSystemsToInsert.add(objSystem);
            }  
            if(string.isBlank(CAPP.Temporary_Account_ID_18__c) && ! string.isBlank(CAPP.Temporary_MCN__c) && 
            mapMCNAccountTemp.containsKey(CAPP.Temporary_MCN__c)){
                System_Relationship__c objSystem = new System_Relationship__c();
                objSystem.Account__c = mapMCNAccountTemp.get(CAPP.Temporary_MCN__c).Customer_or_Prospect_Account__c;
                objSystem.CAPP__c = CAPP.Id;
                listSystemsToInsert.add(objSystem);
            }
        }
        system.debug('listSystemsToInsert>>'+listSystemsToInsert);
        if(!listSystemsToInsert.isEmpty()) {
            Database.insert(listSystemsToInsert, true);   
        }
        //SF-2542 end
        if(!accountsToBeUpdated.isEmpty()) {
            Database.update(accountsToBeUpdated, false);   
        }
    }
    
    public void afterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {}
    
    public void afterDelete(Map<Id, SObject> oldItems) {}
    public void afterUndelete(Map<Id, SObject> oldItems){}
}