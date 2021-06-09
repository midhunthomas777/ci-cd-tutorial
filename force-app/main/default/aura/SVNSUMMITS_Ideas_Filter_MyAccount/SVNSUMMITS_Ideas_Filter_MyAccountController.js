({
    filterByMyCompanyIdeas : function(component, event, helper) {
     	helper.debug(component, '---- My Company Ideas filter ----');

		const filter = component.get("v.myAccountIdeas");
		helper.debug(component, "    Filter: " + filter);

        $A.get("e.c:SVNSUMMITS_Ideas_Filters_Event")
	        .setParams(
	        	{
			        listId        : component.get('v.listId'),
			        searchMyCompanyIdeas : filter ? 'Display My Company Ideas Only' : ' '
	        	})
	        .fire();
    }
})