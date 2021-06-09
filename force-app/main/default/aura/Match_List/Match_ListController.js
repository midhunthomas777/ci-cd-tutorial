/*
 * Copyright (c) 2018  7Summits Inc.
 */
/**
 * Created by francois korb on 3/20/18.
 */
({
	onInit: function (component, event, helper) {
		let baseLoaded = component.get("v.baseLoaded");

		if (!baseLoaded) {
			component.set('v.baseLoaded', true);
			const useUserId = component.get('v.useUserId');

			let filterString = component.get('v.filterString');
			let targetId     = useUserId ? $A.get('$SObjectType.CurrentUser.Id') : component.get('v.recordId') || '';
			const dataParams = {name: component.get('v.settingName')};

			helper.doCallout(component, 'c.getDataModel', dataParams, false, 'Load data model')
				.then($A.getCallback(function (results) {
					let model = helper.setDataModel(component, results);
					component.set('v.model', model);

					const listParams = {
						name         : component.get('v.settingName'),
						searchString : ''
					};

					helper.doCallout(component, 'c.getMatchTargetList', listParams, false, 'Get target list')
						.then($A.getCallback(function (results) {
							let list = [];

							for (let key in results) {
								list.push({label: key, value: results[key]});
							}

							if (!targetId && list.length) {
								targetId = list[0].value;
							}

							component.set("v.targetId", targetId);
							component.set('v.targets', list);

							component.set('v.filterString', helper.updateFilter(filterString, 'targetId', targetId));
							component.set('v.sortString', 'confidence:true');

							helper.getList(component);
						}));
				}));
		}
	},

	updateColumnSorting: function (component, event, helper) {
		let fieldName     = event.getParam('fieldName');
		let sortDirection = event.getParam('sortDirection');

		component.set("v.sortedBy", fieldName);
		component.set("v.sortedDirection", sortDirection);

		helper.sortData(component, fieldName, sortDirection);
	},

	storeColumnWidths: function (component, event, helper) {
		helper.storeColumnWidths(component, event.getParam('columnWidths'));
	},

	///////////////////////////////////////////////////////
	// Event handlers

	handleRefresh: function (component, event, helper) {
		helper.getList(component);
	},

	handlePagination: function (component, event, helper) {
		helper.goToPage(component, event, event.getParam('buttonClicked'));
	},

	handleFilterEvent: function (component, event, helper) {
		component.set('v.sortString', event.getParam('sortString'));
		component.set('v.filterString',
			helper.updateFilterEntry(component.get('v.filterString'), event.getParam('filterString')));

		helper.getList(component);
	},

	handleRowAction: function (component, event, helper) {
		let action = event.getParam('action');
		let row    = event.getParam('row');

		console.log('handleFlowAction: ' + action.name);

		if (action.name === 'match_details') {
			helper.gotoRecord(component, row.id);
		} else {
			helper.startFlow(component, row.id, action.name);
		}
	},

	flowStatusChange: function (component, event, helper) {
		let model   = component.get('v.model');
		let status  = event.getParam('status');
		let label   = event.getParam('flowTitle');

		let message = 'Flow completed';

		model.flows.forEach(function (flow) {
			if (flow.label === label) {
				message = flow.message;
			}
		});

		let toastType = status === 'FINISHED_SCREEN' ? 'info' : 'error';

		helper.showToast(component, 'flowToast', label, message, toastType);
	}
});