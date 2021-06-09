({
    retrieveUserDetails : function(component, event, helper) {
        var action = component.get("c.getUserData");
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state==='SUCCESS'){
                var responseWrapper = response.getReturnValue();
                component.set("v.defaultRMARequestFormWrapper", responseWrapper);
                component.set("v.RMARequestFormWrapper", JSON.parse(JSON.stringify(responseWrapper)));
            }
        });
        $A.enqueueAction(action);
    },
    showToast : function(component,message,messageType,duration){
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title"  : messageType+"!",
            "type"   : messageType,
            "message": message,
            "duration" : duration
        });
        toastEvent.fire();
    },
    submitrequest : function(component, event, helper) {
        var lineItemList = JSON.stringify(component.get("v.RMARequestFormWrapper"));
        var action = component.get("c.submitForm");
        action.setParams({
            "submittedForm": lineItemList
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === 'SUCCESS'){
                var rmaid = response.getReturnValue();
                var message = "Your RMA has been submitted for processing, your confirmation number is "+rmaid;
                helper.showToast(component, message, 'Success', 70000);
                component.set("v.isOpen", false);
                component.find("overlayLib").notifyClose();
            }
            else
            {
                
            }
        });
        $A.enqueueAction(action);
    }
})