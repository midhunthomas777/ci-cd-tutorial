/*
     Copyright (c) 2018. 7Summits Inc.
     Created by 7Summits - Melinda Grad on 7/25/18.
 */

@isTest
public with sharing class Adventure_Peak_BaseControllerTest
{

    @testSetup static void testSetup() {
        Contact testContact = Adventure_TestUtils.createTestContact();
    }

    @isTest
    public static void testGetSitePrefix() {
    	system.assert(Adventure_Peak_BaseController.getSitePrefix() != null);
    }

    // Test finding a user
    @isTest
    public static void testUser(){
        List<Contact> testContacts = [SELECT Id from Contact where Email = :Adventure_TestConstants.STANDARD_EMAIL];

        User testUser = Adventure_TestUtils.createStandardUserNoContact();
        testUser.ContactId = testContacts[0].Id;
        insert testUser;

        test.startTest();

        System.runAs(testUser) {
            System.assertEquals(false, Adventure_Peak_BaseController.isGuestUser());
        }

        Test.stopTest();

    }

    // Test running as a guest
    @isTest
    public static void testGuest(){
        // Set up and run as guest user 
        User guestUser = Adventure_TestUtils.createGuestUser();

        System.runAs(guestUser) {
            System.assertEquals(true, Adventure_Peak_BaseController.isGuestUser());
        }
    }

    // test current year
    @isTest
    public static void testGetYear() {
        Adventure_Peak_BaseController currentYear = new Adventure_Peak_BaseController();

        Integer reqYear = Adventure_Peak_BaseController.getYear();
        System.assert(reqYear != null);
    }

}