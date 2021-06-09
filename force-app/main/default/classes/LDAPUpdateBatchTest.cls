/************************************************************************************************* 
* File Name  : LDAPUpdateBatchTest
* Description: Test class for LDAPUpdateBatch class
* Modification Log 
* ============================================================================= 
*   Date               Author                         Modification 
* ---------------------------------------------------------------------------------------
* 05-Aug-2018     Vineela N(TCS)	  			Initial development
*
*************************************************************************************************/
@isTest
public class LDAPUpdateBatchTest {
    @testSetup
    static void testSetUp() {
        TestDataSetUpUtils.insertCustomSettings();
        
    }
    @isTest static void TestLDAP() {
        
        List<contact> conlist1 =  new List<contact>();
        LDAPUpdateBatch batchobj = new LDAPUpdateBatch();
        Id accrectypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        Id PartnrRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner').getRecordTypeId();
        Id prospectAccrectypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Prospect').getRecordTypeId();
        Id MCNrectypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Motorola Customer Number').getRecordTypeId();
        User partnerUsr = TestDataSetUpUtils.createPortalUser();
        Id siteID = TestDataSetUpUtils.createSite();
        system.debug('partnerUsrAccountId out'+partnerUsr);
        contact con = [SELECT ID,AccountID from Contact where ID =: partnerUsr.ContactId ];
        con.LDAP_Login__c = 'Test@t.com';
        update con;
        contact con1 = [SELECT ID,AccountID,LDAP_Login__c from Contact where ID =: con.Id];
        system.debug('partnerUsrAccountId out'+con);
        Set<Id> contactIds1 = new Set<ID>();
        contactIds1.add(con.Id);
        batchobj.contactIds = contactIds1;
        batchobj.updateLDAPStatusToActive = TRUE;
        List<Integration_Framework__mdt> ldapUpdateMetaData = new List<Integration_Framework__mdt>();
        if(GlobalUtility.runningInASandbox()) {
            ldapUpdateMetaData = [SELECT DeveloperName,Basic_Authentication__c,ClientID__c,ClientSecret__c,Timeout__c,Endpoint_URL__c,OAuthToken_URL__c
                                  FROM Integration_Framework__mdt where Instance__c='Sandbox' and label='LDAPUpdateStatus' limit 1];
        }else{
            ldapUpdateMetaData = [SELECT DeveloperName,Basic_Authentication__c,ClientID__c,ClientSecret__c,Timeout__c,Endpoint_URL__c,OAuthToken_URL__c
                                  FROM Integration_Framework__mdt where Instance__c='Production' and label='LDAPUpdateStatus' limit 1];
        }   
        system.debug('Testing123.....' +ldapUpdateMetaData);
        test.startTest();
        system.debug('Tesing009');
        Test.setMock(HttpCalloutMock.class, new LDAPResponseGenerator());
        Database.executeBatch(batchobj);
        system.debug('Testing2.....');
        test.stopTest();
        
    }  
    @isTest
    static void TestLDAP1() {
        
        List<contact> conlist1 =  new List<contact>();
        LDAPUpdateBatch batchobj = new LDAPUpdateBatch();
        Integration_Framework__mdt metdata = [SELECT DeveloperName,Basic_Authentication__c,ClientID__c,ClientSecret__c,Timeout__c,Endpoint_URL__c,OAuthToken_URL__c
                                              FROM Integration_Framework__mdt where Instance__c='Sandbox' and label='LDAPUpdateStatus' limit 1];
        Id accrectypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        Id PartnrRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner').getRecordTypeId();
        Id prospectAccrectypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Prospect').getRecordTypeId();
        Id MCNrectypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Motorola Customer Number').getRecordTypeId();
        User partnerUsr = TestDataSetUpUtils.createPortalUser();
        Id siteID = TestDataSetUpUtils.createSite();
        system.debug('partnerUsrAccountId out'+partnerUsr);
        contact con = [SELECT ID,AccountID from Contact where ID =: partnerUsr.ContactId ];
        con.LDAP_Login__c = 'Test@t.com';
        update con;
        contact con1 = [SELECT ID,AccountID,LDAP_Login__c from Contact where ID =: con.Id];
        system.debug('partnerUsrAccountId out'+con);
        Set<Id> contactIds1 = new Set<ID>();
        contactIds1.add(con.Id);
        batchobj.contactIds = contactIds1;
        batchobj.updateLDAPStatusToActive = FALSE;
        List<Integration_Framework__mdt> ldapUpdateMetaData = new List<Integration_Framework__mdt>();
        if(GlobalUtility.runningInASandbox()) {
            ldapUpdateMetaData = [SELECT DeveloperName,Basic_Authentication__c,ClientID__c,ClientSecret__c,Timeout__c,Endpoint_URL__c,OAuthToken_URL__c
                                  FROM Integration_Framework__mdt where Instance__c='Sandbox' and label='LDAPUpdateStatus' limit 1];
        }else{
            ldapUpdateMetaData = [SELECT DeveloperName,Basic_Authentication__c,ClientID__c,ClientSecret__c,Timeout__c,Endpoint_URL__c,OAuthToken_URL__c
                                  FROM Integration_Framework__mdt where Instance__c='Production' and label='LDAPUpdateStatus' limit 1];
        }   
        //LDAPUpdateBatch batchinstance = new LDAPUpdateBatch();
        // batchinstance.generateLDAPOAuthToken(ldapUpdateMetaData);
        system.debug('Testing.....');
        test.startTest();
        Test.setMock(HttpCalloutMock.class, new LDAPResponseGenerator());
        //Meher
        /* HttpResponse res = new HttpResponse();    
res.setHeader('Content-Type', 'application/json');
res.setBody('{"example":"test"}');
res.setStatusCode(200);
//return res;
*/
        
        system.debug('Testing1.....');
        Database.executeBatch(batchobj);
        system.debug('Testing2.....');
        test.stopTest();
        
    }    
    
    
}