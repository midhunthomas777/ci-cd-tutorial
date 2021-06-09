/*
 * Copyright (c) 2018. 7Summits Inc.
 */

/**
 * Created by francoiskorb on 9/13/18.
 */

@IsTest
private class Peak_GoogleMapsControllerTest
{
//	Test Data
	private static final String ACCOUNT_NAME    = 'Test Account';
	private static final String ACCOUNT_STREET  = '123 Main Street';
	private static final String ACCOUNT_CITY    = 'New Town';
	private static final String ACCOUNT_STATE   = 'ZZ';
	private static final String ACCOUNT_ZIP     = '1234';
	private static final String ACCOUNT_COUNTRY = 'COUNTRY';

	static testMethod void test_getAddress()
	{
		// create test account
		Account testAccount = createTestAccount();

		Test.startTest();
		{
			// get address info
			String testAddress = Peak_GoogleMapsController.getAddress(
				testAccount.Id,
				'BillingStreet',
				'BillingCity',
				'BillingState',
				'BillingPostalCode',
				'BillingCountry',
				'');
			System.assertNotEquals(null, testAddress);

			// get geo info
			testAddress = Peak_GoogleMapsController.getAddress(
				testAccount.Id,
				'BillingStreet',
				'BillingCity',
				'BillingState',
				'BillingPostalCode',
				'BillingCountry',
				'geo_location__c');
			System.assertNotEquals(null, testAddress);

		}
		Test.stopTest();
	}

	static testMethod void test_addToString()
	{
		String original = 'original';
		String addition = 'addition';

		System.assertEquals(original, Peak_GoogleMapsController.addToString(original, ''));
		System.assertEquals(addition, Peak_GoogleMapsController.addToString('', addition));
		System.assertEquals(original + ',' + addition, Peak_GoogleMapsController.addToString(original, addition));
	}

	static testMethod void test_EncodeString()
	{
		System.assertEquals('my+street', Peak_GoogleMapsController.encodeString('my street'));
	}

	private static Account createTestAccount()
	{
		Account testAccount = new Account(
			Name = ACCOUNT_NAME,
			BillingStreet = ACCOUNT_STREET,
			BillingCity = ACCOUNT_CITY,
			BillingState = ACCOUNT_STATE,
			BillingPostalCode = ACCOUNT_ZIP,
			BillingCountry = ACCOUNT_COUNTRY);

		insert testAccount;

		return testAccount;
	}
}