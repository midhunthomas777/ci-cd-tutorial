({
	doInit : function(component, event, helper) {
        var type = component.get("v.type");      
        if(type==='error'){
            component.set("v.alertclass",component.get("v.errorType"));
        }/*else if(type==='success' || type==='warning' ){
            component.set("v.alertclass",component.get("v.warningType"));
        }*/else if(type==='warning'){
            component.set("v.alertclass",component.get("v.warningType"));
        }else if(type==='offline'){
            component.set("v.alertclass",component.get("v.offlineType"));
        }else if(type === 'success'){
            component.set("v.alertclass",component.get("v.successType"));
        }
	},
})