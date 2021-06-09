/*
 * Copyright (c) 2018. 7Summits Inc.
 */

({
    doInit : function(component, event, helper) {
        var action = component.get("c.getSummaryWrapper");
        action.setParams({ideaId : component.get("v.recordId")});
        action.setCallback(this, function (actionResults) {
            var state = actionResults.getState(); 
            if(state === "SUCCESS") {
                var _response = actionResults.getReturnValue();
                component.set("v.summaryWrapper", _response);
            }		
        });
        $A.enqueueAction(action);
        
    }
});