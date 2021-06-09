/*
 * Copyright (c) 2019. 7Summits Inc. All rights reserved.
 *
 */

({

    handleClick: function(component, event, helper) {
        let link = event.getParam("value");
        helper.completeOnboarding(component, event, helper);
        helper.goToUrl(link);
    },
    completeOnboarding : function(component, event, helper) {
        helper.completeOnboarding(component, event, helper);
    },
    goBack : function(component, event, helper) {
        helper.goBack(component, event, helper);
    },
    goToProfile : function(component, event, helper) {
        helper.goToProfile(component, event, helper);
    }
})