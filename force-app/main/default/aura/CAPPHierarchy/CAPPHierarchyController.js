({
    doInit : function(component, event, helper){
        component.set("v.loadSpinner", true);
        helper.identifyCurrentAPP(component, event, helper);
    },
    createSR : function(component, event, helper){
        var createRecordEvent = $A.get("e.force:createRecord");
        createRecordEvent.setParams({
            "entityApiName": "System_Relationship__c",
            "defaultFieldValues": {
                "CAPP__c" : component.get("v.recordId")
            }
        });
        createRecordEvent.fire();
    },
})