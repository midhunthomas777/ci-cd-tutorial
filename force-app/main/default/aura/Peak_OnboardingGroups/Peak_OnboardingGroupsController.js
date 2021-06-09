/*
 * Copyright (c) 2019. 7Summits Inc. All rights reserved. 
 *
 */

({
    init : function(component, event, helper) {
/*
        TODO: Dynamic query builder for custom fields
*/
        if(component.get("v.showUserSpecificGroups") === true){
            helper.grabUserSpecific(component, event, helper);
        } else {
            const groupIDs = component.get("v.groupIDs");
            if(groupIDs && groupIDs !== '') {
                let groupIDsArray = groupIDs.split(",");
                if(groupIDsArray.length > 0) {
                    helper.initGroups(component, event, helper, groupIDsArray);
                }
            }
        }
    },
    goToNext : function(component, event, helper) {
        helper.joinGroups(component, event, helper);
        helper.goToNext(component, event, helper);
    },
    goBack : function(component, event, helper) {
        helper.goBack(component, event, helper);
    },

    handleGroupNotificationChange : function (cmp, event, helper) {
        let groups = cmp.get("v.groups");
        const groupId = event.getParam("id");
        const notificationFrequency = event.getParam("value");
        groups.forEach(function (group) {
            if(group.id === groupId) {
                group.notificationFrequency = notificationFrequency;
            }
        });
        cmp.set("v.groups", groups);
    },

    handleGroupJoin : function (cmp, event, helper) {
        let groups = cmp.get("v.groups");
        const groupId = event.getParam("id");
        groups.forEach(function (group) {
            if(group.id === groupId) {
                group.following = true;
            }
        });
        cmp.set("v.groups", groups);
    },

    handleGroupRemove : function (cmp, event, helper) {
        let groups = cmp.get("v.groups");
        const groupId = event.getParam("id");
        groups.forEach(function (group) {
            if(group.id === groupId) {
                group.following = false;
            }
        });
        cmp.set("v.groups", groups);
    }
})