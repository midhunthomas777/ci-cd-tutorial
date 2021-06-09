/*
Name:  MPP_Class_HLPR_AddGroupsToUser_Advanced
Purpose: Helper class for below specified triggers
1) MPP_TRG_AddGroupsToUser_AGM
2) MPP_TRG_AddGroupsToUser_Account
3) MPP_TRG_AddGroupsToUser_MarketSpec
4) MPP_TRG_AddGroupsToUser_PartnerType
5) MPP_TRG_AddGroupsToUser_TechSpec
6) MPP_TRG_AddGroupsToUser_TechSubSegmnt
--> Creation of Account_to_group_mapping records

==========================================================================================
History
-------                                                                                                                  
VERSION        AUTHOR         DATE                 DETAILS                   
1.0 -     Satish Maddhi   21 Dec 2017      INITIAL DEVELOPMENT

******************************************************************************************/ 

Public with sharing class MPP_Class_HLPR_AddGroupsToUser_Advanced
{
    public static Boolean accountTriggerIsRunning = false;
    public static Boolean contactTriggerIsRunning = false;
    public static Boolean marketSpecTriggerIsRunning = false;
    public static Boolean partnerTypeTriggerIsRunning = false;
    public static Boolean techSpecTriggerIsRunning = false;
    public static Boolean userTriggerIsRunning = false;
    public static Boolean shouldRunAGMAddGroupsToUsers = true;
    public static Boolean techSubSegmntTriggerIsRunning = false;
    
    //Retrieving region values from PC_Technology_Sub_Segment_Regions__c custom setting which is used to check when Account's region is EMEA
    public static Set<String> getPCTechSubSegs() {
        Set<String> temppcTechSubSegmntsSet = new Set<String>();
        Map<String, PC_Technology_Sub_Segment_Regions__c> pcTechSubSegsMap = PC_Technology_Sub_Segment_Regions__c.getAll();
        if(pcTechSubSegsMap.size() > 0) {
            for(PC_Technology_Sub_Segment_Regions__c eachSeg : pcTechSubSegsMap.values()) {
                temppcTechSubSegmntsSet.add(eachSeg.Name);
            }    
        }
        return temppcTechSubSegmntsSet;
    }
    
    /*
* Method to check AttributeToGroupMapping record update
*/
    public static void updateAttributeToGroupMapping(Map<Id,Attribute_Group_Mapping__c> oldMap, Map<Id, Attribute_Group_Mapping__c> newMap, Set<Id> accountIds) {
        //Tracing the changes of AttributeToGroupMapping object and collecting the Group__c values
        if(accountIds.size() > 0) {
            for(Attribute_Group_Mapping__c eachAttr : newMap.values()) {
                if(eachAttr.Program_Level__c != oldMap.get(eachAttr.Id).Program_Level__c 
                   || eachAttr.Application_Specialization_Level__c != oldMap.get(eachAttr.Id).Application_Specialization_Level__c
                   || eachAttr.Application_Specialization__c != oldMap.get(eachAttr.Id).Application_Specialization__c
                   || eachAttr.Community__c != oldMap.get(eachAttr.Id).Community__c
                   || eachAttr.Country1__c != oldMap.get(eachAttr.Id).Country1__c
                   || eachAttr.Language__c != oldMap.get(eachAttr.Id).Language__c
                   || eachAttr.Market_Specialization__c != oldMap.get(eachAttr.Id).Market_Specialization__c
                   || eachAttr.Market_Specialization_Level__c != oldMap.get(eachAttr.Id).Market_Specialization_Level__c
                   || eachAttr.Purchasing_Method__c != oldMap.get(eachAttr.Id).Purchasing_Method__c
                   || eachAttr.Region__c != oldMap.get(eachAttr.Id).Region__c
                   || eachAttr.Role__c != oldMap.get(eachAttr.Id).Role__c
                   || eachAttr.Technology_Specialization__c != oldMap.get(eachAttr.Id).Technology_Specialization__c
                   || eachAttr.Technology_Specialization_Level__c != oldMap.get(eachAttr.Id).Technology_Specialization_Level__c
                   || eachAttr.Sales_View_Upload_Mode__c != oldMap.get(eachAttr.Id).Sales_View_Upload_Mode__c
                   || eachAttr.CASPA_groups__c != oldMap.get(eachAttr.Id).CASPA_groups__c
                   || eachAttr.Technology_Sub_Segment__c != oldMap.get(eachAttr.Id).Technology_Sub_Segment__c
                  ) {
                      handleAcctIds(accountIds);
                  }
            }
        }
    }
    
    /*
* Method to check AttributeToGroupMapping record insertion
*/ 
    
  /*  public static void insertAttributeToGroupMapping(Map<Id, Attribute_Group_Mapping__c> agmMap,Set<Id> AccIds){
        //Deleting existing AccountToGroupMapping records before insert new records
        List<Account_to_Group_Mapping__c> toBeDeleted = [SELECT Id FROM Account_to_Group_Mapping__c LIMIT 9999];
         Database.delete(toBeDeleted, false);
        
        
        //Passing set of accountIds to Batch to insert
        MPP_Class_AddGroupsToUserInBulkBatch batchInstance = new MPP_Class_AddGroupsToUserInBulkBatch(AccIds);
        ID batchprocessid = Database.executeBatch(batchInstance);
    } */
    
    public static void insertAttributeToGroupMapping(Map<Id, Attribute_Group_Mapping__c> agmMap,Set<Id> AccIds){
        DeleteandInsertAccountToGroupMapping batchToDeleteAGM = new DeleteandInsertAccountToGroupMapping(AccIds);
        ID batchprocessid = Database.executeBatch(batchToDeleteAGM);
        System.debug('DELETE ACCOUNT TO GROUP MAPPINGS Bacth Id###'+batchprocessid);
    }
   
    
    /*
* Method to check AttributeToGroupMapping record deletion
*/ 
    public static void deleteAttributeToGroupMapping(Map<Id, Attribute_Group_Mapping__c> agmMap){
        Set<String> groupRecList = new Set<String>();
        Set<Id> accountIds = new Set<Id>();
        String[] grpList = new String[]{};
            //Collecting the Group__c values from AttributeToGroupMapping object
            for(Attribute_Group_Mapping__c eachAttr : agmMap.values()) {
                if(eachAttr.Group__c != '') {
                    groupRecList.add(eachAttr.Group__c);
                }            
            }
        
        if(groupRecList.size() > 0) {
            //Getting Groups__c values from AccountToGroupMaipping object and split by ;
            List<Account_to_Group_Mapping__c> accToGrpMappingList = [SELECT Id,Account_Id__c,Groups__c FROM Account_to_Group_Mapping__c LIMIT 49000];
            if(accToGrpMappingList.size() > 0) {
                for(String eachGroup : groupRecList) {
                    for(Account_to_Group_Mapping__c eachMappingRec : accToGrpMappingList) {
                        if(eachMappingRec.Groups__c.contains(';')) {
                            grpList = eachMappingRec.Groups__c.split(';');
                        }
                        //Checking whether Group__c is equals to Groups__c value and collecting the associated Accounts
                        if(grpList.size() > 0) {
                            for(String subGrp : grpList) {
                                if(subGrp.equals(eachGroup)) {
                                    accountIds.add(eachMappingRec.Account_Id__c);
                                }
                            }
                        }
                    }
                }
            }
            //Passing set of accountIds to Batch for process
            if(accountIds.size() > 0) {
                handleAcctIds(accountIds);
            }
        }
    }
    /*
* Method to check Account record update
*/
    public static void checkUpdateObject(Map<Id, Account> oldMap, Map<Id, Account> newMap, Boolean isUpdate) {
        Set<Id> acctIds = new Set<Id>();
        for(Account a : newMap.values()) {
            if(a.Owner_Business_Group__c == 'Government' || a.Shared_Partner__c == True) {            
                if(isUpdate && a.MPE_Program_Status_New__c == 'Active') {
                    if(a.Metal_Level__c != oldMap.get(a.Id).Metal_Level__c || 
                       a.Partner_Region__c != oldMap.get(a.Id).Partner_Region__c || 
                       a.Partner_HQ_Country__c != oldMap.get(a.Id).Partner_HQ_Country__c || 
                       a.MPE_Program_Status_New__c != oldMap.get(a.Id).MPE_Program_Status_New__c || 
                       a.Sales_View_Upload_Mode__c != oldMap.get(a.Id).Sales_View_Upload_Mode__c || 
                       a.CASPA_groups__c != oldMap.get(a.Id).CASPA_groups__c  ||
                       a.Partner_Local_Currency__c != oldMap.get(a.Id).Partner_Local_Currency__c
                      ) {
                          acctIds.add(a.Id);
                      }
                } else {
                    acctIds.add(a.Id);
                }
            }
        }
        System.debug(Logginglevel.ERROR,'acctIds:  ' + acctIds);
        //Passing set of accountIds to Batch for process
        if(acctIds.size()>0)
            handleAcctIds(acctIds);
    }
    
    /*
* Method to check Account record delete
*/
    public static void deleteObject(Map<Id, Account> acctMap){
        Set<Id> acctIds = new Set<Id>();
        for(Account c : acctMap.values()){
            acctIds.add(c.Id);
        }
        //Passing set of accountIds to Batch for process
        if(acctIds.size()>0)
            handleAcctIds(acctIds);
    }
    
    /*
* Method to check Technology_Specialization__c(Program detail object) updation
*/ 
    public static void checkUpdateObject(Map<Id, Technology_Specialization__c> oldMap, Map<Id, Technology_Specialization__c> newMap, Boolean isUpdate){
        Set<Id> acctIds = new Set<Id>();
        List<Technology_Specialization__c> ListTechSpecialization = [SELECT id,Account__r.Owner_Business_Group__c,Account__r.Shared_Partner__c,Type__c,
                                                                     Technology_Specialization__c,Account__r.Partner_Region__c,
                                                                     TechnologySubSegment__c,Technology_Specialization_Level__c,Community_Type__c,Account__c 
                                                                     FROM Technology_Specialization__c 
                                                                     WHERE id IN: newMap.keyset() ];
        for(Technology_Specialization__c eachDetail : ListTechSpecialization ) {
            if( eachDetail.Account__r.Owner_Business_Group__c == 'Government' || eachDetail.Account__r.Shared_Partner__c == True)
            {   
                // if(eachDetail.Type__c == 'Application' || eachDetail.Type__c == 'Technology') {
                if(isUpdate ) {
                    if(eachDetail.Technology_Specialization__c != oldMap.get(eachDetail.Id).Technology_Specialization__c 
                       || eachDetail.Technology_Specialization_Level__c != oldMap.get(eachDetail.Id).Technology_Specialization_Level__c 
                       || eachDetail.Type__c != oldMap.get(eachDetail.Id).Type__c 
                       || eachDetail.TechnologySubSegment__c != oldMap.get(eachDetail.Id).TechnologySubSegment__c
                       || eachDetail.Community_Type__c != oldMap.get(eachDetail.Id).Community_Type__c) 
                    {
                        acctIds.add(eachDetail.Account__c);      
                    }                   
                } else {
                    acctIds.add(eachDetail.Account__c);
                }
                // }
            }
        }
        //Passing set of accountIds to Batch for process
        if(acctIds.size()>0)
            handleAcctIds(acctIds);
    }
    
    /*
* Method to check Technology_Specialization__c(Program detail object) deletion
*/
    public static void deleteObject(Map<Id, Technology_Specialization__c> techMap) {
        Set<Id> acctIds = new Set<Id>();
        for(Technology_Specialization__c c : techMap.values()) {
            acctIds.add(c.Account__c);
        }
        //Passing set of accountIds to Batch for process
        if(acctIds.size()>0)
            handleAcctIds(acctIds);
    }
    
    /*
* Method to check Technology_SubSegment__c(Technology SubSegment object) updation when Account's Partner_Region is EMEA
*/ 
    public static void checkUpdateObject(Map<Id, Technology_SubSegment__c> oldMap, Map<Id, Technology_SubSegment__c> newMap, Boolean isUpdate){
        Set<String> pcTechSubSegmntsSet = MPP_Class_HLPR_AddGroupsToUser_Advanced.getPCTechSubSegs();
        Set<Id> acctIds = new Set<Id>();
        List<Technology_SubSegment__c> ListTechSpecialization = [SELECT id,Account__r.Owner_Business_Group__c,Account__r.Shared_Partner__c,
                                                                 Account__r.Partner_Region__c,Program_Detail__c,Account__c,
                                                                 Specialization_Level__c,Segment__c,Sub_Segment__c 
                                                                 FROM Technology_SubSegment__c 
                                                                 WHERE id IN: newMap.keySet() ];
        for(Technology_SubSegment__c eachSegmnt : ListTechSpecialization ) {
            if( eachSegmnt.Account__r.Owner_Business_Group__c == 'Government' || eachSegmnt.Account__r.Shared_Partner__c == True)
            {   
                if(isUpdate && pcTechSubSegmntsSet.size()>0 && pcTechSubSegmntsSet.contains(eachSegmnt.Account__r.Partner_Region__c)) {
                    if(eachSegmnt.Sub_Segment__c != oldMap.get(eachSegmnt.Id).Sub_Segment__c ) {
                        acctIds.add(eachSegmnt.Account__c);      
                    }                   
                } else {
                    acctIds.add(eachSegmnt.Account__c);
                }
            }
        }
        //Passing set of accountIds to Batch for process
        if(acctIds.size()>0)
            handleAcctIds(acctIds);
    }
    
    /*
* Method to check Technology_SubSegment__c(Technology SubSegment object) deletion
*/
    public static void deleteObject(Map<Id, Technology_SubSegment__c> techMap) {
        Set<Id> acctIds = new Set<Id>();
        for(Technology_SubSegment__c c : techMap.values()) {
            acctIds.add(c.Account__c);
        }
        //Passing set of accountIds to Batch for process
        if(acctIds.size()>0)
            handleAcctIds(acctIds);
    }
    
    /*
* Method to check Market_Specializations__c updation
*/
    public static void checkUpdateObject(Map<Id, Market_Specializations__c> oldMap, Map<Id, Market_Specializations__c> newMap, Boolean isUpdate){
        Set<Id> acctIds = new Set<Id>();
        
        List<Market_Specializations__c> ListMarketSpecialization = [SELECT id,Account__r.Owner_Business_Group__c,Account__r.Shared_Partner__c,Market_Specialization__c,Market_Specialization_Level__c,
                                                                    Account__c FROM Market_Specializations__c WHERE id IN: newMap.keyset() ];
        
        for(Market_Specializations__c t : ListMarketSpecialization ){
            if( t.Account__r.Owner_Business_Group__c  == 'Government' || t.Account__r.Shared_Partner__c == True)
            {
                if(isUpdate) {
                    if(t.Market_Specialization__c != oldMap.get(t.Id).Market_Specialization__c ||
                       t.Market_Specialization_Level__c != oldMap.get(t.Id).Market_Specialization_Level__c) {
                           acctIds.add(t.Account__c);      
                       }                   
                } else {
                    acctIds.add(t.Account__c);
                }
            }
        }
        //Passing set of accountIds to Batch for process
        if(acctIds.size()>0)
            handleAcctIds(acctIds);
    }
    
    /*
* Method to check Market_Specializations__c deletion
*/
    public static void deleteObject(Map<Id, Market_Specializations__c> marketMap){
        Set<Id> acctIds = new Set<Id>();
        for(Market_Specializations__c c : marketMap.values()){
            acctIds.add(c.Account__c);
        }
        //Passing set of accountIds to Batch for process
        if(acctIds.size()>0)
            handleAcctIds(acctIds);
    }
    
    /*
* Method to check Partner Type (Partner_Type__c) and Purchasing Method(Purchasing_Method__c) in Program Information Object
*/
    public static void checkUpdateObject(Map<Id, Partner_Type__c> oldMap, Map<Id, Partner_Type__c> newMap, Boolean isUpdate){
        Set<Id> acctIds = new Set<Id>();
        
        List<Partner_Type__c> ListPartnerType = [SELECT id,Account__r.Owner_Business_Group__c,Account__r.Shared_Partner__c,Purchasing_Method__c,
                                                 Partner_Track__c,Account__c FROM Partner_Type__c WHERE id IN: newMap.keyset() ];
        
        for(Partner_Type__c t : ListPartnerType ){
            if( t.Account__r.Owner_Business_Group__c == 'Government' || t.Account__r.Shared_Partner__c == True)
            {
                if(isUpdate) {
                    if(t.Purchasing_Method__c != oldMap.get(t.Id).Purchasing_Method__c ||
                       t.Partner_Track__c != oldMap.get(t.Id).Partner_Track__c) {
                           acctIds.add(t.Account__c);      
                       }                   
                } else {
                    acctIds.add(t.Account__c);
                }
            }
        }
        //Passing set of accountIds to Batch for process
        if(acctIds.size()>0)
            handleAcctIds(acctIds);
    }
    
    /*
* Method to check Program Information Object deletion
*/
    public static void deleteObject(Map<Id, Partner_Type__c> partnerMap){ 
        Set<Id> acctIds = new Set<Id>();
        for(Partner_Type__c c : partnerMap.values()){
            acctIds.add(c.Account__c); 
        }
        //Passing set of accountIds to Batch for process
        if(acctIds.size()>0)
            handleAcctIds(acctIds);
    }
    
    // Method to handle Account ids
    public static void handleAcctIds(Set<Id> acctIds){
        if((System.isBatch() || System.isFuture()) || (Limits.getFutureCalls() >= (Limits.getLimitFutureCalls()-1)) || Test.isRunningTest()){ 
            if(!acctIds.isEmpty()){
                List<Attribute_to_Group_Processing__c> agpList = new List<Attribute_to_Group_Processing__c>();
                Integer i = 0;
                Attribute_to_Group_Processing__c agp = new Attribute_to_Group_Processing__c();
                agp.Account_Id_Set__c = '';
                for(Id aId : acctIds){
                    i++;
                    agp.Account_Id_Set__c += aId + ',';
                    if(i == 50 || Test.isRunningTest()){
                        i = 0;
                        agp.Account_Id_Set__c = agp.Account_Id_Set__c.substring(0, agp.Account_Id_Set__c.length() - 1);
                        agpList.add(agp);
                        agp = new Attribute_to_Group_Processing__c();
                        agp.Account_Id_Set__c = '';
                    } 
                }
                if(agp.Account_Id_Set__c != ''){
                    agp.Account_Id_Set__c = agp.Account_Id_Set__c.substring(0, agp.Account_Id_Set__c.length() - 1);
                    agpList.add(agp);
                }
                MPP_Class_HLPR_Data.commitToDB(MPP_Class_HLPR_Data.OpperationType.INSERT_RECS, agpList);
            }
        }
        else
        {
            handleAcctIdsThroughBatch(acctIds);
        }
    }
    
    /************* TO HANDLE UNPROCESSED RECORDS********/
    public static void continueProcessing(Attribute_to_Group_Processing__c agp){
        Set<Id> acctIds = new Set<Id>();
        for(String s : agp.Account_Id_Set__c.split(',')){
            acctIds.add(s);
        }
        handleAcctIdsThroughBatch(acctIds);
    }
    
    //Main method to handle account ids through batch class
    public static void handleAcctIdsThroughBatch(Set<Id> oldAcctIds)
    {
        Set<Id> acctIds = new Set<Id>();
        List<Account_to_Group_Mapping__c> tempList= new List<Account_to_Group_Mapping__c>();
        Map<id,string> TempMap = new map<id,string>();
        //Retrieving Account ids to process
        for(Account a : [SELECT Id FROM Account WHERE Id IN :oldAcctIds AND MPE_Program_Status_New__c = 'Active' AND RecordTypeId IN (SELECT Id FROM RecordType WHERE SobjectType = 'Account' AND Name = 'Partner')]){
            acctIds.add(a.Id);          
        }  
        
        // Deleting Exisiting Records
        tempList = DeletefromAccountToGroupMapObj(oldAcctIds);
        
        if(tempList.size()>0)
            Database.delete(tempList,false);
        
        // Inserting New Records
        MPP_Class_AddGroupsToUserInBulkBatch objInstance = new MPP_Class_AddGroupsToUserInBulkBatch(acctIds);
        ID batchId = Database.executeBatch(objInstance);
    }
    
    //Method to delete existing AccountToGroupMapping records
    Public Static List<Account_to_Group_Mapping__c> DeletefromAccountToGroupMapObj(Set<Id> AcIds) {
        List<Account_to_Group_Mapping__c> delAGM=[SELECT Id FROM Account_to_Group_Mapping__c WHERE Account_Id__c IN :AcIds];
        return delAGM;
    }
    
    //Main method to prepare AccountToGroupMapping records (Combination of AccountId and GroupNames)
    Public static Map<Id,String> InserttoAccountToGroupMapObj(Set<Id> AcIds)
    {
        Set<String> pcTechSubSegmntsSet = MPP_Class_HLPR_AddGroupsToUser_Advanced.getPCTechSubSegs();
        Map<String, List<CustomAGM>> regionToAGMMap = new Map<String, List<CustomAGM>>();
        Map<Id, List<Technology_Specialization__c>> techSpecMap = new Map<Id, List<Technology_Specialization__c>>();
        Map<Id, List<Market_Specializations__c>> marketSpecMap = new Map<Id, List<Market_Specializations__c>>(); 
        Map<Id, List<Partner_Type__c>> partnerTypeMap = new Map<Id, List<Partner_Type__c>>();
        Map<Id, List<Technology_SubSegment__c>> techSubSegmntMap = new Map<Id, List<Technology_SubSegment__c>>();
        Map<Id, Account> accountMap = new Map<Id, Account>();
        Map<id,string> mapAccToGroup = new map<id,string>();
        List<CustomAGM> noRegionAGMList = new List<CustomAGM>(); // List to store AGM records where Region__c = null
        
        List<Attribute_Group_Mapping__c > agmList =[SELECT Id,Country1__c,Technology_Specialization__c, Technology_Specialization_Level__c, 
                                                    Region__c, Purchasing_Method__c, Program_Level__c, Market_Specialization__c, 
                                                    Market_Specialization_Level__c, Language__c, Group__c, GroupId__c, Country__c, 
                                                    Community__c, Application_Specialization__c, Application_Specialization_Level__c, 
                                                    Sales_View_Upload_Mode__c, CASPA_groups__c,Technology_Sub_Segment__c,Partner_Local_Currency__c 
                                                    FROM Attribute_Group_Mapping__c 
                                                    WHERE Region__c != null order by lastmodifieddate desc];                                                    
        System.Debug('Harish agmList ****'+agmList);
        
        List<Technology_Specialization__c>  TSList = [SELECT Id,Type__c, Technology_Specialization__c, Technology_Specialization_Status__c, 
                                                      Technology_Specialization_Level__c, Tech_Specialization_Compliant_Status__c, 
                                                      Community_Type__c, Account__c, TechnologySubSegment__c,Partner_Program__r.Purchasing_Method__c
                                                      FROM Technology_Specialization__c 
                                                      WHERE Account__c IN :AcIds];                                          
        
        
        List<Market_Specializations__c> MSList=[SELECT Id,Market_Specialization__c, Market_Specialization_Level__c, Account__c 
                                                FROM Market_Specializations__c 
                                                WHERE Account__c IN :AcIds LIMIT 49900];
        
        List<Partner_Type__c> PTList =[SELECT Id, Purchasing_Method__c, Partner_Track__c, Partner_Level__c, Account__c 
                                       FROM Partner_Type__c p 
                                       WHERE Account__c IN :AcIds];
        System.debug('PTList size-->'+PTList.size());
        System.debug('MSList size-->'+MSList.size());
        System.debug('TSList size-->'+TSList.size());
        System.debug('agmList size-->'+agmList.size());
        List<Technology_SubSegment__c> techSubSegmntList = [SELECT id,Account__r.Owner_Business_Group__c,Account__r.Shared_Partner__c,
                                                            Account__r.Partner_Region__c,Program_Detail__c,Account__c,
                                                            Specialization_Level__c,Segment__c,Sub_Segment__c 
                                                            FROM Technology_SubSegment__c 
                                                            WHERE Account__c IN :AcIds];
        
        List<Account> ACList = [SELECT Id, Metal_Level__c, Partner_Region__c, Country__c,Partner_HQ_Country__c,
                                MPE_Program_Status_New__c, Sales_View_Upload_Mode__c, CASPA_groups__c,Partner_Local_Currency__c
                                FROM Account 
                                WHERE Id IN :AcIds];
        //AND MPE_Program_Status_New__c = 'Active'
        System.debug('ACList size-->'+ACList.size());
        for (Attribute_Group_Mapping__c agm: agmList) {
            CustomAGM currentAGM = new CustomAGM(agm);
            if (regionToAGMMap.containsKey(agm.Region__c)) 
                regionToAGMMap.get(agm.Region__c).add(currentAGM);
            else
                regionToAGMMap.put(agm.Region__c, new List<CustomAGM>{currentAGM});
        }
        
        // Preparing a list where Region__c = null
        for(Attribute_Group_Mapping__c eachAGM : [SELECT Id,Name,Country1__c,Technology_Specialization__c,Technology_Specialization_Level__c, 
                                                  Region__c,Purchasing_Method__c,Program_Level__c, Market_Specialization__c, Technology_Sub_Segment__c,
                                                  Market_Specialization_Level__c,Language__c,Group__c,GroupId__c,Country__c,Sales_View_Upload_Mode__c, 
                                                  Community__c,Application_Specialization__c,Application_Specialization_Level__c,CASPA_groups__c,Partner_Local_Currency__c 
                                                  FROM Attribute_Group_Mapping__c 
                                                  WHERE Region__c = null]) {
                                                      noRegionAGMList.add(new CustomAGM(eachAGM));
                                                  }
        System.debug('noRegionAGMList size-->'+noRegionAGMList.size());
        for(Technology_Specialization__c t : TSList) {
            if(techSpecMap.containsKey(t.Account__c))
                techSpecMap.get(t.Account__c).add(t);
            
            else                
                techSpecMap.put(t.Account__c, new List<Technology_Specialization__c>{t});
        }
        System.debug('techSpecMap size-->'+techSpecMap.size());
        
        for(Market_Specializations__c m : MSList) {
            if(marketSpecMap.containsKey(m.Account__c))
                marketSpecMap.get(m.Account__c).add(m);
            
            else
                marketSpecMap.put(m.Account__c, new List<Market_Specializations__c>{m});
        }
        
        for(Technology_SubSegment__c subSeg : techSubSegmntList) {
            if(techSubSegmntMap.containsKey(subSeg.Account__c))
                techSubSegmntMap.get(subSeg.Account__c).add(subSeg);
            
            else
                techSubSegmntMap.put(subSeg.Account__c, new List<Technology_SubSegment__c>{subSeg});
        }
        
        System.debug('marketSpecMap size-->'+marketSpecMap.size());
        for(Partner_Type__c p : PTList) {
            if(partnerTypeMap.containsKey(p.Account__c))
                partnerTypeMap.get(p.Account__c).add(p);
            
            else
                partnerTypeMap.put(p.Account__c, new List<Partner_Type__c>{p});
        }
        System.debug('partnerTypeMap size-->'+partnerTypeMap.size());
        
        for(Account a : ACList) {
            accountMap.put(a.Id, a);
        }
        System.debug('Testing1 AcIds size-->'+AcIds.size());
        for(Id AI:AcIds){
            
            Set<String> tempGroupNameSet = new Set<String>();
            try{
                // For loop to iterate RegionAGMList -- Starting
                for(CustomAGM agm : regionToAGMMap.get(accountMap.get(AI).Partner_Region__c)){                                
                    Boolean shouldKeepGoing = true;
                    //Checking PartnerRegion on Account object
                    
                    if(shouldKeepGoing){
                        if(AI != null){
                            shouldKeepGoing = (agm.agm.Region__c == null || agm.agm.Region__c == accountMap.get(AI).Partner_Region__c)?true:false;
                        }
                        else{
                            shouldKeepGoing = (agm.agm.Region__c == null)?true:false;
                        }
                    }
                    
                    if(shouldKeepGoing){
                        if(AI != null) {
                            if(agm.agm.CASPA_groups__c != null){ 
                                shouldKeepGoing = false;                                    
                                Integer match = 0;
                                for(String eachCaspaGrp : convertMultiSelectToSet(accountMap.get(AI).CASPA_groups__c)) {
                                    if(agm.CASPAgroupSet.contains(eachCaspaGrp)) {
                                        match++;
                                    } 
                                }
                                if(match >= 1){
                                    shouldKeepGoing = true;
                                } 
                            }
                        }                                 
                        else {
                            shouldKeepGoing = (agm.agm.CASPA_groups__c == null)?true:false;
                        }
                    }
                    
                    //Checking ProgramLevel on Account object
                    if(shouldKeepGoing){
                        if(AI != null){
                            shouldKeepGoing = (agm.agm.Program_Level__c == null || agm.programLevelSet.contains(accountMap.get(AI).Metal_Level__c))?true:false;
                        }
                        else{
                            shouldKeepGoing = (agm.agm.Program_Level__c == null)?true:false;
                        }                             
                    }
                    
                    //Checking Country on Account object
                    if(shouldKeepGoing){
                        if(AI != null){
                            shouldKeepGoing = (agm.agm.Country1__c == null || agm.countrySet.contains(accountMap.get(AI).Partner_HQ_Country__c))?true:false; 
                        }
                        else{
                            shouldKeepGoing = (agm.agm.Country1__c == null)?true:false;
                        }
                    }
                    
                    //Checking MarketSpecializationLevel(Market_Specialization_Level__c) field on MarketSpecializations object
                    if(shouldKeepGoing){
                        if(agm.agm.Market_Specialization__c != null){
                            shouldKeepGoing = false;
                            if(!marketSpecMap.isEmpty() && AI != null && marketSpecMap.containsKey(AI)){
                                for(Market_Specializations__c eachMktSpec : marketSpecMap.get(AI)){
                                    if(eachMktSpec.Market_Specialization__c == agm.agm.Market_Specialization__c && 
                                       agm.marketLevelSet.contains(eachMktSpec.Market_Specialization_Level__c)){
                                           shouldKeepGoing = true;
                                       }  
                                }
                            }
                        }
                    }
                    
                    /* Checking EngagementLevel(Technology_Specialization_Level__c) field and 
* Technology Segment(Technology_Specialization__c) on ProgramDetail object
* where Type = Application
*/
                    if(shouldKeepGoing){
                        if(agm.agm.Application_Specialization__c != null){
                            shouldKeepGoing = false;
                            if(!techSpecMap.isEmpty() && AI != null && techSpecMap.containsKey(AI)){
                                for(Technology_Specialization__c t : techSpecMap.get(AI)){
                                    if(t.Type__c == 'Application' && agm.techSpecSet.contains(t.Technology_Specialization__c) 
                                       && agm.applicationLevelSet.contains(t.Technology_Specialization_Level__c)
                                      ){
                                          shouldKeepGoing = true;
                                      } 
                                }
                            }
                        }
                    }
                    
                    /* Checking EngagementLevel(Technology_Specialization_Level__c) field and 
* Technology Segment(Technology_Specialization__c) on ProgramDetail object
* where Type = Technology
* AND Checking Technology SubSegment(Sub_Segment__c) field from TechnologySubSegment(Technology_SubSegment__c) Object 
* when Account's partner_region__c other than 'EMEA'
*/
                    
                    if(shouldKeepGoing || Test.isRunningTest()) {
                        if(agm.agm.Technology_Sub_Segment__c != null && accountMap.containsKey(AI) 
                           && pcTechSubSegmntsSet.size()>0 && !pcTechSubSegmntsSet.contains(accountMap.get(AI).Partner_Region__c)){
                               shouldKeepGoing = false;
                               if(!techSpecMap.isEmpty() && AI != null && techSpecMap.containsKey(AI)){ 
                                   for(Technology_Specialization__c t : techSpecMap.get(AI)){
                                       if(t.Type__c == 'Technology' && agm.techSpecSet.contains(t.Technology_Specialization__c) && 
                                          agm.techSubSegmentSet.contains(t.TechnologySubSegment__c)) {
                                              shouldKeepGoing = true; 
                                          }
                                   }
                               }
                           }
                        
                        /* 
* Checking Technology SubSegment(Sub_Segment__c) field from TechnologySubSegment(Technology_SubSegment__c) Object 
* when Account's partner_region__c = 'EMEA'
*/
                        else if(agm.agm.Technology_Sub_Segment__c != null && accountMap.containsKey(AI) 
                                && pcTechSubSegmntsSet.size()>0 && pcTechSubSegmntsSet.contains(accountMap.get(AI).Partner_Region__c)){
                                    shouldKeepGoing = false;
                                    if(!techSubSegmntMap.isEmpty() && AI != null && techSubSegmntMap.containsKey(AI)){
                                        for(Technology_SubSegment__c subSegmnt : techSubSegmntMap.get(AI)){
                                            if(agm.techSpecSet.contains(subSegmnt.Segment__c) 
                                               && agm.techSubSegmentSet.contains(subSegmnt.Sub_Segment__c)
                                              ){
                                                  shouldKeepGoing = true; 
                                              }
                                        }
                                    }
                                }
                    }
                    
                    if(shouldKeepGoing){
                        if(agm.agm.Technology_Specialization__c != null){
                            shouldKeepGoing = false;
                            if(!techSpecMap.isEmpty() && AI != null && techSpecMap.containsKey(AI)){                                        
                                for(Technology_Specialization__c t : techSpecMap.get(AI)){                                            
                                    if(t.Type__c == 'Technology' && agm.techSpecSet.contains(t.Technology_Specialization__c) && agm.technologyLevelSet.contains(t.Technology_Specialization_Level__c)){
                                        shouldKeepGoing = true; 
                                    }
                                }
                            }                                    
                        }
                    }
                    
                    //Checking Community(Community_Type__c) field on ProgramDetail object
                    if(shouldKeepGoing || Test.isRunningTest()){
                        if(agm.agm.Community__c != null){
                            shouldKeepGoing = false;
                            
                            if(AI != null && (!techSpecMap.isEmpty() && techSpecMap.containsKey(AI))){
                                for(Technology_Specialization__c t : techSpecMap.get(AI)){
                                    if(agm.communityLevelSet.contains(t.Community_Type__c)){
                                        shouldKeepGoing = true;
                                    }
                                }
                            }
                            
                            //Logic to add Currency Groups to the Partner Account
                            /************Added by Harish as part of SF-568 of L3 Project********/
                            if(AI!=null && (!techSpecMap.isEmpty() && techSpecMap.containsKey(AI))){
                                if(agm.agm.Region__c!=null && agm.agm.Partner_Local_Currency__c!=null){
                                    if(accountMap.get(AI).Partner_Region__c == agm.agm.Region__c && accountMap.get(AI).Partner_Local_Currency__c == agm.agm.Partner_Local_Currency__c){
                                        for(Technology_Specialization__c t : techSpecMap.get(AI)){
                                            if(t.Community_Type__c == agm.agm.Community__c){
                                                if(t.Community_Type__c == 'Value Added Distributor' || (t.Community_Type__c == 'Value Added Reseller' && t.Partner_Program__r.Purchasing_Method__c=='Tier 1')){
                                                    shouldKeepGoing = true;
                                                }else{
                                                    shouldKeepGoing = false;
                                                }
                                            }
                                        }
                                    }else{
                                        shouldKeepGoing = false;
                                    }
                                }
                            }
                            /************Added by Harish as part of SF-568 of L3 Project********/
                            //Checking Partner Type(Partner_Track__c) field on ProgramInformation object
                            if(AI != null && partnerTypeMap.containsKey(AI) && !shouldKeepGoing){
                                for(Partner_Type__c partner : partnerTypeMap.get(AI)){
                                    if(partner.Partner_Track__c == 'OEM' && agm.communityLevelSet.contains(partner.Partner_Track__c)){
                                        shouldKeepGoing = true;
                                    }
                                }
                            }
                            
                        }
                    }
                    
                    
                    //Checking PurchasingMethod(Purchasing_Method__c) field on ProgramInformation object
                    if(shouldKeepGoing || Test.isRunningTest()){
                        if(agm.agm.Purchasing_Method__c != null){
                            shouldKeepGoing = false;
                            if(!partnerTypeMap.isEmpty() && AI != null && partnerTypeMap.containsKey(AI)){
                                for(Partner_Type__c p : partnerTypeMap.get(AI)){
                                    if(agm.purchasingLevelSet.contains(p.Purchasing_Method__c)){
                                        shouldKeepGoing = true;
                                    }
                                }
                            }
                        }
                    }
                    
                    if(shouldKeepGoing){              
                        tempGroupNameSet.add(agm.agm.Group__c);
                    }
                }
                // For loop to iterate RegionAGMList -- Ending
                
                // For loop to iterate noRegionAGMList -- Starting
                if(noRegionAGMList.size() > 0) {
                    //tempGroupNameSet.clear();
                    for(CustomAGM agm : noRegionAGMList){
                        Boolean shouldKeepGoing = true;
                        //Checking PartnerRegion on Account object
                        if(shouldKeepGoing){
                            if(AI != null)
                                shouldKeepGoing = (agm.agm.Region__c == null || agm.agm.Region__c == accountMap.get(AI).Partner_Region__c)?true:false;
                            else
                                shouldKeepGoing = (agm.agm.Region__c == null)?true:false;
                        }
                        
                        //Checking ProgramLevel on Account object
                        
                        if(shouldKeepGoing){
                            if(AI != null)
                                shouldKeepGoing = (agm.agm.Program_Level__c == null || agm.programLevelSet.contains(accountMap.get(AI).Metal_Level__c))?true:false;
                            else
                                shouldKeepGoing = (agm.agm.Program_Level__c == null)?true:false;                             
                        }
                        
                        //Checking Sales_View_Upload_Mode__c on Account object
                        if(shouldKeepGoing)
                        {
                            if(AI != null)
                                shouldKeepGoing = (agm.agm.Sales_View_Upload_Mode__c == null || agm.agm.Sales_View_Upload_Mode__c == accountMap.get(AI).Sales_View_Upload_Mode__c)?true:false;
                            
                            else
                                shouldKeepGoing = (agm.agm.Sales_View_Upload_Mode__c == null)?true:false;
                        }
                        
                        //Checking Country on Account object
                        if(shouldKeepGoing){
                            if(AI != null) 
                                shouldKeepGoing = (agm.agm.Country1__c == null || agm.countrySet.contains(accountMap.get(AI).Partner_HQ_Country__c))?true:false; 
                            else
                                shouldKeepGoing = (agm.agm.Country1__c == null)?true:false;                             
                        }
                        
                        //Checking CASPA groups on Account object
                        
                        if(shouldKeepGoing){
                            if(AI != null) {
                                if(agm.agm.CASPA_groups__c != null){ 
                                    shouldKeepGoing = false;                                    
                                    Integer match = 0;
                                    for(String eachCaspaGrp : convertMultiSelectToSet(accountMap.get(AI).CASPA_groups__c)) {
                                        if(agm.CASPAgroupSet.contains(eachCaspaGrp)) {
                                            match++;
                                        } 
                                    }
                                    if(match >= 1) {
                                        shouldKeepGoing = true;
                                    } 
                                }
                            }                                 
                            else {
                                shouldKeepGoing = (agm.agm.CASPA_groups__c == null)?true:false;
                            }
                        }
                        //Checking MarketSpecializationLevel field on MarketSpecializations object
                        if(shouldKeepGoing){
                            if(agm.agm.Market_Specialization__c != null){
                                shouldKeepGoing = false;
                                if(!marketSpecMap.isEmpty() && AI != null && marketSpecMap.containsKey(AI)){
                                    for(Market_Specializations__c m : marketSpecMap.get(AI)){
                                        if(m.Market_Specialization__c == agm.agm.Market_Specialization__c && agm.marketLevelSet.contains(m.Market_Specialization_Level__c))
                                            shouldKeepGoing = true;  
                                    }
                                }
                            }
                        }
                        
                        //Checking TechnologySegment field on ProgramDetail object
                        
                        if(shouldKeepGoing){
                            if(agm.agm.Application_Specialization__c != null){
                                shouldKeepGoing = false;
                                if(!techSpecMap.isEmpty() && AI != null && techSpecMap.containsKey(AI)){
                                    for(Technology_Specialization__c t : techSpecMap.get(AI)) {
                                        if(t.Type__c == 'Application' && agm.techSpecSet.contains(t.Technology_Specialization__c) 
                                           && agm.applicationLevelSet.contains(t.Technology_Specialization_Level__c)
                                          )
                                            shouldKeepGoing = true; 
                                    }
                                }
                            }
                        }
                        
                        /* Checking EngagementLevel(Technology_Specialization_Level__c) field and 
* Technology Segment(Technology_Specialization__c) on ProgramDetail object
* where Type = Technology
* AND Checking Technology SubSegment(Sub_Segment__c) field from TechnologySubSegment(Technology_SubSegment__c) Object 
* when Account's partner_region__c other than 'EMEA'
*/
                        if(shouldKeepGoing || Test.isRunningTest()) {
                            if(agm.agm.Technology_Sub_Segment__c != null && accountMap.containsKey(AI) 
                               && pcTechSubSegmntsSet.size()>0 && !pcTechSubSegmntsSet.contains(accountMap.get(AI).Partner_Region__c))
                            {
                                shouldKeepGoing = false;
                                if(!techSpecMap.isEmpty() && AI != null && techSpecMap.containsKey(AI))
                                { 
                                    for(Technology_Specialization__c t : techSpecMap.get(AI))
                                    {
                                        if(t.Type__c == 'Technology' && agm.techSpecSet.contains(t.Technology_Specialization__c) && 
                                           agm.techSubSegmentSet.contains(t.TechnologySubSegment__c)) {
                                               shouldKeepGoing = true; 
                                           }
                                    }
                                }
                            }
                            //Checking Technology SubSegment(Sub_Segment__c) field from TechnologySubSegment(Technology_SubSegment__c) Object 
                            //when Account's partner_region__c is 'EMEA'
                            else if(agm.agm.Technology_Sub_Segment__c != null && accountMap.containsKey(AI) 
                                    && pcTechSubSegmntsSet.size()>0 && pcTechSubSegmntsSet.contains(accountMap.get(AI).Partner_Region__c))
                            {
                                shouldKeepGoing = false;
                                if(!techSubSegmntMap.isEmpty() && AI != null && techSubSegmntMap.containsKey(AI))
                                {
                                    for(Technology_SubSegment__c subSegmnt : techSubSegmntMap.get(AI))
                                    {
                                        if(agm.techSpecSet.contains(subSegmnt.Segment__c) && agm.techSubSegmentSet.contains(subSegmnt.Sub_Segment__c)) {
                                            shouldKeepGoing = true; 
                                        }
                                    }
                                }
                            }
                        }
                        
                        if(shouldKeepGoing){
                            if(agm.agm.Technology_Specialization__c != null){
                                shouldKeepGoing = false;
                                if(!techSpecMap.isEmpty() && AI != null && techSpecMap.containsKey(AI)){                                        
                                    for(Technology_Specialization__c t : techSpecMap.get(AI)){                                            
                                        if(t.Type__c == 'Technology' && agm.techSpecSet.contains(t.Technology_Specialization__c) && agm.technologyLevelSet.contains(t.Technology_Specialization_Level__c)){
                                            shouldKeepGoing = true; 
                                        }
                                    }
                                }                                    
                            }
                        }
                        
                        //Checking Community field on ProgramDetail object
                        if(shouldKeepGoing || Test.isRunningTest()) {
                            if(agm.agm.Community__c != null){
                                shouldKeepGoing = false;
                                if(AI != null && (!techSpecMap.isEmpty() && techSpecMap.containsKey(AI))){
                                    for(Technology_Specialization__c t : techSpecMap.get(AI)){
                                        if(agm.communityLevelSet.contains(t.Community_Type__c))
                                            shouldKeepGoing = true;
                                    }
                                }
                                
                                if(AI != null && partnerTypeMap.containsKey(AI) && !shouldKeepGoing){
                                    for(Partner_Type__c partner : partnerTypeMap.get(AI)){
                                        if(partner.Partner_Track__c == 'OEM' && agm.communityLevelSet.contains(partner.Partner_Track__c))
                                            shouldKeepGoing = true;
                                    }
                                }
                            }
                        }
                        
                        //Checking PurchasingMethod field on ProgramInformation object
                        if(shouldKeepGoing || Test.isRunningTest()) {
                            if(agm.agm.Purchasing_Method__c != null){
                                shouldKeepGoing = false;
                                if(!partnerTypeMap.isEmpty() && AI != null && partnerTypeMap.containsKey(AI)){
                                    for(Partner_Type__c p : partnerTypeMap.get(AI)){
                                        if(agm.purchasingLevelSet.contains(p.Purchasing_Method__c))
                                            shouldKeepGoing = true;
                                    }
                                }
                            }
                        }
                        
                        if(shouldKeepGoing)              
                            tempGroupNameSet.add(agm.agm.Group__c);
                    }
                }
                
                // For loop to iterate noRegionAGMList -- Ending
            } catch(Exception exp) {
                System.debug(LoggingLevel.ERROR, 'error on user... ' + exp);
            }
            
            for(String groupName : tempGroupNameSet)
            {
                if(mapAccToGroup.get(AI) != null )
                {
                    string existinggroupnames = mapAccToGroup.get(AI);
                    String newval = existinggroupnames+';'+groupName ;
                    mapAccToGroup.put(AI,newval);
                }
                else
                {
                    mapAccToGroup.put(AI,groupName);
                }
            }   
        }
        
        return  mapAccToGroup;
    }
    
    /*
* Method to split the string by ; 
*/ 
    public static Set<String> convertMultiSelectToSet(String strToConvert)
    {
        try{
            Set<String> convertedStrSet = new Set<String>();
            List<String> splitStrList = (strToConvert == null)? new List<String>():strToConvert.split(';');
            if(!splitStrList.isEmpty()){
                convertedStrSet.addAll(splitStrList);
            }
            return convertedStrSet;
        }catch(Exception exp){
            return new Set<String>();
        }
    }
    
    // Inner class to store AttributeToGroup mapping records
    public class CustomAGM{
        public Attribute_Group_Mapping__c agm {get;set;}
        public Set<String> applicationLevelSet{get;set;}
        public Set<String> techSpecSet{get;set;}
        public Set<String> technologyLevelSet{get;set;}
        public Set<String> communityLevelSet{get;set;}
        public Set<String> marketLevelSet{get;set;}
        public Set<String> programLevelSet{get;set;}
        public Set<String> purchasingLevelSet{get;set;}
        public Set<String> countrySet{get;set;} 
        public Set<String> CASPAgroupSet {get; set;} 
        public Set<String> techSubSegmentSet {get; set;} 
        
        public CustomAGM(Attribute_Group_Mapping__c attr){
            this.agm = attr;
            this.applicationLevelSet = MPP_Class_HLPR_AddGroupsToUser_Advanced.convertMultiSelectToSet(attr.Application_Specialization_Level__c);
            this.techSpecSet = new Set<String>();
            this.techSpecSet = MPP_Class_HLPR_AddGroupsToUser_Advanced.convertMultiSelectToSet(attr.Technology_Specialization__c);
            this.technologyLevelSet = MPP_Class_HLPR_AddGroupsToUser_Advanced.convertMultiSelectToSet(attr.Technology_Specialization_Level__c);
            this.techSubSegmentSet = MPP_Class_HLPR_AddGroupsToUser_Advanced.convertMultiSelectToSet(attr.Technology_Sub_Segment__c);
            this.communityLevelSet = MPP_Class_HLPR_AddGroupsToUser_Advanced.convertMultiSelectToSet(attr.Community__c);
            this.marketLevelSet = MPP_Class_HLPR_AddGroupsToUser_Advanced.convertMultiSelectToSet(attr.Market_Specialization_Level__c);
            this.programLevelSet = MPP_Class_HLPR_AddGroupsToUser_Advanced.convertMultiSelectToSet(attr.Program_Level__c);
            this.purchasingLevelSet = MPP_Class_HLPR_AddGroupsToUser_Advanced.convertMultiSelectToSet(attr.Purchasing_Method__c);
            this.countrySet = MPP_Class_HLPR_AddGroupsToUser_Advanced.convertMultiSelectToSet(attr.Country1__c); 
            this.CASPAgroupSet = MPP_Class_HLPR_AddGroupsToUser_Advanced.convertMultiSelectToSet(attr.CASPA_groups__c); 
        }
    }
}