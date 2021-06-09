({
    callForApprovalSubmission : function(component, event, helper) {
        component.set("v.loadSpinner", true);
        var recordId = component.get("v.recId");
        var recordTypeId = component.get("v.recordTypeId");
        var region = component.get("v.region");
        var functionality = component.get("v.functionality");
        var customApprovalComment = component.get("v.customApprovalComment");
        var action = component.get("c.submitAndProcessApprovalRequest");
        action.setParams({
            "recordId" 		: recordId,
            "recordTypeId"  : recordTypeId,
            "region" 		: region,
            "functionality" : functionality,
            "customApprovalComment": customApprovalComment

        });
        action.setCallback(this, function(response) {
            component.set("v.loadSpinner", false);
            var state = response.getState();
            var response = response.getReturnValue();
            var appEvent = $A.get("e.c:GenericApprovalSubmissionEvent");
            appEvent.setParams({
                "state" : state,
                "response" : response
            });
            appEvent.fire();
        });
        $A.enqueueAction(action);
    }
})