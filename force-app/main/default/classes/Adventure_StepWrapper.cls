/**
 * Copyright (c) 2018. 7Summits Inc.
 * Created by 7Summits - Created by Melinda Grad on 8/7/18.
 */

public with sharing class Adventure_StepWrapper {

    @AuraEnabled public Id id{get;set;}
    @AuraEnabled public String stepName{get;set;}
    @AuraEnabled public String title{get;set;}
    @AuraEnabled public String subtitle{get;set;}
    @AuraEnabled public Decimal order{get;set;}
    @AuraEnabled public String iconImage{get;set;}
    @AuraEnabled public List<ContentDocumentLink> contentDocumentLinks {get;set;}
    @AuraEnabled public List<Adventure_StepModuleWrapper> stepModuleWrapperList{get;set;}


}