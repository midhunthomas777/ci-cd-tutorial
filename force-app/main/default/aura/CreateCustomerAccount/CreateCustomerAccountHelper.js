({
	showToast : function(component, event, helper) {
        var successMessage = $A.get("$Label.c.Create_Google_Drive_Success_Message");
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "mode":'dismissible',
            "title": "Request Submitted Successfully!",
            "message": successMessage
        });
        toastEvent.fire();
    }
})