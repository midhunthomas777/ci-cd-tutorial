/*  
* File Name     : ADPContactListTest
* Description   : This class is test class for ADPContactList
* Modification Log
* =============================================================================
*   Ver     Date         Author                      Modification
*------------------------------------------------------------------------------
*   1.0     06-03-17    Madhavi Latha Pannala       Initial Creation
*
*/
@isTest
public class ADPContactListTest {
    @testSetup
    static void testSetUp() {
        TestDataSetUpUtils.insertCustomSettings();
    }  
    private static testmethod void method_1() {
        Id accrt = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner').getRecordTypeId();   
        Id conrt = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Partner').getRecordTypeId(); 
        Id rt2 = Schema.SObjectType.Case.getRecordTypeInfosByName().get('ADP Partner Contact Request').getRecordTypeId();  
        ADP_Global_Account_Name__c ag=new ADP_Global_Account_Name__c(name='testing', GitLab_Group_Id__c=835);
        insert ag;
        List<Account> acclist = TestDataSetUpUtils.createAccounts(1,accrt);
        acclist[0].ADP_Global_Account_Name1__c=ag.id;
        update acclist;
        List<Contact> conlist = TestDataSetUpUtils.createcontacts(2,conrt,acclist);
        conlist[0].Primary_Contact_Type__c='sales';
        conlist[0].tag__c='ADP';
        update conlist;
        conlist[1].Primary_Contact_Type__c='sales';
        conlist[1].tag__c='SFDC partner admin';
        update conlist;
        Test.startTest();
        Profile p = [SELECT Id FROM Profile WHERE Name='MPE Partner Profile']; 
        User usr = new User(Alias = 'standt', Email='standarduser@testorg.com', 
                            EmailEncodingKey='UTF-8', FirstName='VTest',LastName='Testing', LanguageLocaleKey='en_US', 
                            LocaleSidKey='en_US', ProfileId = p.Id, contactid=conlist[1].id,
                            TimeZoneSidKey='America/Los_Angeles', UserName='testswing@testorg.com');
        insert usr ;
        System.runAs(usr) {
            ADPcontactList obj = new ADPcontactList(new ApexPages.StandardController(acclist[0]));
            obj.accid=acclist[0].id;
            obj.getcontacts();
            obj.getcases();
            obj.redirect();
            obj.savecasedetails();
            obj.Backtocontactslist();
        }
        Test.stopTest();
    }
    private static testmethod void method_2() {
        Id accrt = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner').getRecordTypeId();   
        Id conrt = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Partner').getRecordTypeId();   
        ADP_Global_Account_Name__c ag=new ADP_Global_Account_Name__c(name='testing', GitLab_Group_Id__c=835);
        insert ag;
        List<Account> acclist = TestDataSetUpUtils.createAccounts(1,accrt);
        acclist[0].ADP_Global_Account_Name1__c=ag.id;
        update acclist;
        List<Contact> conlist = TestDataSetUpUtils.createcontacts(2,conrt,acclist);
        conlist[0].Primary_Contact_Type__c='sales';
        conlist[0].tag__c='ADP';
        update conlist;
        conlist[1].Primary_Contact_Type__c='sales';
        conlist[1].tag__c='SFDC partner admin';
        update conlist;        
        Test.startTest();
        Profile p = [SELECT Id FROM Profile WHERE Name='MPE Partner Profile']; 
        User usr = new User(Alias = 'standt', Email='standarduser@testorg.com', 
                            EmailEncodingKey='UTF-8', FirstName='VTest',LastName='Testing', LanguageLocaleKey='en_US', 
                            LocaleSidKey='en_US', ProfileId = p.Id, contactid=conlist[1].id,
                            TimeZoneSidKey='America/Los_Angeles', UserName='testswing1@testorg.com');
        insert usr ;
        System.runAs(usr) {
            ADPcontactList obj = new ADPcontactList(new ApexPages.StandardController(acclist[0]));
            obj.accid=acclist[0].id;
            obj.getcontacts();
            obj.getcases();
            obj.redirect();
            obj.savecasedetails();
            obj.Backtocontactslist();
        }
        Test.stopTest();
    }
    
    private static testmethod void method_3() {
        Id accrt = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner').getRecordTypeId();   
        Id conrt = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Partner').getRecordTypeId(); 
        Id rt2 = Schema.SObjectType.Case.getRecordTypeInfosByName().get('ADP Partner Contact Request').getRecordTypeId();  
        ADP_Global_Account_Name__c ag=new ADP_Global_Account_Name__c(name='testing', GitLab_Group_Id__c=835);
        insert ag;
        List<Account> acclist = TestDataSetUpUtils.createAccounts(1,accrt);
        acclist[0].ADP_Global_Account_Name1__c=ag.id;
        update acclist;
        List<Contact> conlist = TestDataSetUpUtils.createcontacts(2,conrt,acclist);
        conlist[0].Primary_Contact_Type__c='sales';
        conlist[0].tag__c='ADP';
        update conlist;
        conlist[1].Primary_Contact_Type__c='sales';
        conlist[1].tag__c='SFDC partner admin';
        update conlist;
        Test.startTest();
        Profile p = [SELECT Id FROM Profile WHERE Name='MPE Partner Profile']; 
        User usr = new User(Alias = 'standt', Email='standarduser@testorg.com', 
                            EmailEncodingKey='UTF-8', FirstName='VTest',LastName='Testing', LanguageLocaleKey='en_US', 
                            LocaleSidKey='en_US', ProfileId = p.Id, contactid=Conlist[1].id,
                            TimeZoneSidKey='America/Los_Angeles', UserName='testswing5@testorg.com');
        insert usr ;
        System.runAs(usr) {
            ADPcontactList obj = new ADPcontactList(new ApexPages.StandardController(acclist[0]));
            obj.cas=new case();
            obj.cas.accountid=null;
            obj.cas.recordtypeid=null;
            obj.cas.status='';
            try {
                insert obj.cas;
            } 
            catch (DmlException e) {
                System.assert (e.getMessage().contains('INVALID_CROSS_REFERENCE_KEY') ,e.getMessage() );
            }//End catch
            obj.accid=acclist[0].id;
            obj.getcontacts();
            obj.redirect();
            obj.savecasedetails();
            obj.Backtocontactslist();
        }
        Test.stopTest();
    }
    
}