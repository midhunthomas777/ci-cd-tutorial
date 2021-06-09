({
    doInit : function(component, event, helper) {
        var recId = component.get("v.recordId");
        // if(recId.startsWith('006') || recId.startsWith('a09')){ //SF-2509
        if(recId.startsWith('006')){
            
        }else if(recId.startsWith('a09')){            
            helper.checkOppValidility(component,event,helper);
        }else if(recId.startsWith('001')){            
            helper.isCreateQuoteFromAccTrue(component,event);
        }else{            
            helper.getCPQSiteId(component,event); 
        }
    },
    handleRecordUpdated: function(component, event, helper) {//SF-2509
        var eventParams = event.getParams();
        if(eventParams.changeType === "LOADED") {
            var recId = component.get("v.recordId");
            if(recId.startsWith('006')){
                component.set("v.loadSpinner",false);            
                var oppAccID = component.get("v.recordInfo.AccountId");
                component.set("v.oppoAccId", oppAccID);    
                console.log('1 NewQuoteInternal oppoAccId****'+component.get("v.oppoAccId")); 
                helper.checkOppValidility(component,event,helper);
            }
        } else if(eventParams.changeType === "CHANGED") {
            // record is changed
        } else if(eventParams.changeType === "REMOVED") {
            // record is deleted
        } else if(eventParams.changeType === "ERROR") {
            // there’s an error while loading, saving, or deleting the record
        }
    },
    
})