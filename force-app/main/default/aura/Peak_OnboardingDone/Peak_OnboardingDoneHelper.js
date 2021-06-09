/*
 * Copyright (c) 2019. 7Summits Inc. All rights reserved.
 *
 */

({
    completeOnboarding : function(component, event, helper) {
        var compEvent = component.getEvent("pageChange");
        compEvent.setParams({"message": "Close", "slide": "Done"});
        compEvent.fire();
    },
    goBack : function(component, event, helper) {
        var compEvent = component.getEvent("pageChange");
        compEvent.setParams({"message" : "12", "slide" : ""});
        compEvent.fire();
    },
    goToProfile : function(component, event, helper) {
        var user = component.get("v.user");
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": "/s/profile/" + user.Id
        });
        urlEvent.fire();
    },
    goToUrl: function(url) {
        var action = $A.get('e.force:navigateToURL');
        action.setParams({
            url: url
        });
        action.fire();
    }
})