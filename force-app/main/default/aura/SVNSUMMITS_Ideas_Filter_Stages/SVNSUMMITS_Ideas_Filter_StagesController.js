/*
 * Copyright (c) 2019. 7Summits Inc.
 */
({
	// Initialize page filters
	onInit: function (component, event, helper) {
		let statusAllowed = component.get("v.StatusValue");

		if (statusAllowed && statusAllowed.trim() !== '') {
			component.set("v.statusList", statusAllowed.split(','));
		} else {
			helper.doCallout(component, "c.getStatusValues",
				{
					'objName'  : "Idea",
					'fieldName': "Status"
				}, true, "", true)
				.then($A.getCallback(function (list) {
					helper.debug(component, 'Statuses loaded');
					component.set("v.statusList", list);
				}));
		}
	},

	// Method to filter list of ideas on basis of stages
	filterByStatus : function(component, event, helper) {
		helper.debug(component, '---- Filter By Status ----');

		let filter = component.get('v.statusSelect');
		let clear  = component.get("v.labelFilter");

		helper.debug(component, '    filter: ' + filter);

		$A.get("e.c:SVNSUMMITS_Ideas_Filters_Event")
			.setParams(
				{
					listId         : component.get('v.listId'),
					searchByStatus : filter === clear ? ' ' : filter
				})
			.fire();
	}
});