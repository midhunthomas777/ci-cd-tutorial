/**
 * Copyright (c) 2018. 7Summits Inc.
 * Created by 7Summits - Created by Melinda Grad on 8/1/18.
 */

public with sharing class Adventure_StepModuleWrapperHelper {

    public static Adventure_StepModuleWrapper createWrapper(Step_Module__c theStepModule, List<Module_Task__c> moduleTasks){

        Adventure_StepModuleWrapper stepModule = new Adventure_StepModuleWrapper();

        stepModule.id = theStepModule.Id;
        stepModule.Adventure_Step_Id = theStepModule.Adventure_Step__c;
        stepModule.title = theStepModule.title__c;
        stepModule.moduleTasks = moduleTasks;
        stepModule.order = (Integer)theStepModule.Order__c;
        stepModule.descriptionLabel = theStepModule.Description_Label__c;
        stepModule.descriptionLink = theStepModule.Description_URL__c;
        stepModule.tooltip = theStepModule.Tooltip_Description__c;

        return stepModule;
    }

}