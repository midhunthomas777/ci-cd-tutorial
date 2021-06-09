/*
 * Copyright (c) 2019. 7Summits Inc. All rights reserved. 
 *
 */

({
    initGroups : function(component, event, helper, groupIds) {
        var action = component.get("c.getGroups");
        console.log('initGroups', groupIds);
        action.setParams({
            "groupIds": groupIds
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                var groups = response.getReturnValue();
                if(groups.length > 0) {
                    console.log('initGroups:groups', groups, groups.length);
                    component.set("v.groups", groups);
                } else {
                    console.log('No groups returned');
                }
            } else {
                console.log("Failed with state: " + state);
            }
        });
        $A.enqueueAction(action);
    },

/*
    TODO: Dynamic query builder for custom fields
*/
    grabUserSpecific : function(component, event, helper) {
        var action = component.get("c.getUserSpecificGroups");
        action.setCallback(this, function(response){
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                var groups = response.getReturnValue();
                component.set("v.groups", groups);
            } else {
                console.log("Failed with state: " + state);
            }
        });
        $A.enqueueAction(action);
    },
    goToNext : function(component, event, helper) {
        var compEvent = component.getEvent("pageChange");
        compEvent.setParams({"message" : "10", "slide" : "Group"});
        compEvent.fire();
    },
    goBack : function(component, event, helper) {
        var compEvent = component.getEvent("pageChange");
        compEvent.setParams({"message" : "4", "slide" : ""});
        compEvent.fire();
    },
    joinGroups : function(component, event, helper) {
        var action = component.get("c.insertGroupMember");
        const groups = component.get("v.groups");
        action.setParams({
            "groupOneId":       groups[0] && groups[0].id ? groups[0].id : null,
            "groupOneEmail":    groups[0] && groups[0].notificationFrequency ? groups[0].notificationFrequency : '',
            "groupOneJoined":   groups[0] && groups[0].following ? groups[0].following : '',
            "groupTwoId":       groups[1] && groups[1].id ? groups[1].id : null,
            "groupTwoEmail":    groups[1] && groups[1].notificationFrequency ? groups[1].notificationFrequency : '',
            "groupTwoJoined":   groups[1] && groups[1].following ? groups[1].following : '',
            "groupThreeId":     groups[2] && groups[2].id ? groups[2].id : null,
            "groupThreeEmail":  groups[2] && groups[2].notificationFrequency ? groups[2].notificationFrequency : '',
            "groupThreeJoined": groups[2] && groups[2].following ? groups[2].following : '',
            "groupFourId":      groups[3] && groups[3].id ? groups[3].id : null,
            "groupFourEmail":   groups[3] && groups[3].notificationFrequency ? groups[3].notificationFrequency : '',
            "groupFourJoined":  groups[3] && groups[3].following ? groups[3].following : ''
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                console.log('resolved: ' + response.getReturnValue());
            }
            else {
                console.log("Failed with state: " + state);
            }
        });
        $A.enqueueAction(action);

    }
})