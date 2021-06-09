@isTest
public class GlobalUtility_Test {
    
    @testSetup
    static void testSetUp() {
        TestDataSetUpUtils.insertCustomSettings();
        
        List<TriggerSettings__c> tSC = new List<TriggerSettings__c>();
        tsc.add(new TriggerSettings__C(Name ='OpportunityTriggerDisabled',Isactive__c=TRUE));
        Insert tSC;
    }
    

    @isTest static void globalUtilityTest1() {
        String recId = GlobalUtility.recordTypeId('Opportunity','Project');
        GlobalUtility.getRecordTypeNameById('Opportunity', recId);
        GlobalUtility.runningInASandbox();
        GlobalUtility.fetchIntegrationUsers('Lead');
        GlobalUtility.fetchFieldsByObject('Customer_Portfolio_Presence__c', 'REFERENCE', true, false);
        GlobalUtility.fetchFieldsByObject('Customer_Portfolio_Presence__c', 'REFERENCE', false, true);
        GlobalUtility.fetchFieldsByObject('Customer_Portfolio_Presence__c', 'REFERENCE', false, false);
        Id AccRegId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Prospect').getRecordTypeId();
        List<Account> acclist = TestDataSetUpUtils.createaccounts(1,AccRegId);
        BigMachines__Quote__c bigmachinesquote = new BigMachines__Quote__c(); //Added by Meher as part of SF-2059
        bigmachinesquote.BigMachines__Account__c=acclist[0].Id;
        bigmachinesquote.Name='testQuote';
        bigmachinesquote.BigMachines__Site__c=TestDataSetUpUtils.createSite();
        insert bigmachinesquote; //Added by Meher as part of SF-2059
        Id OppRegId = Schema.Sobjecttype.Opportunity.getRecordTypeInfosByName().get('Registration').getRecordTypeId();
        List<opportunity> opplist = TestDataSetUpUtils.createOpportunities(1, OppRegId, acclist);
        String myString = 'StringToBlob';
        Blob myBlob = Blob.valueof(myString);
        
        List<Submit_For_Approval_Queue_Finder__mdt> sbq;
        sbq= new MetadataCoverage().getMetadatacoverageRecords('SELECT MasterLabel,Approval_Process_API_Name__c,Object_Name__c, Record_Type__c,SkipEntryCriteria__c,Region__c,Submission_Comment__c,Submitter_User_Id__c, Queue_Id__c FROM Submit_For_Approval_Queue_Finder__mdt');
        
        
        List<MR_Digitization_Settings__mdt> mrd;
        mrd= new MetadataCoverage().getMetadatacoverageRecords('SELECT MasterLabel,DeveloperName FROM MR_Digitization_Settings__mdt');
        GlobalUtility.getDigitizationSettings(mrd.get(0).DeveloperName);
        //GlobalUtility.getDigitizationSettings();
        GlobalUtility.fetchQueryByFieldSet(opplist[0].id, 'LeadConversionPanel');
        GlobalUtility.readFieldSet('LeadConversionPanel', 'Opportunity');
        GlobalUtility.metaMessagesMap(NULL, 'GoogleDrive');
        GlobalUtility.userTheme();
        GlobalUtility.getBaseUrl();
        GlobalUtility.fetchPicklistsByObjectAndField('Account','Primary_Route_to_Market__c');
        GlobalUtility.fetchQueryForAllFieldsByObject('Account');
        GlobalUtility.fetchPicklistsByObjectAndFieldMap('Account','Industry');
        GlobalUtility.fieldsByFieldSet('Opportunity', 'LeadConversionPanel');
        GlobalUtility.isLoggedinPartnerUser();
        GlobalUtility.createContentVersion(myString,myBlob);
        GlobalUtility.getContentDocuments(opplist[0].id);
        set<id> mySet = new set<Id>();
        mySet.add(opplist[0].id);

        GlobalUtility.getContentVersionDetails(mySet);
        //Added by Meher to increase the test coverage
        GlobalUtility.submitAndProcessApprovalRequest(opplist[0].id,OppRegId,'APAC','function');
        //GlobalUtility.submitAndProcessApprovalRequest(opplist[0].id,OppRegId,'APAC','function','Approved');
        GlobalUtility.deleteRecord(bigmachinesquote.id);
        GlobalUtility.subtractDays(system.now(),3,'NA Radio Lead Management');
        GlobalUtility.isLoggedinCustomerCommunityUser();
        GlobalUtility.createContentDocumentLink(NULL,NULL,'V','InternalUsers');
        Map<String,String> mapUrlParam = new Map<String,String>();
        mapUrlParam.put('Id', 'value');
        GlobalUtility.buildHttpUrl(mapUrlParam);
        Set<String> isoCodes = new Set<String>();
        isoCodes.add('USD');
        GlobalUtility.getConversionRate(isoCodes);
        Set<Id> roleIds = new Set<Id>();
        roleIds.add(UserInfo.getUserRoleId());
        GlobalUtility.getAllSubRoleIds(roleIds);
        GlobalUtility.getSObjectNameById(opplist[0].Id);
    }
    @isTest 
    public static void testRejectionWithoutComment() {
        //TestDataSetUpUtils.insertCustomSettings();
         Empower_Application__c empower= createPartnerEmpower();
        //Empower_Application__c empower=TestDataSetUpUtils.createPartnerEmpower();
        Id cur2Id = generateAndSubmitObject();
        Approval.ProcessWorkitemRequest testRej = new Approval.ProcessWorkitemRequest();
        testRej.setComments('');
        testRej.setAction  ('Reject');      
        testRej.setWorkitemId(cur2Id);
        Test.startTest();        
        try
        {
            Approval.ProcessResult testRejResult =  Approval.process(testRej);
            system.assert(false, 'A rejection with no comment should cause an exception');
        }
        catch(DMLException e)
        {
            system.assertEquals('Please provide a rejection reason!', 
                                e.getDmlMessage(0), 
                                'error message should be Operation Cancelled: Please provide a rejection reason!'); 
        }
        Test.stopTest();
    }
    public static Id generateAndSubmitObject(){
        Empower_Application__c empower=createPartnerEmpower();
        Approval.ProcessSubmitRequest req1 =  new Approval.ProcessSubmitRequest();
        req1.setComments('Submitting request for approval.');
        req1.setObjectId(empower.id);
        req1.setSubmitterId(UserInfo.getuserId()); 
        req1.setProcessDefinitionNameOrId('AP_Partner_OnBoarding_Approval_Process');
        req1.setSkipEntryCriteria(true);
        Approval.ProcessResult result = Approval.process(req1);
        System.assert(result.isSuccess(),'Unable to submit new Currency Approval record for approval');
        return result.getNewWorkitemIds()[0];
    }
    public static Empower_Application__c createPartnerEmpower(){
        
        Empower_Application__c empower=new Empower_Application__c(Primary_Supervertical__c='Education',Applicant_Salutation__c='Ms.',Applicant_First_Name__c='Test Partner',
                                                                  Applicant_Last_Name__c='Test LastName',Applicant_Primary_Language__c='English',
                                                                  Partner_Region__c='NA',Applicant_Mobile_Number__c='2012201820',Applicant_Phone_Number__c='2012201820',
                                                                  Applicant_Email_Address__c='testrabit@hnm.com',Applicant_Primary_Role__c='Finance',Partner_Community_Type__c='Value Added Reseller',
                                                                  Partner_Technology_Segment__c='Mission Critical Radio Systems',Total_Number_of_Marketing_Personnel__c=2,Technology_Sub_Segment__c='FirstNet',
                                                                  Total_Number_of_Sales_Personnel__c=3,Total_Number_of_Technical_Personnel__c=5,Are_You_Authorized_to_Sign_Legal_Agmt__c='Yes',
                                                                  Company_Legal_Name__c='Motorola',Company_Signature_Authority_First_Name__c='testauto',Company_Signature_Authority_Last_Name__c='testlast',
                                                                  Company_Signature_Authority_Phone_Number__c='2016201789',Company_Website__c='www.testmoto.com',Company_Tax_Registration_ID__c='123489',
                                                                  Main_place_of_business_Address_1__c='Singapore High Street',Main_place_of_business_Address_2__c='Near NUS',Main_place_of_business_Country__c='United States',
                                                                  Main_place_of_business_State__c='AR',Main_place_of_business_Postal_Code__c='411041',Company_Signature_Authority_Salutation__c='Ms.',Company_Signature_Authority_Mobile__c='2012201820',
                                                                  Company_Signature_Authority_Email__c='testrabit@hnm.com',Company_Trading_Name__c='testMotorola',
                                                                  Main_place_of_business_Town_City__c='NY',Divison_of_or_Owned_by_Another_Company__c='Yes',Main_Business_Phone_Number__c='2012201820',
                                                                  ownerId='00580000003QMBtAAO',
                                                                  Partner_Application_Status__c='Partner Submitted');
        insert empower;
        return empower;
    }
}