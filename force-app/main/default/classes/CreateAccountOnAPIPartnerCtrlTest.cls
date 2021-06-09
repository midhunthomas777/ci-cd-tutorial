@isTest
public class CreateAccountOnAPIPartnerCtrlTest {
    
    @isTest private static void getAPIPartnerApplTest(){
        test.startTest();
        TestDataSetUpUtils.insertCustomSettings();
        API_Partner_Application__c apiPartner = TestDataSetUpUtils.createAPIPartnerAppl();
        API_Partner_Application__c newAPIPartner = CreateAccountOnAPIPartnerCtrl.getAPIPartnerAppl(apiPartner.Id);
        String createAccount = CreateAccountOnAPIPartnerCtrl.createAccOnApplication(apiPartner.Id);
        String accId = createAccount.substringAfter('Success');
        Account acc = [SELECT Id, Name FROM Account WHERE Id =: accId];
        system.assertEquals(newAPIPartner.Company_Name__c, acc.Name);
        test.stopTest();
    }    
}