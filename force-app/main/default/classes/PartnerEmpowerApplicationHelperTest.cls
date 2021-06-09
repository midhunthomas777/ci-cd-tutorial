@isTest
public class PartnerEmpowerApplicationHelperTest {
    @isTest private static void populateSignatoryEmailTest(){
        TestDataSetUpUtils.insertCustomSettings();
        test.startTest();
        //PartnerEmpowerApplicationHelper.runOnce=false;
        Empower_Application__c empower=TestDataSetUpUtils.createPartnerEmpower();
        empower.Partner_Application_Status__c='Approved';
        update empower;
        
        
        
        /*Approval.ProcessSubmitRequest req1 =  new Approval.ProcessSubmitRequest();
req1.setComments('Submitting request for approval.');
req1.setObjectId(empower.id);
req1.setSubmitterId(UserInfo.getuserId()); 
req1.setProcessDefinitionNameOrId('AP_Partner_OnBoarding_Approval_Process');
req1.setSkipEntryCriteria(true);
Approval.ProcessResult result = Approval.process(req1);

system.debug('test'+result);*/
        
        /*system.debug( 'instancestatus****'+result.instancestatus);
system.debug('resultget****'+result.getInstanceStatus()); */       
        
       // empower.Partner_Application_Status__c='Denied';
        // update empower;
        test.stopTest();
    }
    
    public static testmethod void testRejectionWithoutComment() {
        TestDataSetUpUtils.insertCustomSettings();
        Empower_Application__c empower=TestDataSetUpUtils.createPartnerEmpower();
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
        Empower_Application__c empower=TestDataSetUpUtils.createPartnerEmpower();
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
}