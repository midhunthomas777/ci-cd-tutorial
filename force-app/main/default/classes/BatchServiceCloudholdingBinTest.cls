@isTest
private class BatchServiceCloudholdingBinTest{
    
     @testSetup
    static void testSetUp() {
       TestDataSetUpUtils.insertCustomSettings();
    }
    static List<LM_StateCode__c> customSettings1(){
        List<LM_StateCode__c> LMSList= New List<LM_StateCode__c>();
        LM_StateCode__c LMS1= new LM_StateCode__c(Name='Alabama', State_Name__c='Alabama',Country__c = 'United States', State_Code__c = 'AL');
        LMSList.add(LMS1); 
        insert LMSList;
        return LMSList;
    }
    static CAM_Geo_Onboarding_Map__c CreateGeoMap(){
        User u = [SELECT id FROM user WHERE name='Ken Rey' LIMIT 1];
        CAM_Geo_Onboarding_Map__c CAM = new CAM_Geo_Onboarding_Map__c(State_Province__c='AL',Federal_Agency__c='Department of Defense',Community__c='test',Track__c = 'Radio',Function__c = 'Onboarding',Channel_Account_Manager__c=u.id,Territory__c='T3',Country__c='United States',County__c ='United States');
        insert CAM;
        return CAM;
    }
    static List<Account> createAccounts(){        
        Id accrectypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        List<Account> accList = new List<Account>();
        Account accnt1 = new Account(name='cusaccount1');
        accnt1.Type ='Customer';
        accnt1.RecordTypeId=accrectypeID;
        accnt1.Federal_Agency__c = 'Department of Defense';
        accnt1.BillingCity = 'Grant Park';
        accnt1.BillingCountry = 'United States';
        accnt1.BillingState = 'Alabama';
        accnt1.Billing_County__c = 'United States';
        accnt1.Billing_County__c = 'Yuma';       
        accnt1.Territory__c = '';
        acclist.add(accnt1);
        Account accnt2 = new Account(name='customerAccount2');
        accnt2.Type ='Customer';
        accnt2.RecordTypeId=accrectypeID;
        accnt2.BillingCity = 'Haskell';
        accnt2.BillingCountry = 'United States';
        accnt2.BillingState = 'California';
        accnt2.Billing_County__c = 'Bibb';
        accnt2.Territory__c = '';
        acclist.add(accnt2);
        Account accnt3 = new Account(name='accountCust3');
        accnt3.Type ='Customer';
        accnt3.RecordTypeId=accrectypeID;
        accnt3.BillingCity = 'NEW BERN';
        accnt3.BillingCountry = 'United states';
        accnt3.BillingState = 'New Jersey';
        accnt3.Region__c='NA';
        accnt3.Territory__c = 'T3';
        acclist.add(accnt3);
        
        Account accnt4 = new Account(name='newCustomerAcc4');
        accnt4.Type ='Customer';
        accnt4.RecordTypeId=accrectypeID;
        accnt4.Federal_Agency__c = 'Law Enforcement Agencies';
        accnt4.BillingCity = 'ONTARIO';
        accnt4.BillingCountry = 'United states';
        accnt4.BillingState = 'Iowa';
        accnt4.Region__c='NA';
        accnt4.Territory__c = 'T3';
        acclist.add(accnt4);
        Account accnt5 = new Account(name='cusaccount5');
        accnt5.Type ='Customer';
        accnt5.RecordTypeId=accrectypeID;
        accnt5.Federal_Agency__c = 'Department of Defense';
        accnt5.BillingCity = 'Grant Park';
        accnt5.BillingCountry = 'United States';
        accnt5.BillingState = 'Alabama';
        accnt5.Billing_County__c = 'Yuma';       
        accnt5.Territory__c = '';
        acclist.add(accnt5);
        insert acclist;
        return acclist;
    }
    static testMethod void holdingBinTest() {
        String camCountry='United States';
        String camStateCode='AL';
        String camCommunity='test';
        String camFedAgency='Department of Defense';
        String camBCounty='United states';
        String accTerritory='T3';
        String accBillingState='Alabama';
        Id rectcsid = Schema.SObjectType.Case.RecordTypeInfosByName.get('MR Customer Account Creation').RecordTypeId;
        Id rectcsupdid = Schema.SObjectType.Case.RecordTypeInfosByName.get('MR Customer Account Update').RecordTypeId;
        List<Account> accountList = BatchServiceCloudholdingBinTest.createAccounts();
        List<Case> CSList = new List<Case>();
        User CAMuser = [SELECT id FROM user WHERE name='Ken Rey' LIMIT 1];
        User Hiddenuser = [SELECT id FROM user WHERE name='Andrew Byrne' LIMIT 1];
        BatchServiceCloudholdingBinTest.customSettings1();
        LM_StateCode__c LMS = new LM_StateCode__c(name='Alabama',State_Name__c='Alabama');
        insert LMS;
        BatchServiceCloudholdingBinTest.CreateGeoMap();
        
        User u = [SELECT id FROM user WHERE name='Ken Rey' LIMIT 1];
        CAM_Geo_Onboarding_Map__c CAM1 = new CAM_Geo_Onboarding_Map__c(State_Province__c='AL',Federal_Agency__c='',Community__c='test',Track__c = 'Radio',Function__c = 'Onboarding',Channel_Account_Manager__c=u.id,Territory__c='T3',Country__c='United States',County__c ='United States');
        insert CAM1;
        Case cs3 = new case();
        cs3.Accountid = accountList[0].id;
        cs3.RecordTypeId = rectcsid;
        cs3.Status = 'New';
        cs3.ASM_Approval_Status__c = 'In Approval';
        cs3.Assigned_ASM__c=CAMuser.id;
        cs3.Hidden_CAM__c=Hiddenuser.id;
        cs3.ownerId = '00G2H000003dybY';
        CSList.add(cs3);
        insert CSList;
        
        Holding_Bin_Queue__c holdingObj = new Holding_Bin_Queue__c();
        holdingObj.name='EACCR Holding';
        holdingObj.New_QueueId__c = '00G0v0000022AcO';
        insert holdingObj;
        HoldingBinClass.performCaseUpdate(CSList);
        
        Test.startTest();
            BatchServiceCloudholdingBin  batchObj = new BatchServiceCloudholdingBin();
            Database.executeBatch(batchObj);
        Test.stopTest();
    }
}