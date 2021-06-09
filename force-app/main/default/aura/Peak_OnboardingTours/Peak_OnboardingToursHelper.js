/*
 * Copyright (c) 2019. 7Summits Inc. All rights reserved. 
 *
 */

({
    goToNext : function(component, event, helper) {
        var compEvent = component.getEvent("pageChange");
        compEvent.setParams({"message" : "12", "slide" : "Tours"});
        compEvent.fire();
    },
    goBack : function(component, event, helper) {
        var compEvent = component.getEvent("pageChange");
        compEvent.setParams({"message" : "10", "slide" : ""});
        compEvent.fire();
    },
    completeOnboarding : function(component, event, helper) {
        var compEvent = component.getEvent("pageChange");
        compEvent.setParams({"message": "Close", "slide": "Done"});
        compEvent.fire();
    },
    goBackToTours : function(component, event, helper) {
        var compEvent = component.getEvent("pageChange");
        compEvent.setParams({"message" : "11", "slide" : ""});
        compEvent.fire();
    }
})