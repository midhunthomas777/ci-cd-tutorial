({
    getcurrentValue : function(component, event, helper){
        var incomingKey = component.get("v.key");
        var map = component.get("v.finalMap");
        var recordsMeta = [];
        var singleMap = [];
        for(var mapkey in map){
            var outerMap = map[mapkey];
            for(var innerkey in outerMap){
                if(innerkey == incomingKey){
                    singleMap = outerMap[innerkey];
                }
            }
        }
        for(var key in singleMap){
            recordsMeta.push({
                value: singleMap[key],
                key: key
            });
        }
        return recordsMeta;
    },
    updateRecords : function(component, event, helper){
        var action = component.get("c.upsertCAPPS");
        action.setParams({ 
            "wrapper"  : JSON.stringify(component.get("v.cappsData")),
            "operation": "updation"
        });
        action.setCallback(this, function(response){ 
            var state = response.getState();
            var storeResponse = response.getReturnValue();
            if(state === "SUCCESS" && storeResponse == "SUCCESS"){
                component.set("v.showSpinner",false);
                this.showToast(component,"Records has been updated successfully!","Success");
            }else if(state === "ERROR"){
                component.set("v.showSpinner",false);
                var errors = response.getError();
                if(errors){
                    if(errors[0] && errors[0].message) {
                        console.log("Error message: "+errors[0].message);
                        this.showToast(component,errors[0].message,"Error");
                    }
                } 
            }else{
                component.set("v.showSpinner",false);
                console.log("Error = "+response.getReturnValue());
                this.showToast(component,"Exception Occurred while updating the records","Error");
            }
        });
        $A.enqueueAction(action);
    },
    showToast : function(component,message,messageType){
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title"  : messageType+"!",
            "type"   : messageType,
            "message": message
        });
        toastEvent.fire();
    },
})