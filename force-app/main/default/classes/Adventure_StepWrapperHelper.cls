/**
 * Copyright (c) 2018. 7Summits Inc.
 * Created by 7Summits - Created by Melinda Grad on 8/1/18.
 */

public with sharing class Adventure_StepWrapperHelper {

    public static Adventure_StepWrapper createWrapper(Adventure_Step__c theStep, List<Adventure_StepModuleWrapper> theStepModuleList){

        Adventure_StepWrapper stepWrapper = new Adventure_StepWrapper();

        stepWrapper.id = theStep.Id;
        stepWrapper.stepName = theStep.title__c;
        stepWrapper.title = theStep.subtitle__c;
        stepWrapper.subtitle = theStep.description__c;
        stepWrapper.order = theStep.Order__c;
        stepWrapper.iconImage = theStep.Icon_Image__c;
        stepWrapper.contentDocumentLinks = theStep.ContentDocumentLinks;
        stepWrapper.stepModuleWrapperList = theStepModuleList;

        return stepWrapper;
    }

}