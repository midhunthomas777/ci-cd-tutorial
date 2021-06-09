@isTest
public class EInvoiceControllerMockTest implements HttpCalloutMock{
	public Integer code;
    public String requestBody;
    
    public EInvoiceControllerMockTest(Integer code,String requestBody) {
        this.code = code;
        this.requestBody = requestBody;
    }
    
    public HTTPResponse respond(HTTPRequest req) {
        HttpResponse resp = new HttpResponse();
        resp.setHeader('Content-Type', 'application/json');
        resp.setStatusCode(code);
        resp.setBody(requestBody);

        return resp;
    }
}