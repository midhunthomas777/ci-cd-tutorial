/************************************************************************************************* 
* File Name  : CommunitiesLoginControllerTest
* Description: Test class for CommunitiesLoginController class
* Modification Log 
* ============================================================================= 
*   Date               Author                         Modification 
* ---------------------------------------------------------------------------------------
* 09-April-2018     Satish Maddhi(TCS)	  Removed SeeAllData=true and increased code coverage
*
*************************************************************************************************/
@IsTest global with sharing class CommunitiesLoginControllerTest {
    @IsTest 
    global static void testCommunitiesLoginController () {
     	CommunitiesLoginController controller = new CommunitiesLoginController();
     	System.assertEquals(null, controller.forwardToAuthPage());       
    }    
}