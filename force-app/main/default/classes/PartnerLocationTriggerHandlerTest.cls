/************************************************************************************************* 
* File Name  : PartnerLocationTriggerHandlerTest
* Description: Test class for PartnerLocationTriggerHandler 
* Modification Log 
* ============================================================================= 
*   Date               Author                         Modification 
* ---------------------------------------------------------------------------------------
* 06-Aug-2018     Vineela N(TCS)	  			Initial development
*
*************************************************************************************************/
@istest
public class PartnerLocationTriggerHandlerTest {
    @testSetup
    static void testSetUp() {
        TestDataSetUpUtils.insertCustomSettings();
        TriggerSettings__c triggerdisbl = new TriggerSettings__c(Name='PartnerLocationTriggerHandler',IsActive__c=FALSE);
        insert triggerdisbl; 
    }
    static testmethod void PLcreation() {   
        Id prospectId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Prospect').getRecordTypeId();
        List<Account> prospectacclist = TestDataSetUpUtils.createAccounts(2, prospectId);
       // List<Partner_Location__c> PLlist = TestDataSetUpUtils.CreatePLRecords(2,prospectacclist);
       Partner_Location__c PL = new Partner_Location__c(Account__c=prospectacclist[0].id,Country1__c='United States',State__c='Alabama',Address_Type__c='Primary Location');
       insert PL;
}
static testmethod void PLcreation2() {   
        Id prospectId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Prospect').getRecordTypeId();
        List<Account> prospectacclist = TestDataSetUpUtils.createAccounts(2, prospectId);
       // List<Partner_Location__c> PLlist = TestDataSetUpUtils.CreatePLRecords(2,prospectacclist);
       Partner_Location__c PL = new Partner_Location__c(Account__c=prospectacclist[0].id,Country_Code__c='US',
                                                        State_Code__c = 'WY',Address_Type__c='HQ');
       insert PL;
       PL.state__c = 'Washington';
       update PL;
}
}