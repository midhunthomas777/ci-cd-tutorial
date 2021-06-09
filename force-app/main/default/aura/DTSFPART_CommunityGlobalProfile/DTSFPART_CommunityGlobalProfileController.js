({
    logout : function(component, event, helper) {
        $A.get("e.force:logout").fire();
    }
})