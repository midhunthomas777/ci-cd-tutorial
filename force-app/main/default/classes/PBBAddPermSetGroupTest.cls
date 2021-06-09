@isTest
public class PBBAddPermSetGroupTest {
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
                                    profileid = Prof.Id,timezonesidkey='America/Los_Angeles', isActive=true,Login_Type__c = 'SSO',
                                    username='partnerusr@testorg.com',CommunityNickname='ABCFED',   FederationIdentifier='ABCFED',
                                    Core_ID__c='ABCFED',EmployeeNumber = 'ABCFED');
            
            Test.startTest();
            insert stduser;    
            //stduser = TestDataSetUpUtils.createInternalUser() ;
            Test.stopTest();
            /*list<PBBAddPermSetGroup.AddPermSetGrpRequest> PSRs = new list<PBBAddPermSetGroup.AddPermSetGrpRequest>();
            PBBAddPermSetGroup.AddPermSetGrpRequest PSR = new PBBAddPermSetGroup.AddPermSetGrpRequest();
            PSR.UserId = stduser.id;
            PSR.PermissionSetGroupId =  system.label.Enable_SSO;
            PSRS.add(PSR);
            PBBAddPermSetGroup.AddPermSetGroup(PSRs); */  
            stduser.IsActive = false;
            update stduser;
            
            
            UserTriggerHandler.TriggerDisabled = false;
        }catch(Exception ex){
            
        }
    }
    
    @isTest static void testBulkPermSetGroup1() {
        //User newUser = TestDataSetUpUtils.createInternalUser();
        
        UserTriggerHandler.TriggerDisabled = true;
        try{
            list<PBBAddPermSetGroup.AddPermSetGrpRequest> PSRs = new list<PBBAddPermSetGroup.AddPermSetGrpRequest>();
            PBBAddPermSetGroup.AddPermSetGrpRequest PSR = new PBBAddPermSetGroup.AddPermSetGrpRequest();
            PSR.UserId = '00534000003hcJTAAY';
            PSR.PermissionSetGroupId =  system.label.Enable_SSO;
            PSRS.add(PSR);
            PBBAddPermSetGroup.AddPermSetGroup(PSRs);
            
            UserTriggerHandler.TriggerDisabled = false;
        }catch(Exception ex){
            
        }
    }
}