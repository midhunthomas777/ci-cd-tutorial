({
    identifyCurrentAPP : function(component, event, helper){
        var workspaceAPI = component.find("workspace");
        workspaceAPI.isConsoleNavigation().then(function(response){
            if(response){
                component.set("v.urlTarget","_parent");
            }
        })
        .catch(function(error){
            console.log("error while identfing the current logged in app = "+error);
        });
    },
    getcurrentObject : function(component,event,helper){
        var currentRecordId = component.get("v.recordId");
        if(currentRecordId.startsWith("001")){
            component.set("v.currentObjName","Account");
        }else{
            component.set("v.currentObjName","Site");
        }
    },
    getCAPPControllingFields : function(component,event,helper){
        var action = component.get("c.getControllingPicklistFields");
        action.setCallback(this, function(response){ 
            var state = response.getState();
            if(state == "SUCCESS"){ 
                var storeResponse = response.getReturnValue();
                component.set("v.controllingFieldsMap", storeResponse);
            }else{
                console.log("Error while getting controlling picklist fields = "+response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
    },
    getCompetitorRecId : function(component, event, helper){
       component.set("v.showSpinner",true);
        var recTypAction = component.get("c.getRecTypeId");
        recTypAction.setParams({"recTypeName" : "Competitor"});
        recTypAction.setCallback(this, function(response) {
            var state = response.getState();
            if (state == "SUCCESS"){
                component.set("v.competitorRecTypeId", response.getReturnValue());
                console.log("recTypeId Returned: " + response.getReturnValue());
                component.set("v.showSpinner",false);
            }
            else{
                component.set("v.competitorRecTypeId", "");
                console.log("Failed to get recTypeId with state: " + state);
                component.set("v.showSpinner",false);
            }
            
        });
        $A.enqueueAction(recTypAction); 
    },
    getCAPPDetails : function(component,event,helper){
        component.set("v.showSpinner",true);
        var action = component.get("c.getFieldSets");  
        action.setParams({ 
            currentRecordId : component.get("v.recordId")
        });
        action.setCallback(this, function(response){ 
            var state = response.getState();
            if(state == "SUCCESS"){ 
                var storeResponse = response.getReturnValue();
                console.log("FINAL RESPONSE = "+JSON.stringify(storeResponse));
                var arrayOfMapKeys = [];
                for(var singlekey in storeResponse){
                    var newkey = singlekey.split('-').pop();
                    arrayOfMapKeys.push(newkey);
                    storeResponse[newkey] = storeResponse[singlekey];
                    delete storeResponse[singlekey];
                }
                component.set("v.allTabs", arrayOfMapKeys);
                component.set("v.fieldSetMap", storeResponse);
                component.set("v.showSpinner",false);
                component.set("v.reloadData",false);
                component.set("v.reloadData",true);
                this.getfieldsWithSections(component,event,helper);
            }else if(state === "ERROR"){
                var errors = response.getError();
                if(errors){
                    if(errors[0] && errors[0].message){
                        console.log("Error = "+errors[0].message);
                    }
                }
                component.set("v.showSpinner",false);
            }else{
                console.log("Error = "+response.getReturnValue());
                component.set("v.showSpinner",false);
            }
        });
        $A.enqueueAction(action);
    },
    getfieldsWithSections : function(component,event,helper){
        component.set("v.showSpinner",true);
        var action = component.get("c.getfieldsWithSections");
        action.setCallback(this, function(response){ 
            var state = response.getState();
            if(state == "SUCCESS"){ 
                var storeResponse = response.getReturnValue();
                component.set("v.sectionsWithFields", storeResponse);
                //console.log(" sectionsWithFields =  " +JSON.stringify(component.get("v.sectionsWithFields")));
                component.set("v.showSpinner",false);
            }else if(state === "ERROR"){
                var errors = response.getError();
                if(errors){
                    if(errors[0] && errors[0].message){
                        console.log("Error = "+errors[0].message);
                    }
                }
                component.set("v.showSpinner",false);
            }else{
                console.log("Error = "+response.getReturnValue());
                component.set("v.showSpinner",false);
            }
        });
        $A.enqueueAction(action);
    },
})