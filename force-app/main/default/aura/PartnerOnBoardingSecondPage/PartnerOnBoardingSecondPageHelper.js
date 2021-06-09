({
    navigateToObject : function(component, event, helper,recordId) {
        var urlPrefix = $A.get("{!$Label.c.POCommunityPrefix}");
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": urlPrefix+"partneronboarding-detail-page?applicationId="+recordId
        });
        urlEvent.fire();
        
    },
    callForApprovalSubmission : function(component, event, helper, recordId, recordTypeId, region) {
        component.set("v.loadSpinner", true);          
        if(region == 'APAC'){
            component.set("v.functionality",'PO APAC Application Submission');
        }else if (region == 'EMEA'){
            component.set("v.functionality",'PO EMEA Application Submission');
        }else if (region == 'LA'){
            component.set("v.functionality",'PO LA Application Submission');
        }else if (region == 'NA'){
            component.set("v.functionality",'PO NA Application Submission');
        }
        var functionality = component.get("v.functionality");
        var action = component.get("c.submitAndProcessApprovalRequest");
        action.setParams({
            "recordId" 		: recordId,
            "recordTypeId"  : recordTypeId,
            "region" 		: region,
            "functionality" : functionality,
            "customApprovalComment": "Submit For Approval"
            
        });
        action.setCallback(this, function(response) {
            component.set("v.loadSpinner", false);
            var state = response.getState();
            var response = response.getReturnValue();           
        });
        $A.enqueueAction(action);
    }    
    
})