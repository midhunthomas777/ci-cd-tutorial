({
    doInit : function(component, event, helper) {
        var action=component.get('c.deactivateAppAccess');
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS"){
                if( response.getReturnValue()==true){
                    component.set("v.isAdminProfile",true);
                }else{
                    component.set("v.isnotAdminProfile",true);
                }
            }
        });
        $A.enqueueAction(action);
},
    Deactivate : function(component, event, helper){
        component.set("v.loadSpinner",true);
        var applicationAccessId = component.get("v.recordId");        
        var action=component.get('c.deactivateApplicationAccess');
        action.setParams({
            "applicationAccessId" : applicationAccessId                     
        });
        action.setCallback(this, function(response) {
            var dismissActionPanel = $A.get("e.force:closeQuickAction"); 
            dismissActionPanel.fire();
            component.set("v.loadSpinner",false);
            var state = response.getState();
            if (state === "SUCCESS") {
                window.location.reload();
            }
        });
        $A.enqueueAction(action);
    }
})