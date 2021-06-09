({
	doInit : function(component, event, helper) {
        console.log('LeadId JS===>' +component.get("v.leadId"));
		helper.validateMCNAccount(component, event, helper);
	}
})