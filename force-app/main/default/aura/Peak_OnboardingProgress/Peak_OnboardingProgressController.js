/*
 * Copyright (c) 2019. 7Summits Inc. All rights reserved.
 *
 */

({
    handlePageChange : function(component, event, helper) {
        var clickEvent = component.getEvent("onclick");
        clickEvent.setParams({
            message: event.getParam("message"),
            slide: event.getParam("slide")
        });
        clickEvent.fire();
    },

    closeModal: function(component, event, helper) {
        component.set("v.displayOnboarding", false);
    }
})