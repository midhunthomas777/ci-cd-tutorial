/*
 * Copyright (c) 2019. 7Summits Inc.
 */
/**
 * Created by francois korb on 9/21/16.
 */
({
	// Initialize page filters
	initializeFilters: function (component, event, helper) {
		let categoriesAllowed = component.get("v.CatValue");

		if (categoriesAllowed && categoriesAllowed.trim() !== '') {
			component.set("v.categoriesSet", categoriesAllowed.split(','));
		} else {
			helper.doCallout(component, "c.getCategoryValues", {}, true, "", true)
				.then($A.getCallback(function (list) {
					helper.debug(component, 'Categories loaded');
					component.set("v.categoriesSet", list);
				}));
		}
	},

	// Method to filter list of ideas on basis of category
	filterByCategories : function(component, event, helper) {
		helper.debug(component, '---- Filter By Category ----');

		let filter = component.get('v.categorySelect');
		let clear  = component.get("v.labelFilter");

		helper.debug(component, '    filter: ' + filter);

		$A.get("e.c:SVNSUMMITS_Ideas_Filters_Event")
			.setParams(
				{
					listId             : component.get('v.listId'),
					searchByCategories : filter === clear ? ' ' : filter
				})
			.fire();
	}
});