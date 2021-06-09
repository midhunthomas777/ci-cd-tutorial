@IsTest
public class FieldSetControllerTest {
    
    private static testMethod void findParentIdTest() {
        FieldSetController.findParentId(UserInfo.getUserId(), 'CreatedById');
        FieldSetController.readFieldSet('LeadConversionPanel', 'Opportunity');
    }
}