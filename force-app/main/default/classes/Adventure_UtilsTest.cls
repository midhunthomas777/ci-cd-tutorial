// ===================
// Test Peak Utils
// - Copyright (c) 2018. 7Summits Inc.
// - Created by 7Summits - Melinda Grad on 7/25/18.
// ===================
@isTest
public with sharing class Adventure_UtilsTest
{

    @testSetup
    static void testSetup() {
        Contact testContact = Adventure_TestUtils.createTestContact();
    }

    // Test building a formatted string from a set of strings
    @isTest
    public static void testBuildStringFromSet(){
        Set<String> sourceSet = new Set<String>();
        sourceSet.add('Hello');
        sourceSet.add('There');
        system.assertEquals('Hello, There', Adventure_Utils.buildStringFromSet(sourceSet)); // test that this is building a string from a set properly
    }

    @isTest
    public static void testGetUser(){
        // Set up and run as a standard user
        List<Contact> testContacts = [SELECT Id from Contact where Email = :Adventure_TestConstants.STANDARD_EMAIL];

        User testUser = Adventure_TestUtils.createStandardUserNoContact();
        testUser.ContactId = testContacts[0].Id;
        insert testUser;

        system.runAs(testUser){
            system.assertEquals(testUser.Id, Adventure_Utils.getUser().Id);
        }
    }

    @isTest
    public static void testIsNullOrEmpty() {
        // Assert return true for empty list
        List<String> stringList = new List<String>();
        system.assertEquals(Adventure_Utils.isNullOrEmpty(stringList),true);

        // Assert return false for not empty list
        stringList.add(Adventure_TestConstants.ACCOUNT_NAME);
        system.assertEquals(Adventure_Utils.isNullOrEmpty(stringList),false);
    }

    @isTest
    public static void testGetSitePrefix() {
        system.assert(Adventure_Utils.getSitePrefix() != null);
    }

    @isTest
    public static void testCreateAttachment() {
        // Set up and run as a standard user
        List<Contact> testContacts = [SELECT Id from Contact where Email = :Adventure_TestConstants.STANDARD_EMAIL];

        User testUser = Adventure_TestUtils.createStandardUserNoContact();
        testUser.ContactId = testContacts[0].Id;
        insert testUser;

        Attachment testAttachment = Adventure_TestUtils.createAttachment(testUser.Id);
        system.assert(testAttachment != null);
    }

    @isTest
    public static void testGetPicklistValues(){
        List<String> options = Adventure_Utils.getPicklistValues('User','LanguageLocaleKey');
        System.assert(options.size()>0);
    }

    @isTest
    public static void testCreateListFromMultiPicklist(){

        String multiPicklistString = 'string1;string2;string3';

        List<String> multiPicklistList = Adventure_Utils.createListFromMultiPicklist(multiPicklistString);

        system.assertEquals(multiPicklistList.get(0), 'string1');
        system.assertEquals(multiPicklistList.get(1), 'string2');
        system.assertEquals(multiPicklistList.get(2), 'string3');

    }

    @isTest
    public static void testDoesStringContainListItem(){

        List<String> compareList = new List<String>();
        compareList.add('string1');
        compareList.add('string2');

        //Assert list contains target string
        system.assert(Adventure_Utils.doesStringContainListItem(compareList, 'string1'));

        //Assert list does not contain target string
        system.assert(!Adventure_Utils.doesStringContainListItem(compareList, 'string3') );
    }

    @isTest
    public static void testGetYear() {
        Adventure_Utils currentYear = new Adventure_Utils();

        Integer reqYear = Adventure_Utils.getYear();
        System.assert(reqYear != null);
    }
}