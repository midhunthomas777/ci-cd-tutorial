@IsTest
public class MotoCommunityBannerControllerTest {
    
    @testSetup
    static void testSetUp() {
        TestDataSetUpUtils.insertCustomSettings(); // need custom settings for triggers to run
    }
    
    @IsTest
    public static void testGetUserDetails() {
        User partneruser= TestDataSetUpUtils.createCommunityUser();
        System.runAs(partneruser) {
            Map<String,Object> userInfo = MotoCommunityBannerController.getUserDetails();
            System.assertNotEquals(null, userInfo);
        }
    }
    
    @IsTest
    public static void testGetOrderCount() {
        
        String responseBody = '{"totalrec":10}';
        User partneruser= TestDataSetUpUtils.createCommunityUser();
        System.runAs(partneruser) {
            Test.startTest();
            
            Test.setMock(HttpCalloutMock.class, new EInvoiceControllerMockTest(200,responseBody));
            Integer count = MotoCommunityBannerController.getOrderCount('');
            //System.assertEquals(10, count);
            Test.stopTest();
        }
        
    }
    
    @IsTest
    public static void testGetCaseCount() {
        String responseBody = '{"result":{ "stats": { "count": 10 }}}';
        User partneruser= TestDataSetUpUtils.createCommunityUser();
        System.runAs(partneruser) {
            Test.startTest();
            
            Test.setMock(HttpCalloutMock.class, new EInvoiceControllerMockTest(200,responseBody));
            Integer count = MotoCommunityBannerController.getCaseCount(new Map<String,String>());
            System.assertEquals(10, count);
            Test.stopTest();
        }
    }    
    
    @IsTest
    public static void testGetContractCount() {
        
        String responseBody ='[{ "END_USER_SITE_NUMBER": "109467", "SERVICE_END_DATE": "2025-02-25T00:00:00", "QUANTITY": 1, "SERVICE_START_DATE": "2020-02-26T00:00:00", "SYSTEM_NUMBER": "109467_VESTA 9-1-1", "ITEM_NUMBER": "809800-35124", "CUST_ADDRESS1": "5715 GLENWOOD AVE", "CUST_ADDRESS2": null, "CUST_ADDRESS3": null, "CONTRACT_LINE_STATUS": "ACTIVE", "SITE_STATE": "NC", "CONTRACT_START_DATE": "26-FEB-2020", "CUST_POSTAL_CODE": "27612", "CUST_PO_NUMBER": null, "CONTRACT_END_DATE": "25-FEB-2025", "SITE_NAME": "At&T Hosted - North Carolina 2A", "CONTRACT_NUMBER": "USC000210079", "LINE_NUMBER": "1", "CUSTOMER_ACCT_NUM": "1208448233", "CONTRACT_NUMBER_MODIFIER": null, "CUSTOMER_NAME": "AT&T SERVICES", "ITEM_DESCRIPTION": "V911 ACT VIEW SW SPT 5YR", "CONTRACT_HEADER_STATUS": "ACTIVE", "CUST_CITY": "RALEIGH" }]';
        String response;
        User partneruser= TestDataSetUpUtils.createPortalUser();
        
        System.runAs(partneruser)
        {
            Test.startTest();
            //TODO: could not find that CommonMockTest class using EInvoiceControllerMockTest for now.
            //It can be updated later
            Test.setMock(HttpCalloutMock.class, new EInvoiceControllerMockTest(200,responseBody));
            response=MotoCommunityBannerController.getContracts(); // running for partner user
            Test.stopTest();            
        }
        System.assert(response!=null);
    }    
    
    @IsTest
    public static void testMotoCommunityTabClass(){
        Id custRecTypeId = GlobalUtility.getRecordTypeIdByDeveloperName('Account','SoldToAccount');
        List<Account> cusAccLst = TestDataSetUpUtils.createAccounts(1,custRecTypeId);
        MotoCommunityTabsController.getTabsMetadata(cusAccLst.get(0).Id);
    }
    
}