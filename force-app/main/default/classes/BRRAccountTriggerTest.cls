@isTest
public class BRRAccountTriggerTest {
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
     public static void updateBRRAccount(){
        //Id ProjectRTId = Schema.Sobjecttype.Opportunity.getRecordTypeInfosByName().get('Project').getRecordTypeId();
        Id prospectId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Prospect').getRecordTypeId();
        List<Account> AccountList = TestDataSetUpUtils.createAccounts(1, prospectId);
         Test.startTest();
        List<Briefing_Room_Report__c> lstBRR = [SELECT Id FROM Briefing_Room_Report__c];
        BRR_Account__c BRRAcc =  new BRR_Account__c(Briefing_Room_Report__c=lstBRR.get(6).Id,Account__c =AccountList.get(0).Id );
         insert BRRAcc;
         Test.stopTest();
         try{
             
             BRRAcc.BRR_Notes__c = 'test';
             update BRRAcc;
             delete BRRAcc;
         }
         catch(Exception e){
             
         }
        
     }
    @isTest
     public static void deleteBRRAccount(){
        //Id ProjectRTId = Schema.Sobjecttype.Opportunity.getRecordTypeInfosByName().get('Project').getRecordTypeId();
        Id prospectId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Prospect').getRecordTypeId();
        List<Account> AccountList = TestDataSetUpUtils.createAccounts(1, prospectId);
         Test.startTest();
        List<Briefing_Room_Report__c> lstBRR = [SELECT Id FROM Briefing_Room_Report__c];
        BRR_Account__c BRRAcc =  new BRR_Account__c(Briefing_Room_Report__c=lstBRR.get(6).Id,Account__c =AccountList.get(0).Id );
         insert BRRAcc;
         Test.stopTest();
         try{
             delete BRRAcc;
         }
         catch(Exception e){
             
         }
        
     }
   

}