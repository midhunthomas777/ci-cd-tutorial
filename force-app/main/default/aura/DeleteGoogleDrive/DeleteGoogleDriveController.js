({
    doInit: function (component,event,helper) {
        var recordId = component.get("v.recordId");
        var insufficientPrivilegesErrorMessage = $A.get("$Label.c.Insufficient_Privilges");
        var permittedUsers = $A.get("$Label.c.Permitted_Uses_for_Google_Drive_Deletion");
        var confirmMessage = $A.get("$Label.c.Delete_Confirmation");
        var userId = $A.get("$SObjectType.CurrentUser.Id");
        if(permittedUsers.includes(userId)){
            helper.checkAccess(component,event,helper);
        } else{
            component.set("v.hideButton",true);                    
            component.set("v.displayMessage",insufficientPrivilegesErrorMessage);
        }
        
    },
    
    handleDelete : function(component, event, helper) {
       	helper.deleteGoogleDrive(component,event,helper); 
        //var userId = $A.get("$SObjectType.CurrentUser.Id");
        //$A.get("e.force:closeQuickAction").fire();
        //helper.showToast();
    }
})