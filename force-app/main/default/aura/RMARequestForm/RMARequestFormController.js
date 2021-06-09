({
    doInit : function(component, event, helper) {
        helper.retrieveUserDetails(component,event,helper);
    },
    
    closeModal : function(component, event, helper) {
        component.set("v.isOpen", false);
    },
    
    submitRequest : function(component, event, helper) {
     helper.submitrequest(component,event,helper);
    }
})