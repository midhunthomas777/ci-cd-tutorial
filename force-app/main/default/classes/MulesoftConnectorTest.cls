/**
 * @author: WGVR43 
 * @date: 21.09.2020
 * @group: DTSFPART
 * @description: 
 */

@IsTest
private class MulesoftConnectorTest {
	@IsTest
	static void testBasicRequest() {
		HttpRequest request = new HttpRequest();
		request.setEndpoint('callout:Mulesoft_OAuth');
		request.setMethod('GET');

		Map<String, Object> response;
		Test.startTest();
		Test.setMock(HttpCalloutMock.class, new DTSFPART_MockHttpResponseGenerator(200));
		response = MulesoftConnector.callMulesoft(request);
		Test.stopTest();

		System.assert(!response.isEmpty());
		System.assert((Boolean) response.get('ok'));
		System.assertEquals('Test status', response.get('statusText'));
		System.assertEquals(200, response.get('status'));
	}

	@IsTest
	static void testCustomRequest() {
		Map<String, Object> response;
		Test.startTest();
		Test.setMock(HttpCalloutMock.class, new DTSFPART_MockHttpResponseGenerator(200));
		response = MulesoftConnector.callMulesoft('', 'MyView', 'Mulesoft_OAuth');
		Test.stopTest();

		System.assert(!response.isEmpty());
		System.assert((Boolean) response.get('ok'));
		System.assertEquals('OK', response.get('statusText'));
		System.assertEquals(200, response.get('status'));
	}

	@IsTest
	static void testBadRequest() {
		HttpRequest request = new HttpRequest();
		request.setEndpoint('callout:badRequest');
		request.setMethod('GET');

		Map<String, Object> response;
		Test.startTest();
		Test.setMock(HttpCalloutMock.class, new DTSFPART_MockHttpResponseGenerator(400));
		response = MulesoftConnector.callMulesoft(request);
		Test.stopTest();

		System.assert(!response.isEmpty());
		System.assert(!(Boolean) response.get('ok'));
		System.assertEquals('bad status', response.get('statusText'));
		System.assertEquals(400, response.get('status'));
	}

	@IsTest
	static void testFederationIdWithCustomParam() {
		Map<String, Object> response;
		Test.startTest();
			Test.setMock(HttpCalloutMock.class, new DTSFPART_MockHttpResponseGenerator(200));
			MulesoftConnector.useFederationId = true;
			response = MulesoftConnector.callMulesoft('', 'DTSFPART_Download_Attachment', 'Mulesoft_OAuth');
		Test.stopTest();

		System.assert(!response.isEmpty());
		System.assert((Boolean) response.get('ok'));
		System.assertEquals('SUCCESS', response.get('statusText'));
		System.assertEquals(200, response.get('status'));
		System.assertEquals('RemedyCaseTest attachment', response.get('body'));
	}

	@IsTest
	static void testException() {
		HttpRequest request = new HttpRequest();
		request.setEndpoint('callout:Mulesoft_OAuth');
		request.setMethod('GET');

		Map<String, Object> response;
		Test.startTest();
			Test.setMock(HttpCalloutMock.class, new DTSFPART_MockHttpResponseGenerator(true));
			response = MulesoftConnector.callMulesoft(request);
		Test.stopTest();

		System.assert(!response.isEmpty());
		System.assert(!(Boolean) response.get('ok'));
		System.assertEquals('Exception during callout!', response.get('body'));

		List<LogForAllErrors__c> errors = [SELECT Id FROM LogForAllErrors__c WHERE ModuleCreatingError__c = 'Mulesoft'];
		System.assert(!errors.isEmpty());
	}
}