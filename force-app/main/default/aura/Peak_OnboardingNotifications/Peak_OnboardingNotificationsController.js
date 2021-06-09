/*
 * Copyright (c) 2019. 7Summits Inc. All rights reserved.
 *
 */

({
    goToNext : function(component, event, helper) {
        console.log('in js controller');
        helper.updateNotifications(component, event, helper);
        helper.goToNext(component, event, helper);
    },
    goBack : function(component, event, helper) {
        helper.goBack(component, event, helper);
    },
    notificationChange : function(component, event, helper) {
        var checked = event.getSource().get("v.checked");
        console.log('checked', JSON.parse(JSON.stringify(checked)));
        component.set("v.getNotifications", checked);
    }

})