/**
 * @author		Paweł Woźniak
 * @created		2020-09-18
 * @updated		2021-02-16
 * @description	Usage in test classes Test.setMock(HttpCalloutMock.class, new DTSFPART_DTSFPART_MockHttpResponseGenerator());
*/

global class DTSFPART_MockHttpResponseGenerator implements HttpCalloutMock  {
    public static final String UNAUTHORIZED_ENDPOINT = 'TEST MESG: Unauthorized endpoint, please check Setup->Security->Remote site settings.';

    Boolean isUnathorizedEndpoint;
    Integer returnCode;
    String userEmail;

    public DTSFPART_MockHttpResponseGenerator(Boolean isUnathorizedEndpoint) {
        this.isUnathorizedEndpoint = isUnathorizedEndpoint;
    }

    public DTSFPART_MockHttpResponseGenerator(Integer returnCode) {
        this.isUnathorizedEndpoint = false;
        this.returnCode = returnCode;
    }
    
    public DTSFPART_MockHttpResponseGenerator(Integer returnCode, String userEmail) {
        this.isUnathorizedEndpoint = false;
        this.returnCode = returnCode;
        this.userEmail = userEmail;
    }

    global HTTPResponse respond(HTTPRequest req) {

        if (isUnathorizedEndpoint == true) {
            CalloutException e = (CalloutException) CalloutException.class.newInstance();
            e.setMessage(UNAUTHORIZED_ENDPOINT);
            throw e;
        }

        String endpointURL = req.getEndpoint();
        String requestMethod = req.getMethod();
        System.debug('Request endpoint: ' + endpointURL);
        System.debug('Request method: ' + requestMethod);
        System.debug('Return code: ' + returnCode);

        // ### DTSFPART_LWC_ResendInvitation 200 OK
        if (endpointURL.contains('ecom/v1.0/c360/admin/v1.0/user/test200@test.pl/resendemail') && req.getMethod() == 'POST' && returnCode == 200) {
            System.debug('Inside DTSFPART_LWC_ResendInvitation mock response 200.');
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"data":{"app":"AEM","path":"/","email":"e18a_e18a_test_test.pl_mailinator.com@mailinator.com","login_id":"test@test.pl","token_generated_time":"2020-09-18T10:12:22.389Z"},"status":"success","success":true}');
            res.setStatusCode(returnCode);
            res.setStatus('OK');
            return res;
        }

        // ### DTSFPART_LWC_ResendInvitation 400 validation failed
        if (endpointURL.contains('ecom/v1.0/c360/admin/v1.0/user/test400@test.pl/resendemail') && req.getMethod() == 'POST' && returnCode == 400) {
            System.debug('Inside DTSFPART_LWC_ResendInvitation mock response 400.');
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"error":{"code":"not_found","message":"No inactive user with id:tes400test.pl"}');
            res.setStatusCode(returnCode);
            res.setStatus('Bad Request');
            return res;
        }
		
        // ### DTSFPART_UserInvitationController 200 UserExist OK
        if (endpointURL.contains('/ecom/v1.0/c360/user/'+userEmail+'/ldap/v2.2') && req.getMethod() == 'GET' && returnCode == 200) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"success":"true"}');
            res.setStatusCode(returnCode);
            res.setStatus('OK');
            return res;
        }
        
        // ### DTSFPART_UserInvitationController 204 UserDoesNotExist
        if (endpointURL.contains('/ecom/v1.0/c360/user/'+userEmail+'/ldap/v2.2') && req.getMethod() == 'GET' && returnCode == 204) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"success":"false"}');
            res.setStatusCode(returnCode);
            return res;
        }
        
        // ### DTSFPART_UserInvitationController 302 API ERROR
        if (endpointURL.contains('/ecom/v1.0/c360/user/'+userEmail+'/ldap/v2.2') && req.getMethod() == 'GET' && returnCode == 302) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"success":"false"}');
            res.setStatusCode(returnCode);
            return res;
        }

        // ### DTSFPART_DashboardComponentsController.callMulesoft 200 UserExist OK
        if (endpointURL.contains('/ecom/orders/molorderhistory/v5.0') && req.getMethod() == 'POST' && returnCode == 200) {
            System.debug('Inside DTSFPART_DashboardComponentsController mock response 200.');
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"success":"true"}');
            res.setStatusCode(returnCode);
            res.setStatus('OK');
            return res;
        }

        // ### DTSFPART_DashboardComponentsController.callMulesoftProxy 200 UserExist OK
        if (endpointURL.contains('/gw/myview/api/v1.0') && req.getMethod() == 'GET' && returnCode == 200) {
            System.debug('Inside DTSFPART_DashboardComponentsController mock response 200.');
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"success":"true"}');
            res.setStatusCode(returnCode);
            res.setStatus('OK');
            return res;
        }

        // ### DTSFPART_DashboardComponentsController.callMulesoftFileProxy
        if (endpointURL.contains('/gw/myview/api/v1.0') && req.getMethod() == 'POST' && returnCode == 200) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"success":"true"}');
            res.setStatusCode(returnCode);
            res.setStatus('OK');
            return res;
        }

        // ### DTSFPART_CommissionSummaryController 200 Ok
        if (endpointURL.contains('/ecom/invoices/invoice_header/v1.0') && req.getMethod() == 'GET' && returnCode == 200) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('[{"STATUS_TRX": "OP","BILL_PARTY_NAME": "WILSON POLICE, CITY OF","PURCHASE_ORDER": "LEASE# 24800","TRX_NUMBER": "41284543"}]');
            res.setStatusCode(returnCode);            
            return res;
        }
        
        // ### DTSFPART_CommissionSummaryController 500 No Data Available
        if (endpointURL.contains('/ecom/invoices/invoice_header/v1.0') && req.getMethod() == 'GET' && returnCode == 500) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('No Data Found (com.msi.invoices.CustomException).');
            res.setStatusCode(returnCode);            
            return res;
        }
        
        // ### DTSFPART_CommissionSummaryController 400 Error Occurred
        if (endpointURL.contains('/ecom/invoices/invoice_header/v1.0') && req.getMethod() == 'GET' && returnCode == 400) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(returnCode);            
            return res;
        }

        // ### DTSFPART_CommonComponentsController get remedy attachment
        if (endpointURL.contains('gw/remedyprxy/arsys/v1/entry/HPD:WorkLog/') && req.getMethod() == 'GET' && returnCode == 200) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'text/plain');
            res.setBodyAsBlob(EncodingUtil.base64Decode('UmVtZWR5Q2FzZVRlc3QgYXR0YWNobWVudA=='));
            res.setStatus('SUCCESS');
            res.setStatusCode(returnCode);
            return res;
        }

        // ### DTSFPART_CommonComponentsController add remedy attachment
        if (endpointURL.contains('gw/remedyprxy/arsys/v1/entry/HPD:WorkLog') && req.getMethod() == 'POST' && returnCode == 200) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'text/plain');
            res.setBodyAsBlob(EncodingUtil.base64Decode('UmVtZWR5Q2FzZVRlc3QgYXR0YWNobWVudA=='));
            res.setStatus('SUCCESS');
            res.setStatusCode(returnCode);
            return res;
        }

        // Wrong Api Endpoint
        if(endpointURL.contains('badRequest') && req.getMethod().equals('GET') && returnCode == 400){
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"success":"true"}');
            res.setStatusCode(returnCode);
            res.setStatus('bad status');
            return res;
        }

        // Default Mule api endpoint
        if(endpointURL.contains('Mulesoft_OAuth') && req.getMethod().equals('GET') && returnCode == 200){
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"success":"true"}');
            res.setStatusCode(returnCode);
            res.setStatus('Test status');
            return res;
        }

        if (endpointURL.contains('EMEA_Google_Drive') && req.getMethod().equals('GET') && returnCode == 200){
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"success":"true"}');
            res.setStatusCode(returnCode);
            res.setStatus('Test status');
            return res;
        }

        System.debug('##### ^^^ Returning null from http mock class. Something went wrong, check your code. ^^^ ######');
        return null;
    }
}