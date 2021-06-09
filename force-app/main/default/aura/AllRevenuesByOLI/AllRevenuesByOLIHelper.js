({
    updateOLI: function(component, event, helper, eventFields) {
        component.set("v.loadSpinner", true);
        var recordid=component.get("v.recordId");//added by akhil
        var action = component.get('c.updateOLI');
        var userTheme = component.get("v.userTheme"); //added by akhil
        action.setParams({
            'recordId': eventFields['recordId'],
            'oli': eventFields
        });        
        action.setCallback(this, function(response) { 
            component.set("v.loadSpinner", false);
            var state = response.getState();
            if(state=='SUCCESS'){ 
                var storeResponse = response.getReturnValue();
                if(storeResponse =='Success'){
                    window.location.reload();
                }
            }
        });
        $A.enqueueAction(action);
    }
})