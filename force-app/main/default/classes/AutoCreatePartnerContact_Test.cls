@isTest
private class AutoCreatePartnerContact_Test {
@testSetup
   static void testSetUp() {
       TestDataSetUpUtils.insertCustomSettings();
   }
  /*  public static testMethod void ADP_AutoCreatePartnerContact_method1() {
        RecordType rect1=[Select r.Id From RecordType r where r.SobjectType='Account' and r.name='Partner'];
        List<Account> acclist = TestDataSetUpUtils.createAccounts(1, rect1.id) ; 
        RecordType conRtype = [Select r.Id From RecordType r where r.SobjectType='Contact' and r.name='Partner'];
        List<Contact> Conlist = TestDataSetUpUtils.createContacts(2, conRtype.id, acclist);
        RecordType adpRType=[Select r.Id From RecordType r where r.SobjectType='ADP_Registration__c' and r.name='ADP'];
        List<ADP_Registration__c> adplist = TestDataSetUpUtils.CreateADPRecords(1,adpRType.id);
        List<ADPContact__c> adpConlist = TestDataSetUpUtils.CreateADPContactRecords(3,adplist);
        
        Profile p1 = [select id from profile where name='MPE Partner Profile'];        
        User usr1 = new User();
        usr1.FirstName = 'Rita'; 
        usr1.LastName = 'Mary'; 
        usr1.Username = 'Ritam@email.com.test';
        usr1.Email =  'Ritam@email.com';
        usr1.Alias = 'RMary';
        usr1.TimeZoneSidKey = 'America/Los_Angeles'; 
        usr1.LocaleSidKey = 'en_US'; 
        usr1.EmailEncodingKey = 'UTF-8'; 
        usr1.ProfileId = p1.id; 
        usr1.LanguageLocaleKey ='en_US';
        usr1.Primary_Business_Group__c='Government'; 
        usr1.ContactId = Conlist[0].id;
        usr1.IsActive = true;
        insert usr1;
        
        RecordType agrRType=[Select r.Id From RecordType r where r.SobjectType='Apttus__APTS_Agreement__c' and r.name='ADP License'];
        Apttus__APTS_Agreement__c licAgmt = new Apttus__APTS_Agreement__c();
        licAgmt.Name = 'Test ASTRO Agreement';
        licAgmt.Agreement_Title__c = 'Test ASTRO License';
        licAgmt.m_Business_Unit__c = 'Government';
        licAgmt.Apttus__Status_Category__c = 'Request';
        licAgmt.Apttus__Status__c = 'Request';
        licAgmt.m_GTM_Region__c = 'Global';
        licAgmt.m_Technology__c = 'ASTRO P25 Accessories';
        licAgmt.Apttus__Subtype__c = 'IPR';
        licAgmt.RecordTypeID = agrRType.id;
        licAgmt.ADP_Technology__c = 'ASTRO';
        insert licAgmt;
        
        licAgmt.Apttus__Account__c = acclist[0].id;
        licAgmt.ADP_Application__c = adplist[0].id;
        licAgmt.Create_Contact__c = true; 

        Test.startTest();
        update licAgmt;
        Test.stopTest();
         
    
    }*/
       public static testMethod void ADP_AutoCreatePartnerContact_method2() {
        RecordType rect1=[Select r.Id From RecordType r where r.SobjectType='Account' and r.name='Partner'];
        List<Account> acclist = TestDataSetUpUtils.createAccounts(1, rect1.id) ; 
        RecordType conRtype = [Select r.Id From RecordType r where r.SobjectType='Contact' and r.name='Partner'];
        List<Contact> Conlist = TestDataSetUpUtils.createContacts(2, conRtype.id, acclist);
      //  Conlist[0].tag__c=null;
     //   Conlist[1].tag__c=null;
      //  update conlist;
      System.debug('=====Conlist===='+Conlist);
        RecordType adpRType=[Select r.Id From RecordType r where r.SobjectType='ADP_Registration__c' and r.name='ADP'];
        List<ADP_Registration__c> adplist = TestDataSetUpUtils.CreateADPRecords(1,adpRType.id);
        List<ADPContact__c> adpConlist = TestDataSetUpUtils.CreateADPContactRecords(3,adplist);
        adpConlist[0].Applicant_Email_Address__c='test1@gmail.com';
        adpConlist[0].Admin__c=false;
      
        update adpConlist;
        Profile p1 = [select id from profile where name='MPE Partner Profile'];        
        User usr1 = new User();
        usr1.FirstName = 'Rita'; 
        usr1.LastName = 'Mary'; 
        usr1.Username = 'Ritam@email.com.test';
        usr1.Email =  'Ritam@email.com';
        usr1.Alias = 'RMary';
        usr1.TimeZoneSidKey = 'America/Los_Angeles'; 
        usr1.LocaleSidKey = 'en_US'; 
        usr1.EmailEncodingKey = 'UTF-8'; 
        usr1.ProfileId = p1.id; 
        usr1.LanguageLocaleKey ='en_US';
        usr1.Primary_Business_Group__c='Government'; 
        usr1.ContactId = Conlist[0].id;
        usr1.IsActive = true;
        insert usr1;
        
        RecordType agrRType=[Select r.Id From RecordType r where r.SobjectType='Apttus__APTS_Agreement__c' and r.name='ADP License'];
        Apttus__APTS_Agreement__c licAgmt = new Apttus__APTS_Agreement__c();
        licAgmt.Name = 'Test ASTRO Agreement';
        licAgmt.Agreement_Title__c = 'Test ASTRO License';
        licAgmt.m_Business_Unit__c = 'Government';
        licAgmt.Apttus__Status_Category__c = 'Request';
        licAgmt.Apttus__Status__c = 'Request';
        licAgmt.m_GTM_Region__c = 'Global';
        licAgmt.m_Technology__c = 'ASTRO P25 Accessories';
        licAgmt.Apttus__Subtype__c = 'IPR';
        licAgmt.RecordTypeID = agrRType.id;
        licAgmt.ADP_Technology__c = 'ASTRO';
        insert licAgmt;
        
        licAgmt.Apttus__Account__c = acclist[0].id;
        licAgmt.ADP_Application__c = adplist[0].id;
        licAgmt.Create_Contact__c = true; 

        Test.startTest();
        update licAgmt;
        Test.stopTest();
         
    
    }
}