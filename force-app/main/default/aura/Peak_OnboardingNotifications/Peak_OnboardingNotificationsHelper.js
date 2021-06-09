/*
 * Copyright (c) 2019. 7Summits Inc. All rights reserved.
 *
 */

({
    goToNext : function(component, event, helper) {
        var compEvent = component.getEvent("pageChange");
        compEvent.setParams({"message" : "11", "slide" : "Notification"});
        compEvent.fire();

    },
    goBack : function(component, event, helper) {
        var compEvent = component.getEvent("pageChange");
        compEvent.setParams({"message" : "9", "slide" : ""});
        compEvent.fire();
    },
    updateNotifications : function(component, event, helper) {
        var action = component.get("c.updatePreferences");
        action.setParams({
            "decision": component.get("v.getNotifications")
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                console.log('Update of notifications preferences successful.');
            }
            else {
                console.log("Failed with state: " + state);
            }
        });
        $A.enqueueAction(action);
    }
})