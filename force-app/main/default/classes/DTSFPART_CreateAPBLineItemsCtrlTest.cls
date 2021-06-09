@isTest
public class DTSFPART_CreateAPBLineItemsCtrlTest {
    
    @testSetup
    static void testSetUp() {
        DTSFPART_TestDataSetUpUtils.insertCustomSettings();
    }

    @isTest
    public static void isLoggedInFromCommunityTest() {
        Boolean loggedInSource = DTSFPART_CreateAPBLineItemsCtrl.isLoggedInFromCommunity();
        System.assertEquals(loggedInSource, false);
    }
    
    @isTest
    public static void generateAuthTokenTest() {
        List<Above_Price_Book__c> apbRecord = DTSFPART_TestDataSetUpUtils.createAPBRecords(1);
        String authToken = DTSFPART_CreateAPBLineItemsCtrl.generateAuthToken(apbRecord[0].Id);
        System.assertNotEquals(authToken, null);
    }
}