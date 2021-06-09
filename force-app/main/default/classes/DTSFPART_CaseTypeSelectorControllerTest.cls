@IsTest
public with sharing class DTSFPART_CaseTypeSelectorControllerTest {

    @TestSetup
    private static void setup() {
    }

    @IsTest
    private static void getCaseTypeByCategoryTest() {
        List<DTSFPART_CaseTypeSelectorController.RadioButtonGroupSettings> buttons = new List<DTSFPART_CaseTypeSelectorController.RadioButtonGroupSettings>();
        Test.startTest();
        buttons = DTSFPART_CaseTypeSelectorController.getCaseTypeByCategory();
        Test.stopTest();

        System.assertEquals(2, buttons.size(), 'Wrong number of buttons found.');
    }
}