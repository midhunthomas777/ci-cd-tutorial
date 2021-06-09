({
    filterByMyCompanyCommentedIdeas : function(component, event, helper) {
     	helper.debug(component, '---- My Company Ideas Commented On filter ----');

		let filter = component.get("v.myAccountCommentedIdeas");
		helper.debug(component, "    Filter: " + filter);

        $A.get("e.c:SVNSUMMITS_Ideas_Filters_Event")
	        .setParams(
	        	{
			        listId        : component.get('v.listId'),
			        searchMyCompanyCommentedIdeas : filter ? 'Display My Company Commented Ideas Only' : ' '
	        	})
	        .fire();
    }
})