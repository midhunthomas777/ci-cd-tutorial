/*
Name:  MPP_TEST_Class_AddGroupsToUser_Advanced
Purpose: Test class for MPP_Class_HLPR_AddGroupsToUser_Advanced
          
==========================================================================================
History
-------                                                                                                                  
VERSION        AUTHOR            DATE                 DETAIL                   
  1.0 -     Satish Maddhi      24 Jan 2017       INITIAL DEVELOPMENT       

******************************************************************************************/
@isTest
private class MPP_TEST_Class_AddGroupsToUser_Advanced {
    @testSetup
   static void testSetUp() {
       TestDataSetUpUtils.insertCustomSettings();
   }
    
    //Creating test data for Account object
    public static List<Account> createAccounts() {
        List<Account> accountList = new List<Account>();
        Recordtype recType = [SELECT Id,DeveloperName,Name,SobjectType FROM RecordType WHERE SobjectType = 'Account'
                             AND DeveloperName = 'Partner'];
        Account acc1 = new Account(Name='Test Systems Inc.',RecordTypeId=recType.Id,Shared_Partner__c=true,MPE_Program_Status_New__c='Active', 
                                   Level__c='Authorized Reseller',WNS_Track__c= true,Mobility_Track__c=true,
                                   Status__c='Active',Metal_Level__c = 'gold', 
                                   Partner_Region__c='NAMR',Owner_Business_Group__c='Government',
                                  Partner_HQ_Country__c='Austria',Sales_View_Upload_Mode__c='DLS',
                                  CASPA_groups__c = 'Connect Adv Partner');
        accountList.add(acc1);
        Account acc2 = new Account(Name='motorola Systems Inc.',RecordTypeId=recType.Id,Shared_Partner__c=true,MPE_Program_Status_New__c='Active', 
                                   Level__c='Authorized Reseller',WNS_Track__c= true,Mobility_Track__c=true,
                                   Status__c='Active',Metal_Level__c = 'gold', 
                                   Partner_Region__c='EMEA',Owner_Business_Group__c='Government',
                                  Partner_HQ_Country__c='Austria',Sales_View_Upload_Mode__c='DLS',
                                  CASPA_groups__c = 'Connect Adv Partner');
        accountList.add(acc2);
        Database.insert(accountList);
        return accountList;
    }
    
    //Creating test data for Program Information object
    public static List<Partner_Type__c> createProgramInformations() {
        List<Account> accList = MPP_TEST_Class_AddGroupsToUser_Advanced.createAccounts();
        List<Partner_Type__c> pgrmInfoList = new List<Partner_Type__c>();
        Partner_Type__c pt1 = new Partner_Type__c(Account__c = accList[0].id, Program__c = 'RADIO',Purchasing_Method__c='Tier 1',Status__c='Active',Partner_Track__c='Reseller');
        Partner_Type__c pt2 = new Partner_Type__c(Account__c = accList[1].id, Program__c = 'RADIO',Purchasing_Method__c='Tier 1',Status__c='Active',Partner_Track__c='Reseller');
        pgrmInfoList.add(pt1);
        pgrmInfoList.add(pt2);
        Database.insert(pgrmInfoList,false);
        return pgrmInfoList;
    }
    
    //Creating test data for AccountToGroupMapping object
    public static List<Account_to_Group_Mapping__c> createAccountToGrpMappingRecs() {
        List<Account> accList = MPP_TEST_Class_AddGroupsToUser_Advanced.createAccounts();
        List<Account_to_Group_Mapping__c> accGrpList = new List<Account_to_Group_Mapping__c>();
        Account_to_Group_Mapping__c accGrp1 = new Account_to_Group_Mapping__c(Account_Id__c=accList[0].Id,Groups__c='PC-NAMR-VAR-XXXX-XXXXX-XXXX-X-T1;PC-NAMR-VAR-XXXX-XXXXX-XXXX-X-T2;PC-NAMR-VAR-XXXX-XXXXX-XXXX-X-XX');
        Account_to_Group_Mapping__c accGrp2 = new Account_to_Group_Mapping__c(Account_Id__c=accList[1].Id,Groups__c='PC-APAC-VAR-XXXX-XXXXX-XXXX-X-T1;PC-EMEA-VAR-XXXX-XXXXX-XXXX-X-T2;PC-NAMR-VAR-XXXX-XXXXX-XXXX-X-XX');
        accGrpList.add(accGrp1);
        accGrpList.add(accGrp2);
        Database.insert(accGrpList,false);
        return accGrpList;
    }
    
    //Creating test data for ProgramDetail object
    public Static List<Technology_Specialization__c> createProgramDetailRecs() {
        List<Account> accList = MPP_TEST_Class_AddGroupsToUser_Advanced.createAccounts();
        List<Partner_Type__c> pgrmInfoList = MPP_TEST_Class_AddGroupsToUser_Advanced.createProgramInformations();
        List<Technology_Specialization__c> prgmDetailList = new List<Technology_Specialization__c>();
        Technology_Specialization__c techSpec1 = new Technology_Specialization__c(Partner_Program__c = pgrmInfoList[0].Id,
                                                                                  Account__c=accList[0].Id,
                                                                          Technology_Specialization__c='Professional and Commercial Radio',
                                                                          Community_Type__c='Application Partner',
                                                                          Technology_Specialization_Status__c ='Active',
                                                                          Technology_Specialization_Level__c='Authorized',
                                                                          TechnologySubSegment__c='MOTOTRBO Capacity Max',
                                                                          Type__c = 'Application');
        prgmDetailList.add(techSpec1);
        Technology_Specialization__c techSpec2 = new Technology_Specialization__c(Partner_Program__c = pgrmInfoList[1].Id,
                                                                                  Account__c=accList[1].Id,
                                                                          Technology_Specialization__c='Professional and Commercial Radio',
                                                                          Community_Type__c='Application Partner',
                                                                          Technology_Specialization_Status__c ='Active',
                                                                          Technology_Specialization_Level__c='Authorized',
                                                                          TechnologySubSegment__c='MOTOTRBO Capacity Max',
                                                                          Type__c = 'Technology');
        prgmDetailList.add(techSpec2);
        Database.insert(prgmDetailList,false);
        return prgmDetailList;
    }
    
    //Creating test data for MarketSpecialization object
    public static List<Market_Specializations__c> createMarketSpecRecs() {
        List<Account> accList = MPP_TEST_Class_AddGroupsToUser_Advanced.createAccounts();
        List<Market_Specializations__c> marketSpecialList = new List<Market_Specializations__c>();
        Market_Specializations__c marketSpecialization1  = new Market_Specializations__c(Market_Specialization_Level__c='Authorized',
                                                                                      Market_Specialization__c = 'US Federal',
                                                                                        Account__c = accList[0].Id);
        marketSpecialList.add(marketSpecialization1);
        Market_Specializations__c marketSpecialization2  = new Market_Specializations__c(Market_Specialization_Level__c='Authorized',
                                                                                      Market_Specialization__c = 'US Federal',
                                                                                        Account__c = accList[1].Id);
        marketSpecialList.add(marketSpecialization2);
        Database.insert(marketSpecialList);
        return marketSpecialList;
    }
    
    //Testing account records updation
    static testMethod void accountTest() {
        Test.startTest();
        List<Account> accList = MPP_TEST_Class_AddGroupsToUser_Advanced.createAccounts();
        Set<Id> accSet = new Set<Id>();
        Map<Id,Account> oldAccMap = new Map<Id,Account>();
        for(Account acc : accList) {
            accSet.add(acc.Id);
            oldAccMap.put(acc.Id,acc);
        }
        
        accList[0].Metal_Level__c = 'silver';
        accList[0].Partner_HQ_Country__c='USA';
        accList[0].Sales_View_Upload_Mode__c = 'TLS';
        accList[0].Partner_Region__c = 'APAC';
        accList[0].MPE_Program_Status_New__c = 'Active';
        accList[0].Owner_Business_Group__c = 'Government';
        accList[0].CASPA_groups__c = 'Connect Adv Subs Partner';
        
        accList[1].Metal_Level__c = 'platinum';
        accList[1].Partner_HQ_Country__c='USA';
        accList[1].Sales_View_Upload_Mode__c = 'TLS';
        accList[1].Partner_Region__c = 'APAC';
        accList[1].MPE_Program_Status_New__c = 'Active';
        accList[1].Owner_Business_Group__c = 'Government';
        accList[1].CASPA_groups__c = 'Connect Adv Subs Partner';
        Database.update(accList,false);
        Map<Id,Account> newAccMap = new Map<Id,Account>();
        for(Account acc : accList) {
            newAccMap.put(acc.Id,acc);
        }
        
        Test.stopTest();
        MPP_Class_HLPR_AddGroupsToUser_Advanced.checkUpdateObject(oldAccMap,newAccMap, true);
        MPP_Class_HLPR_AddGroupsToUser_Advanced.deleteObject(oldAccMap);
        MPP_Class_HLPR_AddGroupsToUser_Advanced.InserttoAccountToGroupMapObj(accSet);
        MPP_Class_HLPR_AddGroupsToUser_Advanced.handleAcctIdsThroughBatch(accSet);
    }
    
    //Testing ProgramInformation records updation
    static testMethod void programInfoTest() {
        Test.startTest();
        List<Account> accList = MPP_TEST_Class_AddGroupsToUser_Advanced.createAccounts();
        Set<Id> accSet = new Set<Id>();
        for(Account acc : accList) {
            accSet.add(acc.Id);
        }
        List<Partner_Type__c> pgrmInfoList = MPP_TEST_Class_AddGroupsToUser_Advanced.createProgramInformations();
        Map<Id,Partner_Type__c> oldPartnerMap = new Map<Id,Partner_Type__c>();
        for(Partner_Type__c eachPartner : pgrmInfoList) {
            oldPartnerMap.put(eachPartner.Id, eachPartner);
        }
        pgrmInfoList[0].Purchasing_Method__c = 'Tier 2';
        pgrmInfoList[0].Partner_Track__c = 'OEM';
        pgrmInfoList[1].Purchasing_Method__c = 'Tier 2';
        pgrmInfoList[1].Partner_Track__c = 'OEM';
        Database.Update(pgrmInfoList,false);
        Map<Id,Partner_Type__c> newPartnerMap = new Map<Id,Partner_Type__c>();
        for(Partner_Type__c eachPartner : pgrmInfoList) {
            newPartnerMap.put(eachPartner.Id, eachPartner);
        }
        Test.stopTest();
        MPP_Class_HLPR_AddGroupsToUser_Advanced.checkUpdateObject(oldPartnerMap,newPartnerMap,true);
        MPP_Class_HLPR_AddGroupsToUser_Advanced.deleteObject(new Map<Id, Partner_Type__c>{pgrmInfoList[1].Id => pgrmInfoList[1]});
        MPP_Class_HLPR_AddGroupsToUser_Advanced.InserttoAccountToGroupMapObj(accSet);
        MPP_Class_HLPR_AddGroupsToUser_Advanced.handleAcctIdsThroughBatch(accSet);
    }
    
    //Testing MarketSpecialization records updation
    static testMethod void marketSpecializationTest() {
        List<Market_Specializations__c> marketSpecialList = new List<Market_Specializations__c>();
        Map<Id,Market_Specializations__c> marketSpecialMap = new Map<Id,Market_Specializations__c>();
        Test.startTest();
        List<Account> accList = MPP_TEST_Class_AddGroupsToUser_Advanced.createAccounts();
        Set<Id> accSet = new Set<Id>();
        for(Account acc : accList) {
            accSet.add(acc.Id);
        }
        Market_Specializations__c marketSpecialization1  = new Market_Specializations__c(Market_Specialization_Level__c='Specialist',
                                                                                      Market_Specialization__c = 'US Federal',
                                                                                        Account__c = accList[0].Id);
        marketSpecialList.add(marketSpecialization1);
        Market_Specializations__c marketSpecialization2  = new Market_Specializations__c(Market_Specialization_Level__c='Specialist',
                                                                                      Market_Specialization__c = 'US Federal',
                                                                                        Account__c = accList[1].Id);
        marketSpecialList.add(marketSpecialization2);
        Database.insert(marketSpecialList);
        for(Market_Specializations__c eachRec : marketSpecialList) {
            marketSpecialMap.put(eachRec.Id, eachRec);
        }
        Test.stopTest();
        MPP_Class_HLPR_AddGroupsToUser_Advanced.checkUpdateObject(marketSpecialMap,marketSpecialMap,true);
        MPP_Class_HLPR_AddGroupsToUser_Advanced.deleteObject(new Map<Id, Market_Specializations__c>{marketSpecialList[1].Id => marketSpecialList[1]});
        MPP_Class_HLPR_AddGroupsToUser_Advanced.InserttoAccountToGroupMapObj(accSet);
        MPP_Class_HLPR_AddGroupsToUser_Advanced.handleAcctIdsThroughBatch(accSet);
    }
    
    //Testing ProgramDetail records updation
    static testMethod void pgrmDetailTest() {
        Test.startTest();
        List<Account> accList = MPP_TEST_Class_AddGroupsToUser_Advanced.createAccounts();
        Set<Id> accSet = new Set<Id>();
        for(Account acc : accList) {
            accSet.add(acc.Id);
        }
        List<Technology_Specialization__c> pgrmDetailList = MPP_TEST_Class_AddGroupsToUser_Advanced.createProgramDetailRecs();
        Map<Id,Technology_Specialization__c> oldPgrmDetailMap = new Map<Id,Technology_Specialization__c>();
        for(Technology_Specialization__c eachDetail : pgrmDetailList) {
            oldPgrmDetailMap.put(eachDetail.Id, eachDetail);
        }
        List<Technology_Specialization__c> newpgrmDetailList = [SELECT Id,Partner_Program__c,Account__c,Technology_Specialization__c,
                                                                Community_Type__c,TechnologySubSegment__c,Technology_Specialization_Status__c,
                                                                Technology_Specialization_Level__c,Type__c,Partner_Category__c
                                                                FROM Technology_specialization__c 
                                                                WHERE Id IN : oldPgrmDetailMap.keySet()];
        newpgrmDetailList[0].Account__c = accList[0].Id;
        newpgrmDetailList[0].Technology_Specialization__c = 'Mission Critical Radio Systems';
        newpgrmDetailList[0].Community_Type__c = 'Value Added Reseller';
        newpgrmDetailList[0].Technology_Specialization_Status__c = 'Active';
        newpgrmDetailList[0].Technology_Specialization_Level__c = 'Specialist';
        newpgrmDetailList[0].TechnologySubSegment__c = 'Wave on Cloud';
        newpgrmDetailList[0].Type__c = 'Technology';
        
        newpgrmDetailList[1].Account__c = accList[1].Id;
        newpgrmDetailList[1].Technology_Specialization__c = 'Mission Critical Radio Systems';
        newpgrmDetailList[1].Community_Type__c = 'Value Added Reseller';
        newpgrmDetailList[1].Technology_Specialization_Status__c = 'Active';
        newpgrmDetailList[1].Technology_Specialization_Level__c = 'Elite Specialist';
        newpgrmDetailList[1].Type__c = 'Application';
        newpgrmDetailList[1].TechnologySubSegment__c = 'Wave on Cloud';
        newpgrmDetailList[1].Partner_Category__c = 'Channel Partner';
        Database.update(newpgrmDetailList,false);
        
        Map<Id,Technology_Specialization__c> newPgrmDetailMap = new Map<Id,Technology_Specialization__c>();
        for(Technology_Specialization__c eachDetail : newpgrmDetailList) {
            newPgrmDetailMap.put(eachDetail.Id, eachDetail);
        }
        Test.stopTest();
        MPP_Class_HLPR_AddGroupsToUser_Advanced.InserttoAccountToGroupMapObj(accSet);
        MPP_Class_HLPR_AddGroupsToUser_Advanced.handleAcctIdsThroughBatch(accSet);
        MPP_Class_HLPR_AddGroupsToUser_Advanced.checkUpdateObject(oldPgrmDetailMap,newPgrmDetailMap,true);
        MPP_Class_HLPR_AddGroupsToUser_Advanced.deleteObject(oldPgrmDetailMap);
        
    }
    
    //Testing TechnologySubSegment records updation
    static testMethod void technologySubSegmentTest() {
        Test.startTest();
        List<Technology_SubSegment__c> oldTechSubSegList = new List<Technology_SubSegment__c>();
        Map<Id,Technology_SubSegment__c> oldTechSubSegMap = new Map<Id,Technology_SubSegment__c>();
        Map<Id,Technology_SubSegment__c> newTechSubSegMap = new Map<Id,Technology_SubSegment__c>();
        List<Account> accList = MPP_TEST_Class_AddGroupsToUser_Advanced.createAccounts();
        List<Technology_Specialization__c> progrmDetailRecs = MPP_TEST_Class_AddGroupsToUser_Advanced.createProgramDetailRecs();
        Set<Id> accSet = new Set<Id>();
        for(Account acc : accList) {
            accSet.add(acc.Id);
        }
        Technology_SubSegment__c segment1 = new Technology_SubSegment__c(Account__c=accList[0].Id,Program_Detail__c=progrmDetailRecs[0].Id,
                                                                        Segment__c='Professional and Commercial Radio',Sub_Segment__c='MOTOTRBO');
        oldTechSubSegList.add(segment1);
        Technology_SubSegment__c segment2 = new Technology_SubSegment__c(Account__c=accList[1].Id,Program_Detail__c=progrmDetailRecs[1].Id,
                                                                        Segment__c='Professional and Commercial Radio',Sub_Segment__c='MOTOTRBO');
        oldTechSubSegList.add(segment2);
        Database.insert(oldTechSubSegList,false);      
        List<Technology_SubSegment__c> newTechSubSegList = [SELECT Id,Account__c,Program_Detail__c,Segment__c,Sub_Segment__c FROM Technology_SubSegment__c WHERE Id IN :oldTechSubSegList];
        for(Technology_SubSegment__c eachSeg : oldTechSubSegList) {
            oldTechSubSegMap.put(eachSeg.Id, eachSeg);
        }
        for(Technology_SubSegment__c eachSubSeg : newTechSubSegList) {
            newTechSubSegMap.put(eachSubSeg.Id, eachSubSeg);
        }
        Test.stopTest();
        MPP_Class_HLPR_AddGroupsToUser_Advanced.InserttoAccountToGroupMapObj(accSet);
        MPP_Class_HLPR_AddGroupsToUser_Advanced.handleAcctIdsThroughBatch(accSet);
        MPP_Class_HLPR_AddGroupsToUser_Advanced.checkUpdateObject(oldTechSubSegMap,newTechSubSegMap,true);
        MPP_Class_HLPR_AddGroupsToUser_Advanced.deleteObject(oldTechSubSegMap);
        
    }
    
    //Testing AttributeToGroupMapping records updation
    static testMethod void attributeToGroupTest() {
        Test.startTest();
        List<Account> accList = MPP_TEST_Class_AddGroupsToUser_Advanced.createAccounts();
        List<Partner_Type__c> pgrmInfoList = MPP_TEST_Class_AddGroupsToUser_Advanced.createProgramInformations();
        List<Market_Specializations__c> marketSpecList = MPP_TEST_Class_AddGroupsToUser_Advanced.createMarketSpecRecs();
        List<Attribute_Group_Mapping__c> attributeList = new List<Attribute_Group_Mapping__c>();
        List<Technology_Specialization__c> pgrmDetailList = MPP_TEST_Class_AddGroupsToUser_Advanced.createProgramDetailRecs();
        Set<Id> accSet = new Set<Id>();
        for(Account acc : accList) {
            accSet.add(acc.Id);
        }
        
        Attribute_Group_Mapping__c newAttr1 = new Attribute_Group_Mapping__c(Application_Specialization__c = 'Business Radio',
                                                                            Application_Specialization_Level__c = 'Specialist',
                                                                            Community__c = 'Application Partner',
                                                                            Country1__c = 'Austria',
                                                                            Language__c = 'English',
                                                                            Market_Specialization__c = 'US Federal',
                                                                            Market_Specialization_Level__c = 'Authorized',
                                                                            Program_Level__c = 'gold',
                                                                            Purchasing_Method__c = 'Tier 1',
                                                                            Region__c = 'NAMR',
                                                                            Role__c = 'Executive',
                                                                            Technology_Sub_Segment__c = 'Wave on Cloud',
                                                                            Sales_View_Upload_Mode__c = 'DLS',
                                                                            Technology_Specialization__c = 'Professional and Commercial Radio',
                                                                            Technology_Specialization_Level__c = 'Authorized',
                                                                            Group__c = 'PC-NAMR-XXX-XXXX-XXXXX-XXXX-X-XX');
        attributeList.add(newAttr1);
        Attribute_Group_Mapping__c newAttr2 = new Attribute_Group_Mapping__c(Application_Specialization__c = 'Business Radio',
                                                                            Application_Specialization_Level__c = 'Specialist',
                                                                            Community__c = 'Application Partner',
                                                                            Country1__c = 'Austria',
                                                                            Language__c = 'English',
                                                                            Market_Specialization__c = 'US Federal',
                                                                            Market_Specialization_Level__c = 'Authorized',
                                                                            Program_Level__c = 'gold',
                                                                            Purchasing_Method__c = 'Tier 1',
                                                                            Region__c = '',
                                                                            Role__c = 'Executive',
                                                                            Technology_Sub_Segment__c = 'Wave on Cloud',
                                                                            Sales_View_Upload_Mode__c = 'DLS',
                                                                            Technology_Specialization__c = 'Professional and Commercial Radio',
                                                                            Technology_Specialization_Level__c = 'Authorized',
                                                                            Group__c = 'PC-NAMR-XXX-XXXX-XXXXX-XXXX-X-XX');
        attributeList.add(newAttr2);
        Database.insert(attributeList,false);
        Map<Id,Attribute_Group_Mapping__c> attrMap = new Map<Id,Attribute_Group_Mapping__c>();
        for(Attribute_Group_Mapping__c eachAttr : attributeList) {
            attrMap.put(eachAttr.Id, eachAttr);
        }
        Test.stopTest();
        MPP_TEST_Class_AddGroupsToUser_Advanced.createAccountToGrpMappingRecs();
        MPP_Class_HLPR_AddGroupsToUser_Advanced.updateAttributeToGroupMapping(attrMap,attrMap,accSet);
        MPP_Class_HLPR_AddGroupsToUser_Advanced.deleteAttributeToGroupMapping(new Map<Id, Attribute_Group_Mapping__c>{attributeList[0].Id => attributeList[0]});
        MPP_Class_HLPR_AddGroupsToUser_Advanced.insertAttributeToGroupMapping(attrMap, accSet);
        MPP_Class_HLPR_AddGroupsToUser_Advanced.convertMultiSelectToSet('Executive;Authorized');
        MPP_Class_HLPR_AddGroupsToUser_Advanced.InserttoAccountToGroupMapObj(accSet);
        MPP_Class_HLPR_AddGroupsToUser_Advanced.handleAcctIdsThroughBatch(accSet);
        MPP_Class_HLPR_AddGroupsToUser_Advanced.getPCTechSubSegs();
    }
    
    //Code coverage for inner class properties
    static testMethod void innerClassTest() {
        Attribute_Group_Mapping__c newAttr1 = new Attribute_Group_Mapping__c(Application_Specialization__c = 'Business Radio',
                                                                            Application_Specialization_Level__c = 'Specialist',
                                                                            Community__c = 'Application Partner',
                                                                            Country1__c = 'Austria',
                                                                            Language__c = 'English',
                                                                            Market_Specialization__c = 'US Federal',
                                                                            Market_Specialization_Level__c = 'Authorized',
                                                                            Program_Level__c = 'gold',
                                                                            Purchasing_Method__c = 'Tier 1',
                                                                            Region__c = 'NAMR',
                                                                            Role__c = 'Executive',
                                                                            Sales_View_Upload_Mode__c = 'DLS',
                                                                            Technology_Sub_Segment__c = 'Wave on Cloud',
                                                                            CASPA_groups__c = 'Connect Adv Partner',
                                                                            Technology_Specialization__c = 'Business Radio',
                                                                            Technology_Specialization_Level__c = 'Authorized',
                                                                            Group__c = 'PC-NAMR-XXX-XXXX-XXXXX-XXXX-X-XX');
        insert newAttr1;
        MPP_Class_HLPR_AddGroupsToUser_Advanced.CustomAGM innerClassRef = new MPP_Class_HLPR_AddGroupsToUser_Advanced.CustomAGM(newAttr1);
        Set<String> appSet = innerClassRef.applicationLevelSet;
        Set<String> techSet = innerClassRef.techSpecSet;
        Set<String> techLevelSet = innerClassRef.technologyLevelSet;
        Set<String> commLevelSet = innerClassRef.communityLevelSet;
        Set<String> marketLevelSet = innerClassRef.marketLevelSet;
        Set<String> pgrmLevelSet = innerClassRef.programLevelSet;
        Set<String> purLevelSet = innerClassRef.purchasingLevelSet;
        Set<String> cntrySet = innerClassRef.countrySet;
        Set<String> caspagrpSet = innerClassRef.CASPAgroupSet;
        Set<String> techsubsegmentSet = innerClassRef.techSubSegmentSet;
    }

    static testMethod void testContinueProcessing() {
        List<Account> accList = MPP_TEST_Class_AddGroupsToUser_Advanced.createAccounts();
        MPP_Class_HLPR_AddGroupsToUser_Advanced.continueProcessing(new Attribute_to_Group_Processing__c(Account_Id_Set__c = accList[0].Id));
    }
    
    //Testing MPP_Class_AddGroupsToUserInBulkBatch class
    static testmethod void testBatchProcessing() {
        List<Account> accList = MPP_TEST_Class_AddGroupsToUser_Advanced.createAccounts();
        Set<Id> accSet = new Set<Id>();
        for(Account eachAcc : accList) {
            accSet.add(eachAcc.id);
        }
        MPP_Class_AddGroupsToUserInBulkBatch batchInstance = new MPP_Class_AddGroupsToUserInBulkBatch(accSet);
        MPP_Class_HLPR_AddGroupsToUser_Advanced.InserttoAccountToGroupMapObj(accSet);
        MPP_Class_HLPR_AddGroupsToUser_Advanced.handleAcctIds(accSet);
        MPP_Class_HLPR_AddGroupsToUser_Advanced.handleAcctIdsThroughBatch(accSet);
    }
    
    //Testing TechnologySubSegment Trigger event
    static testMethod void test_MPP_TRG_AddGroupsToUser_TechSubSeg() {
        List<Account> accList = MPP_TEST_Class_AddGroupsToUser_Advanced.createAccounts();
        List<Technology_Specialization__c> progrmDetailRecs = MPP_TEST_Class_AddGroupsToUser_Advanced.createProgramDetailRecs();
        Technology_SubSegment__c techSubSegment = new Technology_SubSegment__c(Account__c=accList[0].Id,
                                                                               Program_Detail__c=progrmDetailRecs[0].Id,
                                                                               Segment__c='Professional and Commercial Radio',
                                                                               Sub_Segment__c='Professional and Commercial Radio');
        Test.startTest();
        try{
            insert techSubSegment;
            //Noting to assert, just testing trigger execution. Helper logic is tested in another test class.
        }catch (System.exception e){
            System.debug('ERROR: ' + e.getMessage());
        }
        Test.stopTest();
    }
}