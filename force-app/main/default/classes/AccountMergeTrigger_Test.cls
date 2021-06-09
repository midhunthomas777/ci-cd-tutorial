@isTest(seeAllData=false)
public class AccountMergeTrigger_Test
{
    @testSetup
   static void testSetUp() {
       TestDataSetUpUtils.insertCustomSettings();
   }

  static testMethod void testCDH1()
  {

 TriggerDeactivateSwitch__c td = new TriggerDeactivateSwitch__c();
 td.Name = 'AccountUpdateRelatedMCNTrigger';
 td.IsTriggerActive__c = true;
 insert td;
RecordType rt = [Select Id From RecordType Where SobjectType = 'Account' and Name = 'Customer']; 
Id partnerRTId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Partner').getRecordTypeId();

 Account accMain = new Account();
 accMain.Name='Check';
 accMain.recordtypeId=rt.id;
 accMain.billingcountry = 'United States';
 accMain.billingcity='texas';
 accMain.billingstate='Texas';
 //acc.RecordTypeID =rt.id;
 accMain.party_number__c = '5678';

 insert accMain;
 
 
 Account acc = new Account();
 acc.Name='Test Developer';
 acc.recordtypeId=rt.id;
 acc.billingcountry = 'United States';
 acc.billingcity='texas';
 acc.billingstate='Texas';
 //acc.RecordTypeID =rt.id;
 acc.party_number__c = '1234';
 //acc.MasterRecordId =accMain.id;
 insert acc;
 merge accMain acc;
 Account partneracc = new Account();
 partneracc.Name='Test Developer';
 partneracc.recordtypeId=partnerRTId;
 partneracc.billingcountry = 'United States';
 partneracc.billingcity='texas';
 partneracc.billingstate='Texas';
 //acc.RecordTypeID =rt.id;
 partneracc.Program_Level_Community__c = 'US Federal';
 //acc.MasterRecordId =accMain.id;
 insert partneracc;
 partneracc.Program_Level_Community__c = 'Manufacturer Representative';
 update partneracc; 
 }
}