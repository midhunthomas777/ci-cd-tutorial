/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class ApsAgreementDocumentTest {
            @testSetup
    static void testSetUp() {
        TestDataSetUpUtils.insertCustomSettings();
        TriggerSettings__C agreetrgr = new TriggerSettings__C(Name = 'AgreementTriggerDisabled', IsActive__c = TRUE);
        insert agreetrgr;
    }

	private User adminUser;
	private Apttus__APTS_Agreement__c sofAgmt;	
	private Apttus__Agreement_Document__c agmtDoc;
	
    static testMethod void test1() {
        ApsAgreementDocumentTest instance = new ApsAgreementDocumentTest();
        instance.perform();
    }
    // test all six triggers
    private void perform() {
    	
    	// create data
    	createTestData();
    	
    	// perform tests
    	System.runAs(adminUser) {
    		performTestAsAdminUser();
    	}
    }
    private void performTestAsAdminUser() {
		update agmtDoc;
		
    }

    // create agreement and related objects
    private void createTestData() {
    	
    	// get admin user
		Profile adminProfile = [select Id from Profile where Name = 'System Administrator'];
		List<User> adminUserList = [select Id from User 
										where ProfileId = :adminProfile.Id
										and IsActive = true];
		adminUser = adminUserList[0];
		
    	System.RunAs(adminUser) {
	    	// agreement
	          sofAgmt = new Apttus__APTS_Agreement__c( Name = 'Test ' 
							, Apttus__Agreement_Category__c = 'Sales'
							, Apttus__Status_Category__c = DocumentChangeHistory.STATUS_CATEGORY_EXPIRED);
			insert sofAgmt;
			System.assert(sofAgmt.Id != null);
			
			// agmtDoc
			agmtDoc = new Apttus__Agreement_Document__c(Name = 'AgreementDocument');	
			agmtDoc.Apttus__Agreement__c = sofAgmt.id;
			agmtDoc.Apttus__Path__c = 'http://test/test.pdf';
			insert agmtDoc;
			System.assert(agmtDoc.Id != null);
    	}
    }			
}