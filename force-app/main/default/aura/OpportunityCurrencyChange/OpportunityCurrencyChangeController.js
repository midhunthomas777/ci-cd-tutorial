({
    updatedRecord : function(component, event, helper) {
        var opportunityRecord = component.get("v.opportunityRecord");
        var recordTypeId = opportunityRecord.RecordTypeId;
        var newCurrency = opportunityRecord.New_Currency__c;
        component.set("v.recordTypeId", recordTypeId);
        console.log('inside load1');
        component.find("newCurrency").set("v.value",newCurrency);
    },
    handleSubmit : function(component, event, helper) {
        event.preventDefault();
        var eventFields = event.getParam("fields");
        var oldValue= component.find("oldCurrency").get("v.value");
        var newValue= component.find("newCurrency").get("v.value");
        var opportunityError = $A.get("{!$Label.c.OpportunityNewCurrencyError}");
        if(newValue==='' || oldValue===newValue || newValue===null){
            component.set("v.errorMsg",opportunityError);
        }else if(oldValue != newValue && newValue !='' ){ 
            component.set("v.errorMsg",'');
            component.set("v.showSpinner", true);
            component.find('editForm').submit(eventFields); 
        }         
    },
    handleError: function(component, event, helper) {
        var errors = event.getParam('detail');
        console.log("response-->", JSON.stringify(errors));
        component.set("v.showSpinner", false); 
    },
    handleLoad: function(component, event, helper) {		
        component.set("v.showSpinner", false); 
    },
    handleSuccess: function(component, event, helper) {
        var opportunitySuccess = $A.get("{!$Label.c.OpportunityNewCurrencySuccess}");
        component.set("v.showSpinner", false);
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : 'Success Message',
            message: opportunitySuccess,
            type: 'success',
        });
        toastEvent.fire();
        $A.get("e.force:closeQuickAction").fire();
        $A.get('e.force:refreshView').fire();
    }
})