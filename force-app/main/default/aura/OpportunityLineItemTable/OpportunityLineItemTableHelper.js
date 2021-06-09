({
    fetchMetaMessages : function(component, helper){
        var action = component.get("c.getMetaMessages");
        action.setParams({
            "metaName": "New_Opportunity"
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS" && component.isValid()){
                component.set("v.metaMessages", response.getReturnValue());
                helper.validateOpportunityAccess(component, helper);
            }else{
                console.log("Error retrieving meta messages");
                component.set("v.loadSpinner", false);
            }
        });
        $A.enqueueAction(action);
    },
    validateOpportunityAccess : function(component, helper){
        var metaMessages = component.get("v.metaMessages");
        var action = component.get("c.validateOpportunityAccess");
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS" && component.isValid()){
                var resp = response.getReturnValue();
                if($A.util.isUndefinedOrNull(resp) || $A.util.isEmpty(resp)){
                	helper.getOpportunityProducts(component, helper);
                }else if(resp == "NO_ACCESS"){
                    component.set("v.errorMsg",metaMessages["Insufficient_Privileges"].Message__c);
                    component.set("v.loadSpinner", false);
                    component.set("v.isRenewalDisabled", true);
                }
            }else{
                console.log("Error retrieving during validate opportunity access");
                component.set("v.loadSpinner", false);
            }
        });
        $A.enqueueAction(action);
    },
    getOpportunityProducts : function(component, helper){
        var metaMessages = component.get("v.metaMessages");
        var action = component.get("c.getOpportunityLineitems");
        component.set("v.errorMsg", "");
        action.setParams({
            "orignalOppId": component.get("v.oldOpportunityId")
        });
        action.setCallback(this, function(response) {
            component.set("v.loadSpinner", false);           
            var state = response.getState();
            if(state === "SUCCESS" && component.isValid()){
                component.set("v.productList", response.getReturnValue());
                var products = component.get("v.productList");
                if($A.util.isUndefinedOrNull(products) || $A.util.isEmpty(products)){
                    component.set("v.errorMsg", metaMessages['Renewal_No_Products_Found'].Message__c);
                    component.set("v.isRenewalDisabled", true);
                }
            }else{
                console.log("Error : "+response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
    },
    removeProductRow : function(component, event, helper){
        var row = event.getParam("row");
        var data = component.get("v.productList");
        data.splice(data.indexOf(row), 1);
        component.set("v.productList", []);
        component.set("v.productList", data);
    },
    renewalOpportunity : function(component, event, helper){
        component.set("v.errorMsg", "");
        var metaMessages = component.get("v.metaMessages");
        var action = component.get("c.createRenewalOpportunity");
        var childObjectsNames = component.get("v.childObjectsNames");
        action.setParams({
            "opportunityProducts" : JSON.stringify(component.get("v.productList")),
            "childObjectsNames"   : childObjectsNames,
            "orignalOpportunityId": component.get("v.oldOpportunityId")
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            var resp = response.getReturnValue();
            if(state === "SUCCESS" && component.isValid() && !($A.util.isUndefinedOrNull(resp) || $A.util.isEmpty(resp))){
                component.set("v.loadSpinner", false);
                if(resp.startsWith('Error')){
                    var errorMSg = resp.split('Error')[1];
                    component.set("v.errorMsg", errorMSg);
                    component.set("v.isRenewalDisabled", true);
                }else{
                    component.find("navService").navigate({
                        type: "standard__recordPage",
                        attributes: {
                            recordId   	  : resp,
                            objectApiName : "Opportunity",
                            actionName    : "view"
                        }
                    });
                }
            }else{
                component.set("v.loadSpinner", false);
                component.set("v.errorMsg", metaMessages['Exception_Error'].Message__c);
            }
        });
        $A.enqueueAction(action);
    },
});