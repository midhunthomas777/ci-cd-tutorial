({
    doInit : function(component, event, helper) {
        component.set("v.showSpinner", true);
        var action = component.get('c.getAllRevenuesPerOppo');
        action.setParams({
            'oppoId': component.get("v.recordId")
        });        
        action.setCallback(this, function(response) { 
            var state = response.getState();
            if(state=='SUCCESS'){ 
                var storeResponse = response.getReturnValue();
                //SF-2243
                var finalResult = storeResponse;
                for (var i = 0; i < finalResult.length; i++) {
                    if(finalResult[i].Revenue_Delta_New__c > 0){
                        finalResult[i].Revenue_Delta_New__c = '+' + finalResult[i].Revenue_Delta_New__c
                    }
                }
                //console.log('storeResponse '+JSON.stringify(storeResponse));
                component.set('v.oppoLineItems', storeResponse);
            }
        });
        $A.enqueueAction(action);
        
    },
    handleSuccess : function(component, event, helper) {
        // alert('success');
    },
    
    handleLoad : function(component, event, helper) {
    },
    handleSubmit : function(component, event, helper) {
        event.preventDefault();
        var fields = event.getParam('fields');
        console.log('test-->'+JSON.stringify(fields));
        helper.updateOLI(component, event, helper, fields);
    },
    handleError :function(component, event, helper) {
        console.log('error');
    },
    refresh:function(component, event, helper) {
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": component.get("v.recordId"),
            "slideDevName": "related"
        });
        navEvt.fire();
    }
})