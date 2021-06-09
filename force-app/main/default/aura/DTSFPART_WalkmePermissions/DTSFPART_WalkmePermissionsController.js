({
    setWalkmePermissions : function(component, event, helper) {
        window.WalkMeUserInfo = event.getParam('arguments').permissions;
    },

    handlePubsubReady : function(component, event, helper) {
        const pubsub = component.find("pubsub");
        const callback = $A.getCallback(function(param) {
            if (window.WalkMeAPI) {
                window.WalkMeAPI.startFlowById(parseInt(param.walkMeId));
            }
        });
        pubsub.registerListener("showWalkMe", callback);    
    }
})