@isTest 
public class PBBRemovePermSetGroupTest {
	static {
        TestDataSetUpUtils.insertCustomSettings();
    }
    @isTest static void testBulkPermSetGroup() {
        //User newUser = TestDataSetUpUtils.createInternalUser();
        
        UserTriggerHandler.TriggerDisabled = true;
        try{
        Profile Prof = [SELECT Id FROM Profile WHERE Name = 'System Administrator' and UserLicense.Name ='Salesforce' Limit 1]; 
        
        List<User> userList = new List<User>();
        
        User stduser = new User(alias = 'partusr',email='standarduser@motorolasolutions.com',emailencodingkey='UTF-8', 
                                lastname='Testing', languagelocalekey='en_US',localesidkey='en_US', 
                                profileid = Prof.Id,timezonesidkey='America/Los_Angeles', 
                                username='partnerusr@testorg.com',CommunityNickname='ABCFED',	FederationIdentifier='ABCFED',
                                Core_ID__c='ABCFED',EmployeeNumber = 'ABCFED');
        
        Test.startTest();
        insert stduser;    
            
            
        list<PBBRemovePermSetGroup.RemovePermSetGrpRequest> PSRs = new list<PBBRemovePermSetGroup.RemovePermSetGrpRequest>();
        PBBRemovePermSetGroup.RemovePermSetGrpRequest PSR = new PBBRemovePermSetGroup.RemovePermSetGrpRequest();
        PSR.UserId = stduser.id;
        PSR.PermissionSetGroupId = system.label.Enable_SSO;
        PSRS.add(PSR);
        PBBRemovePermSetGroup.RemovePermSetGroup(PSRs);
        //stduser = TestDataSetUpUtils.createInternalUser() ;
        Test.stopTest();
        stduser.IsActive = false;
        update stduser;
        UserTriggerHandler.TriggerDisabled = false;
        }catch(Exception ex){
            
        }
    }
}