/**
* @author Accenture
* @date March 2020
* @description Test class for the controller class ExternalCasesController
*/
@isTest(seeAllData = false)
private class ExternalCasesControllerTest {
    
    @testSetup
    static void testSetUp() {
        TestDataSetUpUtils.insertCustomSettings();// need custom settings for triggers to run
    }  
    
    static testMethod void caseList()
    {   
        String responseBody ='{ "result": [{ "u_supp_activity": "","parent": "","u_assignment_date": "","u_connectivity_issues": "false","u_call_first_tier_req": "false","caused_by": "","watch_list": "","u_audible_alarm": "false","u_subcontractor_name_case": "Audiocodes case 170322-000049","u_call_back_number": "(616) 881-2175","active_escalation": "","account": {"link": "https://ecmportaltest.motorolasolutions.com:443/api/now/v1/table/customer_account/5215c59f4f983200ce5c0ad14210c793"}}}';
        String response;
        Map<String,String> requestParams = new Map<String,String>();
        User partneruser = TestDataSetUpUtils.createCommunityUser();
        User usr = [Select Id,AccountId from User where Id =: partneruser.Id];
        System.runAs(partneruser)
        {
            system.debug('######partneruser##### => ' + partneruser);
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new EInvoiceControllerMockTest(200,responseBody));
            response=ExternalCasesController.caseList(requestParams, usr.AccountId);
            Test.stopTest();            
        }
        System.assert(response!=null);
    }
    
    static testMethod void caseListEX()
    {   
        String responseBody ='{ "result": [{ "u_supp_activity": "","parent": "","u_assignment_date": "","u_connectivity_issues": "false","u_call_first_tier_req": "false","caused_by": "","watch_list": "","u_audible_alarm": "false","u_subcontractor_name_case": "Audiocodes case 170322-000049","u_call_back_number": "(616) 881-2175","active_escalation": "","account": {"link": "https://ecmportaltest.motorolasolutions.com:443/api/now/v1/table/customer_account/5215c59f4f983200ce5c0ad14210c793"}}}';
        String response;
        Map<String,String> requestParams = new Map<String,String>();
        User partneruser= TestDataSetUpUtils.createCommunityUser();
        System.runAs(partneruser)
        {
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new EInvoiceControllerMockTest(200,responseBody));
            response=ExternalCasesController.caseList(requestParams, '');
            Test.stopTest();            
        }
        System.assert(response!=null);
    }
    
    static testMethod void caseDetail()
    {   
        String responseBody ='{ "result": [{ "u_supp_activity": "","parent": "","u_assignment_date": "","u_connectivity_issues": "false","u_call_first_tier_req": "false","caused_by": "","watch_list": "","u_audible_alarm": "false","u_subcontractor_name_case": "Audiocodes case 170322-000049","u_call_back_number": "(616) 881-2175","active_escalation": "","account": {"link": "https://ecmportaltest.motorolasolutions.com:443/api/now/v1/table/customer_account/5215c59f4f983200ce5c0ad14210c793"}}}';
        String response;
        User partneruser= TestDataSetUpUtils.createCommunityUser();
        System.runAs(partneruser)
        {
            Test.startTest(); 
            Test.setMock(HttpCalloutMock.class, new EInvoiceControllerMockTest(200,responseBody));
            response=ExternalCasesController.caseDetail('CS00179859'); 
            Test.stopTest();
        }
        System.assert(response!=null);
    }
}