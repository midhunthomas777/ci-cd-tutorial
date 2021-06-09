({
	checkAccess : function(component, event, helper) {
        var createConfirmation = $A.get("$Label.c.Create_Confirmation");
        component.set("v.loadSpinner", true);
        var action = component.get("c.quickCheckForDrive");
        var recordId = component.get("v.recordId");
        //console.log('recordId###'+recordId);
        action.setParams({ recordId : recordId, deleteDrive: false});
        action.setCallback(this, function(response) {
            if (response.getState() === "SUCCESS") {
                if(response.getReturnValue()  === "") {
                    component.set("v.hideButton", false);  
                    component.set("v.confirmMessage",createConfirmation);
                } else {
                    component.set("v.hideButton", true);  
                    component.set("v.displayMessage",response.getReturnValue());
                } 
            } else {
                console.log('Error in verifying the existing drives');
            }
        });
        component.set("v.loadSpinner", false);
        $A.enqueueAction(action);
    },
    createGoogleDrive : function(component, event, helper) {
        var recordId = component.get("v.recordId");
        var recIds = [];
        recIds.push(recordId);
        var action = component.get("c.googleDriveFunctions");
        action.setParams({ lstRecordIds : recIds,
                          action: 'Create'
                         });
        action.setCallback(this, function(response) {
            if (response.getState() === "SUCCESS") {
                component.set("v.hideButton", true);  
                //component.set("v.displayMessage",'Google Drive Creation is in Process,it might take few minutes.Please come back later.');
                $A.get("e.force:closeQuickAction").fire();
                this.showToast(); 
            } else {
                $A.get("e.force:closeQuickAction").fire();
                console.log('Error in verifying the existing drives');
            }
        });
        $A.enqueueAction(action);
    },
    showToast : function(component, event, helper) {
        var successMessage = $A.get("$Label.c.Create_Google_Drive_Success_Message");
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "mode":'pester',
            "title": "Request Submitted Successfully!",
            "message": successMessage
        });
        toastEvent.fire();
    }
})