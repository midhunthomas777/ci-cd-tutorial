@isTest
public class MassActionLeadPartnerSendEmail_Test {
    @isTest static void assignPartner(){
        TestDataSetUpUtils.insertCustomSettings();  
        Id partnerRTId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Partner').getRecordTypeId();
        Id partContact = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Partner').getRecordTypeId();
		List<Account> partnerAcclist = TestDataSetUpUtils.createAccounts(1, partnerRTId);
        List<Contact> lstContact = TestDataSetUpUtils.createContacts(1,partContact,PartnerAcclist);
        partnerAcclist.get(0).Radio_Leads__c = True;
        Update partnerAcclist;
        
        lstContact.get(0).Tag__c='SFDC Partner Admin';
        Update lstContact;
        
        Map<String,ID> profiles = new Map<String,ID>();
        List<Profile> ps = [select id, name from Profile where name = 'EMS Partner Administrator Profile NAMR' or name = 'System Administrator'];
        for(Profile p : ps){
            profiles.put(p.name, p.id);
        }
        User partnerUsr = new User(alias = 'partusr',email='standarduser@testorg.com',emailencodingkey='UTF-8', 
                                   lastname='Testing', languagelocalekey='en_US',localesidkey='en_US', contactId=lstContact.get(0).Id,
                                   profileid = profiles.get('EMS Partner Administrator Profile NAMR'),timezonesidkey='America/Los_Angeles', 
                                   username='partnerusr@testorg.com',CommunityNickname='pusr1', FederationIdentifier='partnerusr@testorg.com',
                                   Core_ID__c='partnerusr@testorg.com',IsActive = True);
        insert partnerUsr;
        
        List<Lead> leadlst = TestDataSetUpUtils.createLeadRecords(2);
        leadlst.get(0).Track__c='Radio';
        leadlst.get(0).Partner_Account_NA__c=lstContact.get(0).AccountId;
        leadlst.get(0).Partner_Email_Sent__c='Email Pending';
        update leadlst;
        List<Id> leadIds = new List<Id>();
        leadIds.add(leadlst.get(0).Id);
        System.debug('leadlst.get(0)===>'+leadlst.get(0));
        MassActionLeadPartnerSendEmail.sendMailsToCon(leadIds);        
    }
}