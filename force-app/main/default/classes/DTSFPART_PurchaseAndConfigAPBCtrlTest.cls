@isTest
public class DTSFPART_PurchaseAndConfigAPBCtrlTest {
    
    @testSetup
    static void testSetUp() {
        DTSFPART_TestDataSetUpUtils.insertCustomSettings();
    }

    @isTest
    public static void isLoggedInFromCommunityTest() {
        Boolean loggedInSource = DTSFPART_PurchaseAndConfigAPBCtrl.isLoggedInFromCommunity();
        System.assertEquals(loggedInSource, false);
    }
    
    @isTest
    public static void generateAuthTokenTest() {
        List<Above_Price_Book__c> apbRecord = DTSFPART_TestDataSetUpUtils.createAPBRecords(1);
        String authToken = DTSFPART_PurchaseAndConfigAPBCtrl.generateAuthToken(apbRecord[0].Id, '/s');
        DTSFPART_PurchaseAndConfigAPBCtrl.submitAndProcessApprovalReq(apbRecord[0].Id);
        System.assertNotEquals(authToken, null);
    }
}