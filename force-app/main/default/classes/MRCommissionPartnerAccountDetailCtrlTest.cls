@isTest
public class MRCommissionPartnerAccountDetailCtrlTest {
    @isTest
    public static void  MRCommissionPartnerAccountDetail(){
        TestDataSetUpUtils.insertCustomSettings();
        User partneruser= TestDataSetUpUtils.createPortalUser();
        List<Opportunity> lstOpportunity = TestDataSetUpUtils.createProjectOpportunity();
        Id PartnrRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner').getRecordTypeId();
        Id accrectypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        system.runas(partneruser){
            Account partnerAccount=TestDataSetUpUtils.createPartnerAccount(PartnrRecordTypeId);
            LookupSearchResult lkup = new LookupSearchResult(partnerAccount.Id,'Account','ab','test','test');
            lkup.getIcon();
            lkup.getId();
            lkup.getSObjectType();
            lkup.getSubtitle();
            lkup.getTitle();
            MRCommissionPartnerAccountDetailsCtrl.fetchPartnerAccounts('Test Account',partnerAccount.Id);
        }
        
    }
    
}