@isTest

public class NA_product_TestClass {

    @testSetup static void setup() {
TestDataSetUpUtils.insertCustomSettings();
    }

    static testmethod void Method1() {
        Id prospectId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Prospect').getRecordTypeId();
        test.starttest();
        DeactivateOpportunityTrigger__c setting1 = new DeactivateOpportunityTrigger__c(Name = 'Deactivate OppRelatedActions', Deactivate__c = true);
        insert setting1;
        DeactivateOpportunityTrigger__c setting2 = new DeactivateOpportunityTrigger__c(Name = 'populateAccountExecutiveDeactivate', Deactivate__c = true);
        insert setting2;

        DeactivateOpportunityTrigger__c setting3 = new DeactivateOpportunityTrigger__c(Name = 'Deactivate UpdateAwardStatusValue', Deactivate__c = true);
        insert setting3;
        
        TriggerSettings__c ts = new TriggerSettings__c(Name='OpportunityTriggerDisabled',isActive__c=False);
        insert ts;

        Account Acc1 = new Account(Name = 'Test Prospect Account', billingcountry = 'United States', billingstate = 'Illinois', billingcity = 'Schaumburg', recordtypeId = prospectId);
        Insert Acc1;
        Opportunity opp1 = new Opportunity(name = 'Opp1', Account = acc1, stagename = 'Secure', closedate = System.today(), ownerid = UserInfo.getUserId(), first_ship_date__c = System.today() + 1, pull_forward_date__c = System.today() - 1);
        insert opp1;

        Id pricebookId = Test.getStandardPricebookId();

        // Product insertion
        Product2 pro1 = new Product2(name = 'A8', description = 'Radio', NA_Alternate_Product_Hierarchy__c = 'SI');
        insert pro1;
        Product2 pro2 = new Product2(name = 'A8', description = 'Radio', NA_Alternate_Product_Hierarchy__c = 'LCS');
        insert pro2;

        // end

        PricebookEntry pbEntry = new PricebookEntry(
            Pricebook2Id = pricebookId,
            Product2Id = pro2.Id,
            UnitPrice = 100.00,
            IsActive = true
        );
        insert pbEntry;

        PricebookEntry pbEntry2 = new PricebookEntry(
            Pricebook2Id = pricebookId,
            Product2Id = pro1.Id,
            UnitPrice = 100.00,
            IsActive = true
        );
        insert pbEntry2;


        OpportunityLineItem oli = new OpportunityLineItem(
            OpportunityId = opp1.Id,
            Quantity = 5,
            PricebookEntryId = pbEntry.Id,
            TotalPrice = 100
        );
        insert oli;
        OpportunityLineItem oli2 = new OpportunityLineItem(
            OpportunityId = opp1.Id,
            Quantity = 5,
            PricebookEntryId = pbEntry2.Id,
            TotalPrice = 100
        );
        insert oli2;


        test.stoptest();
    }
    static testmethod void Method2() {
        Id prospectId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Prospect').getRecordTypeId();
        test.starttest();
        DeactivateOpportunityTrigger__c setting1 = new DeactivateOpportunityTrigger__c(Name = 'Deactivate OppRelatedActions', Deactivate__c = true);
        insert setting1;

        DeactivateOpportunityTrigger__c setting2 = new DeactivateOpportunityTrigger__c(Name = 'populateAccountExecutiveDeactivate', Deactivate__c = true);
        insert setting2;

        DeactivateOpportunityTrigger__c setting3 = new DeactivateOpportunityTrigger__c(Name = 'Deactivate UpdateAwardStatusValue', Deactivate__c = true);
        insert setting3;
        TriggerSettings__c ts = new TriggerSettings__c(Name='OpportunityTriggerDisabled',isActive__c=False);
        insert ts;

        Account Acc1 = new Account(Name = 'Test Prospect Account', billingcountry = 'United States', billingstate = 'Illinois', billingcity = 'Schaumburg', recordtypeId = prospectId);
        Insert Acc1;
        Opportunity opp1 = new Opportunity(name = 'Opp1', Account = acc1, stagename = 'Secure', closedate = System.today(), ownerid = UserInfo.getUserId(), first_ship_date__c = System.today() + 1, pull_forward_date__c = System.today() - 1);
        insert opp1;

        Id pricebookId = Test.getStandardPricebookId();
        Product2 pro3 = new Product2(name = 'A8', description = 'Radio', NA_Alternate_Product_Hierarchy__c = 'SPSS');
        insert pro3;
        PricebookEntry pbEntry3 = new PricebookEntry(
            Pricebook2Id = pricebookId,
            Product2Id = pro3.Id,
            UnitPrice = 100.00,
            IsActive = true
        );
        insert pbEntry3;
        OpportunityLineItem oli3 = new OpportunityLineItem(
            OpportunityId = opp1.Id,
            Quantity = 5,
            PricebookEntryId = pbEntry3.Id,
            TotalPrice = 100
        );
        insert oli3;
        test.stoptest();

    }
    static testmethod void Method3() {
        Id prospectId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Prospect').getRecordTypeId();
        test.starttest();
        DeactivateOpportunityTrigger__c setting1 = new DeactivateOpportunityTrigger__c(Name = 'Deactivate OppRelatedActions', Deactivate__c = true);
        insert setting1;

        DeactivateOpportunityTrigger__c setting2 = new DeactivateOpportunityTrigger__c(Name = 'populateAccountExecutiveDeactivate', Deactivate__c = true);
        insert setting2;

        DeactivateOpportunityTrigger__c setting3 = new DeactivateOpportunityTrigger__c(Name = 'Deactivate UpdateAwardStatusValue', Deactivate__c = true);
        insert setting3;
        TriggerSettings__c ts = new TriggerSettings__c(Name='OpportunityTriggerDisabled',isActive__c=False);
        insert ts;

        Account Acc1 = new Account(Name = 'Test Prospect Account', billingcountry = 'United States', billingstate = 'Illinois', billingcity = 'Schaumburg', recordtypeId = prospectId);
        Insert Acc1;
        Opportunity opp1 = new Opportunity(name = 'Opp1', Account = acc1, stagename = 'Secure', closedate = System.today(), ownerid = UserInfo.getUserId(), first_ship_date__c = System.today() + 1, pull_forward_date__c = System.today() - 1);
        insert opp1;

        Id pricebookId = Test.getStandardPricebookId();
        Product2 pro4 = new Product2(name = 'A8', description = 'Radio', NA_Alternate_Product_Hierarchy__c = 'Equipment');
        insert pro4;
        update pro4;
        
        Id pricebookId2 = Test.getStandardPricebookId();
        Product2 pro5 = new Product2(name = 'A9', description = 'Radio', NA_Alternate_Product_Hierarchy__c = 'FirstNet');
        insert pro5;
        update pro5;

        PricebookEntry pbEntry4 = new PricebookEntry(
            Pricebook2Id = pricebookId,
            Product2Id = pro4.Id,
            UnitPrice = 100.00,
            IsActive = true
        );
        insert pbEntry4;
        
        PricebookEntry pbEntry5 = new PricebookEntry(
            Pricebook2Id = pricebookId2,
            Product2Id = pro5.Id,
            UnitPrice = 100.00,
            IsActive = true);
            
            insert pbEntry5; 

        OpportunityLineItem oli4 = new OpportunityLineItem(
            OpportunityId = opp1.Id,
            Quantity = 5,
            PricebookEntryId = pbEntry4.Id,
            TotalPrice = 100
        );
        insert oli4;
        
         OpportunityLineItem oli5 = new OpportunityLineItem(
            OpportunityId = opp1.Id,
            Quantity = 5,
            PricebookEntryId = pbEntry5.Id,
            TotalPrice = 100
        );
        insert oli5;
        test.stoptest();

    }

}