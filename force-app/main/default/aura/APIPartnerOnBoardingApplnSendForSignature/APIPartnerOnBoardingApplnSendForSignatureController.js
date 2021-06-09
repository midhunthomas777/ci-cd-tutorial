({
    handleRecordUpdated: function(component, event, helper) {
        var eventParams = event.getParams();
        if(eventParams.changeType === "LOADED") {
            var recordId=component.get("v.recordId");
            var templateId=component.get("v.applicationRecord.Agreement_Template__c");
            var counterSignerEmailId=component.get("v.applicationRecord.Counter_Signer_Email__c");
            console.log("Agreement Template>>"+templateId);
            console.log("Counter Signer Email>>"+counterSignerEmailId);
            if(!$A.util.isUndefinedOrNull(templateId) && !$A.util.isEmpty(templateId)){
                if(component.get("v.applicationRecord.Application_Status__c")==="Approved" &&
                  !$A.util.isUndefinedOrNull(counterSignerEmailId) && !$A.util.isEmpty(counterSignerEmailId)){
                    var urlEvent = $A.get("e.force:navigateToURL");
                    console.log('/apex/echosign_dev1__AgreementTemplateProcess?masterId='+recordId+'&templateId='+templateId+'&retURL=/'+recordId);
                    urlEvent.setParams({
                        "url":"/apex/echosign_dev1__AgreementTemplateProcess?masterId="+recordId+"&templateId="+templateId+"&retURL=/"+recordId
                    });
                    urlEvent.fire();
                    var dismissActionPanel = $A.get("e.force:closeQuickAction");
                    dismissActionPanel.fire();
                }else if (component.get("v.applicationRecord.Application_Status__c") === "Signed"){
                   component.set('v.errorMsg','API Partner Application is already Signed.'); 

                }else if (component.get("v.applicationRecord.Application_Status__c") === "Out for Signature"){
                   component.set('v.errorMsg','API Partner Application is Out for Signature.'); 

                }else if ($A.util.isUndefinedOrNull(counterSignerEmailId) || $A.util.isEmpty(counterSignerEmailId)){
                   component.set('v.errorMsg','Counter Signer Email is blank, please enter counter signer email.'); 

                }else {
                    component.set('v.errorMsg','API Partner Application can only be sent for signature once it is Approved and Counter Signer Email is not blank'); 
                }
            }else{
                component.set('v.errorMsg','Please select Agreement Template on API Partner Application'); 
            }
            
        }
    }
})