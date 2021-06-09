/**
* @author Accenture
* @date March 2020
*

* @description Test class for the controller class MotoCommunityHeaderController
*/
@isTest(seeAllData = false)
private class MotoCommunityHeaderControllerTest {
    
    @testSetup
    static void testSetUp() {
        TestDataSetUpUtils.insertCustomSettings(); // need custom settings for triggers to run
    } 
    
    static testMethod void getUserDetails()
    {
        MotoCommunityHeaderController.UserDetails userDetils;
        User user = TestDataSetUpUtils.createPortalUser();
        System.runAs(user)
        {
            Test.startTest();
            userDetils = MotoCommunityHeaderController.getUserDetails('Partner Self Service');
            Test.stopTest();
        }
        System.assert(userDetils!=null);
        System.assertEquals(user.FirstName, userDetils.firstName);

    }
}