({
    getPartnerContactDetails : function(component,event,helper){
        var action = component.get("c.getExistingDetails");
        action.setParams({ 
            currentRecordId : component.get("v.recordId")
        });
        action.setCallback(this, function(response){ 
            var state = response.getState();
            var response = response.getReturnValue();
            if(state == "SUCCESS"){
                if(response.mpeStatus !== "Pending Registration"){
                    component.set("v.errorMessage",true);
                }
            }else{
                console.log("Error getting Contact Details = "+response);
            }
        });
        $A.enqueueAction(action);
    }
})