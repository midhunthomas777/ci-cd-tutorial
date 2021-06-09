/**
 * Copyright (c) 2019. 7Summits Inc. All rights reserved.
 */
({
    init: function(component, event, helper) {
        var title = component.get("v.title") || '';
        var description = component.get("v.description") || '';
        var subText = component.get("v.subText") || '';

        if(
            title && title.trim() === '' &&
            description && description.trim() === '' &&
            subText && subText.trim() === ''
        ) {
            component.set("v.hideHeader", true);
        }
    },

    handlePrimaryClick: function (component, event) {
        var event = component.getEvent("primaryOnClick");
        event.setParams({
            value: "primary"
        });
        event.fire();
    },

    handleBackClick: function (component, event) {
        var event = component.getEvent("backOnClick");
        event.setParams({
            value: "back"
        });
        event.fire();
    }
})