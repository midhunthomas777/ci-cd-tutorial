/************************************************************************************************* 
* File Name  : DeleteOppTrigger_Test
* Description: Test class for OpportunityTrigger and OpportunityTriggerHandler
* Modification Log 
* ============================================================================= 
*   Date               Author              Modification 
* ---------------------------------------------------------------------------------------
* 27-Nov-2017     Satish Maddhi(TCS)       Initial Code
*
*************************************************************************************************/ 

@IsTest
private Class DeleteOppTrigger_Test {
    @testSetup
    static void testSetup() {
        TestDataSetUpUtils.insertCustomSettings();
    }
    
    static TestMethod void doTest(){
        Test.startTest();
            Id prospectRecId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Prospect').getRecordTypeId();
            Id compRecId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Competitor').getRecordTypeId();
            Id prjtRecId = Schema.Sobjecttype.Opportunity.getRecordTypeInfosByName().get('Project').getRecordTypeId();
            
            List<Account> prospectAccList = TestDataSetUpUtils.createAccounts(2, prospectRecId);
            List<Account> competitorAccList = TestDataSetUpUtils.createAccounts(2, compRecId);
            List<Opportunity> myOppLst =  TestDataSetUpUtils.createOpportunities(1, prjtRecId, prospectAccList);
            System.debug('myOppLst - ' + myOppLst);
        	Product2 prd1 = new Product2 (Name='Test Product Entry 1',Description='Test Product Entry 1',
                                          productCode = 'ABC', isActive = true);
            //Product2 myProd= new Product2(Name = 'SPSS C&C PremierOne Suite', IsActive = True);
            insert prd1;
        	
        	/* commented by Sagar as a Part of VESTA_SPILLMAN_INT-265 because JunctionforAccountCompetitior__c object 
			needs to be deleted and CompetitiveDB__c fields autopopulated from opportunity. */
            CompetitiveDB__c myDb = new CompetitiveDB__c();
            myDb.Competitive_Vendor__c = competitorAccList[1].id;
            myDb.Related_Opportunity__c = myOppLst[0].id;
            /*myDb.Account_ID__c = prospectAccList[0].id;
            myDb.TechnologyType__c = prd1.id;*/
            insert myDb;
            //Check for JuncObject Now
            /*JunctionforAccountCompetitior__c juncObject = [SELECT Id FROM JunctionforAccountCompetitior__c WHERE CompetitiveId__c= :MyDb.Id];
            System.assert(juncObject != NULL);*/
            
        	try{
            	//delete juncObject;
            	delete myDb;
                delete myOppLst; 
            } Catch(Exception exp){
                System.debug('Exception found: '+exp.getMessage());
            }
        Test.stopTest();
    }
}