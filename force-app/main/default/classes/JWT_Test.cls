/**
* @author Swarupa
* @date Nov 2020
*
* @group Utilities
* @group-content ../../Utility/JWT.htm
*
* @description Test Coverage Class for JWT.apxc
*
*/

@isTest
public class JWT_Test {
    
     @testSetup
    static void testSetUp() {
        TestDataSetUpUtils.insertCustomSettings();
    }

    @isTest
    public static void generateAuthTokenTest() {
        Map<String,Object> samplePayload = new Map<String,Object>();
        String testPrivateKey = 'Dummy1234';
        //Passing Test Account Parameters in test Payload
        List<Account> accList = TestDataSetUpUtils.createAccounts(1, GlobalUtility.getRecordTypeIdByDeveloperName('Account', 'Prospect'));
        samplePayload.put('Account Name',accList.get(0).Name);
        samplePayload.put('Billing State',accList.get(0).BillingState);
        Test.startTest();
        String testAuthToken = JWT.generateAuthToken(samplePayload, testPrivateKey);
        System.assertNotEquals(testAuthToken, null);
        Test.stopTest();
        
    }
}