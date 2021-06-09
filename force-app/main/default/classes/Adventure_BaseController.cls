/**
 *
 * Copyright (c) 2018. 7Summits Inc.
 * Created by 7Summits - Created by Melinda Grad on 8/1/18.
 *
 * //TODO: NULL checks!!!!!!!
 */

public with sharing class Adventure_BaseController {

    /* Method to return Adventure and related Adventure Steps, Step Modules and Module Tasks */
    @AuraEnabled
    public static Adventure_Response getAdventure(String adventureId){
        Adventure_Response peakResponse = new Adventure_Response();

        String adventureQuery = 'SELECT Id, Name, title__c, Title_Image__c, Header_Image__c, Banner_Image__c, (SELECT Id, ContentDocumentId, ' +
                'ContentDocument.LatestPublishedVersionId, ContentDocument.title, ContentDocument.FileExtension ' +
                'FROM ContentDocumentLinks) ' +
                'FROM Adventure__c WHERE Id =: adventureId';

        String adventureStepQuery = 'SELECT Id, Name, title__c, subtitle__c, Order__c, Icon_Image__c, description__c, (SELECT Id, ContentDocumentId, ' +
                'ContentDocument.LatestPublishedVersionId, ContentDocument.title, ContentDocument.FileExtension ' +
                'FROM ContentDocumentLinks) FROM Adventure_Step__c WHERE Adventure__r.Id =: adventureId ORDER BY Order__c';

        try{
            //Query the Adventure
            List<Adventure__c> theAdventures = Database.query(adventureQuery);
            Map<Id,List<Adventure_StepModuleWrapper>> stepModuleMap = new Map<Id, List<Adventure_StepModuleWrapper>>();
            List<Adventure_StepWrapper> stepWrapperList = new List<Adventure_StepWrapper>();


            List<Adventure_Step__c> adventureSteps = new List<Adventure_Step__c>();
            if(!Adventure_Utils.isNullOrEmpty(theAdventures)) {

                //Query the Adventure Steps
                adventureSteps = Database.query(adventureStepQuery);

                if (!Adventure_Utils.isNullOrEmpty(adventureSteps)) {
                    stepModuleMap = mapRelatedStepModules(adventureSteps);

                    //For each Adventure step, create a wrapper using fields from query and map values for step modules and module tasks
                    for (Adventure_Step__c theStep : adventureSteps) {
                        if (theStep != NULL) {
                            Adventure_StepWrapper stepWrapper = Adventure_StepWrapperHelper.createWrapper(theStep, stepModuleMap.get(theStep.Id));
                            stepWrapperList.add(stepWrapper);
                        }
                    }
                }
            }

            //Create Peak_Content Object to return Adventure, Adventure_Steps, Step_Modules, and Module_Tasks
            Adventure_ContentObject peakContentObject = Adventure_ContentObjectHelper.formatPeakContentObject(theAdventures[0],stepWrapperList);

            peakResponse.peakResults.add(peakContentObject);
            peakResponse.success = TRUE;

        } catch (exception e) {
            peakResponse.success = FALSE;
            peakResponse.messages.add(e.getMessage());
        }
        // Return result and possible error messages
        return peakResponse;
    }

    /* Method to Map Adventure_Step Id's to their related Step Modules */
    @AuraEnabled
    public static Map<Id, List<Adventure_StepModuleWrapper>> mapRelatedStepModules(List<Adventure_Step__c> adventureSteps){

        Map<Id, List<Adventure_StepModuleWrapper>> adventureStepModuleWrapperMap = new Map<Id, List<Adventure_StepModuleWrapper>>();

        //Get a list of Adventure Step Ids
        List<String> adventureStepIds = new List<String>();
        for(Adventure_Step__c theAdventureStep : adventureSteps){
            adventureStepIds.add(theAdventureStep.Id);
        }

        String stepModuleQuery = 'SELECT Id, Name, Adventure_Step__c, Title__c, Order__c, Tooltip_Description__c, Description_URL__c, Description_Label__c FROM Step_Module__c WHERE Adventure_Step__c IN: adventureStepIds ORDER BY Order__c';

        String moduleTaskQuery = 'SELECT Id, Title__c, Name, Content_URL__c, Icon_Name__c, Step_Module__c, isNew__c, (SELECT Id, ContentDocumentId, ' +
                'ContentDocument.LatestPublishedVersionId, ContentDocument.title, ContentDocument.FileExtension ' +
                'FROM ContentDocumentLinks) FROM Module_Task__c WHERE Step_Module__c IN: stepModules ORDER BY Order__c';

        if(!Adventure_Utils.isNullOrEmpty(adventureStepIds)) {
            try {

                //Query Step Modules and Module Tasks
                List<Step_Module__c> stepModules = Database.query(stepModuleQuery);
                List<Module_Task__c> moduleTasks = Database.query(moduleTaskQuery);

                //Create a Map of Step Modules and related Module Tasks
                Map<Id, List<Module_Task__c>> stepTaskMap = new Map<Id, List<Module_Task__c>>();
                for(Module_Task__c theModuleTask: moduleTasks){

                    if(!stepTaskMap.containsKey(theModuleTask.Step_Module__c)){
                        List<Module_Task__c> moduleTaskList = new List<Module_Task__c>();
                        moduleTaskList.add(theModuleTask);

                        stepTaskMap.put(theModuleTask.Step_Module__c, moduleTaskList);
                    }else{
                        stepTaskMap.get(theModuleTask.Step_Module__c).add(theModuleTask);
                    }
                }

                //Wrap the Step Modules with their related Module Tasks
                List<Adventure_StepModuleWrapper> moduleWrappers = new List<Adventure_StepModuleWrapper>();
                for(Step_Module__c theStepModule : stepModules){
                    if(theStepModule != NULL) {
                        moduleWrappers.add(Adventure_StepModuleWrapperHelper.createWrapper(theStepModule, stepTaskMap.get(theStepModule.Id)));
                    }
                }

                //Build the Map <Adventure ID, List of Step Modules>
                for(Adventure_StepModuleWrapper theWrapper : moduleWrappers){

                    //If the Map doesn't yet have the Key
                    if(!adventureStepModuleWrapperMap.containsKey(theWrapper.Adventure_Step_Id)){

                        //Create the Step Module Wrapper List
                        List<Adventure_StepModuleWrapper> newValueList = new List<Adventure_StepModuleWrapper>();
                        newValueList.add(theWrapper);

                        //and Map it to the Adventure Step Id
                        adventureStepModuleWrapperMap.put(theWrapper.Adventure_Step_Id, newValueList);

                    //If Map does contain the key, add the value
                    }else{
                        adventureStepModuleWrapperMap.get(theWrapper.Adventure_Step_Id).add(theWrapper);
                    }
                }

            } catch (exception e) {
                System.debug('ERROR ==' + e.getMessage());
            }
        }

        return adventureStepModuleWrapperMap;
    }
}