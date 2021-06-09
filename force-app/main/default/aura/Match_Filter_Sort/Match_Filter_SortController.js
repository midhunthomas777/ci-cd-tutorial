/*
 * Copyright (c) 2018. 7Summits Inc.
 */

/**
 * Created by francois korb on 6/15/18.
 */
({
	onSortChange: function(component, event, helper) {
		let sortItem   = component.get('v.sortItem');
		let sortString = component.get('v.sortString');

		console.log('Sort Select: ' + sortItem.label + ', ' + sortString);

		// fire the filter event
		component.getEvent('sortSubEvent').setParams({
			sortString: sortString
		}).fire();
	}
});