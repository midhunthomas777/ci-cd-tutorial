({
	getPlanviewResponse : function(component, event, helper) {
        var planviewSuccessMessage = $A.get("{!$Label.c.Planview_Created_Success_Message}");
		var action = component.get("c.createOpportunityInPlanView");
                    console.log('##Invoking action##');
                    action.setParams({ 
                        "opportunityId" : component.get("v.recordId")
                    });
                    
                    action.setCallback(this, function(response) {
                        var state = response.getState();
                        var result = response.getReturnValue();
                        component.set("v.planViewResponseWrapper",result);	
                        console.log('##state##'+state);
                        if (state === "SUCCESS") {
                            var planViewData = component.get("v.planViewResponseWrapper");
                            if(planViewData.Status=="Success"){
                                component.set("v.showSpinner",false);
                                $A.get("e.force:closeQuickAction").fire();
                                var toastEvent = $A.get("e.force:showToast");
                                toastEvent.setParams({
                                    "title": "Success!",
                                    "type": "success",
                                    "message": planviewSuccessMessage
                                });
                                toastEvent.fire();
                                $A.get('e.force:refreshView').fire();
                            }else{
                                component.set("v.showSpinner",false);
                                component.set("v.errorMsg",planViewData.Details); 
                            }
                        }
                        else if (state === "ERROR") {
                            var errors = response.getError();
                            console.log('##state##'+errors);
                            if (errors) {
                                if (errors[0] && errors[0].message) {
                                    console.log("Error message: " + 
                                                errors[0].message);
                                    component.set("v.showSpinner",false);
                                    $A.get("e.force:closeQuickAction").fire();
                                    var toastEvent = $A.get("e.force:showToast");
                                    toastEvent.setParams({
                                        "title": "Error!",
                                        "type": "error",
                                        "message": errors[0].message
                                    });
                                    toastEvent.fire();
                                }
                            } 
                        }
                    });
                    $A.enqueueAction(action); 
	}
})