// ===================
// Custom Response wrapper
//  Copyright (c) 2018. 7Summits Inc.
//  Created by 7Summits - Melinda Grad on 7/25/18.
// ===================
public with sharing class Adventure_Response
{
    @AuraEnabled public Boolean success{get;set;} // success or failure
    @AuraEnabled public List<String> messages{get;set;}  // messages to display
    @AuraEnabled public List<SObject> results{get;set;} // results to iterate over - use this when querying SOjbects directoy
    @AuraEnabled public List<Adventure_ContentObject> peakResults{get;set;} // custom results to iterate over - use this when creating a list of custom wrapper classes

    public Adventure_Response(){
        success = true;
        messages = new List<String>();
        results = new List<SObject>();
        peakResults = new List<Adventure_ContentObject>();
    }
}