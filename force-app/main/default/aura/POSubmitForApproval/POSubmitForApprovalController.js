({
    doInit : function(component, event, helper) {
    },
    handleClick: function(component, event, helper){
        var poSubmitErrorMsg = $A.get("{!$Label.c.OpportunityResubmitErrorMessage}");
        var poError = $A.get("{!$Label.c.POErrorMsg}");
        var appStatus = component.get("v.EmpowerAppFields.Partner_Application_Status__c");
        if($A.util.isUndefinedOrNull(appStatus) || $A.util.isEmpty(appStatus)){
            component.set("v.openPopUp",true);
        }else{
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": poError,
                "type":"Error",
                "message": poSubmitErrorMsg
            });
            toastEvent.fire();
        }
        // component.set("v.loadData",true);
    },
    handleRecordUpdated : function(component, event, helper) {
        var eventParams = event.getParams();
        if(eventParams.changeType === "LOADED") {
            var partnerRegion = component.get("v.EmpowerAppFields.Partner_Region__c");
            if(partnerRegion == 'APAC'){
                component.set("v.functionality",'PO APAC Application Submission');
            }else if (partnerRegion == 'EMEA'){
                component.set("v.functionality",'PO EMEA Application Submission');
            }else if (partnerRegion == 'LA'){
                component.set("v.functionality",'PO LA Application Submission');
            }else if (partnerRegion == 'NA'){
                component.set("v.functionality",'PO NA Application Submission');
            }
            component.set("v.loadSpinner",false);
        } else if(eventParams.changeType === "CHANGED") {
            // record is changed
        } else if(eventParams.changeType === "REMOVED") {
            // record is deleted
        } else if(eventParams.changeType === "ERROR") {
            // there’s an error while loading, saving, or deleting the record
        }
    },
    submitForApproval : function(component, event, helper){
        component.set("v.comment",false);
        var comments = component.find("approvalComment").get("v.value");
        component.set("v.approvalComment",comments);
        //if(!$A.util.isUndefinedOrNull(comments) || !$A.util.isEmpty(comments)){
        component.set("v.comment",true);
        //}
    },
    close: function(component, event, helper){
        component.set("v.openPopUp",false);
    }
})