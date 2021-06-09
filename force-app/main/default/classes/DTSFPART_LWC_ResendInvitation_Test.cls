/**
 * @author		Paweł Woźniak
 * @created		2020-09-18
 * @updated		2020-09-18
 * @isTesting	DTSFPART_LWC_ResendInvitation
 * @description
 */
@isTest
public with sharing class DTSFPART_LWC_ResendInvitation_Test {

    @TestSetup
    static void testSetup(){
        DTSFPART_TestDataSetUpUtils.insertCustomSettings();
    }

    @IsTest
    static void resendInvitation_success(){

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new DTSFPART_MockHttpResponseGenerator(200));
        Boolean isSuccess = DTSFPART_LWC_ResendInvitation.resendInvitation('test200@test.pl');
        Test.stopTest();

        System.assertEquals(true, isSuccess);
    }

    @IsTest
    static void resendInvitation_emailNotFound(){

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new DTSFPART_MockHttpResponseGenerator(400));
        Boolean isSuccess = DTSFPART_LWC_ResendInvitation.resendInvitation('test400@test.pl');
        Test.stopTest();

        System.assertEquals(false, isSuccess);
    }

    @IsTest
    static void test_revokeInvitation(){
        Account acc = DTSFPART_TestDataSetUpUtils.createPartnerAccountWithTechSpec();
        Contact cnt2 = DTSFPART_TestDataSetUpUtils.createPartnerContact(acc, false);
        cnt2.Persona__c = 'SalesManager';
        insert cnt2;
        Test.startTest();
        DTSFPART_LWC_ResendInvitation.revokeInvitation(cnt2);
        Test.stopTest();

        List<Contact> contactsAfter = [SELECT Id FROM Contact WHERE Id = :cnt2.Id];
        System.assertEquals(true, contactsAfter.isEmpty(), 'Contact should be deleted and list empty');
    }
}