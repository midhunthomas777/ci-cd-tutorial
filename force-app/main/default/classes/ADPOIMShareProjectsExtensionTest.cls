/*  
* File Name     : ADPOIMShareProjectsExtensionTest
* Description   : Test class for ADPOIMShareProjectsExtension
* Modification Log
* =============================================================================
*   Ver     Date         Author                      Modification
*------------------------------------------------------------------------------
*   1.0     30-Dec-16    Poongodi V                  Initial Creation
*/
@isTest
public class ADPOIMShareProjectsExtensionTest{

@testSetup
    static void testSetUp() {
        TestDataSetUpUtils.insertCustomSettings();
    }

//Response with Status code 200 and has Error in the body

    public class ADPShareProjectMockHttpResponseGenerator1 implements HttpCalloutMock{
        public HTTPResponse respond(HTTPRequest request) {   
         HttpResponse response = new HttpResponse();
         response.setHeader('Content-Type', 'application/json');
         if(request.getbody().contains('{"count":"1","gitLabProjectIds":["1"],"expires_at":"2018-02-20","group_id":"815","group_access":"30"}'))
         
            response.setBody('ERROR:{"count":"1","gitLabProjectIds":["1"],"expires_at":"2018-02-20","group_id":"815","group_access":"30"}');
            response.setStatusCode(200);
         return response;
        }
    }
//Response with Status code other than 200 or 409
    public class ADPShareProjectMockHttpResponseGenerator2 implements HttpCalloutMock{
        public HTTPResponse respond(HTTPRequest request) {   
         HttpResponse response = new HttpResponse();
         response.setHeader('Content-Type', 'application/json');
         if(request.getbody().contains('{"count":"1","gitLabProjectIds":["1"],"expires_at":"2018-02-20","group_id":"815","group_access":"30"}'))
         
            response.setBody('{"count":"1","gitLabProjectIds":["1"],"expires_at":"2018-02-20","group_id":"815","group_access":"30"}');
            response.setStatusCode(300);
         return response;
        }
    }
    
    

//Test cover :  When the response status is 200 and it has Error in the body, Send Mail to the respective team
    private static testMethod void doTest1() {   
        Test.setMock(HttpCalloutMock.class, new ADPShareProjectMockHttpResponseGenerator1 ()); 
        Test.startTest();
        
        ADP_Global_Account_Name__c NewADPGlobalAccName= new ADP_Global_Account_Name__c();
        NewADPGlobalAccName.Name='testRun';
        NewADPGlobalAccName.GitLab_Group_Id__c=815;
        insert NewADPGlobalAccName;
        TriggerDeactivateSwitch__c CS = new TriggerDeactivateSwitch__c(Name='AccountUpdateRelatedMCNTrigger',IsTriggerActive__c=FALSE);
        insert CS;
        ID ADPRTypeID = Schema.SObjectType.ADP_Registration__c.RecordTypeInfosByName.get('ADP').RecordTypeId;
        ADP_Registration__c NewADPReg= new ADP_Registration__c();
        NewADPReg.recordtypeId=ADPRTypeID;
        NewADPReg.Applicant_First_Name__c='TestRun1';
        NewADPReg.Applicant_Last_Name__c='Test2';
        NewADPReg.Company_Name__c='Test company';
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

        ADP_Registration__c ADPReg1=[Select id,Applicant_First_Name__c,Applicant_Last_Name__c,Company_Name__c,Company_Website__c,Technology_Segment_Interest__c,Company_Registration_Number__c,ADP_Global_Account_Name1__c,Partner_Account__c,Application_Status__c,Existing_Partner_Membership_ID__c,City_Town__c,Country__c,zipcode__c,Applicant_State_Province__c,Street_Address_1__c,Address_Line_2__c,Has_Existing_Relationship__c,Region_Requested__c,Is_New_Account_Created__c from ADP_Registration__C where Id=:NewADPReg.Id];
        
        RecordType theRecordType = [Select Id from RecordType where Name='Partner' and SobjectType='Account' limit 1];
        Account NewAcc=new Account();
        NewAcc.recordtypeId=theRecordType.Id;
        NewAcc.Name=ADPReg1.Company_Name__c;
        NewAcc.ADP_Global_Account_Name1__c=ADPReg1.ADP_Global_Account_Name1__c;
        NewAcc.ADP_Technology_Segment__c=ADPReg1.Technology_Segment_Interest__c;
        NewAcc.Company_Tax_Registration_ID__c=ADPReg1.Company_Registration_Number__c;
        NewAcc.BillingStreet=ADPReg1.Street_Address_1__c+' '+ADPReg1.Address_Line_2__c;
        NewAcc.BillingCity=ADPReg1.City_Town__c;
        NewAcc.BillingState=ADPReg1.Applicant_State_Province__c;
        NewAcc.BillingCountry =ADPReg1.Country__c;
        NewAcc.BillingPostalCode=String.Valueof(ADPReg1.zipcode__c);
        NewAcc.ADP_Partner__c=true;
        NewAcc.Hierarchy_Placement__c='Regional Account';
        NewAcc.MPE_Program_Status_New__c='Active';
        NewAcc.Partner_Region__c='NAMR';
        Insert NewAcc;
        
        Partner_Type__c ProgInfo=new Partner_Type__c();
        ProgInfo.Account__c=NewAcc.Id;
        ProgInfo.Status__c='Active';
        ProgInfo.Program__c='RADIO';
        Insert ProgInfo;
        
        Account[] TAcc=[Select Id,Partner_Membership_ID__c from Account where Id=:NewAcc.Id limit 1];
        ADPReg1.Partner_Account__c =NewAcc.Id;
        ADPReg1.Is_New_Account_Created__c=true;
        ADPReg1.Existing_Partner_Membership_ID__c=TAcc[0].Partner_Membership_ID__c;
        Upsert ADPReg1;
                
         ID ADPLicRTypeID = Schema.SObjectType.Apttus__APTS_Agreement__c.RecordTypeInfosByName.get('ADP License').RecordTypeId;
   
         String technology = 'ASTRO';
        
         Apttus__APTS_Agreement__c newLicAgr = new Apttus__APTS_Agreement__c();
            
                //Field mapping from ADP Application
                newLicAgr.ADP_Technology__c = ADPReg1.Technology_Segment_Interest__c ;
                newLicAgr.Apttus__Account__c= ADPReg1.Partner_Account__c;
                newLicAgr.ADP_Application__c = ADPReg1.id;
                newLicAgr.RecordTypeID = ADPLicRTypeID;
                //Field for Share Project API
                newLicAgr.Apttus__Contract_End_Date__c=Date.valueof('2018-02-20');
                upsert newLicAgr;
                
                ADP_GITLAB_Project__c newGIT = new ADP_GITLAB_Project__c();
                newGIT.Agreement_ADP__c=newLicAgr.Id;
                newGIT.GIT_Project_ID__c = 1;
                newGIT.GIT_Project_Name__c = 'test1proj';
                upsert newGIT;

                PageReference pageRef = Page.ADPOIMShareProjects;
                Test.setCurrentPage(pageRef);
        
                pageRef.getParameters().put('Id', String.valueOf(newLicAgr.Id));
                ApexPages.StandardController sc = new ApexPages.StandardController(newLicAgr);
                ADPOIMShareProjectsExtension testAccPlan = new ADPOIMShareProjectsExtension(sc);
                testAccPlan.enableCreateContact();
             
                Test.stopTest();
        
    }
//Test cover :  When the response status is other than 200 or 409, Send Mail to the respective team
    private static testMethod void doTest2() {
    
        Test.setMock(HttpCalloutMock.class, new ADPShareProjectMockHttpResponseGenerator2()); 
        Test.startTest();
       
         TriggerDeactivateSwitch__c CS = new TriggerDeactivateSwitch__c(Name='AccountUpdateRelatedMCNTrigger',IsTriggerActive__c=FALSE);
        insert CS;
        ADP_Global_Account_Name__c NewADPGlobalAccName= new ADP_Global_Account_Name__c();
        NewADPGlobalAccName.Name='testRun';
        NewADPGlobalAccName.GitLab_Group_Id__c=815;
        insert NewADPGlobalAccName;
        
        ID ADPRTypeID = Schema.SObjectType.ADP_Registration__c.RecordTypeInfosByName.get('ADP').RecordTypeId;
        ADP_Registration__c NewADPReg= new ADP_Registration__c();
        NewADPReg.recordtypeId=ADPRTypeID;
        NewADPReg.Applicant_First_Name__c='TestRun1';
        NewADPReg.Applicant_Last_Name__c='Test2';
        NewADPReg.Company_Name__c='Test company';
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

        ADP_Registration__c ADPReg1=[Select id,Applicant_First_Name__c,Applicant_Last_Name__c,Company_Name__c,Company_Website__c,Technology_Segment_Interest__c,Company_Registration_Number__c,ADP_Global_Account_Name1__c,Partner_Account__c,Application_Status__c,Existing_Partner_Membership_ID__c,City_Town__c,Country__c,zipcode__c,Applicant_State_Province__c,Street_Address_1__c,Address_Line_2__c,Has_Existing_Relationship__c,Region_Requested__c,Is_New_Account_Created__c from ADP_Registration__C where Id=:NewADPReg.Id];
        
        RecordType theRecordType = [Select Id from RecordType where Name='Partner' and SobjectType='Account' limit 1];
        Account NewAcc=new Account();
        NewAcc.recordtypeId=theRecordType.Id;
        NewAcc.Name=ADPReg1.Company_Name__c;
        NewAcc.ADP_Global_Account_Name1__c=ADPReg1.ADP_Global_Account_Name1__c;
        NewAcc.ADP_Technology_Segment__c=ADPReg1.Technology_Segment_Interest__c;
        NewAcc.Company_Tax_Registration_ID__c=ADPReg1.Company_Registration_Number__c;
        NewAcc.BillingStreet=ADPReg1.Street_Address_1__c+' '+ADPReg1.Address_Line_2__c;
        NewAcc.BillingCity=ADPReg1.City_Town__c;
        NewAcc.BillingState=ADPReg1.Applicant_State_Province__c;
        NewAcc.BillingCountry =ADPReg1.Country__c;
        NewAcc.BillingPostalCode=String.Valueof(ADPReg1.zipcode__c);
        NewAcc.ADP_Partner__c=true;
        NewAcc.Hierarchy_Placement__c='Regional Account';
        NewAcc.MPE_Program_Status_New__c='Active';
        NewAcc.Partner_Region__c='NAMR';
        Insert NewAcc;
        
        Account[] TAcc=[Select Id,Partner_Membership_ID__c from Account where Id=:NewAcc.Id limit 1];
        ADPReg1.Partner_Account__c =NewAcc.Id;
        ADPReg1.Is_New_Account_Created__c=true;
        ADPReg1.Existing_Partner_Membership_ID__c=TAcc[0].Partner_Membership_ID__c;
        Upsert ADPReg1;
                
         ID ADPLicRTypeID = Schema.SObjectType.Apttus__APTS_Agreement__c.RecordTypeInfosByName.get('ADP License').RecordTypeId;
   
         String technology = 'ASTRO';
        
         Apttus__APTS_Agreement__c newLicAgr = new Apttus__APTS_Agreement__c();
            
                //Field mapping from ADP Application
                newLicAgr.ADP_Technology__c = ADPReg1.Technology_Segment_Interest__c ;
                newLicAgr.Apttus__Account__c= ADPReg1.Partner_Account__c;
                newLicAgr.ADP_Application__c = ADPReg1.id;
                newLicAgr.RecordTypeID = ADPLicRTypeID;
                //Field for Share Project API
                newLicAgr.Apttus__Contract_End_Date__c=Date.valueof('2018-02-20');
                insert newLicAgr;
                
                ADP_GITLAB_Project__c newGIT = new ADP_GITLAB_Project__c();
                newGIT.Agreement_ADP__c=newLicAgr.Id;
                newGIT.GIT_Project_ID__c = 1;
                newGIT.GIT_Project_Name__c = 'test1proj';
                insert newGIT;

                PageReference pageRef = Page.ADPOIMShareProjects;
                Test.setCurrentPage(pageRef);
        
                pageRef.getParameters().put('Id', String.valueOf(newLicAgr.Id));
                ApexPages.StandardController sc = new ApexPages.StandardController(newLicAgr);
                ADPOIMShareProjectsExtension testAccPlan = new ADPOIMShareProjectsExtension(sc);
                testAccPlan.enableCreateContact();
             
                Test.stopTest();
        
}



}