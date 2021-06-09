@isTest
public class MRCPQ_DeactivateAppAccessControllerTest {
    @isTest
    public static void deactivateAppAccessTest(){
        TestDataSetUpUtils.insertCustomSettings();
        Id accrectypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        User partnerUsr = TestDataSetUpUtils.createPortalUser();
        Id siteID = TestDataSetUpUtils.createSite();
        ID partnerAccountId= [Select accountId from Contact WHERE Id=:partnerUsr.ContactId].accountId;
        system.debug('Only partnerAccountId'+partnerAccountId); 
        Account acc = new Account(id=partnerAccountId,Applications_Enabled__c='CPQ',BigMachines__Partner_Organization__c ='test34');
        update acc;
        Applications_Access__c appAcc = new Applications_Access__c();
        appAcc.App_Name__c='CPQ';
        appAcc.Contact__c=partnerUsr.ContactId;
        appAcc.Is_Bypass__c=true;
        //appAcc.App_Access_Status__c='T&C';
        insert appAcc;
        //partnerUsr.FederationIdentifier=null;
        //update partnerUsr;
        //appAcc.App_Access_Status__c='T&C';
        update appAcc;
        
        System.runAs(partnerUsr){
            MRCPQ_DeactivateAppAccessController.deactivateAppAccess();
            MRCPQ_DeactivateAppAccessController.deactivateApplicationAccess(appAcc.id);
                        MRCPQ_DeactivateAppAccessController.reactivateApplicationAccess(appAcc.id);

        }
                    MRCPQ_DeactivateAppAccessController.deactivateAppAccess();

    }
}