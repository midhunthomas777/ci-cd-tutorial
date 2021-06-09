({
    doInit: function(component, event, helper) {
        // Create the action
        var action = component.get("c.getAccountManager");
        // Add callback behavior for when response is received
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                //alert(response.getReturnValue());
                component.set("v.setMeOnInit",$A.get("$Label.c.CAM")+' '+response.getReturnValue());
            }
            else {
                console.log("Unable to find your account manager");
            }
        });
        // Send action off to be executed
        $A.enqueueAction(action);
    }
})