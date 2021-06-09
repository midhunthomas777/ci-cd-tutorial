@isTest
private class AccountMCNTriggerHanlder_test{
    
    @testSetup
    static void testSetUp() {
        TestDataSetUpUtils.insertCustomSettings();
    }
    
    static{
        
        
        TriggerDeactivateSwitch__c switch1 = new TriggerDeactivateSwitch__c();
        switch1.Name = 'AccountUpdateRelatedMCNTrigger';
        switch1.IsTriggerActive__c = true;
        insert switch1;
        
        
    }
    static testMethod void AccountInsert1() 
    {
        
        List<Account> aclist=new List<Account>();
        List<Account> acParent=new List<Account>();
        List<Account> acChild=new List<Account>();
        List<String> mergelist=new list<String>(); 
        Test.startTest();       
        RecordType rt1 = [select Id from RecordType where SObjectType='Account' and DeveloperName='Prospect' limit 1]; 
        RecordType rmcn2 = [select Id from RecordType where SObjectType='Account' and Name='Motorola Customer Number' limit 1];
        Account Pacc1= new Account(Name = 'TestParent1',
                                   RecordTypeId = rt1.Id , 
                                   CurrencyIsoCode ='USD',
                                   BillingCountry = 'United States',
                                   Primary_County__c= 'Australia',
                                   BillingState= 'New York',
                                   BillingCity = 'New York',
                                   BillingStreet= 'test',
                                   MCN_Account_Number__c=string.valueof(integer.valueof(math.random()*10000)*100), 
                                   BillingPostalCode = '112004',
                                   Billing_County__c='Test'
                                  );
        acParent.add(Pacc1);
        Account Pacc2= new Account(Name = 'TestParent2',
                                   RecordTypeId = rt1.Id , 
                                   CurrencyIsoCode ='USD',
                                   BillingCountry = 'United States',
                                   Primary_County__c= 'Australia',
                                   BillingState= 'New York',
                                   BillingCity = 'New York',
                                   BillingStreet= 'test', 
                                   BillingPostalCode = '112004',
                                   Billing_County__c='Test'
                                  );
        acParent.add(Pacc2);
        insert acParent;
        Account Chilacc1=new Account(
            Name = 'MCN1',
            ParentId=acParent[0].Id,
            RecordTypeId = rmcn2.Id , 
            CurrencyIsoCode ='USD',
            Primary_Route_to_Market__c='',
            Motorola_Customer_Number__c =string.valueof(integer.valueof(math.random()*10000)*100),
            ERP_Active__c=true
        );
        acChild.add(Chilacc1);
        
        Account Chilacc2=new Account(
            Name = 'MCN1',
            ParentId=acParent[1].Id,
            RecordTypeId = rmcn2.Id , 
            CurrencyIsoCode ='USD',
            Primary_Route_to_Market__c='Partner Led',
            Motorola_Customer_Number__c =string.valueof(integer.valueof(math.random()*10000)*100),
            ERP_Active__c=true
        );
        acChild.add(Chilacc2);
        
        insert acChild;
        //aclist.add(acChild);
        
        Mergelist.add(Pacc2.Id);
        
        AccountMCNTriggerHandler.onBeforeInsert(acChild);
        AccountMCNTriggerHandler.onMergeAccount(Mergelist);
        Test.stopTest();
    }
    static testMethod void AccountUpdate1() 
    {
        Database.DMLOptions dml = new Database.DMLOptions();
	 	dml.DuplicateRuleHeader.AllowSave = true;
        Test.startTest();
        List<account> achildlist=new list<account>();  
        // List<String> mergelist=new list<String>();     
        RecordType rt1 = [select Id from RecordType where SObjectType='Account' and DeveloperName='Prospect' limit 1]; 
        RecordType rmcn2 = [select Id from RecordType where SObjectType='Account' and Name='Motorola Customer Number' limit 1];
        Account Pacc1= new Account(Name = 'TestParent3',
                                   RecordTypeId = rt1.Id , 
                                   CurrencyIsoCode ='USD',
                                   BillingCountry = 'United States',
                                   Primary_County__c= 'Australia',
                                   BillingState= 'New York',
                                   BillingCity = 'New York',
                                   BillingStreet= 'test',
                                   // MCN_Account_Number__c='123 (Active)', 
                                   MCN_Account_Number__c=string.valueof(integer.valueof(math.random()*1000000000)*100),
                                   BillingPostalCode = '112004',
                                   Billing_County__c='Test'
                                  );
        insert Pacc1;
        
        Account Pacc2= new Account(Name = 'TestParent4',
                                   RecordTypeId = rt1.Id , 
                                   CurrencyIsoCode ='USD',
                                   BillingCountry = 'United States',
                                   Primary_County__c= 'Australia',
                                   BillingState= 'New York',
                                   BillingCity = 'New York',
                                   BillingStreet= 'test',
                                   MCN_Account_Number__c=string.valueof(integer.valueof(math.random()*1000000000)*100), 
                                   BillingPostalCode = '112004',
                                   Billing_County__c='Test'
                                  );
        Database.insert(Pacc2,dml);
        
        Account Chilacc1=new Account(
            Name = 'MCN1',
            ParentId=Pacc1.Id,
            RecordTypeId = rmcn2.Id , 
            CurrencyIsoCode ='USD',
            Primary_Route_to_Market__c='',
            Motorola_Customer_Number__c =string.valueof(integer.valueof(math.random()*100000)*100),
            ERP_Active__c=true
        );
        
        
        insert Chilacc1;
        AccountMCNTriggerHandler.run=True;
        // Test.stopTest();
        // Test.startTest();
        list<account> accupdatelist=new list<account>();
        List<Account> accinsertlist=new List<Account>();
        system.assertEquals(Pacc1.id,Chilacc1.parentID);
        //achildlist.add(Chilacc1);
        
        Account childacc2 = new Account();
        childacc2.id=chilacc1.id;
        childacc2.Motorola_Customer_Number__c =string.valueof(integer.valueof(math.random()*100000)*100);
        childacc2.Primary_Route_to_Market__c='';  
        childacc2.ERP_Active__c=false; 
        childacc2.parentID=Pacc2.id ;    
        update childacc2;
        system.debug('accupdatelist===>'+accupdatelist);
        AccountMCNTriggerHandler.run=True;
        delete childacc2;
        //  accinsertlist.add(Chilacc1);
        //insert accinsertlist;
        //  system.debug('accinsertlist===>'+accinsertlist);
        
        // for(Account acc:accinsertlist)
        // {
        // acc.parentId=Pacc2.Id;
        //  accupdatelist.add(acc);
        //  }
        
        //accupdatelist.addAll(accinsertlist);
        // update accupdatelist;
        //system.debug('accupdatelist===>'+accupdatelist);
        // AccountMCNTriggerHanlder.onAfterUpdate(accupdatelist);
        Test.stopTest();
        
        
    }  
    
    static testMethod void AccountUpdate2() 
    {
        
        Test.startTest();
        Database.DMLOptions dml = new Database.DMLOptions();
	 	dml.DuplicateRuleHeader.AllowSave = true;
        List<account> achildlist=new list<account>();  
        // List<String> mergelist=new list<String>();     
        RecordType rt1 = [select Id from RecordType where SObjectType='Account' and DeveloperName='Prospect' limit 1]; 
        RecordType rmcn2 = [select Id from RecordType where SObjectType='Account' and Name='Motorola Customer Number' limit 1];
        Account Pacc1= new Account(Name = 'TestParent5',
                                   RecordTypeId = rt1.Id , 
                                   CurrencyIsoCode ='USD',
                                   BillingCountry = 'United States',
                                   Primary_County__c= 'Australia',
                                   BillingState= 'New York',
                                   BillingCity = 'New York',
                                   BillingStreet= 'test',
                                   // MCN_Account_Number__c='123 (Active)', 
                                   MCN_Account_Number__c=string.valueof(integer.valueof(math.random()*1000000000)*100),
                                   BillingPostalCode = '112004',
                                   Billing_County__c='Test'
                                  );
        insert Pacc1;
        
        Account Pacc2= new Account(Name = 'TestParent6',
                                   RecordTypeId = rt1.Id , 
                                   CurrencyIsoCode ='USD',
                                   BillingCountry = 'United States',
                                   Primary_County__c= 'Australia',
                                   BillingState= 'New York',
                                   BillingCity = 'New York',
                                   BillingStreet= 'test',
                                   MCN_Account_Number__c=string.valueof(integer.valueof(math.random()*1000000000)*100), 
                                   BillingPostalCode = '112004',
                                   Billing_County__c='Test'
                                  );
        Database.insert(Pacc2,dml);
        
        Account Chilacc1=new Account(
            Name = 'MCN1',
            ParentId=Pacc1.Id,
            RecordTypeId = rmcn2.Id , 
            CurrencyIsoCode ='USD',
            Primary_Route_to_Market__c='',
            Motorola_Customer_Number__c ='34545354',
            ERP_Active__c=true
        );
        
        
        insert Chilacc1;
        AccountMCNTriggerHandler.run=True;
        // Test.stopTest();
        // Test.startTest();
        list<account> accupdatelist=new list<account>();
        List<Account> accinsertlist=new List<Account>();
        system.assertEquals(Pacc1.id,Chilacc1.parentID);
        //achildlist.add(Chilacc1);
        
        Account childacc2 = new Account();
        childacc2.id=chilacc1.id;
        childacc2.Motorola_Customer_Number__c =string.valueof(integer.valueof(math.random()*10000)*100);
        childacc2.Primary_Route_to_Market__c='Partner Led';  
        childacc2.ERP_Active__c=false; 
        childacc2.parentID=Pacc2.id ;    
        update childacc2;
        system.debug('accupdatelist===>'+accupdatelist);
        AccountMCNTriggerHandler.run=True;
        
        
        Test.stopTest();
        
        
    }
    
    
}