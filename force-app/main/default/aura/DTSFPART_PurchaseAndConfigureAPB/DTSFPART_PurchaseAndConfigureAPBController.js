({
	doInit : function(component, event, helper) {
        helper.getLoggedInSource(component, event);
    },
    
    closeModal : function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    }
})