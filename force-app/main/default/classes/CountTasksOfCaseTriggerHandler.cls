/*
* Created on: 07-dec-2019
* Trigger handler class for CountTasksOfCase trigger to prevent case closure, 
* if there are non closed tasks associated with case.
* US: Open Tasks prevent Case Closure (7)
*/
public class CountTasksOfCaseTriggerHandler{
    
    public static void preventCaseClosureForNonClosedTasks(Map<Id, SObject> newItems, Map<Id, SObject> oldItems){
        Map<Id,Case> newCaseMap = new Map<Id,Case>();
        if(newItems != null) newCaseMap = (Map<Id,Case>) newItems;
        Map<Id,Case> oldCaseMap = new Map<Id,Case>();
        if(oldItems != null) oldCaseMap = (Map<Id,Case>) oldItems; 
        
         // Find all cases that are being closed...
        Set<Id> newlyClosedCaseIds = new Set<Id>();
        system.debug('case Id: '+newCaseMap.keySet());
        
        for (Id caseId : newCaseMap.keySet()) {
            if (newCaseMap.get(caseId).status != oldCaseMap.get(caseId).status && (newCaseMap.get(caseId).IsClosed || newCaseMap.get(caseId).status=='Resolved')  &&   
                !oldCaseMap.get(caseId).IsClosed) {
                    
                    Case caseObj = [select id,recordTypeId,recordType.name,recordtype.developerName,Customer_Account__c from case where id=:caseId];
                    
                    string recordTypeName = Schema.SObjectType.Case.getRecordTypeInfosById().get(caseObj.recordTypeId).getname();
                    system.debug('Record type : '+recordTypeName);                
                    String recordType  = caseObj.recordtype.developerName;
                    
                    //Trigger should run only for specific record types  
                    //Removing 'MSI_Support_Case_Incident' reference from below if - "|| recordType == 'MSI_Support_Case_Incident'"          
                    if (recordType == 'Admin_Service_Case' || recordType == 'MSI_Support_Case_Technical_Request'
                        || recordType == 'MSI_Support_Case_Application_Support' || recordType == 'MSI_Support_Case_Administrative'
                        || recordType == 'MSI_Support_Case_Order_Management' || recordType == 'Image') 
                    {
                        //check for “Populate Customer Number from MCN (Customer Account)” process builder
                        //if(caseObj.Customer_Account__c!=null)
                        //{
                            system.debug('recordType '+recordType);
                            newlyClosedCaseIds.add(caseId);
                        //}
                    }
                }
        }
        
        // For every newly closed Case that has at least one not closed task add an error to the Trigger.newMap entry.
        // Adding the error to the Trigger.new entry will prevent the save and add the error message to the page messages 
        // that get displayed on the page.
        
        for (AggregateResult aggResult : [
            Select Count(Id), WhatId
            From Task
            Where WhatId In :newlyClosedCaseIds
            And IsClosed = false
            Group by WhatId
            Having Count(Id) > 0
        ]) {
            Id caseId = (Id) aggResult.get('WhatId');
            SObject errorCase = Trigger.newMap.get(caseId);
            
            // change error message as appropriate...
            errorCase.addError('Cannot close case since there are non closed tasks' ); 
        }
    }
}