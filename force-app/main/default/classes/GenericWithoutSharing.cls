public without sharing class GenericWithoutSharing  {
    Id registrationid = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Registration').getRecordTypeId();
    Id standardConRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('EMS_Standard_Contact').getRecordTypeId();
    
    public void convertLeadWithoutSharing(Map<Id,Lead> newLeadMap){
        List<Lead> convertedLeads = new List<Lead>();
        for(Lead partnerConvertingLead : newLeadMap.values()) {
            system.debug('#####partnerConvertingLead###### => ' + partnerConvertingLead);
            system.debug('#####Opportunity Create Access###### => ' + Schema.sObjectType.Opportunity.isCreateable());
            if((partnerConvertingLead.isConverted && partnerConvertingLead.ConvertedOpportunityId == NULL && !Schema.sObjectType.Opportunity.isCreateable()) || Test.isRunningTest()) {
                convertedLeads.add(partnerConvertingLead);
            }   
        }
        if(!convertedLeads.isEmpty()) {
            System.debug('Satish convertLeadWithoutSharing--> ');
            Set<Id> convertedContactIds = new Set<Id>();//Used to store convertedContact ids
            List<Opportunity> oppsToBeInserted = new List<Opportunity>();
            Set<String> currenciesSet = new Set<String>();
            Map<String, String> techSegmentMap = new Map<String, String>();
            for(Lead convertedLead : convertedLeads) {
                Opportunity newOppo = new Opportunity(
                    AccountId = convertedLead.ConvertedAccountId,Name = convertedLead.Company,Lead_Information__c=convertedLead.Id,
                    Territory__c = convertedLead.Territory__c,Region__c = convertedLead.Region__c,
                    State__c= convertedLead.state,RecordTypeId = registrationid,
                    Industry__c = convertedLead.Industry,Channel_Opportunity__c = 'Partner',
                    CloseDate = convertedLead.Close_Date__c,StageName = 'Prospect',
                    CurrencyIsoCode = convertedLead.CurrencyIsoCode,Amount = convertedLead.Lead_Value__c,
                    OwnerId = Userinfo.getUserId()
                );
                if(convertedLead.Region__c == 'EA'){
                    newOppo.Business_Group__c ='EMEA Government System Project';
                }
                
                if(String.isBlank(convertedLead.Partner_Account_NA__c)){
                 newOppo.Channel_Opportunity__c = 'Direct';   
                }else{
                    newOppo.Channel_Opportunity__c = 'Partner';
                }
                oppsToBeInserted.add(newOppo);
                currenciesSet.add(convertedLead.CurrencyIsoCode);
                techSegmentMap.put(convertedLead.ConvertedAccountId, convertedLead.Technology_Segment__c);
               // convertedContactIds.add(convertedLead.ConvertedContactId);
            }
            Database.insert(oppsToBeInserted, true);
            insertProductLineItems(currenciesSet, techSegmentMap, oppsToBeInserted);
            //Below line added by Satish
            //updateConvertedConRecTypeId(convertedContactIds);
        }
    }
    
    private void insertProductLineItems(Set<String> currenciesSet, Map<String, String> techSegmentMap, List<Opportunity> oppsToBeInserted) {
        system.debug('#####currenciesSet###### => ' + currenciesSet);
        system.debug('#####techSegmentMap###### => ' + techSegmentMap);
        Map<String,Id> priceBookEntryMap = new Map<String,Id>();
        for(PriceBookEntry priceBookEntryDB : [Select Id,Product2.Name,CurrencyIsoCode from PriceBookEntry where Product2.Name IN : techSegmentMap.values() and 
                                               Pricebook2.Name='Standard Price Book' and CurrencyIsoCode IN : currenciesSet and IsActive = true]) 
        {
            priceBookEntryMap.put(priceBookEntryDB.Product2.Name+priceBookEntryDB.CurrencyIsoCode, priceBookEntryDB.Id);
        }
        system.debug('#####priceBookEntryMap###### => ' + priceBookEntryMap);
        List<OpportunityLineItem> oppLineItemsToBeInserted = new List<OpportunityLineItem>();
        for(Opportunity convertedOpp : oppsToBeInserted) {
            String productName = techSegmentMap.get(convertedOpp.AccountId);
            String priceBEntryId = priceBookEntryMap.get(productName+convertedOpp.CurrencyIsoCode);
            if(priceBEntryId != NULL && convertedOpp.Amount != NULL) {
                oppLineItemsToBeInserted.add(new OpportunityLineItem(
                    UnitPrice = convertedOpp.Amount,Quantity = 1,
                    PricebookEntryId = priceBEntryId,
                    OpportunityId = convertedOpp.Id
                ));
            }
        }
        system.debug('#####oppLineItemsToBeInserted###### => ' + oppLineItemsToBeInserted);
        if(!oppLineItemsToBeInserted.isEmpty()){
            Database.insert(oppLineItemsToBeInserted, false);
        }        
    }
    
    public void insertPartners(List<Opportunity> insertedOpps){
        Set<Id> convertedLeadIds = new Set<Id>();
        List<Partners2__c> partnersToBeInserted = new List<Partners2__c>();
        
        for(Opportunity convertedOpp:insertedOpps){
            convertedLeadIds.add(convertedOpp.Lead_Information__c);
        }
        
        Map<Id,Lead> leadMap = new Map<Id,Lead>([SELECT Id,Channel_Partner__c,Distributor__c FROM Lead WHERE Id IN:convertedLeadIds]);
        
        for(Opportunity convertedOpp:insertedOpps){
            String channelPartner = '';
            String distributor = '';
            if(leadMap.containsKey(convertedOpp.Lead_Information__c)) {
                channelPartner = leadMap.get(convertedOpp.Lead_Information__c).Channel_Partner__c;
                distributor = leadMap.get(convertedOpp.Lead_Information__c).Distributor__c;
            }
            if(String.isNotBlank(channelPartner)){
                partnersToBeInserted.add(new Partners2__c(Opportunity__c = convertedOpp.Id, Account__c = channelPartner, Role__c='Primary Channel Partner'));
            }
            
            if(String.isNotBlank(distributor)){
                partnersToBeInserted.add(new Partners2__c(Opportunity__c = convertedOpp.Id, Account__c = distributor, Role__c='Primary Distributor'));
            }
        }
        
        if(!partnersToBeInserted.isEmpty()){
            database.insert(partnersToBeInserted,false);
        }
    }
    /*
    * Description : 1. Used to update contact record type from Partner from Standard
                    2. Share with Partner User who is converting the Lead    
    * @param : Set of Contact Ids
    * @return : void
    * @Author : Satish
    */
    public void updateConvertedConRecTypeId(Map<Id,Lead> newLeadMap) {
         Set<Id> convertedContacts = new Set<Id>();
         for(Lead partnerConvertingLead : newLeadMap.values()) {
             convertedContacts.add(partnerConvertingLead.ConvertedContactId);
         }   
        
        System.debug('Satish updateConvertedConRecTypeId--> ');
        List<Contact> newContacts = new List<Contact>();
        System.debug('Satish convertedContacts--> '+convertedContacts);
        if(!convertedContacts.isEmpty()) {
            for(Contact eachCon : [SELECT Id,RecordtypeId FROM Contact WHERE Id IN : convertedContacts]) {
                eachCon.RecordTypeId = standardConRecTypeId;
                newContacts.add(eachCon);
            }
            System.debug('Satish newContacts--> '+newContacts);
            try {
                if(!newContacts.isEmpty()) {
                    Database.update(newContacts,false);
                }
            } Catch(Exception exp) {
                System.debug('Exception occured in updateConvertedConRecTypeId()--> '+exp.getMessage());
            }
            //After converting Contact record type to Standard, Creating a ContactShare record for Partner User.
            if(!newContacts.isEmpty()) {
                createContactShare(newContacts);
            }
        }
    }
    
    /*
    * Description : Used to create contact share record.
    * @param : List of Contacts
    * @return : void
    * @Author : Satish
    */
    public void createContactShare(List<Contact> contactIds) {
        System.debug('Satish createContactShare method--> ');
        List<ContactShare> contactShareList = new List<ContactShare>();
        for(Contact eachCon : contactIds) {
            ContactShare eachConShare = new ContactShare();
            eachConShare.ContactId = eachCon.id;
            eachConShare.UserOrGroupId = UserInfo.getUserId();
            eachConShare.ContactAccessLevel = 'Read';
            contactShareList.add(eachConShare);
        }
        System.debug('Satish contactShareList--> '+contactShareList);
        try {
            if(!contactShareList.isEmpty()) {
                Database.insert(contactShareList,false);
            }
        } catch(Exception exp) {
            System.debug('Exception occured while creating contactShare record--> '+exp.getMessage());
        }
    }
    
    public static User getCurrentUser() {
        return [SELECT Contact.Account.OwnerId,Contact.Account.Partner_Region__c,Contact.AccountId FROM User WHERE Id =: UserInfo.getUserId()];
    }
}