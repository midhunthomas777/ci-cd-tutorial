/**
 * Copyright (c) 2018. 7Summits Inc.
 * Created by 7Summits - Created by Melinda Grad on 8/1/18.
 */

public with sharing class Adventure_StepModuleWrapper {

    @AuraEnabled public Id id{get;set;}
    @AuraEnabled public Id Adventure_Step_Id{get;set;}
    @AuraEnabled public String title{get;set;}
    @AuraEnabled public Integer order{get;set;}
    @AuraEnabled public String descriptionLabel{get;set;}
    @AuraEnabled public String descriptionLink{get;set;}
    @AuraEnabled public String tooltip{get;set;}
    @AuraEnabled public List<Module_Task__c> moduleTasks {get;set;}

}