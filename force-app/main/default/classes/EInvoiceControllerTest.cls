@isTest
public class EInvoiceControllerTest {
    
    public static testMethod void callMuleData(){
        String sampleContacts = '[{"P_ACTION_TYPE":"New","P_CUSTOMER_SITE":"455028","P_CONTACT_FIRST_NAME":"test","P_CONTACT_LAST_NAME":"contact","P_EMAIL":"MSI-pawel.wrobel1@motorolasolutions.com","P_CONTACT_ROLE":"Accounts Payable-All Areas Default","P_CONTACT_REFERENCE":"","email":"MSI-pawel.wrobel1@motorolasolutions.com","emailInput":"","BILL_TO_SITE_CONTACT_NAME":"test contact"}]';
        String customerData = '[{"P_CURR_INV_PREFERENCE":"SELECTION PENDING","P_NEW_INV_PREFERENCE":"SELECTION PENDING","P_SOURCE_SYSTEM":"PORTAL","P_SOURCE_SYSTEM_REF":"","P_REQUESTOR_EMAIL":"sagar.sindhi@motorolasolutions.com","P_REQUESTOR_COREID":"FPJ864","P_GF_CUSTOMER_NUMBER":"1000194001","P_GF_CUSTOMER_NAME":"STERLING HEIGHTS, CITY OF","P_FLIP_ALL_ACCTS":""}]';
        String responseBody = '[{"P_STATUS_MSG":null,"P_STATUS_FLAG":"Success"}]';
        
        Test.startTest();
        // call for covering catch block
        EInvoiceController.handleCustomerPref('1000194001','','EInvoice_Customer');
        
        // call for covering if condition
        Test.setMock(HttpCalloutMock.class, new EInvoiceControllerMockTest(200,responseBody));
        EInvoiceController.handleCustomerPref('1000194001','','EInvoice_Customer');
        
        EInvoiceController.callMuleAPI('1000194001','EInvoice_CCPOST');
        EInvoiceController.serverRequest(sampleContacts,sampleContacts,sampleContacts,sampleContacts,customerData);
        
        // call for covering else condition
        Test.setMock(HttpCalloutMock.class, new EInvoiceControllerMockTest(500,responseBody));
        EInvoiceController.handleCustomerPref('1000194001','','EInvoice_Customer');
        Test.stopTest();
    }
    
    public static testMethod void callOtherMethods(){
        Test.startTest();
        EInvoiceController.handleInvoiceRecords('1000194001','test@mail.com','Print','test');
        EInvoiceController.handleInvoiceRecords('1000194001','','Print','test');
        EInvoiceController.fetchLoggedinUserDetails();
        EInvoiceController.isCommunity();
        Test.stopTest();
    }
}