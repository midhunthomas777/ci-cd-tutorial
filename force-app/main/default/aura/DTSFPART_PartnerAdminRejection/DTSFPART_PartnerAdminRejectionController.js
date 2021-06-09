({
    doInit : function(component, event, helper){
        helper.getPartnerContactDetails(component, event, helper);
    },

    handleModalClose: function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
	}
})