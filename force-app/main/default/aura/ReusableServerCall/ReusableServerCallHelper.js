({
    callServer : function(component,method,callback,params) {
        component.set("v.loadingSpinner",true);

        var action = component.get(method);
        if (params) {
            action.setParams(params);
        }
        
        action.setCallback(this,function(response) {
            var state = response.getState();
            if (state === "SUCCESS") { 
                // pass returned value to callback function
                callback.call(this,response.getReturnValue());
                component.set("v.loadingSpinner",false);
            } else if (state === "ERROR") {
                // generic error handler
                var errors = response.getError();
                if (errors) {
                    console.log("Errors", errors);
                    if (errors[0] && errors[0].message) {
                        throw new Error("Error" + errors[0].message);
                    }
                } else {
                    throw new Error("Unknown Error");
                }
                component.set("v.loadingSpinner",false);
                location.reload();
            }
        });
        
        $A.enqueueAction(action);
    }
})