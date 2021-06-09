({
    getAssignedPermissions : function(component, event, helper) {
        var action = component.get("c.fetchAccessibleRecordTypes");
        action.setCallback(this, function(response) { 
            var state = response.getState();
            if(state === 'SUCCESS'){
                var resp = response.getReturnValue();
                var recordTypesMap = [];
                for (var key in resp) {recordTypesMap.push({value: resp[key],key});}
                component.set("v.recordTypes", recordTypesMap);
            }else {
                console.log('Error = '+response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
    },
	getUserType : function(component,event,helper){
        var action = component.get("c.isPartnerUser");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log(response.getReturnValue());   
                if(response.getReturnValue()){
                    component.set("v.isCommunityUser" , true);                    
                }
            }
        });
        $A.enqueueAction(action); 
    }
})