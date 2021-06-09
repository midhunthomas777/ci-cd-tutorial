/**
 * Copyright (c) 2018. 7Summits Inc.
 * Created by 7Summits - Created by Melinda Grad on 8/1/18.
 */

@isTest
public with sharing class Adventure_BaseControllerTest {

    @testSetup
    public static void testSetup(){

        //Create test adventure
        Adventure__c testAdventure = new Adventure__c(Name = Adventure_TestConstants.TEST_ADVENTURE_NAME, Title__c = Adventure_TestConstants.TEST_ADVENTURE_NAME);
        insert testAdventure;

        //Create test Adventure Step
        Adventure_Step__c testAdventureStep = new Adventure_Step__c(Name = Adventure_TestConstants.TEST_ADVENTURE_STEP_NAME,
                Title__c = Adventure_TestConstants.TEST_ADVENTURE_STEP_NAME, Adventure__c = testAdventure.Id,
                Subtitle__c = Adventure_TestConstants.TEST_ADVENTURE_STEP_SUBTITLE, Description__c = Adventure_TestConstants.TEST_ADVENTURE_STEP_DESCRIPTION);
        insert testAdventureStep;

        //Create test Step Module
        Step_Module__c testStepModule = new Step_Module__c(Name = Adventure_TestConstants.TEST_STEP_MODULE_NAME,
                Title__c = Adventure_TestConstants.TEST_STEP_MODULE_NAME, Adventure_Step__c = testAdventureStep.Id);
        insert testStepModule;

        //Create test Module Task
        Module_Task__c testModuleTask = new Module_Task__c(Name = Adventure_TestConstants.TEST_MODULE_TASK_NAME,
                Title__c = Adventure_TestConstants.TEST_MODULE_TASK_NAME, Content_URL__c = Adventure_TestConstants.TEST_URL,
                Resource_Type__c = Adventure_TestConstants.TEST_RESOURCE_TYPE, Step_Module__c = testStepModule.Id);
        insert testModuleTask;

    }

    @isTest
    public static void testGetAdventure(){

        List<Adventure__c> testAdventures = [SELECT Id FROM Adventure__c];

        Adventure_Response peakResponse = Adventure_BaseController.getAdventure(testAdventures[0].Id);

        System.assertEquals(Adventure_TestConstants.TEST_ADVENTURE_NAME, peakResponse.peakResults[0].adventure.Name);

    }

}