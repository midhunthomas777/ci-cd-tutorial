/*
 * Copyright (c) 2019. 7Summits Inc.
 */
/**
 * Created by francois korb on 9/21/16.
 */
({
    // Initialize page filters
    initializeFilters : function(component, event, helper) {

 	},

	setInitialSort : function(component, event, helper) {
		if (event.getParam("listId") === component.get('v.listId')) {
			component.set("v.sortBy", event.getParam("sortBy"));
		}
    },

    // Method to filter sort of ideas on basis of category
   	handleSortChange : function(component, event, helper) {
     	helper.debug(component, '---- Sort ----');

	    let sortBy  = component.get("v.sortBy");
	    helper.debug(component, '    sort: ' + sortBy);

	    $A.get("e.c:SVNSUMMITS_Ideas_Filters_Event")
		    .setParams(
			    {
				    listId: component.get('v.listId'),
				    sortBy: sortBy
			    })
		    .fire();
	}
});