({
	getCompetitorIntelligenceURL : function(component, event, helper){
        component.set("v.competitorIntURL",null);
        var vendor = component.find('vendor');
        //console.log("vendorId >>"+vendor.get('v.value'));
		var action = component.get("c.getCompetitorIntelligenceURL");
        action.setParams({ 
            "vendorId"  : vendor.get('v.value')
        });
        action.setCallback(this, function(response){ 
            var state = response.getState();
            var storeResponse = response.getReturnValue();
            //console.log("competitorIntURL>>"+storeResponse);
            if(state === "SUCCESS"){
                component.set("v.competitorIntURL",storeResponse);
            }  
        });
        $A.enqueueAction(action);
	}
})