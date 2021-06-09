/*
 * Copyright (c) 2019. 7Summits Inc. All rights reserved.
 *
 */

// ===================
// Test Peak Utils
// ===================
@IsTest
public with sharing class Peak_Onboarding_UtilsTest
{

	@TestSetup
	static void testSetup()
	{
		Contact testContact = Peak_Onboarding_TestUtils.createTestContact();
	}

	// Test building a formatted string from a set of strings
	@IsTest
	public static void testBuildStringFromSet()
	{
		Set<String> sourceSet = new Set<String>();
		sourceSet.add('Hello');
		sourceSet.add('There');
		System.assertEquals('Hello, There', Peak_Onboarding_Utils.buildStringFromSet(sourceSet)); // test that this is building a string from a set properly
	}

	@IsTest
	public static void testGetUser()
	{
		// Set up and run as a standard user
		List<Contact> testContacts = [SELECT Id FROM Contact WHERE Email = :Peak_Onboarding_TestConstants.STANDARD_EMAIL];

		User testUser = Peak_Onboarding_TestUtils.createStandardUserNoContact();
		try
		{
			testUser.ContactId = testContacts[0].Id;
			insert testUser;
		} catch (Exception e)
		{
			testUser.ContactId = null;
			insert testUser;
		}

		System.runAs(testUser)
		{
			System.assertEquals(testUser.Id, Peak_Onboarding_Utils.getUser().Id);
		}
	}

	@IsTest
	public static void testIsNullOrEmpty()
	{
		// Assert return true for empty list
		List<String> stringList = new List<String>();
		System.assertEquals(Peak_Onboarding_Utils.isNullOrEmpty(stringList), true);

		// Assert return false for not empty list
		stringList.add(Peak_Onboarding_TestConstants.ACCOUNT_NAME);
		System.assertEquals(Peak_Onboarding_Utils.isNullOrEmpty(stringList), false);
	}

	@IsTest
	public static void testGetSitePrefix()
	{
		System.assert(Peak_Onboarding_Utils.getSitePrefix() != null);
	}

	@IsTest
	public static void testCreateAttachment()
	{
		// Set up and run as a standard user
		List<Contact> testContacts = [SELECT Id FROM Contact WHERE Email = :Peak_Onboarding_TestConstants.STANDARD_EMAIL];

		User testUser = Peak_Onboarding_TestUtils.createStandardUserNoContact();
		try
		{
			testUser.ContactId = testContacts[0].Id;
			insert testUser;
		} catch (Exception e)
		{
			testUser.ContactId = null;
			insert testUser;
		}

		Attachment testAttachment = Peak_Onboarding_TestUtils.createAttachment(testUser.Id);
		System.assert(testAttachment != null);
	}

	@IsTest
	public static void testGetPicklistValues()
	{
		List<String> options = Peak_Onboarding_Utils.getPicklistValues('User', 'LanguageLocaleKey');
		System.assert(options.size() > 0);
	}

	@IsTest
	public static void testCreateListFromMultiPicklist()
	{

		String multiPicklistString = 'string1;string2;string3';

		List<String> multiPicklistList = Peak_Onboarding_Utils.createListFromMultiPicklist(multiPicklistString);

		System.assertEquals(multiPicklistList.get(0), 'string1');
		System.assertEquals(multiPicklistList.get(1), 'string2');
		System.assertEquals(multiPicklistList.get(2), 'string3');

	}

	@IsTest
	public static void testDoesStringContainListItem()
	{

		List<String> compareList = new List<String>();
		compareList.add('string1');
		compareList.add('string2');

		//Assert list contains target string
		System.assert(Peak_Onboarding_Utils.doesStringContainListItem(compareList, 'string1'));

		//Assert list does not contain target string
		System.assert(!Peak_Onboarding_Utils.doesStringContainListItem(compareList, 'string3'));
	}

	@IsTest
	public static void testisGuestUser()
	{
		// Set up and run as a standard user
		List<Contact> testContacts = [SELECT Id FROM Contact WHERE Email = :Peak_Onboarding_TestConstants.STANDARD_EMAIL];

		User testUser = Peak_Onboarding_TestUtils.createStandardUserNoContact();
		try
		{
			testUser.ContactId = testContacts[0].Id;
			insert testUser;
		} catch (Exception e)
		{
			testUser.ContactId = null;
			insert testUser;
		}

		System.runAs(testUser)
		{
			Boolean isGuest = Peak_Onboarding_Utils.isGuestUser();
			System.assertEquals(isGuest, false);
		}


		User testGuest = Peak_Onboarding_TestUtils.createGuestUser();
		System.runAs(testGuest)
		{
			Boolean isGuest = Peak_Onboarding_Utils.isGuestUser();
			System.assertEquals(isGuest, true);
		}
	}

	@IsTest
	public static void testgetFieldSchema()
	{
		// Super simple - just assert that the account keyset returns name. We know this will always be true
		System.assert(Peak_Onboarding_Utils.getFieldSchema('Account').containsKey('Name'));
	}

	@IsTest
	public static void testToIds()
	{
		// Set up and run as a standard user
		List<Contact> testContacts = [SELECT Id FROM Contact WHERE Email = :Peak_Onboarding_TestConstants.STANDARD_EMAIL];

		// Get IDs
		List<Id> toIds = Peak_Onboarding_Utils.toIds(testContacts, 'Id');

		// Assert that one ID has been added to the list!
		System.assertEquals(toIds.size(), 1);
	}

	@IsTest
	public static void testReplaceSpace()
	{
		System.assertEquals('Hi_Friend', Peak_Onboarding_Utils.replaceSpace('Hi Friend'));
	}
}