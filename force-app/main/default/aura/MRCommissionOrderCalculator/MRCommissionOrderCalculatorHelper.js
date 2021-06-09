({
	 getSitePrefix : function(component){        
        var action = component.get("c.fetchSitePrefix");       
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.getURL",response.getReturnValue());
            }
        });
        $A.enqueueAction(action);  
    },
    getCCMR : function(component){  
        var action = component.get("c.isCCMR");
        action.setParams({ 
            "partnerID": component.get("v.partnerId")
        });
         action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.isCCMR",response.getReturnValue());
            }
        });
        $A.enqueueAction(action); 
    }
})