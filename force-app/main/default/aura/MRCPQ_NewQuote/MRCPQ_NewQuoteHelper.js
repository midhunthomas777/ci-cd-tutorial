({   
    fetchAccountType :function(component) {
        var recId = component.get("v.recordId");
        var action = component.get("c.getAccountRecordTypeDeveloperNameWhenUserHasAccessToNewQuota");
        action.setParams({
            'accountId': recId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log(response.getReturnValue());   
                if(response.getReturnValue()!=null){
                    component.set("v.showQuotebtn",true);
                    component.set("v.accountRecType",response.getReturnValue());
                }
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
                if(response.getReturnValue()===false){
                    component.set("v.isPartnerUser",true);                    
                }
            }
        });
        $A.enqueueAction(action); 
    }
    
})