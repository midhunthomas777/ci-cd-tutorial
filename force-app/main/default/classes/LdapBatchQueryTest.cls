/*  
* File Name     : LdapBatchQueryTest
* Description   : Test method for the LDAP classes.
*
* @author       : Aslam Kamal
*
* Modification Log
* =============================================================================
*   Ver     Date         Author          		Modification
*------------------------------------------------------------------------------
*   1.0     02-Sep-13    Aslam Kamal       		Initial Creation
*   2.0		09-May-18	 Satish Maddhi (TCS)    removed SeeAllData=true and increased code coverage
*/

@isTest
public class LdapBatchQueryTest { 
    @testSetup
    static void testSetUp() {
		TestDataSetUpUtils.insertCustomSettings();
        TriggerSettings__c userTgr = new TriggerSettings__c();
        userTgr.name = 'UserTriggerDisabled';
        userTgr.Isactive__c = TRUE;
        insert userTgr;
        
        Portal_User_Creation_Regions__c regSettings = new Portal_User_Creation_Regions__c();
        regSettings.Name = 'Current Settings';
        regSettings.APAC__c=true;
        regSettings.NAMR__c=true;
        regSettings.EMEA__c=true;
        regSettings.LACR__c=true;
        regSettings.Username_Suffix__c='motoprm.com';
        regSettings.AdminId__c=UserInfo.getUserId();
        regSettings.UsernameTemplate__c='00X80000001Xm8r';
        regSettings.PasswordTemplate__c='00X80000001Xm8q';
        regSettings.OrgWideEmailAddressID__c='0D280000000Kz8Q';
        insert regSettings;
        
        LDAP_Settings__c newSetting = new LDAP_Settings__c();
        newSetting.name = 'Current';
        newSetting.Authentication__c = 'Basic';
        newSetting.Disable_Emails__c = false;
        newSetting.Disable_Triggers__c = false;
        newSetting.Endpoint__c = 'https://wsgw-uat.motorolasolutions.com:443/';
        newSetting.Exception_Recipients__c = 'test@motorolasolutions.com';
        newSetting.New_Partner_Template_ID__c = 'testPartberUd';
        newSetting.Send_Address__c = true;
        newSetting.Send_Company_Attribute__c = true;
        newSetting.Send_Language_Attribute__c = true;
        newSetting.Update_Template_ID__c = 'test';
        insert newSetting;
    }
    public static testmethod void tester() {
        ldapBatchQuery2 classObj = new ldapBatchQuery2 ();
        Account acc = new Account(name='Test',Partner_Region__C='APAC',Hierarchy_Placement__c='GSI Account',Type='Partner',billingcity='hyd',billingcountry='India');
        Account acc1 = new Account(name='Test',Partner_Region__C='NAMR',Hierarchy_Placement__c='GSI Account',Type='Partner',billingcity='hyd',billingcountry='India');
        Account acc2 = new Account(name='Test',Partner_Region__C='EMEA',Hierarchy_Placement__c='GSI Account',Type='Partner',billingcity='hyd',billingcountry='India');
        List<Account> accList = new List<Account>();
        accList.add(acc);accList.add(acc1);accList.add(acc2);
        insert accList;
        
        Contact con = new Contact(AccountId=acc.id, FirstName='testK', LastName='test2', Email='test@email.com',Preferred_Language__c='Korean',Source_Code__c='MSI');
        Contact con1 = new Contact(AccountId=acc1.id, FirstName='testO', LastName='test1', Email='test1@email.com',Preferred_Language__c='English',Source_Code__c='MSI');
        Contact con2 = new Contact(AccountId=acc2.id, FirstName='test1', LastName='test3', Email='test2@email.com',Source_Code__c='MSI');
        List<Contact> conList = new List<Contact>();
        conList.add(con);conList.add(con1);conList.add(con2);
        
        insert conList;
        ldapBatchQuery2.currContact=con;
        classObj.thisContacts = new List<Id>();
        classObj.thisContacts.add(con.id);
        classObj.updateContact(con);
        
        con.Ldap_Login__c = con.email;
        con.Email_Hash__c = '123456789x';
        con1.Ldap_Login__c = con1.email;
        con1.Email_Hash__c = '123456789x';
        con1.Ldap_Login__c = con1.email;
        con1.Email_Hash__c = '1234562789x';
        Test.startTest();
        update conList; 
        
        classObj.to_update.put(con.id,con.email);
        classObj.to_update.put(con1.id,con1.email);
        classObj.to_update.put(con2.id,con2.email);
        classObj.idCount=0;
        classObj.reRuns.add(con.id);
        classObj.reRuns.add(con1.id);
        classObj.reRuns.add(con2.id);
        Database.executeBatch(classObj);
        classObj.getLanguagePreference('');
        classObj.getLanguagePreference('Spanish');
        classObj.getLanguagePreference('Portuguese');
        classObj.getLanguagePreference('Chinese');
        classObj.getLanguagePreference('Korean');
        classObj.getLanguagePreference('Japanese');
        /*LDAPUpdateBatch obj = new LDAPUpdateBatch(); // Add you Class Name
         DataBase.executeBatch(obj);*/
        Test.stopTest();
    }
    
    public static testmethod void testUserUpdateTrigger() {
        Id accrectypeID = GlobalUtility.getRecordTypeIdByDeveloperName('Account','SoldToAccount');
        Id partnerCntRecId = GlobalUtility.getRecordTypeIdByDeveloperName('Contact','MPE_Partner_Contact');
        List<Account> lstAccount = TestDataSetUpUtils.createAccounts(1, accrectypeID);
        List<Contact> lstContact = TestDataSetUpUtils.createContacts(1, partnerCntRecId, lstAccount);
        Id p = [select id from profile where name='EMS Partner Administrator Profile NAMR'].id;
        User newUser = new User(alias = 'test123', email='test123asdfresdf@noemail.com',
                                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                                localesidkey='en_US', profileid = p, country='United States',
                                ContactId = lstContact.get(0).Id,
                                timezonesidkey='America/Los_Angeles', username='tester@noemail.com.niran', 
                                IsActive = false,FederationIdentifier = 'tester@noemail.com.niran');
        
        insert newUser;        
    }
    
    public static testmethod void testUserUpdateUser1(){
        user u = [select id, isActive from user where isActive=false and FederationIdentifier!=null and contactId!=null limit 1];
        u.isActive=true;                                
        update u;
    }
   
}