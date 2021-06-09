/************************************************************************************************* 
* File Name  : EMEAHomePageController_Test
* Description: Test class for EMEAHomePageController class
* Modification Log 
* ============================================================================= 
*   Date               Author                         Modification 
* ---------------------------------------------------------------------------------------
* 13-Aug-2018     Satish Maddhi(TCS)	  			Initial development
*
*************************************************************************************************/
@isTest
public class EMEAHomePageController_Test {
	@testSetup
    static void testSetUp() {
       TestDataSetUpUtils.insertCustomSettings();
    }
    
    static testMethod void test_EMEAHomePage() {
        EMEAHomePageController.getKeyContacts();
    }
}