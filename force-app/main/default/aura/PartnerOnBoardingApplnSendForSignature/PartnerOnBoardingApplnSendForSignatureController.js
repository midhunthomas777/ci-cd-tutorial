({
    handleRecordUpdated: function(component, event, helper) {
        var eventParams = event.getParams();
        if(eventParams.changeType === "LOADED") {
            var recordId=component.get("v.recordId");
            var templateId=component.get("v.applicationRecord.Agreement_Template__c");
            if(!$A.util.isUndefinedOrNull(templateId) || !$A.util.isEmpty(templateId)){
                if(component.get("v.applicationRecord.Partner_Application_Status__c")==="Approved"){
                    var urlEvent = $A.get("e.force:navigateToURL");
                    urlEvent.setParams({
                        "url":"/apex/echosign_dev1__AgreementTemplateProcess?masterId="+recordId+"&templateId="+templateId+"&retURL=/"+recordId
                    });
                    urlEvent.fire();
                    var dismissActionPanel = $A.get("e.force:closeQuickAction");
                    dismissActionPanel.fire();
                }else if (component.get("v.applicationRecord.Partner_Application_Status__c") === "Signed"){
                   component.set('v.errorMsg','Partner Application is already Signed.'); 

                }else if (component.get("v.applicationRecord.Partner_Application_Status__c") === "Out for Signature"){
                   component.set('v.errorMsg','Partner Application is Out for Signature.'); 

                }else {
                    component.set('v.errorMsg','Partner Application can only be sent for signature once it is Approved'); 
                }
            }else{
                component.set('v.errorMsg','Please select Agreement Template on PartnerEmpower Application'); 
            }
            
        }
    }
})