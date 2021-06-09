/*
 * Copyright (c) 2018  7Summits Inc.
 */
/**
 * Created by francois korb on 3/21/18.
 */
({
	onInit: function (component, event, helper) {
		let baseLoaded = component.get("v.baseLoaded");

		if (!baseLoaded) {
			component.set('v.baseLoaded', true);

			const dataParams = {
				name        : component.get('v.settingName'),
				searchString: ''};

			helper.doCallout(component, 'c.getFilterData', dataParams, false, 'Load filter data')
				.then($A.getCallback(function (results) {

					if (component.get('v.showFilters')) {
						const showCritical = component.get('v.showCritical');
						const showRating   = component.get('v.showRating');
						const showMatch    = component.get('v.showMatch');

						let filterData = helper.setFilterData(results, showCritical, showRating, showMatch);
						component.set('v.filterData', filterData);
					}

					if (component.get('v.showSort'))
					{
						const sortCritical  = component.get('v.sortCritical');
						const sortRating    = component.get('v.sortCritical');
						const sortMatch     = component.get('v.sortMatch');

						let sortData = helper.getSortData(component, results, sortCritical, sortRating, sortMatch);
						component.set('v.sortData', sortData);
					}
				}));
		}
	},

	handleSubFilterEvent: function (component, event, helper) {
		let filter = event.getParam('filterName');
		let value  = event.getParam('filterValue');

		$A.get("e.c:Match_Filter_Event")
			.setParams({
				'filterString'  : helper.buildFilterItem(filter, value),
				'sortString'    : component.get('v.sortString')
			}).fire();
	},

	handleSubSortEvent: function (component, event, helper) {
		let sortString = event.getParam('sortString');
		component.set('v.sortString', sortString);

		$A.get("e.c:Match_Filter_Event")
			.setParams({
				'filterString'  : component.get('v.filterString'),
				'sortString'    : sortString
			}).fire();
	},

	onFilterChange: function (component, event, helper) {
		$A.get("e.c:Match_Filter_Event")
			.setParams({
				'filterString'  : component.get('v.filterString'),
				'sortString'    : component.get('v.sortString')
			}).fire();
	}
});