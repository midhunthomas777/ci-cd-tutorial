/************************************************************************************************* 
* File Name  : CommunitiesSelfRegControllerTest
* Description: Test class for CommunitiesSelfRegController class
* Modification Log 
* ============================================================================= 
*   Date               Author                         Modification 
* ---------------------------------------------------------------------------------------
* 09-April-2018     Satish Maddhi(TCS)	  Removed SeeAllData = true and increased code coverage
*
*************************************************************************************************/
@IsTest public with sharing class CommunitiesSelfRegControllerTest {
    @IsTest 
    public static void testCommunitiesSelfRegController() {
        CommunitiesSelfRegController controller = new CommunitiesSelfRegController();
        controller.firstName = 'FirstName';
        controller.lastName = 'LastName';
        controller.email = 'test@force.com';
        controller.communityNickname = 'test';
        
        // registerUser will always return null when the page isn't accessed as a guest user
        System.assert(controller.registerUser() == null);    
        
        controller.password = 'abcd1234';
        controller.confirmPassword = 'abcd123';
        System.assert(controller.registerUser() == null);  
    }    
}