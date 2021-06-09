/**
 * @author: WGVR43 
 * @date: 25.11.2020
 * @group: DTSFPART
 * @description: Test class for DTSFPART_RequestBuilder
 */
@IsTest
public with sharing class DTSFPART_RequestBuilderTest {

	private static final String USERNAME = 'req.builder@mot-solutions.com.test';
	private static final String ALIAS = 'REQBUILD';

	@TestSetup
	private static void setupTests(){
		DTSFPART_TestDataSetUpUtils.insertCustomSettings();
		
		Id profileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id;
		User user = new User(
				FirstName = 'RequestBuilder',
				LastName = 'TestUser',
				Alias = ALIAS,
				Username = USERNAME,
				FederationIdentifier = ALIAS,
				CommunityNickname = ALIAS,
				Core_ID__c = ALIAS,
				EmployeeNumber = ALIAS,
				Email = 'req.builder@motorolasolutions.com.test',
				TimeZoneSidKey = 'America/Los_Angeles',
				LocaleSidKey = 'en_US',
				EmailEncodingKey = 'UTF-8',
				ProfileId = profileId,
				LanguageLocaleKey = 'en_US'
		);
		insert user;
	}

	@IsTest
	private static void defaultRequest(){
		Mulesoft__mdt metadata = DTSFPART_Utils.getMulesoftMetadata('MyView');
		System.assertNotEquals(null, metadata);

		HttpRequest request = new DTSFPART_RequestBuilder('MyView').build();
		System.assertNotEquals(null, request);

		String method = request.getMethod();
		System.assert(String.isNotBlank(method));
		System.assertEquals(metadata.Method_Type__c, method);

		String contentType = request.getHeader('Content-Type');
		System.assert(String.isNotBlank(contentType));
		System.assertEquals(metadata.Content_Type__c, contentType);

		if(method.equals('GET')){
			System.assert(String.isBlank(request.getBody()));
		} else {
			System.assert(String.isNotBlank(request.getBody()));
		}

		System.assert(String.isNotBlank(request.getEndpoint()));
		System.assert(request.getEndpoint().contains(metadata.Endpoint__c));
	}

	@IsTest
	private static void customMethod(){
		Mulesoft__mdt metadata = DTSFPART_Utils.getMulesoftMetadata('MyView');
		System.assertNotEquals(null, metadata);

		HttpRequest request = new DTSFPART_RequestBuilder('MyView').customMethod('TEST').build();
		System.assertNotEquals(null, request);

		String method = request.getMethod();
		System.assert(String.isNotBlank(method));
		System.assertNotEquals(metadata.Method_Type__c, method);
		System.assertEquals('TEST', method);
	}

	@IsTest
	private static void customCredentials(){
		HttpRequest request = new DTSFPART_RequestBuilder('MyView').customCredentials('TEST').build();
		System.assertNotEquals(null, request);

		System.assert(String.isNotBlank(request.getEndpoint()));
		System.assert(request.getEndpoint().contains('TEST'));
	}

	@IsTest
	private static void withHeaders(){
		HttpRequest request = new DTSFPART_RequestBuilder('MyView')
				.withHeaders(new Map<String, String>{ 'Test-Header' => 'Test'})
				.build();
		System.assertNotEquals(null, request);

		String testHeader = request.getHeader('Test-Header');
		System.assert(String.isNotBlank(testHeader));
		System.assertEquals('Test', testHeader);
	}

	@IsTest
	private static void withQueryParams(){
		HttpRequest request = new DTSFPART_RequestBuilder('MyView')
				.withQueryParams(new Map<String, String>{ 'endpoint' => 'Test'})
				.build();
		System.assertNotEquals(null, request);

		System.assert(String.isNotBlank(request.getEndpoint()));
		System.assert(request.getEndpoint().contains('endpoint=Test'), 'Actual endpoint: ' + request.getEndpoint());
	}

	@IsTest
	private static void withCustomParams(){
		HttpRequest request = new DTSFPART_RequestBuilder('MyView')
				.withQueryParams(new Map<String, String>{ 'AccountId' => '$account_id$'})
				.withCustomParams(new Map<String, String>{ '$account_id$' => 'Test'})
				.build();
		System.assertNotEquals(null, request);

		System.assert(String.isNotBlank(request.getEndpoint()));
		System.assert(request.getEndpoint().contains('AccountId=Test'), 'Actual endpoint: ' + request.getEndpoint());

	}

	@IsTest
	private static void withBodyString(){
		HttpRequest request = new DTSFPART_RequestBuilder('MyView')
				.withBody('A test string')
				.build();
		System.assertNotEquals(null, request);

		System.assert(String.isNotBlank(request.getBody()));
		System.assertEquals('A test string', request.getBody());
	}

	@IsTest
	private static void withBodyBlob(){
		HttpRequest request = new DTSFPART_RequestBuilder('MyView')
				.withBody((Object) EncodingUtil.base64Decode('QSB0ZXN0IHN0cmluZw'))
				.build();
		System.assertNotEquals(null, request);

		System.assert(String.isNotBlank(request.getBody()));
		System.assertEquals('A test string', request.getBody());

	}

	@IsTest
	private static void withEndpoint(){
		HttpRequest request = new DTSFPART_RequestBuilder('MyView')
				.withEndpoint('testEndpoint')
				.build();
		System.assertNotEquals(null, request);

		System.assert(String.isNotBlank(request.getEndpoint()));
		System.assert(request.getEndpoint().contains('endpoint=testEndpoint'), 'Actual endpoint: ' + request.getEndpoint());
	}

	@IsTest
	private static void withFederationId(){
		User user = [SELECT Id, FederationIdentifier FROM User WHERE Username = :USERNAME LIMIT 1];
		System.runAs(user) {
			HttpRequest request = new DTSFPART_RequestBuilder('MyView')
					.withOamSession()
					.withFederationId()
					.build();
			System.assertNotEquals(null, request);

			System.assert(String.isNotBlank(request.getEndpoint()));
			System.assert(request.getEndpoint().contains('oam_session=' + ALIAS), 'Actual endpoint: ' + request.getEndpoint());
		}
	}

	@IsTest
	private static void withOamSession(){
		User user = [SELECT Id, FederationIdentifier FROM User WHERE Username = :USERNAME LIMIT 1];
		System.runAs(user) {
			HttpRequest request = new DTSFPART_RequestBuilder('MyView')
					.withOamSession()
					.build();
			System.assertNotEquals(null, request);

			System.assert(String.isNotBlank(request.getEndpoint()));
			System.assert(request.getEndpoint().contains('oam_session=' + ALIAS), 'Actual endpoint: ' + request.getEndpoint());
		}
	}

	@IsTest
	private static void withCustomUser(){
		User user = [SELECT Id, FederationIdentifier FROM User WHERE Username = :USERNAME LIMIT 1];
		System.runAs(user){
			HttpRequest request = new DTSFPART_RequestBuilder('MyView')
					.withOamSession()
					.withCustomUser(ALIAS)
					.build();
			System.assertNotEquals(null, request);

			System.assert(String.isNotBlank(request.getEndpoint()));
			System.assert(request.getEndpoint().contains('oam_session=' + ALIAS), 'Actual endpoint: ' + request.getEndpoint());
		}
	}

	@IsTest
	private static void withMultipleQueryParams(){
		User user = [SELECT Id, FederationIdentifier FROM User WHERE Username = :USERNAME LIMIT 1];
		System.runAs(user) {
			HttpRequest request = new DTSFPART_RequestBuilder('MyView')
					.withQueryParams(new Map<String, String>{
							'AccountId' => '$account_id$', 'testParam' => 'it is test'
					})
					.withCustomParams(new Map<String, String>{
							'$account_id$' => 'Test'
					})
					.withEndpoint('testEndpoint')
					.withOamSession()
					.build();
			System.assertNotEquals(null, request);

			System.assert(String.isNotBlank(request.getEndpoint()));
			System.assert(request.getEndpoint().contains('AccountId=Test'), 'Actual endpoint: ' + request.getEndpoint());
			System.assert(request.getEndpoint().contains('testParam=it is test'), 'Actual endpoint: ' + request.getEndpoint());
			System.assert(request.getEndpoint().contains('endpoint=testEndpoint'), 'Actual endpoint: ' + request.getEndpoint());
			System.assert(request.getEndpoint().contains('oam_session=' + ALIAS), 'Actual endpoint: ' + request.getEndpoint());

			System.assertEquals(1, request.getEndpoint().countMatches('?'));
		}
	}

	@IsTest
	private static void withTimeout(){
		try {
			HttpRequest request = new DTSFPART_RequestBuilder('MyView')
					.withTimeout(1500)
					.build();
		} catch (Exception e){
			System.assert(false, 'Exception shouldn\'t be thrown');
		}
	}
}