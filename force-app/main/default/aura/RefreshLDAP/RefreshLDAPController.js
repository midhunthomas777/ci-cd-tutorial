({
    doInit : function(component, event, helper) {
        var action = component.get("c.getContactDetails");  
        action.setParams({
            conId:component.get("v.recordId")
        });
        
        action.setCallback(this,function(response){
            if (response.getState() === "SUCCESS") {
                component.set("v.ldapId",response.getReturnValue());
            }
        });
        
        $A.enqueueAction(action);
    },
    
    refreshLDAPAttributes : function(component, event, helper){
        console.log('inside refreshLDAP JS Controller');
        var action = component.get("c.peformRefresh");  
        action.setParams({
            conId:component.get("v.recordId")
        });
        
        action.setCallback(this,function(response){
            var state = response.getState();
                    console.log('state##'+state);

            if (state === "SUCCESS") {
                var dismissActionPanel = $A.get("e.force:closeQuickAction");
                dismissActionPanel.fire();
                
                component.find('notifLib').showToast({
                    "variant": "info",
                    "header": "Request Submitted Successfully!",
                    "message": response.getReturnValue()
                });
            }else{
                console.log('Error in retreiving Metadata');
                var dismissActionPanel = $A.get("e.force:closeQuickAction");
                dismissActionPanel.fire();
                
                component.find('notifLib').showToast({
                    "variant": "error",
                    "header": "Something has gone wrong!",
                    "message": "Unfortunately, there was a problem updating the record.Please contact System Administrator"
                });
            }
        });
        
        $A.enqueueAction(action);
    }
})