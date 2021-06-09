({
    doInit : function(component, event, helper){
    	var fieldsMap = component.get("v.value");        
        for(var key in fieldsMap){
            var individualValue = fieldsMap[key];
            for(var individualKey in individualValue){
                if(individualValue[individualKey] == "Name"){
                    component.set("v.recordName",individualValue["fieldValue"]);
                    break;
                }
            }
        }
        var compRecId = component.get("v.competitorRecTypeId");
        //console.log("Competitor Record Type Id: " + compRecId);
        if(compRecId){
            component.set("v.allowNewCompetitor", "true");
        }
        console.log("allow new  Competitor: " + component.get("v.allowNewCompetitor"));
        var recName = component.get("v.recordName");
        if(recName && recName.startsWith("CAPP-")){
            helper.getCompetitorIntelligenceURL(component, event, helper);
        }
        $A.enqueueAction(component.get('c.refreshVendorLine'));
    },
    refreshVendorLine : function(component, event, helper){
        var vendor = component.find('vendor');
        console.log("Method Called from vendor>>"+vendor.get('v.value'));
        //console.log("CappRecordTyrp >>"+component.get("v.cappRecordType"));
        helper.getCompetitorIntelligenceURL(component, event, helper);
        var action = component.get("c.isVendorProdPresent");
        action.setParams({ 
            "vendorId"  : vendor.get('v.value'),
            "cappRecordTypeName"  : component.get("v.cappRecordType")
        });
        action.setCallback(this, function(response){ 
            var state = response.getState();
            var storeResponse = response.getReturnValue();
            //console.log("disableVendorProd>>"+storeResponse);
            if(state === "SUCCESS"){
                component.set("v.disableVendorProd",storeResponse);
                component.set("v.reRenderVendorLine",false);
                component.set("v.reRenderVendorLine",true);
            }  
        });
        
        $A.enqueueAction(action);
    },
    refreshDependentPicklist : function(component, event, helper){
        component.set("v.reRenderPicklist",false);
        component.set("v.reRenderPicklist",true);
    },
    
    handleNewAccount : function(component, event, helper){
        var recType = component.get("v.competitorRecTypeId");
        //console.log("CompetitorRecTypeId:  " + recType);
        var createAccountEvent = $A.get("e.force:createRecord");
        createAccountEvent.setParams({
            "entityApiName" : "Account",
            "recordTypeId" : recType,
            "navigationLocation": "LOOKUP",
            "panelOnDestroyCallback": function(event) {
                var navEvt = $A.get("e.force:navigateToSObject");
                navEvt.setParams({
                    "recordId" : component.get("v.currentRecordId"),
                    //"slideDevName" : "related"
                });
                navEvt.fire();
			}
        });
        createAccountEvent.fire();
    },
})