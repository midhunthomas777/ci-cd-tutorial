/*  
* File Name     : ADPFindDuplicatesExtensionTest
* Description   : Test class for ADPFindDuplicatesExtension
* Modification Log
* =============================================================================
*   Ver     Date         Author                      Modification
*------------------------------------------------------------------------------
*   1.0     21-Feb-17   Poongodi V               Initial creation
*   2.0     1-Mar-17   Poongodi V                Added Methods to cover the Matching Account scenarios
*/
@isTest

public class ADPFindDuplicatesExtensionTest{
 @testSetup
   static void testSetUp() {
       TestDataSetUpUtils.insertCustomSettings();
   }

 public static List<TriggerDeactivateSwitch__c> createADPCustomSetting() {
        List<TriggerDeactivateSwitch__c> adpsettingList = new List<TriggerDeactivateSwitch__c>();
        TriggerDeactivateSwitch__c adpSetting1 = new TriggerDeactivateSwitch__c();
        adpSetting1.Name = 'AccountUpdateRelatedMCNTrigger';
        adpSetting1.IsTriggerActive__c= true;
        adpsettingList.add(adpSetting1);
        
        Database.insert(adpsettingList,false);
        return adpsettingList;
        }
        

//Test to cover the Matching scenario: Company Name having more than one word and the starting word starts with 'The' 
private static testMethod void doTest1() {

Test.startTest();
         List<TriggerDeactivateSwitch__c> adpCustomSettings = ADPFindDuplicatesExtensionTest.createADPCustomSetting();
        ADP_Global_Account_Name__c NewADPGlobalAccName= new ADP_Global_Account_Name__c();
        NewADPGlobalAccName.Name='testRun';
        NewADPGlobalAccName.GitLab_Group_Id__c=815;
        insert NewADPGlobalAccName;
                
        ID ADPRTypeID = Schema.SObjectType.ADP_Registration__c.RecordTypeInfosByName.get('ADP').RecordTypeId;
        ADP_Registration__c NewADPReg= new ADP_Registration__c();
        NewADPReg.recordtypeId=ADPRTypeID;
        NewADPReg.Applicant_First_Name__c='TestRun1';
        NewADPReg.Applicant_Last_Name__c='Test2';
        NewADPReg.Company_Name__c='The Test run';
        NewADPReg.Company_Website__c='www.test.com';
        NewADPReg.Technology_Segment_Interest__c='ASTRO'; 
        NewADPReg.ADP_Global_Account_Name1__c=NewADPGlobalAccName.Id;     
        NewADPReg.Application_Status__c='Approved - ADP Lead';
        NewADPReg.City_Town__c='Test City';
        NewADPReg.Country__c='United States';
        NewADPReg.zipcode__c='600122';
        NewADPReg.Applicant_State_Province__c='Illinois';
        NewADPReg.Street_Address_1__c='Street 1';
        NewADPReg.Address_Line_2__c='Street 2';
        NewADPReg.Region_Requested__c='North America';
        NewADPReg.Is_New_Account_Created__c=false;
        insert NewADPReg;
   
         RecordType theRecordType = [Select Id from RecordType where Name='Partner' and SobjectType='Account' limit 1];
        Account NewAcc=new Account();
        NewAcc.recordtypeId=theRecordType.Id;
        NewAcc.Name=NewADPReg.Company_Name__c;
        NewAcc.ADP_Global_Account_Name1__c=NewADPReg.ADP_Global_Account_Name1__c;
        NewAcc.ADP_Technology_Segment__c=NewADPReg.Technology_Segment_Interest__c;
        NewAcc.Company_Tax_Registration_ID__c=NewADPReg.Company_Registration_Number__c;
        NewAcc.BillingStreet=NewADPReg.Street_Address_1__c+' '+NewADPReg.Address_Line_2__c;
        NewAcc.BillingCity=NewADPReg.City_Town__c;
        NewAcc.BillingState=NewADPReg.Applicant_State_Province__c;
        NewAcc.BillingCountry =NewADPReg.Country__c;
        NewAcc.BillingPostalCode=String.Valueof(NewADPReg.zipcode__c);
        NewAcc.ADP_Partner__c=true;
        NewAcc.Hierarchy_Placement__c='Regional Account';
        NewAcc.MPE_Program_Status_New__c='Active';
        NewAcc.Partner_Region__c='NAMR';
        NewAcc.Metal_Level__c='Registered';
        Insert NewAcc;
        
         Account[] TAcc=[Select Id,Partner_Membership_ID__c from Account where Id=:NewAcc.Id limit 1];
        NewADPReg.Partner_Account__c =NewAcc.Id;
        NewADPReg.Existing_Partner_Membership_ID__c=TAcc[0].Partner_Membership_ID__c;
        Upsert NewADPReg;
        
        PageReference pageRef = Page.ADPFindDuplicates;
        Test.setCurrentPage(pageRef);

        pageRef.getParameters().put('Id', String.valueOf(NewADPReg.Id));
        ApexPages.StandardController sc = new ApexPages.StandardController(NewADPReg);
        ADPFindDuplicatesExtension testAccPlan = new ADPFindDuplicatesExtension(sc);
         testAccPlan.TrueFlag = true; 
         boolean testTrueFlag = testAccPlan.TrueFlag;
         
         testAccPlan.SelGrpName = NewAcc.ADP_Global_Account_Name1__c;
         String testSelGrpName = testAccPlan.SelGrpName;
         testAccPlan.OrgGrpName = NewADPReg.ADP_Global_Account_Name1__c;
         String testOrgGrpName = testAccPlan.OrgGrpName;
        testAccPlan.CreateNewAccount();
            
        
        boolean SelectedAcc= true;
        String GroupName=NewADPReg.Company_Registration_Number__c;

        List<ADPFindDuplicatesExtension.ADPFindDupAccWrapper> lstSetController=new List<ADPFindDuplicatesExtension.ADPFindDupAccWrapper>();
        
        lstSetController.add(new ADPFindDuplicatesExtension.ADPFindDupAccWrapper(true,NewAcc,GroupName));
        lstSetController.add(new ADPFindDuplicatesExtension.ADPFindDupAccWrapper(false,NewAcc,GroupName));
                
        ADPFindDuplicatesExtension.ADPFindDupCustomIterable newPBE= new ADPFindDuplicatesExtension.ADPFindDupCustomIterable(lstSetController);
        newPBE.setPageSize = 1;
        Boolean Previous=newPBE.hasPrevious();
        Boolean next=newPBE.hasNext();
        testAccPlan.previous();
        testAccPlan.next();
        newPBE.next();
        newPBE.previous();

        testAccPlan.AttachAccount();
    Test.stopTest();
        
}

    private static testMethod void doTest123() {

Test.startTest();
         List<TriggerDeactivateSwitch__c> adpCustomSettings = ADPFindDuplicatesExtensionTest.createADPCustomSetting();
        ADP_Global_Account_Name__c NewADPGlobalAccName= new ADP_Global_Account_Name__c();
        NewADPGlobalAccName.Name='testRun';
        NewADPGlobalAccName.GitLab_Group_Id__c=815;
        insert NewADPGlobalAccName;
                
        ID ADPRTypeID = Schema.SObjectType.ADP_Registration__c.RecordTypeInfosByName.get('ADP').RecordTypeId;
        ADP_Registration__c NewADPReg= new ADP_Registration__c();
        NewADPReg.recordtypeId=ADPRTypeID;
        NewADPReg.Applicant_First_Name__c='TestRun1';
        NewADPReg.Applicant_Last_Name__c='Test2';
        NewADPReg.Company_Name__c='The Test run';
        NewADPReg.Company_Website__c='www.test.com';
        NewADPReg.Technology_Segment_Interest__c='ASTRO'; 
        //NewADPReg.ADP_Global_Account_Name1__c=NewADPGlobalAccName.Id;     
        NewADPReg.Application_Status__c='Submit';
        NewADPReg.Approval_Status__c = 'Pending';
        NewADPReg.City_Town__c='Test City';
        NewADPReg.Country__c='United States';
        NewADPReg.zipcode__c='600122';
        NewADPReg.Applicant_State_Province__c='Illinois';
        NewADPReg.Street_Address_1__c='Street 1';
        NewADPReg.Address_Line_2__c='Street 2';
        NewADPReg.Region_Requested__c='North America';
        NewADPReg.Is_New_Account_Created__c=false;
        insert NewADPReg;
        NewADPReg.Application_Status__c = 'Approved - ADP Lead';
        Try {
            update NewADPReg;
        }
        Catch(Exception e) {
            System.debug('err' +e.getMessage());

        }
    Test.stopTest();
        
}
    private static testMethod void doTest1234() {

Test.startTest();
         List<TriggerDeactivateSwitch__c> adpCustomSettings = ADPFindDuplicatesExtensionTest.createADPCustomSetting();
        ADP_Global_Account_Name__c NewADPGlobalAccName= new ADP_Global_Account_Name__c();
        NewADPGlobalAccName.Name='testRun';
        NewADPGlobalAccName.GitLab_Group_Id__c=815;
        insert NewADPGlobalAccName;
                
        ID ADPRTypeID = Schema.SObjectType.ADP_Registration__c.RecordTypeInfosByName.get('ADP').RecordTypeId;
        ADP_Registration__c NewADPReg= new ADP_Registration__c();
        NewADPReg.recordtypeId=ADPRTypeID;
        NewADPReg.Applicant_First_Name__c='TestRun1';
        NewADPReg.Applicant_Last_Name__c='Test2';
        NewADPReg.Company_Name__c='The Test run';
        NewADPReg.Company_Website__c='www.test.com';
        NewADPReg.Technology_Segment_Interest__c='ASTRO'; 
        //NewADPReg.ADP_Global_Account_Name1__c=NewADPGlobalAccName.Id;     
        NewADPReg.Application_Status__c='Submit';
        NewADPReg.Approval_Status__c = 'Pending';
        NewADPReg.City_Town__c='Test City';
        NewADPReg.Country__c='United States';
        NewADPReg.zipcode__c='600122';
        NewADPReg.Applicant_State_Province__c='Illinois';
        NewADPReg.Street_Address_1__c='Street 1';
        NewADPReg.Address_Line_2__c='Street 2';
        NewADPReg.Region_Requested__c='North America';
        NewADPReg.Is_New_Account_Created__c=false;
        insert NewADPReg;
        NewADPReg.Application_Status__c = 'Rejected - PIC Team';
        Try {
            update NewADPReg;
        }
        Catch(Exception e) {
            System.debug('err' +e.getMessage());

        }
    Test.stopTest();
        
}
    private static testMethod void doTest12345() {

Test.startTest();
         List<TriggerDeactivateSwitch__c> adpCustomSettings = ADPFindDuplicatesExtensionTest.createADPCustomSetting();
        ADP_Global_Account_Name__c NewADPGlobalAccName= new ADP_Global_Account_Name__c();
        NewADPGlobalAccName.Name='testRun';
        NewADPGlobalAccName.GitLab_Group_Id__c=815;
        insert NewADPGlobalAccName;
                
        ID ADPRTypeID = Schema.SObjectType.ADP_Registration__c.RecordTypeInfosByName.get('ADP').RecordTypeId;
        ADP_Registration__c NewADPReg= new ADP_Registration__c();
        NewADPReg.recordtypeId=ADPRTypeID;
        NewADPReg.Applicant_First_Name__c='TestRun1';
        NewADPReg.Applicant_Last_Name__c='Test2';
        NewADPReg.Company_Name__c='The Test run';
        NewADPReg.Company_Website__c='www.test.com';
        NewADPReg.Technology_Segment_Interest__c='ASTRO'; 
        //NewADPReg.ADP_Global_Account_Name1__c=NewADPGlobalAccName.Id;     
        NewADPReg.Application_Status__c='Submit';
        NewADPReg.Approval_Status__c = 'Pending';
        NewADPReg.City_Town__c='Test City';
        NewADPReg.Country__c='United States';
        NewADPReg.zipcode__c='600122';
        NewADPReg.Applicant_State_Province__c='Illinois';
        NewADPReg.Street_Address_1__c='Street 1';
        NewADPReg.Address_Line_2__c='Street 2';
        NewADPReg.Region_Requested__c='North America';
        NewADPReg.Is_New_Account_Created__c=false;
        insert NewADPReg;
        NewADPReg.Application_Status__c = 'Approved - PIC Team';
        Try {
            update NewADPReg;
        }
        Catch(Exception e) {
            System.debug('err' +e.getMessage());

        }
    Test.stopTest();
        
}

        private static testMethod void doTest345() {

Test.startTest();
         List<TriggerDeactivateSwitch__c> adpCustomSettings = ADPFindDuplicatesExtensionTest.createADPCustomSetting();
        ADP_Global_Account_Name__c NewADPGlobalAccName= new ADP_Global_Account_Name__c();
        NewADPGlobalAccName.Name='testRun';
        NewADPGlobalAccName.GitLab_Group_Id__c=815;
        insert NewADPGlobalAccName;
                
        ID ADPRTypeID = Schema.SObjectType.ADP_Registration__c.RecordTypeInfosByName.get('ADP').RecordTypeId;
        ADP_Registration__c NewADPReg= new ADP_Registration__c();
        NewADPReg.recordtypeId=ADPRTypeID;
        NewADPReg.Applicant_First_Name__c='TestRun1';
        NewADPReg.Applicant_Last_Name__c='Test2';
        NewADPReg.Company_Name__c='The Test run';
        NewADPReg.Company_Website__c='www.test.com';
        NewADPReg.Technology_Segment_Interest__c='ASTRO'; 
        //NewADPReg.ADP_Global_Account_Name1__c=NewADPGlobalAccName.Id;     
        NewADPReg.Application_Status__c='Submit';
        NewADPReg.Approval_Status__c = 'Pending';
        NewADPReg.City_Town__c='Test City';
        NewADPReg.Country__c='United States';
        NewADPReg.zipcode__c='600122';
        NewADPReg.Applicant_State_Province__c='Illinois';
        NewADPReg.Street_Address_1__c='Street 1';
        NewADPReg.Address_Line_2__c='Street 2';
        NewADPReg.Region_Requested__c='North America';
        NewADPReg.Is_New_Account_Created__c=false;
        insert NewADPReg;
        NewADPReg.Approval_Status__c = 'Rejected';
        Try {
            update NewADPReg;
        }
        Catch(Exception e) {
            System.debug('err' +e.getMessage());

        }
    Test.stopTest();
        
}





//Test to cover the Matching scenario: Company Name is one word 
private static testMethod void doTest2() {

Test.startTest();
         List<TriggerDeactivateSwitch__c> adpCustomSettings = ADPFindDuplicatesExtensionTest.createADPCustomSetting();  
               
        ADP_Global_Account_Name__c NewADPGlobalAccName= new ADP_Global_Account_Name__c();
        NewADPGlobalAccName.Name='testRun';
        NewADPGlobalAccName.GitLab_Group_Id__c=815;
        insert NewADPGlobalAccName;
                
        ID ADPRTypeID = Schema.SObjectType.ADP_Registration__c.RecordTypeInfosByName.get('ADP').RecordTypeId;
        ADP_Registration__c NewADPReg= new ADP_Registration__c();
        NewADPReg.recordtypeId=ADPRTypeID;
        NewADPReg.Applicant_First_Name__c='TestRun1';
        NewADPReg.Applicant_Last_Name__c='Test2';
        NewADPReg.Company_Name__c='TestRun';
        NewADPReg.Company_Website__c='www.test.com';
        NewADPReg.Technology_Segment_Interest__c='ASTRO'; 
        NewADPReg.ADP_Global_Account_Name1__c=NewADPGlobalAccName.Id;     
        NewADPReg.Application_Status__c='Approved - ADP Lead';
        NewADPReg.City_Town__c='Test City';
        NewADPReg.Country__c='United States';
        NewADPReg.zipcode__c='600122';
        NewADPReg.Applicant_State_Province__c='Illinois';
        NewADPReg.Street_Address_1__c='Street 1';
        //NewADPReg.Address_Line_2__c='Street 2';
        NewADPReg.Region_Requested__c='North America';
        NewADPReg.Is_New_Account_Created__c=false;
        insert NewADPReg;
   
         RecordType theRecordType = [Select Id from RecordType where Name='Partner' and SobjectType='Account' limit 1];
        Account NewAcc=new Account();
        NewAcc.recordtypeId=theRecordType.Id;
        NewAcc.Name=NewADPReg.Company_Name__c;
        NewAcc.ADP_Global_Account_Name1__c=NewADPReg.ADP_Global_Account_Name1__c;
        NewAcc.ADP_Technology_Segment__c=NewADPReg.Technology_Segment_Interest__c;
        NewAcc.Company_Tax_Registration_ID__c=NewADPReg.Company_Registration_Number__c;
        NewAcc.BillingStreet=NewADPReg.Street_Address_1__c+' '+NewADPReg.Address_Line_2__c;
        NewAcc.BillingCity=NewADPReg.City_Town__c;
        NewAcc.BillingState=NewADPReg.Applicant_State_Province__c;
        NewAcc.BillingCountry =NewADPReg.Country__c;
        NewAcc.BillingPostalCode=String.Valueof(NewADPReg.zipcode__c);
        NewAcc.ADP_Partner__c=true;
        NewAcc.Hierarchy_Placement__c='Regional Account';
        NewAcc.MPE_Program_Status_New__c='Active';
        NewAcc.Partner_Region__c='NAMR';
        NewAcc.Metal_Level__c='Registered';
        Insert NewAcc;
        
         Account[] TAcc=[Select Id,Partner_Membership_ID__c from Account where Id=:NewAcc.Id limit 1];
        NewADPReg.Partner_Account__c =NewAcc.Id;
        NewADPReg.Existing_Partner_Membership_ID__c=TAcc[0].Partner_Membership_ID__c;
        Upsert NewADPReg;
        
        PageReference pageRef = Page.ADPFindDuplicates;
        Test.setCurrentPage(pageRef);

        pageRef.getParameters().put('Id', String.valueOf(NewADPReg.Id));
        ApexPages.StandardController sc = new ApexPages.StandardController(NewADPReg);
        ADPFindDuplicatesExtension testAccPlan = new ADPFindDuplicatesExtension(sc);
         testAccPlan.TrueFlag = true; 
         boolean testTrueFlag = testAccPlan.TrueFlag;
         
         testAccPlan.SelGrpName = NewAcc.ADP_Global_Account_Name1__c;
         String testSelGrpName = testAccPlan.SelGrpName;
         testAccPlan.OrgGrpName = NewADPReg.ADP_Global_Account_Name1__c;
         String testOrgGrpName = testAccPlan.OrgGrpName;
        testAccPlan.CreateNewAccount();
            
        
        boolean SelectedAcc= true;
        String GroupName=NewADPReg.Company_Registration_Number__c;

        List<ADPFindDuplicatesExtension.ADPFindDupAccWrapper> lstSetController=new List<ADPFindDuplicatesExtension.ADPFindDupAccWrapper>();
        
        lstSetController.add(new ADPFindDuplicatesExtension.ADPFindDupAccWrapper(true,NewAcc,GroupName));
        lstSetController.add(new ADPFindDuplicatesExtension.ADPFindDupAccWrapper(false,NewAcc,GroupName));
                
        ADPFindDuplicatesExtension.ADPFindDupCustomIterable newPBE= new ADPFindDuplicatesExtension.ADPFindDupCustomIterable(lstSetController);
        newPBE.setPageSize = 1;
        Boolean Previous=newPBE.hasPrevious();
        Boolean next=newPBE.hasNext();
        testAccPlan.previous();
        testAccPlan.next();
        newPBE.next();
        newPBE.previous();

        testAccPlan.AttachAccount();
    Test.stopTest();
        
}

//Test to cover the Matching scenario: Company Name having more than one word 
private static testMethod void doTest3() {

Test.startTest();
         List<TriggerDeactivateSwitch__c> adpCustomSettings = ADPFindDuplicatesExtensionTest.createADPCustomSetting();
                 
        ADP_Global_Account_Name__c NewADPGlobalAccName= new ADP_Global_Account_Name__c();
        NewADPGlobalAccName.Name='testRun';
        NewADPGlobalAccName.GitLab_Group_Id__c=815;
        insert NewADPGlobalAccName;
                
        ID ADPRTypeID = Schema.SObjectType.ADP_Registration__c.RecordTypeInfosByName.get('ADP').RecordTypeId;
        ADP_Registration__c NewADPReg= new ADP_Registration__c();
        NewADPReg.recordtypeId=ADPRTypeID;
        NewADPReg.Applicant_First_Name__c='TestRun1';
        NewADPReg.Applicant_Last_Name__c='Test2';
        NewADPReg.Company_Name__c='Test Run';
        NewADPReg.Company_Website__c='www.test.com';
        NewADPReg.Technology_Segment_Interest__c='ASTRO'; 
        NewADPReg.ADP_Global_Account_Name1__c=NewADPGlobalAccName.Id;     
        NewADPReg.Application_Status__c='Approved - ADP Lead';
        NewADPReg.City_Town__c='Test City';
        NewADPReg.Country__c='United States';
        NewADPReg.zipcode__c='600122';
        NewADPReg.Applicant_State_Province__c='Illinois';
        NewADPReg.Street_Address_1__c='Street 1';
        NewADPReg.Address_Line_2__c='Street 2';
        NewADPReg.Region_Requested__c='North America';
        NewADPReg.Is_New_Account_Created__c=false;
        insert NewADPReg;
   
         RecordType theRecordType = [Select Id from RecordType where Name='Partner' and SobjectType='Account' limit 1];
        Account NewAcc=new Account();
        NewAcc.recordtypeId=theRecordType.Id;
        NewAcc.Name=NewADPReg.Company_Name__c;
        NewAcc.ADP_Global_Account_Name1__c=NewADPReg.ADP_Global_Account_Name1__c;
        NewAcc.ADP_Technology_Segment__c=NewADPReg.Technology_Segment_Interest__c;
        NewAcc.Company_Tax_Registration_ID__c=NewADPReg.Company_Registration_Number__c;
        NewAcc.BillingStreet=NewADPReg.Street_Address_1__c+' '+NewADPReg.Address_Line_2__c;
        NewAcc.BillingCity=NewADPReg.City_Town__c;
        NewAcc.BillingState=NewADPReg.Applicant_State_Province__c;
        NewAcc.BillingCountry =NewADPReg.Country__c;
        NewAcc.BillingPostalCode=String.Valueof(NewADPReg.zipcode__c);
        NewAcc.ADP_Partner__c=true;
        NewAcc.Hierarchy_Placement__c='Regional Account';
        NewAcc.MPE_Program_Status_New__c='Active';
        NewAcc.Partner_Region__c='NAMR';
        NewAcc.Metal_Level__c='Registered';
        Insert NewAcc;
        
         Account[] TAcc=[Select Id,Partner_Membership_ID__c from Account where Id=:NewAcc.Id limit 1];
        NewADPReg.Partner_Account__c =NewAcc.Id;
        NewADPReg.Existing_Partner_Membership_ID__c=TAcc[0].Partner_Membership_ID__c;
        Upsert NewADPReg;
        
        PageReference pageRef = Page.ADPFindDuplicates;
        Test.setCurrentPage(pageRef);

        pageRef.getParameters().put('Id', String.valueOf(NewADPReg.Id));
        ApexPages.StandardController sc = new ApexPages.StandardController(NewADPReg);
        ADPFindDuplicatesExtension testAccPlan = new ADPFindDuplicatesExtension(sc);
         testAccPlan.TrueFlag = true; 
         boolean testTrueFlag = testAccPlan.TrueFlag;
         
         testAccPlan.SelGrpName = NewAcc.ADP_Global_Account_Name1__c;
         String testSelGrpName = testAccPlan.SelGrpName;
         testAccPlan.OrgGrpName = NewADPReg.ADP_Global_Account_Name1__c;
         String testOrgGrpName = testAccPlan.OrgGrpName;
        testAccPlan.CreateNewAccount();
            
        
        boolean SelectedAcc= true;
        String GroupName=NewADPReg.Company_Registration_Number__c;

        List<ADPFindDuplicatesExtension.ADPFindDupAccWrapper> lstSetController=new List<ADPFindDuplicatesExtension.ADPFindDupAccWrapper>();
        
        lstSetController.add(new ADPFindDuplicatesExtension.ADPFindDupAccWrapper(true,NewAcc,GroupName));
        lstSetController.add(new ADPFindDuplicatesExtension.ADPFindDupAccWrapper(false,NewAcc,GroupName));
                
        ADPFindDuplicatesExtension.ADPFindDupCustomIterable newPBE= new ADPFindDuplicatesExtension.ADPFindDupCustomIterable(lstSetController);
        newPBE.setPageSize = 1;
        Boolean Previous=newPBE.hasPrevious();
        Boolean next=newPBE.hasNext();
        testAccPlan.previous();
        testAccPlan.next();
        newPBE.next();
        newPBE.previous();

        testAccPlan.AttachAccount();
    Test.stopTest();
        
}


}