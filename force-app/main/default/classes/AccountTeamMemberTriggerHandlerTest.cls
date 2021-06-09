@isTest
public class AccountTeamMemberTriggerHandlerTest {
    @testSetup
    static void testSetUp() {
        TestDataSetUpUtils.insertCustomSettings();
        TestDataSetUpUtils.loadGoogleDriveTestData();
    }    
    @isTest static void accountTeamMemberQuoteShare(){
        Id accrectypeID = GlobalUtility.getRecordTypeIdByDeveloperName('Account','SoldToAccount');
        List<Account> lstAccount = TestDataSetUpUtils.createAccounts(1, accrectypeID);
        AccountTeamMember atm = new AccountTeamMember();
        atm.AccountId =lstAccount.get(0).Id;
        atm.TeamMemberRole='311 Sales Specialist';
        atm.UserId=userinfo.getuserId();
        Test.startTest();
        insert atm;
        Test.stopTest();
        atm.Quote_Access__c='Read/Write';
        update atm;
        
        atm.Quote_Access__c='Private';
        update atm;
        delete atm;
    }  
    @isTest static void accountTeamMemberExternalUserTest(){
        Id accrectypeID = GlobalUtility.getRecordTypeIdByDeveloperName('Account','SoldToAccount');
        Id partnerCntRecId = GlobalUtility.getRecordTypeIdByDeveloperName('Contact','MPE_Partner_Contact');
        List<Account> lstAccount = TestDataSetUpUtils.createAccounts(1, accrectypeID);
        List<Contact> lstContact = TestDataSetUpUtils.createContacts(1, partnerCntRecId, lstAccount);
        User partnerUser =TestDataSetUpUtils.createPartnerPortalUser(lstContact.get(0).Id);
        //Try catch block is intended to test add error usecase
        try{ 
            List<AccountTeamMember> lstATM = new List<AccountTeamMember>();
            AccountTeamMember atm = new AccountTeamMember();
            atm.AccountId =lstAccount.get(0).Id;
            atm.TeamMemberRole='311 Sales Specialist';
            atm.UserId=partnerUser.Id;
            atm.Quote_Access__c='Read/Write';
            lstATM.add(atm);
            AccountTeamMember atm1 = new AccountTeamMember();
            atm1.AccountId =lstAccount.get(0).Id;
            atm1.TeamMemberRole='311 Sales Specialist';
            atm1.UserId=partnerUser.Id;
            atm1.Quote_Access__c='Private';
            lstATM.add(atm1);
            Test.startTest();
            insert lstATM;
			Test.stopTest();
            lstATM.get(1).Quote_Access__c='Read/Write';
            update lstATM.get(1);
        }catch(Exception ex){
            system.debug('Exception is expected');
        }
    }
     @isTest static void accountTeamMemberGoogleDriveTest(){
        GoogleDriveTest.accountTeamMemberGoogleDriveTest();
    }
}