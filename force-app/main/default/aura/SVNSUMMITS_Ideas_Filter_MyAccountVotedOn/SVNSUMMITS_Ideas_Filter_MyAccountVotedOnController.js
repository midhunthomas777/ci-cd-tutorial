({
    filterByMyCompanyVotedIdeas : function(component, event, helper) {
     	helper.debug(component, '---- My Company Ideas Voted On filter ----');

		let filter = component.get("v.myAccountVotedIdeas");
		helper.debug(component, "    Filter: " + filter);

        $A.get("e.c:SVNSUMMITS_Ideas_Filters_Event")
	        .setParams(
	        	{
			        listId        : component.get('v.listId'),
			        searchMyCompanyVotedIdeas : filter ? 'Display My Company Voted Ideas Only' : ' '
	        	})
	        .fire();
    }
})