//Developed as part of SF-2059 - Partners get redirected to wrong place after quote deletion
({
    handleRecordUpdated: function(component, event, helper,accountId) {
        var deleteQuotemessage = $A.get("{!$Label.c.DeleteQuote}");        
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": accountId,
            "slideDevName": "related"
        });
        navEvt.fire();
        var resultsToast = $A.get("e.force:showToast");
        resultsToast.setParams({  //Add Custom Label
            "title": "Deleted",
            "message": deleteQuotemessage
        });
        resultsToast.fire();
    }
})