({
    getLoggedInSource : function(component, event) {
        let action = component.get("c.isLoggedInFromCommunity");
        action.setCallback(this, function(response) {
            let state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.isLoggedInFromComm", !!response.getReturnValue());
            }
            else {
                console.log("Failed with state: " + state);
            }
        });
        $A.enqueueAction(action);
    }
})