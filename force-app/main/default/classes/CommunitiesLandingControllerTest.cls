/************************************************************************************************* 
* File Name  : CommunitiesLandingControllerTest
* Description: Test class for CommunitiesLandingController class
* Modification Log 
* ============================================================================= 
*   Date               Author                         Modification 
* ---------------------------------------------------------------------------------------
* 09-April-2018     Satish Maddhi(TCS)	  Removed SeeAllData=true and increased code coverage
*
*************************************************************************************************/

@IsTest public with sharing class CommunitiesLandingControllerTest {
    
    static testMethod void testCommunitiesLandingController() {
        // Instantiate a new controller with all parameters in the page
        CommunitiesLandingController controller = new CommunitiesLandingController();
        PageReference pageRef = controller.forwardToStartPage();
        //PageRef is either null or an empty object in test context
        if(pageRef != null){
            String url = pageRef.getUrl();
            if(url != null){
                System.assertEquals(true, String.isEmpty(url));
                //show up in perforce
            }
        }
    }
}