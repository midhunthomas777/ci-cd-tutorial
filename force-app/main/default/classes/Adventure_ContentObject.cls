/*
    Copyright (c) 2018. 7Summits Inc.
    Created by 7Summits - Melinda Grad on 7/25/18.
    Custom Wrapper Class to return to Front End
*/
public with sharing class Adventure_ContentObject
{

    @AuraEnabled public Adventure__c adventure{get;set;}
    @AuraEnabled public List<Adventure_StepWrapper> adventureStepWrapper{get;set;}

}