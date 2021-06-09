/**
 * @author		Paweł Woźniak
 * @created		2020-07-31
 * @updated		2020-08-04
 * @isTesting	DTSFPART_Utils
 * @description
 */

@isTest
public with sharing class DTSFPART_Utils_Test {

	@IsTest
	private static void test_isSandbox() {
		Boolean isSandbox = DTSFPART_Utils.isSandbox();
	}

	@IsTest
	private static void test_getSetOf() {
		List<User> users = [SELECT Id, Name FROM user LIMIT 10];
		DTSFPART_Utils.getSetOfIds(users, 'Id');
		DTSFPART_Utils.getSetOfStrings(users, 'Name');
	}

	@IsTest
	private static void test_getPicklistValuesByAPIName() {
		Set<String> picklstValues = DTSFPART_Utils.getPicklistActiveValuesByAPiName('Account', 'Type');
		System.assertEquals(false, picklstValues.isEmpty());
	}

	@IsTest
	private static void test_getPicklistValuesByLabe() {
		Set<String> picklstValues = DTSFPART_Utils.getPicklistActiveValuesByLabel('Account', 'Type');
		System.assertEquals(false, picklstValues.isEmpty());
	}

	@IsTest
	private static void test_throwAuraHandledException() {
		try {
			DTSFPART_Utils.throwAuraHandledException('Test message');
		} catch(Exception ex) {
			System.assertEquals('Test message', ex.getMessage());
		}
	}

	@IsTest
	private static void test_throwExceptionAsAuraHandled() {
		try {
			try {
				Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
			} catch(System.QueryException ex) {
				DTSFPART_Utils.throwExceptionAsAuraHandled(ex);
			}
		}
		catch(AuraHandledException ahe) {
			System.assertEquals('List has no rows for assignment to SObject', ahe.getMessage());
		}

	}

	@IsTest
	private static void test_getPartnerAccountRecordTypeId(){
		Id partnerAccountRecordTypeId = [SELECT Id FROM RecordType WHERE SobjectType = 'Account' AND DeveloperName = 'Partner' LIMIT 1].Id;
		Id utilRecordTypeId = DTSFPART_Utils.getRecordTypeId('Account', 'Partner');

		System.assertEquals(partnerAccountRecordTypeId, utilRecordTypeId);
	}

	@IsTest
	private static void test_getCustomerHubAccounts(){
		DTSFPART_TestDataSetUpUtils.insertCustomSettings();
		String partnerAccountRecordTypeId = DTSFPART_Utils.getRecordTypeId('Account', 'Partner');
		String customerContactRcordTypeId = DTSFPART_Utils.getRecordTypeId('Contact', 'EMS_Standard_Contact');
		Account customerHubAccount = DTSFPART_TestDataSetUpUtils.createCustomerHubAccount(true);
		Account partnerHubAccount  = DTSFPART_TestDataSetUpUtils.createPartnerAccount(partnerAccountRecordTypeId, true);
		Contact customerHubContact = DTSFPART_TestDataSetUpUtils.createContact(customerContactRcordTypeId, customerHubAccount, 'DirectUser', true);
		User customerUser = DTSFPART_TestDataSetUpUtils.createUser(customerHubContact, 'CspLitePortal', true);
		User userInserted = [SELECT Id, Account_Id__c FROM User WHERE ID = :customerUser.Id];
		
		Test.startTest();
		Map<Id, Account> accounts = DTSFPART_Utils.getCustomerHubAccounts(new List<User>{userInserted});
		Test.stopTest();
		System.assert(accounts.get(customerHubAccount.Id) != null);
		System.assertEquals(null, accounts.get(partnerHubAccount.Id), 'Map shuld not contains Partner Hub Account');
	}
	
	@IsTest
	private static void test_hasReceivedErrorFromC360(){
		List<List<Object>> entries = new List<List<Object>> {
			/*            newResponse    , oldResponse    , newStatus  , expectedResult */
			new Object[] {'{status: 500}', ''             , 'Resync'   , true},
			new Object[] {'{status: 500}', ''             , 'Trigger'  , true},
			new Object[] {'Success'      , '{status: 500}', 'Completed', false},
			new Object[] {'Success'      , ''             , 'Completed', false}
		};
		
		Test.startTest();
		for (List<Object> entry : entries) {
			String newResponse = (String) entry[0];
			String oldResponse = (String) entry[1];
			String newStatus = (String) entry[2];
			Boolean expectedResult = (Boolean) entry[3];

			Boolean isError = DTSFPART_Utils.hasReceivedErrorFromC360(newResponse, oldResponse, newStatus);
			System.assertEquals(expectedResult, isError, 'Incorrect result for the entry: '+entry);
		}
		Test.stopTest();
	}

}