/**
 * @author       Sagar Sindhi
 * @created      2020-10-12
 * @updated      2020-12-16
 * @isTesting	 DTSFPART_CommissionSummaryController
 */
@isTest
public class DTSFPART_CommissionSummary_Test {
    
    public static final String FIELDS = 'TRX_NUMBER,BILL_PARTY_NAME,STATUS_TRX,PURCHASE_ORDER';
    
    @isTest
    public static void test_getOrderStatus_Ok() {
        Test.startTest();
        Test.setMock(
            HttpCalloutMock.class,
            new DTSFPART_MockHttpResponseGenerator(200)
        );
        String result = DTSFPART_CommissionSummaryController.getOrderStatus('0958860050265',FIELDS,'Mulesoft_OAuth');
        System.assert(String.isNotBlank(result));
        Test.stopTest();
    }

    @isTest
    public static void test_getOrderStatus_NO_DATA() {
        Test.startTest();
        Test.setMock(
            HttpCalloutMock.class,
            new DTSFPART_MockHttpResponseGenerator(500)
        );
        String result = DTSFPART_CommissionSummaryController.getOrderStatus('0958530080836',FIELDS,'Mulesoft_OAuth');
        System.assertEquals(System.Label.PP_NoInvoices, result);
        Test.stopTest();
    }

    @isTest
    public static void test_getOrderStatus_ErrorOccurred() {
        Test.startTest();
        Test.setMock(
            HttpCalloutMock.class,
            new DTSFPART_MockHttpResponseGenerator(400)
        );
        String result = DTSFPART_CommissionSummaryController.getOrderStatus('0958530080836',FIELDS,'');
        System.assert(String.isNotBlank(result));
        Test.stopTest();
    }
}