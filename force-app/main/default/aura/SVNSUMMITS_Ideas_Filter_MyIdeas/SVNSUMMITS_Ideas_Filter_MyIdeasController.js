/*
 * Copyright (c) 2019. 7Summits Inc.
 */
({
    // Initialize page filters
    initializeFilters : function(component, event, helper) {
 	},

    // Method to fetch ideas for current logged in user
	filterByMyIdeas : function(component, event, helper) {
     	helper.debug(component, '---- MyIdeas filter ----');

		const filter = component.get("v.myIdeas");
		helper.debug(component, "    Filter: " + filter);

        $A.get("e.c:SVNSUMMITS_Ideas_Filters_Event")
	        .setParams(
	        	{
			        listId        : component.get('v.listId'),
			        searchMyIdeas : filter ? 'Display My Ideas Only' : ' '
	        	})
	        .fire();
    }
});