//  Copyright (c) 2018. 7Summits Inc.
//  Created by 7Summits - Melinda Grad on 7/25/18.

@isTest
public with sharing class Adventure_ResponseTest
{

    @isTest
    public static void testPeakReponse(){
        Adventure_Response response = new Adventure_Response();

        // Test success flag
        System.assertEquals(response.success,true);

        // Test messages
        response.messages.add(Adventure_TestConstants.TEST_MESSAGE);
        System.assertEquals(response.messages[0], Adventure_TestConstants.TEST_MESSAGE);

        // Test object list
        Account account = Adventure_TestUtils.createTestAccount();
        response.results.add(account);
        System.assertEquals(account,response.results[0]);
    }
}