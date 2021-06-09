/*
 * Copyright (c) 2018  7Summits Inc.
 */
/**
 * Created by francois korb on 3/20/18.
 */
({
	getList: function (component) {
		component.set('v.isLoading', true);

		let self   = this;
		let params = this.getParams(component);

		this.doCallout(component, 'c.getMatchList', params, false, 'Load match list')
			.then($A.getCallback(function (results) {
				component.set('v.list', results);
				self.setDataTable(component);
			}))
			.finally(function () {
					component.set('v.isLoading', false);
				}
			);
	},

	goToPage: function (component, event, buttonClicked) {
		let currentPage = component.get('v.currentPage');

		currentPage = buttonClicked === 'first' ? 1 : buttonClicked === 'next' ? ++currentPage : --currentPage;
		component.set('v.currentPage', currentPage);

		this.getList(component);
	},

	getParams: function (component) {
		let sortString   = component.get('v.sortString');
		let filterString = component.get('v.filterString');

		// Silent custom filters
		for(let pos = 1; pos <= this.custom.MAX_FILTERS; pos++) {
			let customFilter = component.get('v.customFilter' + pos);
			if (customFilter.length) {
				let customValue = component.get('v.customValue' + pos);
				if (customValue.length) {
					filterString = this.updateFilter(filterString, customFilter, customValue);
				}
			}
		}

		let params = {
			name         : component.get('v.settingName'),
			pageSize     : component.get('v.pageSize'),
			currentPage  : component.get('v.currentPage'),
			filterString : filterString,
			sortOrder    : sortString || 'Confidence:true'
		};

		console.log('getList Params:');
		console.log(params);

		return params;
	},

	setDataTable: function (component) {
		let model   = component.get('v.model');
		let list    = component.get('v.list');
		let icon    = component.get('v.firstColumnIcon');
		let columns = [];
		let position = 0;

		model.columns.forEach(function(column) {
			let newColumn = {
				label    : column.label,
				fieldName: column.name,
				type     : column.type,
				sortable : column.sortable || false,
				cellAttributes : {alignment: column.align}
			};

			if (position === 0 && icon) {
				newColumn.cellAttributes = {
					alignment: column.align,
					iconName : icon
				};
			}

			if (newColumn.fieldName === 'ratingIcon') {
				const iconField = newColumn.fieldName;
				newColumn.fieldName      = '';
				newColumn.cellAttributes = {
					alignment: column.align,
					iconName : {fieldName: iconField}
				};
			}
			columns.push(newColumn);
			++position;
		});

		if (component.get('v.showAction')) {
			let actions = [
				{
					label   : component.get('v.viewLabel'),
					name    : 'match_details',
					iconName: 'utility:description'
				}
			];

			if (component.get('v.showFlow')) {
				model.flows.forEach(function (flow) {
					actions.push({
						label : flow.label,
						name  : flow.name,
						iconName : 'utility:flow'
					});
				});
			}

			columns.push({
				type: 'action',
				typeAttributes: {rowActions: actions}
			});
		}

		let columnsWidths = this.getColumnWidths(component);

		if (columnsWidths.length === columns.length) {
			columns.forEach(function (column, index) {
				column.initialWidth = columnsWidths[index];
			});
		}

		component.set('v.columns', columns);
		component.set('v.data',    list.items);
	},

	startFlow : function (component, id, flowName) {
		let flow     = component.find("matchFlow");
		let targetId = component.get('v.targetId');

		let input    = [
			{
				name: 'sourceId',
				type: 'String',
				value: id
			},
			{
				name: 'targetId',
				type: 'String',
				value: targetId
			}
		];

		console.log('Calling flow: ' + flowName + ' with targetId = ' + targetId + ', sourceId = ' + id);

		flow.startFlow(flowName, input);
	},

	sortData: function (component, fieldName, sortDirection) {
		let data    = component.get("v.data");
		let reverse = sortDirection !== 'asc';

		data = Object.assign([],
			data.sort(this.sortBy(fieldName, reverse ? -1 : 1))
		);

		component.set("v.data", data);
	},

	sortBy: function (field, reverse, primer) {
		let key = primer
			? function(x) { return primer(x[field]) }
			: function(x) { return x[field] };

		return function (a, b) {
			let A = key(a);
			let B = key(b);
			return reverse * ((A > B) - (B > A));
		};
	},

	storeColumnWidths: function (component, widths) {
		localStorage.setItem(this.getColumnSettingsName(component.get('v.settingName')), JSON.stringify(widths));
	},

	getColumnWidths: function (component) {
		let widths = localStorage.getItem(this.getColumnSettingsName(component.get('v.settingName')));

		try {
			widths = JSON.parse(widths);
		} catch(e) {
			return [];
		}
		return Array.isArray(widths) ? widths : [];
	}
});