({
    isApprovedApp : function(component, event, helper) {
        var recordId = component.get("v.recordId");
        var action = component.get("c.isApproved");
        action.setParams({
            "recId" : recordId
        });
        action.setCallback(this, function(response) {
            component.set("v.loadSpinner",false);
            var state = response.getState();
            var resp = response.getReturnValue();
            if (state === "SUCCESS" && resp[0].Partner_Application_Status__c != 'Signed') {
                component.set("v.errorMsg",'This Application is not Signed');
                
            }else if(state === "SUCCESS" && (!$A.util.isUndefinedOrNull(resp[0].Partner_Account__c))){
                component.set("v.errorMsg",'Account is Already Created for this Application Record');
            }else{
                this.createAccount(component, event, helper);
            }
        });
        $A.enqueueAction(action);
    },
    createAccount : function(component, event, helper) {
        component.set("v.loadSpinner",true);
        var recordId = component.get("v.recordId");
        var action = component.get("c.createAccOnApplication");
        action.setParams({
            "recId" : recordId
        });
        action.setCallback(this, function(response) {
            component.set("v.loadSpinner",false);
            var state = response.getState();
            var resp = response.getReturnValue();
            if (state === "SUCCESS" && resp !='Error') {
                var partnerAccId = resp.split('Success')[1];
                this.navigateToRecord(component, event, helper,partnerAccId);
            }else{
                component.set("v.errorMsg",'Error Occured while Creating Account Record.');
            }
        });
        $A.enqueueAction(action); 
    },
    navigateToRecord : function (component, event, helper,partnerAccId) {
          // var recordId = component.get("v.recordId");
        var userTheme = component.get("v.userTheme");
        if (userTheme === 'Theme3') {
            window.open("/" + partnerAccId, "_self");
        }else{
            var navEvt = $A.get("e.force:navigateToSObject");
            navEvt.setParams({
                "recordId": partnerAccId,
                "slideDevName": "related"
            });
            navEvt.fire();  
        }
    }
})