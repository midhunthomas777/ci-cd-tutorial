({
    viewUser : function(component, event, helper) {
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": component.get("v.user.Id"),
            "slideDevName": "related"
        });
        navEvt.fire();
    },
    disableUser : function(component, event, helper) {
        var action = component.get('c.disableComUser'); 
        component.set("v.loadSpinner", true);
        action.setParams({
            'userId': component.get("v.user.Id")
        });        
        action.setCallback(this, function(response) {
            component.set("v.loadSpinner", false);
            var state = response.getState();
            if(state=='SUCCESS'){
                $A.util.addClass(component.find('errorMessageAccordion'), 'slds-hide');
                helper.onSuccessM(component, event, helper);
            } else {
                helper.logErrors(component, response.getError());
            }
        });
        $A.enqueueAction(action);
    }
})