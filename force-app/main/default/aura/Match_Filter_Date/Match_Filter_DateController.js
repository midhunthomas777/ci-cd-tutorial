/*
 * Copyright (c) 2018. 7Summits Inc.
 */

/**
 * Created by francois korb on 6/29/18.
 */
({
	onFilterChange: function(component, event, helper) {
		// dateFilter:startValue,endValue
		let filter = component.get('v.filterItem');
		let search = component.get('v.searchString');

		let searchParts = search.split(helper.custom.VALUE_DELIMITER);
		let dateValues  = ['',''];

		if (searchParts.length > 0) {
			dateValues[0] = searchParts[0];
		}

		if (searchParts.length > 1) {
			dateValues[1] = searchParts[1];
		}

		let dateName = event.getSource().get('v.name');
		if (dateName === 'startDate') {
			dateValues[0] = component.get('v.startDate');
		} else {
			dateValues[1] = component.get('v.endDate');
		}

		search = dateValues.join(helper.custom.VALUE_DELIMITER);
		component.set('v.searchString', search);

		console.log('Filter Select: ' + filter.name + ', ' + search);

		component.getEvent('filterSubEvent').setParams({
			filterName : filter.name,
			filterValue: search
		}).fire();
	}
});