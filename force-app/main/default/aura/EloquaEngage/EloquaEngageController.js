({
    doInit : function(component, event, helper) {
        var action =component.get("c.getdynamicURL");
        action.setParams({incomingRecId:component.get("v.recordId"),
                          isEngageStr:"true"
                         });
        action.setCallback(this, function(response) {
            console.log('response.getReturnValue()##'+response.getReturnValue());
            if (response.getState() === "SUCCESS") {
                component.set("v.redirectURL",response.getReturnValue());
                helper.gotoURL(component);
            }
        });
        $A.enqueueAction(action);
    }
})