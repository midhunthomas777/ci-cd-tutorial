/**
 * @author: WGVR43 
 * @date: 30.01.2021
 * @group: DTSFPART
 * @description: 
 */

@IsTest
private class DTSFPART_MockHttpResponseGeneratorTest {

	@IsTest
	static void testEcom200() {
		HttpRequest request = new HttpRequest();
		request.setEndpoint('callout:Request/ecom/v1.0/c360/admin/v1.0/user/test200@test.pl/resendemail');
		request.setMethod('POST');

		HttpResponse response;
		Test.startTest();
			Test.setMock(HttpCalloutMock.class, new DTSFPART_MockHttpResponseGenerator(200));
			response = new Http().send(request);
		Test.stopTest();

		System.assertEquals('application/json', response.getHeader('Content-Type'));
		System.assert(String.isNotBlank(response.getBody()));
		System.assertEquals(200, response.getStatusCode());
		System.assertEquals('OK', response.getStatus());
	}

	@IsTest
	static void testEcom400() {
		HttpRequest request = new HttpRequest();
		request.setEndpoint('callout:Request/ecom/v1.0/c360/admin/v1.0/user/test400@test.pl/resendemail');
		request.setMethod('POST');

		HttpResponse response;
		Test.startTest();
			Test.setMock(HttpCalloutMock.class, new DTSFPART_MockHttpResponseGenerator(400));
			response = new Http().send(request);
		Test.stopTest();

		System.assertEquals('application/json', response.getHeader('Content-Type'));
		System.assert(response.getBody().contains('not_found'));
		System.assertEquals(400, response.getStatusCode());
		System.assertEquals('Bad Request', response.getStatus());
	}

	@IsTest
	static void c360User200() {
		HttpRequest request = new HttpRequest();
		request.setEndpoint('callout:Request/ecom/v1.0/c360/user/testuser@mail.com/ldap/v2.2');
		request.setMethod('GET');

		HttpResponse response;
		Test.startTest();
			Test.setMock(HttpCalloutMock.class, new DTSFPART_MockHttpResponseGenerator(200, 'testuser@mail.com'));
			response = new Http().send(request);
		Test.stopTest();

		System.assertEquals('application/json', response.getHeader('Content-Type'));
		System.assert(response.getBody().contains('{"success":"true"}'));
		System.assertEquals(200, response.getStatusCode());
		System.assertEquals('OK', response.getStatus());
	}

	@IsTest
	static void c360User204() {
		HttpRequest request = new HttpRequest();
		request.setEndpoint('callout:Request/ecom/v1.0/c360/user/testuser@mail.com/ldap/v2.2');
		request.setMethod('GET');

		HttpResponse response;
		Test.startTest();
			Test.setMock(HttpCalloutMock.class, new DTSFPART_MockHttpResponseGenerator(204, 'testuser@mail.com'));
			response = new Http().send(request);
		Test.stopTest();

		System.assertEquals('application/json', response.getHeader('Content-Type'));
		System.assert(response.getBody().contains('{"success":"false"}'));
		System.assertEquals(204, response.getStatusCode());
	}

	@IsTest
	static void c360User302() {
		HttpRequest request = new HttpRequest();
		request.setEndpoint('callout:Request/ecom/v1.0/c360/user/testuser@mail.com/ldap/v2.2');
		request.setMethod('GET');

		HttpResponse response;
		Test.startTest();
			Test.setMock(HttpCalloutMock.class, new DTSFPART_MockHttpResponseGenerator(302, 'testuser@mail.com'));
			response = new Http().send(request);
		Test.stopTest();

		System.assertEquals('application/json', response.getHeader('Content-Type'));
		System.assert(response.getBody().contains('{"success":"false"}'));
		System.assertEquals(302, response.getStatusCode());
	}

	@IsTest
	static void molOrderHistory200() {
		HttpRequest request = new HttpRequest();
		request.setEndpoint('callout:Request/ecom/orders/molorderhistory/v5.0');
		request.setMethod('POST');

		HttpResponse response;
		Test.startTest();
			Test.setMock(HttpCalloutMock.class, new DTSFPART_MockHttpResponseGenerator(200));
			response = new Http().send(request);
		Test.stopTest();

		System.assertEquals('application/json', response.getHeader('Content-Type'));
		System.assert(response.getBody().contains('{"success":"true"}'));
		System.assertEquals(200, response.getStatusCode());
		System.assertEquals('OK', response.getStatus());
	}

	@IsTest
	static void myView200() {
		HttpRequest request = new HttpRequest();
		request.setEndpoint('callout:Request/gw/myview/api/v1.0');
		request.setMethod('GET');

		HttpResponse response;
		Test.startTest();
			Test.setMock(HttpCalloutMock.class, new DTSFPART_MockHttpResponseGenerator(200));
			response = new Http().send(request);
		Test.stopTest();

		System.assertEquals('application/json', response.getHeader('Content-Type'));
		System.assert(response.getBody().contains('{"success":"true"}'));
		System.assertEquals(200, response.getStatusCode());
		System.assertEquals('OK', response.getStatus());
	}

	@IsTest
	static void myViewFile200() {
		HttpRequest request = new HttpRequest();
		request.setEndpoint('callout:Request/gw/myview/api/v1.0');
		request.setMethod('POST');

		HttpResponse response;
		Test.startTest();
			Test.setMock(HttpCalloutMock.class, new DTSFPART_MockHttpResponseGenerator(200));
			response = new Http().send(request);
		Test.stopTest();

		System.assertEquals('application/json', response.getHeader('Content-Type'));
		System.assert(response.getBody().contains('{"success":"true"}'));
		System.assertEquals(200, response.getStatusCode());
		System.assertEquals('OK', response.getStatus());
	}

	@IsTest
	static void invoiceHeader200() {
		HttpRequest request = new HttpRequest();
		request.setEndpoint('callout:Request/ecom/invoices/invoice_header/v1.0');
		request.setMethod('GET');

		HttpResponse response;
		Test.startTest();
			Test.setMock(HttpCalloutMock.class, new DTSFPART_MockHttpResponseGenerator(200));
			response = new Http().send(request);
		Test.stopTest();

		System.assertEquals('application/json', response.getHeader('Content-Type'));
		System.assert(String.isNotBlank(response.getBody()));
		System.assertEquals(200, response.getStatusCode());
	}

	@IsTest
	static void invoiceHeader500() {
		HttpRequest request = new HttpRequest();
		request.setEndpoint('callout:Request/ecom/invoices/invoice_header/v1.0');
		request.setMethod('GET');

		HttpResponse response;
		Test.startTest();
			Test.setMock(HttpCalloutMock.class, new DTSFPART_MockHttpResponseGenerator(500));
			response = new Http().send(request);
		Test.stopTest();

		System.assertEquals('application/json', response.getHeader('Content-Type'));
		System.assert(response.getBody().contains('No Data Found'));
		System.assertEquals(500, response.getStatusCode());
	}

	@IsTest
	static void invoiceHeader400() {
		HttpRequest request = new HttpRequest();
		request.setEndpoint('callout:Request/ecom/invoices/invoice_header/v1.0');
		request.setMethod('GET');

		HttpResponse response;
		Test.startTest();
			Test.setMock(HttpCalloutMock.class, new DTSFPART_MockHttpResponseGenerator(400));
			response = new Http().send(request);
		Test.stopTest();

		System.assertEquals('application/json', response.getHeader('Content-Type'));
		System.assert(String.isBlank(response.getBody()));
		System.assertEquals(400, response.getStatusCode());
	}

	@IsTest
	static void remedy200() {
		HttpRequest request = new HttpRequest();
		request.setEndpoint('callout:Request/gw/remedyprxy/arsys/v1/entry/HPD:WorkLog/');
		request.setMethod('GET');

		HttpResponse response;
		Test.startTest();
			Test.setMock(HttpCalloutMock.class, new DTSFPART_MockHttpResponseGenerator(200));
			response = new Http().send(request);
		Test.stopTest();

		System.assertEquals('text/plain', response.getHeader('Content-Type'));
		System.assert(String.isNotBlank(EncodingUtil.base64Encode(response.getBodyAsBlob())));
		System.assertEquals(200, response.getStatusCode());
		System.assertEquals('SUCCESS', response.getStatus());
	}

	@IsTest
	static void addRemedy200() {
		HttpRequest request = new HttpRequest();
		request.setEndpoint('callout:Request/gw/remedyprxy/arsys/v1/entry/HPD:WorkLog');
		request.setMethod('POST');

		HttpResponse response;
		Test.startTest();
			Test.setMock(HttpCalloutMock.class, new DTSFPART_MockHttpResponseGenerator(200));
			response = new Http().send(request);
		Test.stopTest();

		System.assertEquals('text/plain', response.getHeader('Content-Type'));
		System.assert(String.isNotBlank(EncodingUtil.base64Encode(response.getBodyAsBlob())));
		System.assertEquals(200, response.getStatusCode());
		System.assertEquals('SUCCESS', response.getStatus());
	}

	@IsTest
	static void badRequest() {
		HttpRequest request = new HttpRequest();
		request.setEndpoint('callout:Request/badRequest');
		request.setMethod('GET');

		HttpResponse response;
		Test.startTest();
			Test.setMock(HttpCalloutMock.class, new DTSFPART_MockHttpResponseGenerator(400));
			response = new Http().send(request);
		Test.stopTest();

		System.assertEquals('application/json', response.getHeader('Content-Type'));
		System.assertEquals(400, response.getStatusCode());
		System.assertEquals('bad status', response.getStatus());
	}

	@IsTest
	static void defaultMule() {
		HttpRequest request = new HttpRequest();
		request.setEndpoint('callout:Mulesoft_OAuth');
		request.setMethod('GET');

		HttpResponse response;
		Test.startTest();
			Test.setMock(HttpCalloutMock.class, new DTSFPART_MockHttpResponseGenerator(200));
			response = new Http().send(request);
		Test.stopTest();

		System.assertEquals('application/json', response.getHeader('Content-Type'));
		System.assertEquals(200, response.getStatusCode());
		System.assertEquals('Test status', response.getStatus());
	}

	@IsTest
	static void testException() {
		HttpRequest request = new HttpRequest();
		request.setEndpoint('callout:Mulesoft_OAuth');
		request.setMethod('GET');

		HttpResponse response;
		Exception ex;
		Test.startTest();
			try{
				Test.setMock(HttpCalloutMock.class, new DTSFPART_MockHttpResponseGenerator(true));
				response = new Http().send(request);
			} catch(CalloutException e){
				ex = e;
			}
		Test.stopTest();
		System.assert(ex != null);
	}
}