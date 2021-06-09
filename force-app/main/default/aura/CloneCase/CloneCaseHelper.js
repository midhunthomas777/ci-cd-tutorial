({
    validateCase : function(component,event, helper){
        component.set("v.loadSpinner", true);
        var caseId = component.get("v.recordId"); 
        var action = component.get("c.isValidated");      
        action.setParams({"caseId": caseId});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var resp= response.getReturnValue();
                if(resp.startsWith('Success')) {
                    var successMSg=resp.split('Success')[1];
                    component.set("v.showSuccess", successMSg);
                    this.createCase(component,event, helper);
                    //component.set("v.loadSpinner", false);
                }else{
                    var errorMSg=resp.split('Error')[1];
                    component.set("v.showError", errorMSg);
                    component.set("v.loadSpinner", false);
                }
            }else{
                component.set("v.showError", 'Error Occured. Something Went Wrong.');
                component.set("v.loadSpinner", false);
            }
        });
        $A.enqueueAction(action);  
    },
    
    
    createCase : function(component,event, helper){
        component.set("v.loadSpinner", true);
        var successMsg = component.get("v.showSuccess");
        var caseId = component.get("v.recordId"); 
        var action = component.get("c.cloneCase");      
        action.setParams({"caseId": caseId});
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === 'SUCCESS' && component.isValid()){
                
                var resp= response.getReturnValue();
                if(resp != 'Fail'){
                    var sObjectEvent = $A.get("e.force:navigateToSObject");
                    sObjectEvent.setParams({
                        "recordId": resp,
                        "slideDevName": "detail"
                    });
                    sObjectEvent.fire();
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title : 'Success',
                        message: successMsg,
                        duration:'60000',
                        key: 'info_alt',
                        type: 'success',
                        mode: 'dismissible'
                    });
                    toastEvent.fire();
                    //window.location.reload();
                }else{
                    component.set("v.FinalMsg", 'Error Occured While creating Record');
                    component.set("v.loadSpinner", false);
                }
            }else{
                component.set("v.FinalMsg", 'Error Occured While creating Record');
                component.set("v.loadSpinner", false);
            }
            //component.set("v.loadSpinner", false);
        });
        $A.enqueueAction(action);
    }
})