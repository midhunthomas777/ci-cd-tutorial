Public class PartnerLocationTriggerHandler implements ITriggerHandler{
    public static Boolean TriggerDisabled = false;
    
    Public void BeforeInsert(List<SObject> newItems){
        for(Partner_Location__c incomingLocation:(List<Partner_Location__c>)newItems){
            String addressLineInfo = incomingLocation.Address_Line1__c;
            if(String.isNotBlank(addressLineInfo)){
                if(addressLineInfo.length() < 80){
                    incomingLocation.Name = addressLineInfo;
                }else{
                    incomingLocation.Name = addressLineInfo.substring(0,79);
                }
            }
            
            if(String.isNotBlank(incomingLocation.Country1__c)){
                if(LMS_Country_Name_And_Code__c.getInstance(incomingLocation.Country1__c) != null){
                    incomingLocation.Country_Code__c = LMS_Country_Name_And_Code__c.getInstance(incomingLocation.Country1__c).Country_Code__c;
                }
            }
            if(String.isNotBlank(incomingLocation.State__c)){
                if(LM_StateCode__c.getInstance(incomingLocation.State__c) != null){
                    incomingLocation.State_Code__c = LM_StateCode__c.getInstance(incomingLocation.State__c).State_Code__c;
                }else if(incomingLocation.State__c.length() == 2){
                    incomingLocation.State_Code__c = incomingLocation.State__c;
                }
            }
        }
    }
    
    Public void BeforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems){
        Map<Id, Partner_Location__c> newPartnerLocationMap = (Map<Id, Partner_Location__c>)newItems;
        for(Partner_Location__c incomingLocation:newPartnerLocationMap.values()){
            Partner_Location__c oldLocation = (Partner_Location__c) oldItems.get(incomingLocation.Id);
            incomingLocation.Name = incomingLocation.Address_Line1__c;
            
            if(String.isNotBlank(incomingLocation.Country1__c)){
                if(LMS_Country_Name_And_Code__c.getInstance(incomingLocation.Country1__c) != null){
                    incomingLocation.Country_Code__c = LMS_Country_Name_And_Code__c.getInstance(incomingLocation.Country1__c).Country_Code__c;
                }
            }
            if(String.isNotBlank(incomingLocation.State__c)){
                if(incomingLocation.State__c.length() == 2){
                    incomingLocation.State_Code__c = incomingLocation.State__c;
                }
            }
            
            
            if(String.isNotBlank(incomingLocation.State__c) && oldLocation.State__c != incomingLocation.State__c ){
                if(String.isNotBlank(incomingLocation.State__c)){
                    if(LM_StateCode__c.getInstance(incomingLocation.State__c) != null){
                        incomingLocation.State_Code__c = LM_StateCode__c.getInstance(incomingLocation.State__c).State_Code__c;
                    }
                }
            }
        }
    }
    
    Public void BeforeDelete(Map<Id, SObject> oldItems){}
    
    Public void AfterInsert(Map<Id, SObject> newItems){
        Set<Id> partnerAccountIds = new Set<Id>();
        Map<Id,Partner_Location__c> accPrimaryPartnerLocationMap = new Map<Id,Partner_Location__c>();
        Map<Id,Partner_Location__c> accHQPartnerLocationMap = new Map<Id,Partner_Location__c>();
        
        for(Partner_Location__c incomingLocation:(List<Partner_Location__c>)newItems.values()){
            if(String.isNotBlank(incomingLocation.Address_Type__c)){
                if(incomingLocation.Address_Type__c.contains('Primary Location')){
                    accPrimaryPartnerLocationMap.put(incomingLocation.Account__c,incomingLocation);
                }else if(incomingLocation.Address_Type__c.contains('HQ')){
                    accHQPartnerLocationMap.put(incomingLocation.Account__c,incomingLocation);
                }
                
                if(String.isNotBlank(incomingLocation.State_Code__c)){
                    if(incomingLocation.Address_Type__c.contains('HQ') && (incomingLocation.State_Code__c=='KS' || incomingLocation.State_Code__c=='KY' || 
                                                                           incomingLocation.State_Code__c=='MO' || incomingLocation.State_Code__c=='NH' ||
                                                                           incomingLocation.State_Code__c=='NJ' || incomingLocation.State_Code__c=='ND' ||
                                                                           incomingLocation.State_Code__c=='OH' || incomingLocation.State_Code__c=='WV' ||
                                                                           incomingLocation.State_Code__c=='WY')){
                                                                               partnerAccountIds.add(incomingLocation.Account__c);         
                                                                           }
                }
            }
        }
        
        if(!partnerAccountIds.isEmpty()){
            updateWaiverSubrogation(partnerAccountIds);
        }
        
        if(!accPrimaryPartnerLocationMap.isEmpty() || !accHQPartnerLocationMap.isEmpty()){
            updateBillingAddressOnPartnerAccount(accPrimaryPartnerLocationMap, accHQPartnerLocationMap);
        }
    }
    
    Public void AfterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems){
        Set<Id> partnerAccountIds = new Set<Id>();
        Map<Id,Partner_Location__c> updatedAddressTypeLocations =new Map<Id,Partner_Location__c>();
        Map<Id,Partner_Location__c> accPrimaryPartnerLocationMap = new Map<Id,Partner_Location__c>();
        Map<Id,Partner_Location__c> accHQPartnerLocationMap = new Map<Id,Partner_Location__c>();
        
        for(Partner_Location__c incomingLocation:(List<Partner_Location__c>)newItems.values()){
            Partner_Location__c oldLocation = (Partner_Location__c) oldItems.get(incomingLocation.Id);
            if((incomingLocation.Address_Type__c.contains('Primary Location') || incomingLocation.Address_Type__c.contains('HQ')) 
               && incomingLocation.LastModifiedDate != oldLocation.LastModifiedDate 
               && Userinfo.getUserType() == 'PowerPartner'){
                incomingLocation.addError(Label.Partner_Location_Validation);
                return;
            }
            if(String.isNotBlank(incomingLocation.Address_Type__c)){
                if(incomingLocation.Address_Type__c.contains('Primary Location')){
                    accPrimaryPartnerLocationMap.put(incomingLocation.Account__c,incomingLocation);
                }else if(incomingLocation.Address_Type__c.contains('HQ')){
                    accHQPartnerLocationMap.put(incomingLocation.Account__c,incomingLocation);
                }
            }
            
            if(incomingLocation.Address_Type__c != oldLocation.Address_Type__c || incomingLocation.State__c != oldLocation.State__c){
                if(String.isNotBlank(incomingLocation.Address_Type__c) && String.isNotBlank(incomingLocation.State__c)){
                    if(incomingLocation.Address_Type__c.contains('HQ') && (incomingLocation.State_Code__c=='KS' || incomingLocation.State_Code__c=='KY' || 
                                                                           incomingLocation.State_Code__c=='MO' || incomingLocation.State_Code__c=='NH' ||
                                                                           incomingLocation.State_Code__c=='NJ' || incomingLocation.State_Code__c=='ND' ||
                                                                           incomingLocation.State_Code__c=='OH' || incomingLocation.State_Code__c=='WV' ||
                                                                           incomingLocation.State_Code__c=='WY')){
                                                                               partnerAccountIds.add(incomingLocation.Account__c);         
                                                                           }
                }
                
                if(incomingLocation.Address_Type__c != oldLocation.Address_Type__c){
                    updatedAddressTypeLocations.put(incomingLocation.Id,incomingLocation);
                }
            }
        }
        
        if(!partnerAccountIds.isEmpty()){
            updateWaiverSubrogation(partnerAccountIds);
        }
        
        if(!accPrimaryPartnerLocationMap.isEmpty() || !accHQPartnerLocationMap.isEmpty()){
            updateBillingAddressOnPartnerAccount(accPrimaryPartnerLocationMap, accHQPartnerLocationMap);
        }
    }
    
    Public void AfterDelete(Map<Id, SObject> oldItems){}
    
    Public void AfterUndelete(Map<Id, SObject> oldItems){}
    
    Public Boolean IsDisabled(){
        if(TriggerSettings__c.getValues('PartnerLocationTriggerDisabled').IsActive__c){
            return true;
        } else{
            return TriggerDisabled;
        }
    }
    
    public void updateWaiverSubrogation(Set<Id> partnerAccountIds){
        List<Account> accuntsToBeUpdated = new List<Account>();
        
        for(Id partnerAccId:partnerAccountIds){
            Account acc =new Account();
            acc.Id = partnerAccId;
            acc.Waiver_Subrogation_Disallowed__c = 'N/A';
            
            accuntsToBeUpdated.add(acc);
        }
        
        if(!accuntsToBeUpdated.isEmpty()){
            update accuntsToBeUpdated;
        }
    }
    
    public void updateContactLocations(Map<Id,Partner_Location__c> updatedAddressTypeLocations){
        List<Contact_Location__c> toBeUpdated = new List<Contact_Location__c>();
        
        for(Contact_Location__c cl:[Select id,Partner_Location__c, Location_Type__c from Contact_Location__c where Partner_Location__c IN:updatedAddressTypeLocations.keySet()]){
            cl.Location_Type__c = updatedAddressTypeLocations.get(cl.Partner_Location__c).Address_Type__c;
            toBeUpdated.add(cl);
        }
        
        if(!toBeUpdated.isEmpty()){
            update toBeUpdated;
        }
    }
    
    public void updateBillingAddressOnPartnerAccount(Map<Id,Partner_Location__c> accPrimaryPartnerLocationMap,Map<Id,Partner_Location__c> accHQPartnerLocationMap){
        List<Account> toBeUpdated =new List<Account>();
        System.debug('accPrimaryPartnerLocationMap##'+accPrimaryPartnerLocationMap);
        System.debug('accHQPartnerLocationMap##'+accHQPartnerLocationMap);
        
        for(Id accId:accPrimaryPartnerLocationMap.keySet()){
            Partner_Location__c partnerLocation = new Partner_Location__c();
            partnerLocation = accPrimaryPartnerLocationMap.get(accId);
            System.debug('partnerLocation###'+partnerLocation.Country1__c);
            System.debug('partnerLocation###'+partnerLocation.State_Code__c);
            
            Account acc = new Account(Id=accId,
                                      BillingCity = partnerLocation.city__c,
                                      BillingCountryCode = partnerLocation.Country_Code__c,
                                      BillingStateCode = partnerLocation.State_Code__c,
                                      BillingStreet = partnerLocation.Address_Line1__c,
                                      BillingPostalCode = partnerLocation.Postal_code__c);
            
            if(String.isNotBlank(partnerLocation.State__c)){
            acc.BillingStreet = partnerLocation.Address_Line1__c+','+partnerLocation.State__c;                
            }
            acc.Partner_HQ_Country__c = partnerLocation.Country1__c;
            acc.Partner_Primary_State__c = partnerLocation.State__c;
            acc.Partner_Primary_Country_Code__c = partnerLocation.Country_Code__c;
            
            toBeUpdated.add(acc);
        }
        
        for(Id accId:accHQPartnerLocationMap.keySet()){
            if(!accPrimaryPartnerLocationMap.keySet().contains(accId)){
                Partner_Location__c partnerLocation = new Partner_Location__c();
                partnerLocation = accHQPartnerLocationMap.get(accId);
                System.debug('partnerLocation###'+partnerLocation.Country1__c);
                System.debug('partnerLocation###'+partnerLocation.State_Code__c);
                
                Account acc = new Account(Id=accId,
                                          BillingCity = partnerLocation.city__c,
                                          BillingCountryCode = partnerLocation.Country_Code__c,
                                          BillingStateCode = partnerLocation.State_Code__c,
                                          BillingStreet = partnerLocation.Address_Line1__c+','+partnerLocation.State__c,
                                          BillingPostalCode = partnerLocation.Postal_code__c);
                toBeUpdated.add(acc);
            }
        }
        
        if(!toBeUpdated.isEmpty()){
            database.update(toBeUpdated,true);
        }
    }
}