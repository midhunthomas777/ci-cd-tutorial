/*  
* File Name     : ADPGetGITProjectsExtensionTest
* Description   : Test class for ADPGetGITProjectsExtension
* Modification Log
* =============================================================================
*   Ver     Date         Author                      Modification
*------------------------------------------------------------------------------
*   1.0     30-Dec-16    Poongodi V                  Initial Creation
*/
@isTest
global class ADPGetGITProjectsExtensionTest{
 @testSetup
   static void testSetUp() {
       TestDataSetUpUtils.insertCustomSettings();
   }

global class ADPGetProjectMockHttpResponseGenerator implements HttpCalloutMock
    {
        global HTTPResponse respond(HTTPRequest request) 
        {   
         HttpResponse response = new HttpResponse();
         response.setHeader('Content-Type', 'application/json');
         //if(request.getEndpoint().contains('https://wsqa.motorolasolutions.com/ADP/GetProjectDetails?search=astro-25&simple=true&sort=asc&per_page=100'))
            //response.setBody('[{"id":144,"http_url_to_repo":"https://hack.mot-solutions.com/astro-25/oem-integration.git","web_url":"https://hack.mot-solutions.com/astro-25/oem-integration","name":"oem-integration","name_with_namespace":"astro-25 / oem-integration","path":"oem-integration","path_with_namespace":"astro-25/oem-integration"},{"id":146,"http_url_to_repo":"https://hack.mot-solutions.com/astro-25/xcm-subscriber.git","web_url":"https://hack.mot-solutions.com/astro-25/xcm-subscriber","name":"xcm-subscriber","name_with_namespace":"astro-25 / xcm-subscriber","path":"xcm-subscriber","path_with_namespace":"astro-25/xcm-subscriber"},{"id":147,"http_url_to_repo":"https://hack.mot-solutions.com/astro-25/packet-data.git","web_url":"https://hack.mot-solutions.com/astro-25/packet-data","name":"packet-data","name_with_namespace":"astro-25 / packet-data","path":"packet-data","path_with_namespace":"astro-25/packet-data"},{"id":148,"http_url_to_repo":"https://hack.mot-solutions.com/astro-25/mpp.git","web_url":"https://hack.mot-solutions.com/astro-25/mpp","name":"mpp","name_with_namespace":"astro-25 / mpp","path":"mpp","path_with_namespace":"astro-25/mpp"},{"id":166,"http_url_to_repo":"https://hack.mot-solutions.com/astro-25/sb9600.git","web_url":"https://hack.mot-solutions.com/astro-25/sb9600","name":"sb9600","name_with_namespace":"astro-25 / sb9600","path":"sb9600","path_with_namespace":"astro-25/sb9600"}]');
           // if(request.getEndpoint().contains('https://wsqa.motorolasolutions.com/ADP/GetProjectDetails?search=dimetra&simple=true&sort=asc&per_page=100')) {
              //response.setBody('[{"id":16,"http_url_to_repo":"https://hack.mot-solutions.com/dimetra/oem-control-head.git","web_url":"https://hack.mot-solutions.com/dimetra/oem-control-head","name":"oem-control-head","name_with_namespace":"dimetra / oem-control-head","path":"oem-control-head","path_with_namespace":"dimetra/oem-control-head"}]');
              response.setBody('{"test":["testdata1","testdata2"]}');
              response.setStatusCode(200);
           // }
         return response;
        }
    }

    public static List<ADP_OIM_Settings__c> createADPCustomSetting() {
        List<ADP_OIM_Settings__c> adpsettingList = new List<ADP_OIM_Settings__c>();
        ADP_OIM_Settings__c adpSetting1 = new ADP_OIM_Settings__c();
        adpSetting1.Name = 'cgCurrent';
        adpSetting1.authorizationType__c = 'Basic';
        adpSetting1.contentHeader__c = 'application/json';
        adpSetting1.emailToAddress__c = 'poongodi.v@motorolasolutions.com';
        adpSetting1.EndPoint__c = 'https://www.motorolasolutions.com/';
        adpSetting1.method__c = 'POST';
        adpSetting1.password__c = 'adppassword';
        adpSetting1.username__c = 'adpuser';
        adpsettingList.add(adpSetting1);
        
        ADP_OIM_Settings__c adpSetting2 = new ADP_OIM_Settings__c();
        adpSetting2.Name = 'rpCurrent';
        adpSetting2.authorizationType__c = 'Basic';
        adpSetting2.contentHeader__c = 'application/json';
        adpSetting2.emailToAddress__c = 'poongodi.v@motorolasolutions.com';
        adpSetting2.EndPoint__c = 'https://www.motorolasolutions.com/';
        adpSetting2.method__c = 'GET';
        adpSetting2.password__c = 'adppassword';
        adpSetting2.username__c = 'adpuser';
        adpsettingList.add(adpSetting2);
        
        ADP_OIM_Settings__c adpSetting3 = new ADP_OIM_Settings__c();
        adpSetting3.Name = 'spCurrent';
        adpSetting3.authorizationType__c = 'Basic';
        adpSetting3.contentHeader__c = 'application/json';
        adpSetting3.emailToAddress__c = 'poongodi.v@motorolasolutions.com';
        adpSetting3.EndPoint__c = 'https://www.motorolasolutions.com/';
        adpSetting3.method__c = 'POST';
        adpSetting3.password__c = 'adppassword';
        adpSetting3.username__c = 'adpuser';
        adpsettingList.add(adpSetting3);
        
        Database.insert(adpsettingList,false);
        return adpsettingList;
    }
    
    public static List<ADP_GitLab_Group_Mapping__c> createADPGrpMapCustomSetting() {
        List<ADP_GitLab_Group_Mapping__c> grpMapList = new List<ADP_GitLab_Group_Mapping__c>();
        ADP_GitLab_Group_Mapping__c grpMapSetting1 = new ADP_GitLab_Group_Mapping__c();
        grpMapSetting1.Name = 'MOTOTRBO';
        grpMapSetting1.GITLab_grpid_of_Tech__c = '123';
        grpMapSetting1.GITLab_Tech_group_name__c = 'testMototrbo';
        grpMapList.add(grpMapSetting1);
        
        ADP_GitLab_Group_Mapping__c grpMapSetting2 = new ADP_GitLab_Group_Mapping__c();
        grpMapSetting2.Name = 'ASTRO';
        grpMapSetting2.GITLab_grpid_of_Tech__c = '234';
        grpMapSetting2.GITLab_Tech_group_name__c = 'testAstro';
        grpMapList.add(grpMapSetting2);
        
        ADP_GitLab_Group_Mapping__c grpMapSetting3 = new ADP_GitLab_Group_Mapping__c();
        grpMapSetting3.Name = 'Convergence Suite';
        grpMapSetting3.GITLab_grpid_of_Tech__c = '345';
        grpMapSetting3.GITLab_Tech_group_name__c = 'testConvergence';
        grpMapList.add(grpMapSetting3);
        
        ADP_GitLab_Group_Mapping__c grpMapSetting4 = new ADP_GitLab_Group_Mapping__c();
        grpMapSetting4.Name = 'DIMETRA';
        grpMapSetting4.GITLab_grpid_of_Tech__c = '456';
        grpMapSetting4.GITLab_Tech_group_name__c = 'testdDimetra';
        grpMapList.add(grpMapSetting4);
        
        Database.insert(grpMapList,false);
        return grpMapList;
    }
  
    private static testMethod void doTest() {
    Test.startTest();
      Test.setMock(HttpCalloutMock.class, new ADPGetProjectMockHttpResponseGenerator());
        List<ADP_OIM_Settings__c> adpCustomSettings = ADPGetGITProjectsExtensionTest.createADPCustomSetting();
        List<ADP_GitLab_Group_Mapping__c> adpGrpSettings = ADPGetGITProjectsExtensionTest.createADPGrpMapCustomSetting();
        
        ADP_Global_Account_Name__c newADPGlobalAccName= new ADP_Global_Account_Name__c();
        newADPGlobalAccName.Name='testdemoRunGIT24';
        newADPGlobalAccName.GitLab_Group_Id__c=234;
        insert newADPGlobalAccName;
        
        ID ADPRTypeID = Schema.SObjectType.ADP_Registration__c.RecordTypeInfosByName.get('ADP').RecordTypeId;
        ADP_Registration__c newADPReg= new ADP_Registration__c();
        newADPReg.recordtypeId=ADPRTypeID;
        newADPReg.Applicant_First_Name__c='TestRun1';
        newADPReg.Applicant_Last_Name__c='Test2';
        newADPReg.Company_Name__c='Test company';
        newADPReg.Company_Website__c='www.test.com';
        newADPReg.Technology_Segment_Interest__c='DIMETRA';     
        newADPReg.ADP_Global_Account_Name1__c= newADPGlobalAccName.Id;     
        newADPReg.Application_Status__c='Approved - ADP Lead';
        newADPReg.City_Town__c='Test City';
        newADPReg.Country__c='United States';
        newADPReg.zipcode__c='600122';
        newADPReg.Applicant_State_Province__c='Illinois';
        newADPReg.Street_Address_1__c='Street 1';
        newADPReg.Address_Line_2__c='Street 2';
        newADPReg.Region_Requested__c='North America';
        newADPReg.Is_New_Account_Created__c=false;
        insert newADPReg;

        ADP_Registration__c ADPReg1=[SELECT id,Applicant_First_Name__c,Applicant_Last_Name__c,Company_Name__c,Company_Website__c,Technology_Segment_Interest__c,Company_Registration_Number__c,ADP_Global_Account_Name1__c,Partner_Account__c,Application_Status__c,Existing_Partner_Membership_ID__c,City_Town__c,Country__c,zipcode__c,Applicant_State_Province__c,Street_Address_1__c,Address_Line_2__c,Has_Existing_Relationship__c,Region_Requested__c,Is_New_Account_Created__c FROM ADP_Registration__C WHERE Id=:newADPReg.Id];
        
        RecordType theRecordType = [SELECT Id FROM RecordType WHERE Name='Partner' AND SobjectType='Account' LIMIT 1];
        Account newAcc=new Account();
        newAcc.recordtypeId=theRecordType.Id;
        newAcc.Name=ADPReg1.Company_Name__c;
        newAcc.ADP_Global_Account_Name1__c=ADPReg1.ADP_Global_Account_Name1__c;
        newAcc.ADP_Technology_Segment__c=ADPReg1.Technology_Segment_Interest__c;
        newAcc.Company_Tax_Registration_ID__c=ADPReg1.Company_Registration_Number__c;
        newAcc.BillingStreet=ADPReg1.Street_Address_1__c+' '+ADPReg1.Address_Line_2__c;
        newAcc.BillingCity=ADPReg1.City_Town__c;
        newAcc.BillingState=ADPReg1.Applicant_State_Province__c;
        newAcc.BillingCountry =ADPReg1.Country__c;
        newAcc.BillingPostalCode=String.Valueof(ADPReg1.zipcode__c);
        newAcc.ADP_Partner__c=true;
        newAcc.Hierarchy_Placement__c='Regional Account';
        newAcc.MPE_Program_Status_New__c='Active';
        newAcc.Partner_Region__c='NAMR';
        Insert newAcc;
        
        Account[] TAcc=[Select Id,Partner_Membership_ID__c from Account where Id=:newAcc.Id limit 1];
        ADPReg1.Partner_Account__c =newAcc.Id;
        ADPReg1.Is_New_Account_Created__c=true;
        ADPReg1.Existing_Partner_Membership_ID__c=TAcc[0].Partner_Membership_ID__c;
        Upsert ADPReg1;
    
        ID ADPLicRTypeID = Schema.SObjectType.Apttus__APTS_Agreement__c.RecordTypeInfosByName.get('ADP License').RecordTypeId;
        
        Apttus__APTS_Agreement__c newLicAgr = new Apttus__APTS_Agreement__c();
    //Field mapping from ADP Application
        newLicAgr.ADP_Technology__c = ADPReg1.Technology_Segment_Interest__c ;
        newLicAgr.Contracting_Party_Account__c = ADPReg1.Partner_Account__c;
        newLicAgr.ADP_Application__c = ADPReg1.id;
        newLicAgr.RecordTypeID = ADPLicRTypeID;
        upsert newLicAgr; 
         
        ADP_GITLAB_Project__c newGITProject = new ADP_GITLAB_Project__c();
        newGITProject.GIT_Project_ID__c=16;
        newGITProject.GIT_Project_Name__c='oem-control-head';
        newGITProject.Agreement_ADP__c=newLicAgr.Id;
        insert newGITProject ;

        PageReference pageRef = Page.ADPGetGITProject;
        Test.setCurrentPage(pageRef);

        pageRef.getParameters().put('Id', String.valueOf(newLicAgr.Id));
        ApexPages.StandardController sc = new ApexPages.StandardController(newLicAgr);
        ADPGetGITProjectsExtension testAccPlan = new ADPGetGITProjectsExtension(sc);
        testAccPlan.GitLabProjects();
        boolean SelectedAcc= true;
        String GroupName=NewADPReg.Company_Registration_Number__c;

    ADPGetGITProjectsExtension.ADPGITWrapper adpWrapperInstance = new ADPGetGITProjectsExtension.ADPGITWrapper();
        List<ADPGetGITProjectsExtension.ADPGITWrapper> lstSetController=new List<ADPGetGITProjectsExtension.ADPGITWrapper>();
        // public ADPGITWrapper(boolean SelectedGITAPIcheckbox,boolean SelectedAllcheckbox, ADP_GITLAB_Project__c GITAPI,Apttus__APTS_Agreement__c Agt,16,String ProjName){
         
        lstSetController.add(new ADPGetGITProjectsExtension.ADPGITWrapper(true,true,newGITProject,newLicAgr,16,'oem-control-head'));
        lstSetController.add(new ADPGetGITProjectsExtension.ADPGITWrapper(false,false,newGITProject,newLicAgr,16,'oem-control-head'));
                
        ADPGetGITProjectsExtension.ADPGetGITCustomIterable newPBE= new ADPGetGITProjectsExtension.ADPGetGITCustomIterable(lstSetController);
        newPBE.setPageSize = 1;
        Boolean Previous=newPBE.hasPrevious();
        Boolean next=newPBE.hasNext();
        testAccPlan.hasNext = true;
        testAccPlan.hasPrevious = true;
        testAccPlan.NorecordExists = true;
        testAccPlan.TrueFlag = true;
        testAccPlan.previous();
        newPBE.hasNext();
        newPBE.hasPrevious();
        newPBE.next();
        newPBE.previous();
        newPBE.checkAll(lstSetController);
        testAccPlan.AttachGITProjects();
        
        ADPGetGITProjectsExtension.ADPGitLabProjectDetailsclass innerClsInstance = new ADPGetGITProjectsExtension.ADPGitLabProjectDetailsclass();
        innerClsInstance.ProjId = 123;
        innerClsInstance.ProjName = 'testProject';
        ADPGetGITProjectsExtension.ADPGetGITProjectJsonClass jsonClsInst = new ADPGetGITProjectsExtension.ADPGetGITProjectJsonClass();
        ADPGetGITProjectsExtension.ParserMethodResponse('{"test":["testdata1","testdata2"]}');
        Test.stopTest();
  }
}