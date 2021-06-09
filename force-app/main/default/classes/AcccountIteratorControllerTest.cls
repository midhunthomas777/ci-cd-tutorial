/************************************************************************************************* 
* File Name  : AcccountIteratorControllerTest
* Description: Test class for AcccountIteratorController class
* Modification Log 
* ============================================================================= 
*   Date               Author                         Modification 
* ---------------------------------------------------------------------------------------
* 09-April-2018     Satish Maddhi(TCS)    Removed seealldate=true and increased code coverage
*
*************************************************************************************************/

@isTest
private class AcccountIteratorControllerTest {
    @testSetup
    static void testSetUp() {
        TestDataSetUpUtils.insertCustomSettings();
    }
    static testMethod void classTest() {
       RecordType theRecordType = [SELECT Id FROM RecordType WHERE Name='Partner' AND SobjectType='Account' LIMIT 1];
       RecordType rec = [SELECT Id FROM RecordType WHERE Name='Customer' AND SobjectType='Account' LIMIT 1];
       Account partnerAcc = new Account(name='Test Account3',RecordTypeId=theRecordType.id,DBA_Trading_Name__c='testDBA',
                                        Partner_HQ_Country__c='United States',AccountNumber='1234',
                                        Motorola_Customer_Number__c ='11312',BillingCountry='United States',
                                        Partner_Region__c='NAMR');   
       Account custAcc1 = new Account(Name = 'TestParent',
                                   RecordTypeId = rec.Id , 
                                   CurrencyIsoCode ='USD',
                                   BillingCountry = 'United States',
                                   Billing_County__c= 'Australia',
                                   BillingState= 'New York',
                                   BillingCity = 'New York',
                                   BillingStreet= 'test',
                                   Assigned_MR__c=partnerAcc.id,
                                   MCN_Account_Number__c=string.valueof(integer.valueof(math.random()*1000000000)*100), 
                                   BillingPostalCode = '112004'
                                  );
         Account custAcc2 = new Account(Name = 'TestParent',
                                   RecordTypeId = rec.Id , 
                                   CurrencyIsoCode ='USD',
                                   BillingCountry = 'United States',
                                   Billing_County__c= 'Australia',
                                   BillingState= 'New York',
                                   BillingCity = 'New York',
                                   BillingStreet= 'test', 
                                   BillingPostalCode = '112004',
                                   Assigned_MR__c=partnerAcc.id
                                  );
       List<Account> accList = new List<Account>();
       accList.add(partnerAcc);
       accList.add(custAcc1);
       accList.add(custAcc2);
       insert accList;
       
       Test.startTest();
       AcccountIteratorController ctrl = new AcccountIteratorController();
       ctrl.userCollection = accList;
       AcccountIteratorController.toCollectionOfCollection(accList);
       Test.stopTest();
    }
}