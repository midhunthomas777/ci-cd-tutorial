/*
 * Copyright (c) 2018. 7Summits Inc.
 */

/**
 * Created by francois korb on 6/11/18.
 */
({
	onFilterChange: function(component, event, helper) {
		let filter = component.get('v.filterItem');
		let search = component.get('v.searchString');

		console.log('Filter Select: ' + filter.name + ', ' + search);

		// fire the filter event
		component.getEvent('filterSubEvent').setParams({
			filterName : filter.name,
			filterValue: search
		}).fire();
	}
});