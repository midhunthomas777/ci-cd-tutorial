@isTest
public class ApplicationsAccessTriggerHandlerTest {
    @testSetup
    static void testSetUp() {
        TestDataSetUpUtils.insertCustomSettings();
    }
    public static testMethod void testRunner1(){
        Id accrectypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner').getRecordTypeId();
        Id conrectypeID = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Partner').getRecordTypeId();
        List<Account> lstAccount = TestDataSetUpUtils.createAccounts(1, accrectypeID);
        User partnerUsr = TestDataSetUpUtils.createPortalUser();
        Id siteID = TestDataSetUpUtils.createSite();
        system.debug('Partner Account id'+partnerUsr.accountId);
        ID partnerAccountId= [Select accountId from Contact WHERE Id=:partnerUsr.ContactId].accountId;
        system.debug('Only partnerAccountId'+partnerAccountId); 
        Account acc = new Account(id=partnerAccountId,Applications_Enabled__c='CPQ',BigMachines__Partner_Organization__c ='test');
        update acc;
        Contact cont= new Contact();
        cont.AccountId=acc.Id;
        cont.RecordTypeId=conrectypeID;
        cont.User__c=partnerUsr.Id;
        cont.FirstName = 'Test FName';
        cont.LastName = 'Test LName' ;
        cont.FirstNameLocal = 'Test';
        cont.email = 'TestLname@gmail.com';
        insert cont;
        Applications_Access__c apaccess = new Applications_Access__c();
        apaccess.Contact__c=cont.Id;
        apaccess.App_Name__c='CPQ';
        insert apaccess;
       // apaccess.App_Access_Status__c='Active'; 
        update apaccess;
        delete apaccess;
        Undelete apaccess;
    }
}