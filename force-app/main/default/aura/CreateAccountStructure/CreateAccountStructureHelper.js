({
	showToast : function(component, event, helper) {
        var successMessage = $A.get("$Label.c.Customer_Account_Creation_Success_Message");
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "mode":'dismissible',
            "title": "Unmerge Request Submitted Successfully!",
            "message": successMessage
        });
        toastEvent.fire();
    }
})