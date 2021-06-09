/*
 * Copyright (c) 2019. 7Summits Inc. All rights reserved. 
 *
 */

({
    goToNext : function(component, event, helper) {
        var compEvent = component.getEvent("pageChange");
        compEvent.setParams({"message" : "2", "slide" : "Welcome"});
        compEvent.fire();
    }
})