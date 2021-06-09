({
    isCCSPApprovedApp : function(component, event, helper) {
        var recordId = component.get("v.recordId");
        var action = component.get("c.getAPIPartnerAppl");
        action.setParams({
            "recId" : recordId
        });
        action.setCallback(this, function(response) {
            component.set("v.loadSpinner",false);
            var state = response.getState();
            var resp = response.getReturnValue();
            console.log('API Record>>'+JSON.stringify(resp));
            if (state === "SUCCESS" && resp.Application_Status__c == 'Partner Submitted') {
                component.set("v.errorMsg",'Application should be Approved by CCSP Team to create Account.');
            }else if(state === "SUCCESS" && (!$A.util.isUndefinedOrNull(resp.Account__c))){
                component.set("v.errorMsg",'Account is Already Created for this Application Record');
            }else if (state === "SUCCESS" && resp.Application_Status__c == 'Under Review') {
                console.log('Call Create Account');
                this.createAccount(component, event, helper);
            } else {
                component.set("v.errorMsg",'Account can be created only in Under Review Status');
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
            console.log('Respose>>'+JSON.stringify(resp));
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