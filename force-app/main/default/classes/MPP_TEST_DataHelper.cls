@isTest
public class MPP_TEST_DataHelper {
    public static User getDefaultPortalUser(String contactId) {
        User u = new User(ContactId=contactId, ProfileId = [Select Id FROM Profile WHERE Name='EMS Partner Profile NAMR' LIMIT 1].Id, FirstName='NAMR', LastName='Partner', alias='abcd', email='NAMR@partner.com', username='NAMR@partner.com', communityNickname='testGuy', TimeZoneSidKey='America/New_York', LocaleSidKey='en_US', EmailEncodingKey='UTF-8', LanguageLocaleKey='en_US',Theater__c='NAMR');
        insert u;
        return u;
    }
    
    public static Account getAccountWithDefaults()
    {
        RecordType rt = [select Id from RecordType where SObjectType='Account' and DeveloperName='Partner' limit 1];
        Account a = new Account(Name='Test Systems Inc.', Level__c='Authorized Reseller',WNS_Track__c= true,Mobility_Track__c=true,BillingCountry='Brazil',Status__c='Active',RecordTypeId=rt.Id );
        insert a;
        return a;
    }
    
    public static Contact getContactWithDefaults(String accountId){
        Contact c = new Contact(Primary_Contact_Type__c = 'Executive', FirstName='NAMR', LastName='Partner', email='NAMR@partner.com', accountId=accountId, RecordTypeId='01280000000LsIz' );
        insert c;
        return c;
    }
}