({
    doInit : function(component, event, helper) {
        component.set("v.loadSpinner", true);
        var action = component.get('c.revokeOppShare');
        action.setParams({
            "recId": component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            component.set("v.loadSpinner", true);
            if (state === 'SUCCESS' && component.isValid()) {
                var resp = response.getReturnValue();
                if(resp === 'true'){
                    $A.get("e.force:closeQuickAction").fire();
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        type:"Success",
                        title: "Success!",
                        message: "Sharing has been revoked successfully."
                    });
                    toastEvent.fire();
                }
                else{
                    $A.get("e.force:closeQuickAction").fire();
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        type:"Error",
                        title: "Error!",
                        duration: 50000,
                        message: resp
                    });
                    toastEvent.fire();
                }
            }
        });
        $A.enqueueAction(action);
    }
})