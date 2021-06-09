/**
* @author Accenture
* @date March 2020
*

* @description Test class for the controller class ExternalOrdersController
*/
@isTest(SeeAllData = false)
private class ExternalOrdersControllerTest {
    
    @testSetup
    static void testSetUp() {
        TestDataSetUpUtils.insertCustomSettings(); // need custom settings for triggers to run
        
    } 
    
    static testMethod void callOrderAPI()
    {
        String responseBody = '{"isB2B":"Y","userid":"b2b_sit@mailinator.com","totalrec":1380,"OrderHistory_data":[{"order_date":"03-31-2020 07:20:31 UTC","confirmation_number":"EC100465454","transaction_id":"EC100465454","order":[{"order_number":"EC100465454","status_value":"INP"}],"total_cost":"32","shipping_handeling":null,"est_tax_to_be_collected":null,"account_number":"1035092006","customer_name":"HUDSON COUNTY","contract":null,"order_by":"Sweety1 Priya1","purchase_order":"12345678","purchase_date":"03-31-2019 07:20:31 UTC","invoice_available":"N","subscription_id":"29816773","woc_customer_ref":"1260","billing_term":null,"source_system_id":"COF","extended_price":0,"type_of_order":null,"oh_field1":"32","oh_field2":null,"oh_field3":"N","oh_field4":"Y","oh_field5":"Y","isOrderReturnable":"N"}]}';
        String response;
        String payload = '{"p_search_type":null,"p_search_date_type":null,"p_ordered_by":null,"p_search_text":null,"customer_number":"","dt_from_date":null,"dt_to_date":null,"pageSize":1000000,"pageIndex":1,"p_order_status":"All","p_SortField":"order_date","p_SortDirection":"DESC"}';
        User partneruser= TestDataSetUpUtils.createPortalUser();
        System.runAs(partneruser)
        {
            Test.startTest();
            //TODO: could not find that OrderDetailMockTest class using EInvoiceControllerMockTest for now.
            //It can be updated later
            Test.setMock(HttpCalloutMock.class, new EInvoiceControllerMockTest(200,responseBody));
            response=ExternalOrdersController.ordersList(payload);
            Test.stopTest();
        }
        System.assert(response!=null);
    }
    
    static testMethod void callOrderDetailAPI()
    {
        String responseBody = '{"order_header":{"order_number":[null],"order_placed_dt":"2020-03-28T01:27:22","total":5576.7,"total_ordered_items":5,"ordered_by":"Nidhi Lakhara","ordered_by_id":null,"order_status":"INP","order_ship_dt":null,"confirmation_number":"EC100577823","contract_number":null,"transaction_id":null,"source_system_id":"COF","po_date":"2020-03-28T01:27:22","po_number":"EC100577823","project_number":null,"items_subtotal":5230.2,"account_name":"HUDSON COUNTY","account_number":"1035092006","shipping_handeling":0,"total_before_tax":5230.2,"discount":-784.53,"est_tax_to_be_collected":346.5,"grand_total":5576.7,"payment_method":"Net Due in 30 Days","applied_discount":"15% - Registered Web Order","billing_address":{"line1":"HUDSON COUNTY","line2":"567 PAVONIA AVE ","line3":"JERSEY CITY, NJ, 07306","line4":"United States"},"receipent_name":"Not Available","shipping_carrier":null,"shipping_method":"FEDEX-Parcel-Ground","shipping_address":{"line1":"HUDSON COUNTY","line2":"3 HECKMAN DR ","line3":"JERSEY CITY, NJ, 07097","line4":"United States"},"ship_partial":null,"invoice_image_loaded":"N","ship_order_complete":null,"ship_early":null,"recieve_email_alerts":"N","isb2c":null,"parametric_data_applicable":"Y","customer_name":null,"customer_number":null,"user_id":null,"ultimate_destination":{"line1":"HUDSON COUNTY","line2":"3 HECKMAN DR ","line3":"JERSEY CITY, NJ, 07097","line4":"United States"},"ultimate_country":"United States","project_contract_number":null,"OCC_promotion_applied":"Y","subscription_id":"29816773","woc_customer_ref":"1260","billing_term":null,"MonthlyCharge":35,"type_of_order":null,"IsOrderReturnable":"N","return_tracknumber":null,"return_credit_memo":null,"restockingFeeTotal":0,"ReturnTaxAmt":346.5,"oh_field1":"Y","oh_field2":"Y","oh_field3":"Y","oh_field4":"N","oh_field5":"N"},"order_line_details":[{"line_number":1,"item_number":"RRDN4362A","order_number_line":null,"line_status":"IN","item_description":"A1- SOLAR CALL BOX","unit_price":2052,"line_ordered_qty":2,"line_shipped_qty":0,"line_open_qty":2,"line_cancelled_qty":0,"extended_price":4104,"item_image_url":"https://s3.amazonaws.com/occ-images/WPNN4013A.image01.battery.jpg","expected_ship_dt":null,"revise_ship_dt":null,"shipped_dt":null,"line_discount":"N","subscription_id":null,"woc_customer_ref":null,"order_source_system_id":"GF","IsLineReturnable":"N","hasSerialNumber":"Y","SerialNumbers":"-","od_field1":"Y","od_field2":"Y","od_field3":"Y","od_field4":"N","od_field5":"N","hasOptions":"N","options":[],"supplemental_info":[{"key":"646NAME","order_quantity":2,"item_number":"RRDN4362A","value":"fbdsanfbfbdsabadb a","description":"A1- SOLAR CALL BOX","option_number":" ","order_number":"EC100577823","line_number":1},{"key":"43CNTCT","order_quantity":2,"item_number":"RRDN4362A","value":"fbdsanfbfbdsabadba","description":"A1- SOLAR CALL BOX","option_number":" ","order_number":"EC100577823","line_number":1}],"frequency_info":[]}]}';
        String confirmationNumber = 'EC100577823';
        String response;
        User partneruser= TestDataSetUpUtils.createPortalUser();
        System.runAs(partneruser)
        {
            Test.startTest();
            //TODO: could not find that OrderDetailMockTest class using EInvoiceControllerMockTest for now.
            //It can be updated later
            Test.setMock(HttpCalloutMock.class, new EInvoiceControllerMockTest(200,responseBody));
            response=ExternalOrdersController.orderDetail(confirmationNumber);
            Test.stopTest();            
        }
        System.assert(response!=null);
    }
    
    static testMethod void callOrderTrackingAPI()
    {
        String responseBody = '{"order_header":{"order_number":null,"order_status":null,"confirmation_number":"EC100577823","receipent_name":"Not Available","invoice_number":null,"billing_term":null,"packing_list":null,"ot_field1":"N","ot_field2":"N","ot_field3":"Y","shipping_address":{"line1":"HUDSON COUNTY","line2":"3 HECKMAN DR ","line3":"JERSEY CITY, NJ, 07097","line4":"United States"}},"order_line_details":[{"item_number":"RRDN4362A","line_status":"IN","item_description":"A1- SOLAR CALL BOX","unit_price":2052,"line_ordered_qty":2,"line_shipped_qty":0,"line_open_quantity":null,"extended_price":4104,"expected_ship_dt":null,"shipping_carrier":null,"tracking_number":null,"line_number":1,"line_cancelled_qty":null,"shipped_dt":null,"carrier_url":null,"packing_list":null,"serial_number_list":"-","otl_field1":"N","otl_field2":"N","otl_field3":"Y","subscription_id":null,"woc_customer_ref":null,"order_source_system_id":"GF"}]}';
        String confirmationNumber = 'EC100577823';
        String response;
        User partneruser= TestDataSetUpUtils.createPortalUser();
        System.runAs(partneruser){
            Test.startTest();
            //TODO: could not find that OrderDetailMockTest class using EInvoiceControllerMockTest for now.
            //It can be updated later
            Test.setMock(HttpCalloutMock.class, new EInvoiceControllerMockTest(200,responseBody));
            response=ExternalOrdersController.orderTracking(confirmationNumber);
            Test.stopTest();
        }
        System.assert(response!=null);
    }
    
    static testMethod void orderLineStatusMapping()
    {   
        Map<String,String> codeToStatus;
        Test.startTest();
        codeToStatus=ExternalOrdersController.getOrderLineStatusMapping();
        Test.stopTest();
        System.assert(codeToStatus!=null);
    }
    
    static testMethod void orderStatusMapping()
    {
        Map<String,String> codeToStatus;
        Test.startTest();
        codeToStatus=ExternalOrdersController.getOrderStatusMapping();
        Test.stopTest();
        System.assert(codeToStatus!=null);
    }
    
    static testMethod void getAllMCNs()
    {
        Id custRecTypeId = GlobalUtility.getRecordTypeIdByDeveloperName('Account','SoldToAccount'); //customer
        Id mcnRecTypeId = GlobalUtility.getRecordTypeIdByDeveloperName('Account','Motorola_Customer_Number');
        
        List<Account> cusAcc = TestDataSetUpUtils.createAccounts(3,custRecTypeId);
        update cusAcc;
        
        List<Account> mcnAcc = TestDataSetUpUtils.createAccounts(1,mcnRecTypeId);
        mcnAcc[0].Customer_or_Prospect_Account__c = cusAcc[0].id;
        mcnAcc[0].Motorola_Customer_Number__c = '123445';
        update mcnAcc;
        ExternalOrdersController.getAllMCNs(cusAcc[0].id);
    }
}