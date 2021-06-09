({
    getfieldsforNewCAPP : function(component, event, helper){
        component.set("v.showSpinner",true);
        var incomingKey = component.get("v.key");
        var map = component.get("v.finalMap");
        //console.log('Final Map>>'+JSON.stringify(map));
        var detailedSections = map[incomingKey];
        var systemRelatedFields = [];
        var accountSpecificFields = [];
        for(var sectionDetail in detailedSections){
            if(sectionDetail == "SLF"){
                systemRelatedFields = detailedSections[sectionDetail];
            }else if(sectionDetail == "ASSF"){
                accountSpecificFields = detailedSections[sectionDetail];
            }
        }
        component.set("v.systemRelatedFields",systemRelatedFields);
        component.set("v.accountSpecificFields",accountSpecificFields);
        component.set("v.showSpinner",false);
    },
    createCAPP : function(component, event, helper){
        var action = component.get("c.upsertCAPPS");
        action.setParams({ 
            "wrapper"  : JSON.stringify(component.get("v.cappsData")),
            "operation": "creation"
        });
        action.setCallback(this, function(response){ 
            var state = response.getState();
            var storeResponse = response.getReturnValue();
            if(state === "SUCCESS" && storeResponse == "SUCCESS"){
                component.set("v.showSpinner",false);
                this.showToast(component,"Record has been created successfully!","Success");
                var appEvent = $A.get("e.c:NewCAPPReloadEvent"); 
                appEvent.setParams({"tabName" : component.get("v.tabName")}).fire(); 
            }else if(state === "ERROR"){
                component.set("v.showSpinner",false);
                var errors = response.getError();
                if(errors){
                    if(errors[0] && errors[0].message){
                        console.log("Error = "+errors[0].message);
                        this.showToast(component,errors[0].message,"Error");
                    }
                } 
            }else{
                component.set("v.showSpinner",false);
                console.log("Error = "+response.getReturnValue());
                this.showToast(component,response.getReturnValue(),"Error");
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