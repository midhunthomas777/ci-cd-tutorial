/*
    Copyright (c) 2018. 7Summits Inc.
    Created by 7Summits - Melinda Grad on 7/25/18.

    Helper class to format Peak Content Object
*/

public with sharing class Adventure_ContentObjectHelper
{

    public static Adventure_ContentObject formatPeakContentObject(Adventure__c theAdventure, List<Adventure_StepWrapper> theStepWrapper){

        Adventure_ContentObject contentObject = new Adventure_ContentObject();
        contentObject.adventure = theAdventure;
        contentObject.adventureStepWrapper = theStepWrapper;

        return contentObject;

    }
}