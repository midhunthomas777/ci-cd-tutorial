/*
 * Copyright (c) 2018. 7Summits Inc.
 */

/**
 * Created by francoiskorb on 6/11/18.
 */
({
	onFilterChange: function(component, event, helper) {
		let filter = component.get('v.filterItem');
		let search = component.get('v.searchString');
		let limit  = component.get('v.threshold');

		if (search == "" || search.length >= limit) {
			console.log('Filter Search: ' + filter.name + ', ' + search);

			// fire the filter event
			component.getEvent('filterSubEvent').setParams({
				filterName : filter.name,
				filterValue: search
			}).fire();
		}
	}
});