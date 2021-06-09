({
    filterByMyCompanySubscribedIdeas : function(component, event, helper) {
     	helper.debug(component, '---- My Company Ideas Subscribed On filter ----');

		let filter = component.get("v.myAccountSubscribedIdeas");
		helper.debug(component, "    Filter: " + filter);

        $A.get("e.c:SVNSUMMITS_Ideas_Filters_Event")
	        .setParams(
	        	{
			        listId        : component.get('v.listId'),
			        searchMyCompanySubscribedIdeas : filter ? 'Display My Company Subscribed Ideas Only' : ' '
	        	})
	        .fire();
    }
})