//  Copyright (c) 2018. 7Summits Inc.
//  Created by 7Summits - Melinda Grad on 7/25/18.

@IsTest
private class Adventure_ContentObjectTest
{

    @testSetup
    static void testSetup() {
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
    public static void testPeak_ContentObject() {

        List<Adventure__c> testAdventures = [SELECT Id, Name FROM Adventure__c];
        List<Adventure_Step__c> testAdventureSteps = [SELECT Id, Name, title__c, subtitle__c, description__c, Order__c, Icon_Image__c,
                    (SELECT Id FROM ContentDocumentLinks) FROM Adventure_Step__c];

        List<Step_Module__c> testStepModules = [SELECT Id, Name, Adventure_Step__c, title__c,Order__c,
                Description_Label__c,Description_URL__c,Tooltip_Description__c FROM Step_Module__c];

        List<Module_Task__c> testStepModuleTasks = [SELECT Id, Name FROM Module_Task__c];

        Adventure_StepModuleWrapper testStepWrapper = Adventure_StepModuleWrapperHelper.createWrapper(testStepModules[0], testStepModuleTasks);
        List<Adventure_StepModuleWrapper> testWrapperList = new List<Adventure_StepModuleWrapper>();
        testWrapperList.add(testStepWrapper);

        Adventure_StepWrapper testWrapper = Adventure_StepWrapperHelper.createWrapper(testAdventureSteps[0], testWrapperList);
        List<Adventure_StepWrapper> stepWrapperList = new List<Adventure_StepWrapper>();
        stepWrapperList.add(testWrapper);

        Test.startTest();

        Adventure_ContentObject peakContentObject = new Adventure_ContentObject();
        peakContentObject.adventure = testAdventures[0];
        peakContentObject.adventureStepWrapper = stepWrapperList;

        System.debug('ADVENTURE ==' + peakContentObject.adventureStepWrapper);


        System.assertEquals(peakContentObject.adventure.Name, Adventure_TestConstants.TEST_ADVENTURE_NAME);
        System.assertEquals(peakContentObject.adventureStepWrapper[0].Id, testAdventureSteps[0].Id);

        Test.stopTest();
    }

}