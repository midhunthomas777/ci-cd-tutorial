({
	navigateToObject : function(recordId, event, helper) {
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId":recordId,
            "slideDevName": "detail"
        });
        navEvt.fire();
    }
})