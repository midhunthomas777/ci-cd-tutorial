/************************************************************************************************* 
* File Name  : PartnerOpportunityTriggerHelperTest
* Description: Test class for PartnerOpportunityTriggerHelper & PartnerOpportunityTriggerHandler 
* Modification Log 
* ============================================================================= 
*   Date               Author                         Modification 
* ---------------------------------------------------------------------------------------
* 06-Aug-2018     Vineela N(TCS)	  			Initial development
*
*************************************************************************************************/
@istest
public class PartnerOpportunityTriggerHelperTest {
    @testSetup
    static void testSetUp() {
        TestDataSetUpUtils.insertCustomSettings();
    }
    public static testMethod void Oppmethod1(){
        Id registrationRecTypeId = Schema.Sobjecttype.Opportunity.getRecordTypeInfosByName().get('Registration').getRecordTypeId();
        Id prospectId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Prospect').getRecordTypeId();
        List<Account> AccountList = TestDataSetUpUtils.createAccounts(2, prospectId);
        AccountList[0].Allowed_for_Run_Rate__c = True;
        AccountList[1].Allowed_for_Run_Rate__c = True;
        Test.startTest();
        Update AccountList[0];
        Update AccountList[1];
        //Inserting Non USD Opportunities 
        User usr = [SELECT id,name FROM user WHERE profile.name = 'EMEA Motorola Government Systems User' LIMIT 1];
        Opportunity oppty = new Opportunity();
        oppty.Name = 'testNonUSDOppty';
        oppty.recordtypeid = registrationRecTypeId;
        oppty.StageName = 'Prospect';
        oppty.CurrencyIsoCode = 'INR';
        oppty.closedate = System.Today().addYears(3);
        oppty.AccountId = AccountList[0].Id;
        oppty.Status__c = 'Active';
        oppty.Approval_Status__c = 'Approved';
        oppty.RCAM_ASL__c = usr.id;
        insert oppty;
        delete oppty;
        undelete oppty;
        
        Test.stopTest();
        
        
    }
    public static testMethod void Oppmethod2(){
        Try{
            Id registrationRecTypeId = Schema.Sobjecttype.Opportunity.getRecordTypeInfosByName().get('Registration').getRecordTypeId();
            Id prospectId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Prospect').getRecordTypeId();
            List<Account> AccountList = TestDataSetUpUtils.createAccounts(2, prospectId);
            AccountList[0].Allowed_for_Run_Rate__c = True;
            AccountList[1].Allowed_for_Run_Rate__c = True;
            Test.startTest();
            Update AccountList[0];
            Update AccountList[1];
            //Inserting Non USD Opportunities 
            User usr = [SELECT id,name FROM user WHERE profile.name = 'EMEA Motorola Government Systems User' LIMIT 1];
            //user partnusr = [SELECT id,name FROM User WHERE profile.name = 'EMS Partner Administrator Profile NAMR' AND isactive = TRUE LIMIT 1];
            //System.runas(partnusr) {
            Opportunity oppty = new Opportunity();
            oppty.Name = 'testNonUSDOppty';
            oppty.recordtypeid = registrationRecTypeId;
            oppty.StageName = 'Prospect';
            oppty.CurrencyIsoCode = 'INR';
            oppty.closedate = System.Today().addYears(3);
            oppty.AccountId = AccountList[0].Id;
            oppty.Status__c = 'Active';
            oppty.Approval_Status__c = 'Waiting Approval';
            oppty.region__c = 'NA';
            oppty.Country__c = 'United States';
            oppty.State__c = 'Alabama';
            oppty.Territory__c = 'T1';
            oppty.RCAM_ASL__c = usr.id;
            //oppty.OwnerId = partnusr.id;
            insert oppty;
            oppty.Approval_Status__c = 'PIC Approved';
            oppty.RCAM_ASL__c = NULL;
            update oppty;
        }
        catch(System.DmlException e) {
            System.debug('Message:Message: Please update Assigned CAM and RCAM/ASL before approval');
        }
        Test.stopTest();
        //}
    }
    public static testMethod void Oppmethod3(){
        Try{
            Id registrationRecTypeId = Schema.Sobjecttype.Opportunity.getRecordTypeInfosByName().get('Registration').getRecordTypeId();
            Id prospectId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Prospect').getRecordTypeId();
            List<Account> AccountList = TestDataSetUpUtils.createAccounts(2, prospectId);
            AccountList[0].Allowed_for_Run_Rate__c = True;
            AccountList[1].Allowed_for_Run_Rate__c = True;
            Test.startTest();
            Update AccountList[0];
            Update AccountList[1];
            //Inserting Non USD Opportunities 
            //User u123 = [SELECT id,name FROM User WHERE Profile.name = 'EA Partner Profile' and ISactive = TRUE LIMIT 1];
            User u123 = [SELECT id,name FROM user WHERE profile.name = 'EMEA Motorola Government Systems User' LIMIT 1];
            //User usr = [SELECT id,name FROM user WHERE profile.name = 'EMEA Motorola Government Systems User' LIMIT 1];
            Opportunity oppty = new Opportunity();
            oppty.Name = 'testNonUSDOppty';
            oppty.recordtypeid = registrationRecTypeId;
            oppty.StageName = 'Prospect';
            oppty.CurrencyIsoCode = 'INR';
            oppty.closedate = System.Today().addYears(3);
            oppty.AccountId = AccountList[0].Id;
            oppty.Status__c = 'Active';
            oppty.Approval_Status__c = 'PIC Approved';
            oppty.region__c = 'NA';
            oppty.Country__c = 'United states';
            oppty.State__c = 'Alaska';
            oppty.Territory__c = 'T2';
            //oppty.RCAM_ASL__c = usr.id;
            oppty.ownerId = u123.Id;
            oppty.Is_the_end_user_an_existing_MSI_Customer__c = 'YES';
            insert oppty;
            oppty.Approval_Status__c = 'CAM Approved';
            oppty.Is_the_end_user_an_existing_MSI_Customer__c = '';
            
            update oppty;
        }
        catch(System.DmlException e) {
            System.debug('Message:Please update Internal questionnaire section before approval');
        }
        Test.stopTest();
        
    }
    
    public static testMethod void Oppmethod4(){
        /*Opportunity_Management_RecordType__c oppDetail = new Opportunity_Management_RecordType__c();
oppDetail.RecordTypeID__c = '01280000000M0qOAAS';
oppdetail.NotYetKnownAccountAPAC__c = '0018000001HIg3xAAD';
insert oppDetail;*/
        Opportunity_Management_RecordType__c oppDetail = Opportunity_Management_RecordType__c.getOrgDefaults();
        Id registrationRecTypeId = Schema.Sobjecttype.Opportunity.getRecordTypeInfosByName().get('Registration').getRecordTypeId();
        Id prospectId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Prospect').getRecordTypeId();
        List<Account> AccountList = TestDataSetUpUtils.createAccounts(2, prospectId);
        Test.startTest();
        //Inserting Non USD Opportunities
        Try{ 
            User usr =  [SELECT id,name FROM user WHERE profile.name = 'EMEA Motorola Government Systems User' LIMIT 1];
            //User usr = [SELECT id,name FROM user WHERE profile.name = 'EMEA Motorola Government Systems User' LIMIT 1];
            //user partnusr = [SELECT id,name FROM User WHERE profile.name = 'EMS Partner Administrator Profile NAMR' AND isactive = TRUE LIMIT 1];
            Opportunity oppty = new Opportunity();
            oppty.Name = 'testNonUSDOppty';
            oppty.recordtypeid = registrationRecTypeId;
            oppty.StageName = 'Prospect';
            oppty.CurrencyIsoCode = 'INR';
            oppty.closedate = System.Today().addYears(3);
            oppty.AccountId = AccountList[0].Id;
            oppty.Status__c = 'Active';
            oppty.Approval_Status__c = 'Waiting Approval';
            insert oppty;
            oppty.Approval_Status__c = 'PIC Approved';
            oppty.AccountId = oppDetail.NotYetKnownAccountAPAC__c;
            update oppty;
        }
        catch(System.DmlException e) {
            System.debug('Message:Please update Customer Account before approval');
        }
        Test.stopTest();
    }
    public static testMethod void Oppmethod5(){
        Try{
            Opportunity_Management_RecordType__c oppDetail = Opportunity_Management_RecordType__c.getOrgDefaults();
            Id registrationRecTypeId = Schema.Sobjecttype.Opportunity.getRecordTypeInfosByName().get('Registration').getRecordTypeId();
            Id prospectId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Prospect').getRecordTypeId();
            List<Account> AccountList = TestDataSetUpUtils.createAccounts(2, prospectId);
            
            Id pricebookId = Test.getStandardPricebookId();
            List<Product2> pdtList = new List<Product2>();
            Product2 prd1 = new Product2 (ECW_shortcut__c=true,Personal_Information__c='Yes',Name='Test Product Entry 1',Run_Rate_Product_Group__c = 'EMEA Business Light',
                                          Description='Test Product Entry 1',productCode = 'ABC', isActive = true, Channel_Region_Subscription__c='EA');
            pdtList.add(prd1);
            insert pdtList;
            List<PricebookEntry> priceBkList = new List<PricebookEntry>();
            PricebookEntry pbe1 = new PricebookEntry (Product2ID=pdtList[0].id,Pricebook2ID=pricebookId,UnitPrice=80000, isActive=true,CurrencyIsoCode='INR');
            priceBkList.add(pbe1);
            insert priceBkList;
            
            
            Test.startTest();
            //Inserting Non USD Opportunities 
            User usr = [SELECT id,name FROM user WHERE profile.name = 'EMEA Motorola Government Systems User' LIMIT 1];
            user partnusr = [SELECT id,name FROM User WHERE profile.name = 'EMS Partner Administrator Profile NAMR' AND isactive = TRUE LIMIT 1];
            Opportunity oppty = new Opportunity();
            oppty.Name = 'testNonUSDOppty';
            oppty.recordtypeid = registrationRecTypeId;
            oppty.StageName = 'Prospect';
            oppty.CurrencyIsoCode = 'INR';
            oppty.closedate = System.Today().addYears(3);
            oppty.AccountId = AccountList[0].Id;
            oppty.Status__c = 'Active';
            //oppty.Approval_Status__c = 'Waiting Approval';
            insert oppty;
            OpportunityLineItem lineItem1 = new OpportunityLineItem (OpportunityID=oppty.id,PriceBookEntryID=priceBkList[0].id,UnitPrice=80000, quantity=4);
            insert lineItem1;
            
            oppty.Approval_Status__c = 'Waiting Approval';
            oppty.AccountId = oppDetail.NotYetKnownAccountAPAC__c;
            oppty.Rejected_By__c = 'PIC';
            update oppty;
            Test.stopTest();
        } catch(System.DmlException e) {
            System.debug('Message:lease update Customer Account before rejecting');
        }
    }
    
    public static testMethod void Oppmethod7(){
        Try{
            Id registrationRecTypeId = Schema.Sobjecttype.Opportunity.getRecordTypeInfosByName().get('Registration').getRecordTypeId();
            Id prospectId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Prospect').getRecordTypeId();
            List<Account> AccountList = TestDataSetUpUtils.createAccounts(2, prospectId);
            AccountList[0].Allowed_for_Run_Rate__c = True;
            AccountList[1].Allowed_for_Run_Rate__c = True;
            Test.startTest();
            Update AccountList[0];
            Update AccountList[1];
            //Inserting Non USD Opportunities 
            //User u123 = [SELECT id,name FROM User WHERE Profile.name = 'EA Partner Profile' and ISactive = TRUE LIMIT 1];
            User u123 = [SELECT id,name FROM user WHERE profile.name = 'EMEA Motorola Government Systems User' LIMIT 1];
            //User usr = [SELECT id,name FROM user WHERE profile.name = 'EMEA Motorola Government Systems User' LIMIT 1];
            OpportunityTriggerHandler.TriggerDisabled = true;
            Opportunity oppty = new Opportunity();
            oppty.Name = 'testNonUSDOppty';
            oppty.recordtypeid = registrationRecTypeId;
            oppty.StageName = 'Prospect';
            oppty.CurrencyIsoCode = 'INR';
            oppty.closedate = System.Today().addYears(3);
            oppty.AccountId = AccountList[0].Id;
            oppty.Status__c = 'Active';
            oppty.Approval_Status__c = 'Waiting Approval';
            oppty.region__c = 'NA';
            oppty.Country__c = 'United states';
            oppty.State__c = 'Alaska';
            oppty.Territory__c = 'T2';
            //oppty.RCAM_ASL__c = usr.id;
            oppty.ownerId = u123.Id;
            oppty.Is_the_end_user_an_existing_MSI_Customer__c = 'YES';
            insert oppty;
            oppty.Approval_Status__c = 'Waiting Approval';
            update oppty;
            system.debug('oppty.Approval_Status__c '+oppty.Approval_Status__c );
            oppty.Approval_Status__c = 'PIC Approved';
            oppty.Is_the_end_user_an_existing_MSI_Customer__c = '';
            oppty.Assigned_CAM__c = NULL;
            update oppty;
            system.debug('oppty.Approval_Status__c '+oppty.Approval_Status__c );
            system.debug('oppty.Assigned_CAM__c '+oppty.Assigned_CAM__c );
        }
        catch(System.DmlException e) {
            System.debug('Message:Please update Internal questionnaire section before approval');
        }
        Test.stopTest();
        
    }
}