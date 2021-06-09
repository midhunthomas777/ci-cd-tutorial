({
    checkAccess : function(component, event, helper) {
        var recordId = component.get("v.recordId");
        var permittedUsers = $A.get("$Label.c.Permitted_Uses_for_Google_Drive_Deletion");
        var confirmMessage = $A.get("$Label.c.Delete_Confirmation");
        var action = component.get("c.quickCheckForDrive");
        action.setParams({ recordId : recordId, deleteDrive: true });
        action.setCallback(this, function(response) {
            //console.log('Entered JS CALL BACK delete init');
            if (response.getState() === "SUCCESS") {
                console.log('RESPONSE###'+response.getReturnValue());
                if(!(response.getReturnValue()  === "")) {
                    //console.log('Inside normal response');
                    component.set("v.hideButton",true);                    
                    component.set("v.displayMessage",response.getReturnValue());
                } else {
                    //console.log('Inside blank response');
                    component.set("v.hideButton",false); 
                    component.set("v.confirmMessage",confirmMessage);
                } 
            } else {
                console.log('Error in verifying the existing drives');
            }
        });
        //console.log('hide button##'+component.get("v.hideButton"));
        $A.enqueueAction(action);
    },
    deleteGoogleDrive : function(component, event, helper) {
        var recordId = component.get("v.recordId");
        var confirmMessage = $A.get("$Label.c.Delete_Confirmation");
        var recIds = [];
        recIds.push(recordId);
        var action = component.get("c.googleDriveFunctions");
        action.setParams({ lstRecordIds : recIds , action: 'Delete' });
        action.setCallback(this, function(response) {
            //console.log('Entered JS CALL BACK delete init');
            if (response.getState() === "SUCCESS") {
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
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "mode":'dismissible',
            "title": "Delete Request Submitted Successfully!",
            "message": "Please check after sometime"
        });
        toastEvent.fire();
    },
})