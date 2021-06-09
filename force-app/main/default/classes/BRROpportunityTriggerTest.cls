@isTest
public class BRROpportunityTriggerTest {
     @testSetup
    static void testSetUp() {   
        TestDataSetUpUtils.insertCustomSettings();
        TestDataSetUpUtils.loadGoogleDriveTestData(); 
        Test.startTest();
        TestDataSetUpUtils.getBRRs();
        Test.stopTest();
        //update AccountListcompetitor[0];
    }   
     @isTest
    public static void BRROppUpdateTEST(){
        Id ProjectRTId = Schema.Sobjecttype.Opportunity.getRecordTypeInfosByName().get('Project').getRecordTypeId();
        Id prospectId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Prospect').getRecordTypeId();
        List<Account> AccountList = TestDataSetUpUtils.createAccounts(1, prospectId);        
        List<Opportunity> lstOpp = new List<Opportunity>();
        List<Briefing_Room_Report__c> lstBRR = [SELECT Id FROM Briefing_Room_Report__c];

        //OpportunityTriggerHandler.TriggerDisabled =true;
        Test.startTest();
        Opportunity opptyFiscal = new Opportunity();
        opptyFiscal.Name = 'testNonUSDOppty1';
        opptyFiscal.recordtypeid = ProjectRTId;
        opptyFiscal.StageName = 'Design & Validate';
        opptyFiscal.CurrencyIsoCode = 'INR';
        opptyFiscal.closedate = Date.newInstance(2019,01,03);
        opptyFiscal.AccountId = AccountList[0].Id;
        opptyFiscal.Status__c = 'Active';
        opptyFiscal.Primary_Competitor__c='3Com';
        opptyFiscal.Competition__c='ACS';
        opptyFiscal.ForecastCategoryName='Commit';
        opptyFiscal.Region__c='NA';
        opptyFiscal.Territory__c = 'T2';
        opptyFiscal.Project_Status__c='Postsale SI Projects';
        // insert opptyFiscal;
        opptyFiscal.Is_Created_From_Conversion__c =true;
        opptyFiscal.Fiscal_Metadata__c = NULL;
        opptyFiscal.Pull_Forward_Date__c = Date.newInstance(2019, 01, 02);
        opptyFiscal.Forecast_Notes__c='test';
        lstOpp.add(opptyFiscal);
        insert lstOpp;
        system.debug('Terriroty in TEST class'+opptyFiscal.Territory__c );
        Opportunity oppUp = new Opportunity();
        oppUp.Id=lstOpp.get(0).Id;
        oppUp.Forecast_Notes__c='testm';
        //Test.stopTest();
        update oppUp;
        system.debug('lstBRR.get(10).Id in test class'+lstBRR.get(10).Id);
        Opportunity oppUp1 = new Opportunity();
        oppUp1.Id=lstOpp.get(0).Id;
        oppUp1.Forecast_Notes__c='testm1';
        oppUp1.New_Currency__c = 'EUR';
        update oppUp1;
        oppUp1.Forecast_Notes__c='testm234';
        oppUp1.StageName ='Execute & Expand / Won';
        oppUp1.Award_Date__c = system.today();
        oppUp1.Reason_for_Win_or_Loss__c = 'Significant strengths in our solution';
       // oppUp1.Briefing_Room_Report__c =lstBRRUpdate.get(7).Id;
        //update oppUp1;
        //List<BRR_Opportunity__c> BRROpplst = [SELECT Id FROM BRR_Opportunity__c];
        //system.debug('BRROpplst'+BRROpplst.size());
        //system.debug('BRROpplst'+BRROpplst);
        Test.stopTest();
        try{
          	BRR_Opportunity__c BRROpp = [SELECT Id FROM BRR_Opportunity__c limit 1];
            BRROpp.BRR_Notes__c ='test';
            update BRROpp;
        }catch(Exception e){
            
        }
       /* try{
           BRR_Opportunity__c BRROpp = [SELECT Id FROM BRR_Opportunity__c limit 1];
            delete BRROpp;
        }catch(Exception e){
            
        }*/
    }  
    @isTest
    public static void BRROppDeleteTEST(){
        Id ProjectRTId = Schema.Sobjecttype.Opportunity.getRecordTypeInfosByName().get('Project').getRecordTypeId();
        Id prospectId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Prospect').getRecordTypeId();
        List<Account> AccountList = TestDataSetUpUtils.createAccounts(1, prospectId);        
        List<Opportunity> lstOpp = new List<Opportunity>();
        List<Briefing_Room_Report__c> lstBRR = [SELECT Id FROM Briefing_Room_Report__c];

        //OpportunityTriggerHandler.TriggerDisabled =true;
        Test.startTest();
        Opportunity opptyFiscal = new Opportunity();
        opptyFiscal.Name = 'testNonUSDOppty1';
        opptyFiscal.recordtypeid = ProjectRTId;
        opptyFiscal.StageName = 'Design & Validate';
        opptyFiscal.CurrencyIsoCode = 'INR';
        opptyFiscal.closedate = Date.newInstance(2019,01,03);
        opptyFiscal.AccountId = AccountList[0].Id;
        opptyFiscal.Status__c = 'Active';
        opptyFiscal.Primary_Competitor__c='3Com';
        opptyFiscal.Competition__c='ACS';
        opptyFiscal.ForecastCategoryName='Commit';
        opptyFiscal.Region__c='NA';
        opptyFiscal.Territory__c = 'T2';
        opptyFiscal.Project_Status__c='Postsale SI Projects';
        // insert opptyFiscal;
        opptyFiscal.Is_Created_From_Conversion__c =true;
        opptyFiscal.Fiscal_Metadata__c = NULL;
        opptyFiscal.Pull_Forward_Date__c = Date.newInstance(2019, 01, 02);
        opptyFiscal.Forecast_Notes__c='test';
        lstOpp.add(opptyFiscal);
        insert lstOpp;
        system.debug('Terriroty in TEST class'+opptyFiscal.Territory__c );
        Opportunity oppUp = new Opportunity();
        oppUp.Id=lstOpp.get(0).Id;
        oppUp.Forecast_Notes__c='testm';
        
        update oppUp;
        Test.stopTest();
        //system.debug('lstBRRUpdate.get(7).Id'+lstBRRUpdate.get(7).Id);
        Opportunity oppUp1 = new Opportunity();
        oppUp1.Id=lstOpp.get(0).Id;
        oppUp1.Forecast_Notes__c='testm1';
        oppUp1.New_Currency__c = 'EUR';
        //update oppUp1;
        try{
           BRR_Opportunity__c BRROpp = [SELECT Id FROM BRR_Opportunity__c limit 1];
            delete BRROpp;
        }catch(Exception e){
            
        }
    }
}