({
    doInit : function(component, event, helper) {
        helper.getAssignedPermissions(component, event, helper);
        helper.getUserType(component, event, helper);
    },
    open:function(component, event, helper) {
        var recordtypeId = event.getSource().get("v.value");
        var createRecordEvent = $A.get("e.force:createRecord");
        createRecordEvent.setParams({
            "entityApiName": "Opportunity",
            "recordTypeId" : recordtypeId
        });
        createRecordEvent.fire();
    },
    newOpportunity:function(component, event, helper) {
        var recordtypeId = event.getSource().get("v.value");
        component.find("navService").navigate({
            type: "standard__component",
            attributes: {
                componentName: "c__NewOpportunity"
            },
            state: {
                c__recordTypeId   : recordtypeId,
                c__isNewOpp 	  : "true",
                c__customerAccId  : component.get("v.recordId")
            }
        });
    },
})