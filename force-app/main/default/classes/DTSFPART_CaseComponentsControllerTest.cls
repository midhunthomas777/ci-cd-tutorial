@IsTest
public with sharing class DTSFPART_CaseComponentsControllerTest {

    @TestSetup
    private static void setup() {
        Case testCase = new Case(
            Status = 'Closed'
        );
        insert testCase;
    }

    @IsTest
    private static void getCasesWithFieldsTest() {
        List<Case> cases = new List<Case>();
        Test.startTest();
        cases = DTSFPART_CaseComponentsController.getCasesWithFields(
            'Status', 
            'Status = \'Open\'',
            'Closed', 
            'Status', 
            'LIMIT 2'
        );
        Test.stopTest();

        // System.assertEquals(1, cases.size(), 'Wrong number of cases found.');
    }
}