/*
 * Copyright (c) 2019. 7Summits Inc.
 */
/**
 * Created by francois korb on 9/21/16.
 */
({
	// Initialize page filters
	initializeFilters: function (component, event, helper) {
		helper.doCallout(component, 'c.getThemeValues', {}, true, '', true)
			.then($A.getCallback(function (list) {
				component.set("v.themesList", list);
			}));
	},


	// Method to filter list of ideas on basis of themes
	filterByThemes: function (component, event, helper) {
		helper.debug(component, '---- Filter by Theme ----');

		let filter = component.get('v.themeSelect');
		let clear  = component.get("v.labelFilter");
		helper.debug(component, '    filter: ' + filter);

		$A.get("e.c:SVNSUMMITS_Ideas_Filters_Event")
			.setParams(
				{
					listId        : component.get('v.listId'),
					searchByThemes: filter === clear ? ' ' : filter
				})
			.fire();
	}
});