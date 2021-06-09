@isTest
public class GenericFieldSetControllerTest {
    @isTest private static void getFieldsTest(){
        TestDataSetUpUtils.insertCustomSettings();
        GenericFieldSetController.getFields('Empower_Application__c','PartnerEmpowerFieldSetFirstPage');
        GenericFieldSetController.getForm('Empower_Application__c','PartnerEmpowerFieldSetFirstPage');
        system.runAs(new User(Id=userInfo.getUserId())){
            User interUser=TestDataSetUpUtils.createPortalUser();
            interUser.Selected_User_Theater__c='LA';
            update interUser;
            GenericFieldSetController.fetchUser();
        }
        
    }
}