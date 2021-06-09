({
    doInit : function(component, event, helper) {
        component.set("v.loadSpinner", true);
        var action = component.get('c.shareOpp');
        action.setParams({
            "recId": component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            component.set("v.loadSpinner", false);
            if (state === 'SUCCESS' && component.isValid()) {
                var resp = response.getReturnValue();
                if(resp === 'true'){
                    $A.get("e.force:closeQuickAction").fire();
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        type:"Success",
                        title: "Success!",
                        message: "Records has been shared successfully."
                    });
                    toastEvent.fire();
                }
                else{
                    $A.get("e.force:closeQuickAction").fire();
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        type:"Error",
                        title: "Error!",
                        duration: 5000,
                        message: resp
                    });
                    toastEvent.fire();
                }
            }
        });
        $A.enqueueAction(action);
    }
})