@isTest
public with sharing class DTSFPART_HideButtonsControllerTest {
  
    @TestSetup
    static void testSetup(){
        Case testCase = new Case(
            Status = 'Closed'
        );

        insert testCase;
    }

    @isTest
    public static void hideButtonsTest() {
        
        Case testCase = [ SELECT Id, Status
                          FROM Case
                          WHERE Status = 'Closed' 
                          LIMIT 1 ];

        Test.startTest();
        List<String> hiddeButtonList = DTSFPART_HideButtonsController.hideButtons(testCase.Id);
        Test.stopTest();

        System.assertNotEquals(null, hiddeButtonList);
    }

}