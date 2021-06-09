({
    gotoURL : function (component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
        console.log('Entered gotoURL');
        var finalURL = component.get("v.redirectURL");
        console.log('finalURL##'+finalURL);
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": finalURL
        });
        urlEvent.fire();
    }
})