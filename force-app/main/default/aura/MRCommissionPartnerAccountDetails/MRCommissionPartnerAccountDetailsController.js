({
    doInit : function(component,event,helper){
    },
    lookupSearch : function(component, event, helper) {
        // Get the SampleLookupController.search server side action
        const serverSearchAction = component.get('c.fetchPartnerAccounts');
        // Passes the action to the Lookup component by calling the search method
        component.find('lookup').search(serverSearchAction);
    },
    getPartnerAccountId : function(component, event, helper){
        var selectedpartnerId = event.getParam("selectedId");
        console.log('selectedpartnerId'+selectedpartnerId);
        component.set("v.selectedpartnerId",selectedpartnerId);
    },
    closeAlertBox : function(component, event, helper){
        var appClose = component.find("Validation");
        appClose.close();
    },
    openCalcDetail : function(component, event, helper){
        var selectedPartnerId= component.get("v.selectedpartnerId");
        if(helper.validatePartnerAccount(component, event, helper))
        {
            var partnerId = $A.get("e.c:MRCommissionPartnerDetailEvent");
            partnerId.setParams({
                "partnerId" :selectedPartnerId
            });
            partnerId.fire(); 
        }
    }
})