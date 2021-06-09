// Copyright (c) 2018 7Summits Inc.
/**
 * Created by francois korb on 3/20/18.
 */
({
	// Constants
	custom : {
		FIELD_SEPARATOR : ';',
		VALUE_SEPARATOR : ':',
		VALUE_DELIMITER : ',',
		MAX_FILTERS     : 5,
		MAX_FIELDS      : 10,
		COLUMN_KEY      : '7s-match-list-dataTable',
		DEFAULT_SELECT  : '1-50,50-100'
	},

	filters : {
		CRITICAL   : 'critical',
		RATING     : 'rating',
		CONFIDENCE : 'confidence'
	},

	columnAlign : {
		LEFT    : 'left',
		CENTER  : 'center',
		RIGHT   : 'right'
	},

	doCallout: function (component, method, params, hideToast, toastTitle) {
		let self = this;

		return new Promise($A.getCallback(function (resolve, reject) {
			let action = component.get(method);

			if (params) {
				action.setParams(params);
			}

			action.setCallback(component, function (response) {
				let state = response.getState();

				if (component.isValid() && state === "SUCCESS") {
					resolve(response.getReturnValue());
				} else {
					let errors = response.getError();
					console.log(JSON.parse(JSON.stringify(errors)));

					if (errors && errors[0] && errors[0].message && !hideToast) {
						self.showMessage("error", toastTitle || 'Callback failed', errors[0].message);
					} else if (!hideToast) {
						self.showMessage("error", 'Callback failed', "Unknown Error");
					}

					reject(errors);
				}
			});

			$A.enqueueAction(action);
		}));
	},

	gotoUrl: function (component, url) {
		$A.get("e.force:navigateToURL")
			.setParams({
				'url'        : url,
				'isredirect' : true
			}).fire();
	},

	gotoRecord: function (component, recordId) {
		$A.get("e.force:navigateToSObject")
			.setParams({
				"recordId"     : recordId,
				"slideDevName" : "related"
			}).fire();
	},

	// The toast type, which can be error, warning, success, or info.
	// The default is other, which is styled like an info toast and doesn’t display an icon,
	// unless specified by the key attribute.
	showMessage: function (level, title, message) {
		console.log("Message (" + level + "): " + message);

		$A.get("e.force:showToast")
			.setParams({
				"title"   : title,
				"message" : message,
				"type"    : level
			}).fire();
	},

	showToast : function(component, name, title, message, variant) {
		component.find(name).showToast({
			"title"  : title,
			"message": message,
			"variant": variant | 'info'
		});
	},

	/*
		Get a URL parameter by name, Locker Service safe!
		helper.getUrlParameter('PARAM')
		Courtesy of https://developer.salesforce.com/forums?id=906F0000000g1blIAA
    */
	getUrlParameter: function getUrlParameter(sParam) {
		let url = decodeURIComponent(window.location.search.substring(1)),
			urlParameters = url.split('&'),
			paramParts;

		for (let i = 0; i < urlParameters.length; i++) {
			paramParts = urlParameters[i].split('=');

			if (paramParts[0] === sParam) {
				return paramParts[1] === undefined ? true : paramParts[1];
			}
		}

		return null;
	},

	isInBuilder: function () {
		let urlToCheck = window.location.hostname.toLowerCase();
		return (urlToCheck.indexOf('sitepreview') >= 0
			||  urlToCheck.indexOf('livepreview') >= 0
			||  urlToCheck.indexOf('--live') >= 0);
	},

	getColumnSettingsName: function (scenarioName) {
		return this.custom.COLUMN_KEY + '-' + scenarioName;
	},

	updateFilterEntry: function(filterString, newEntry) {
		let newParts = newEntry.split(this.custom.VALUE_SEPARATOR);
		return newParts.length > 1 ? this.updateFilter(filterString, newParts[0], newParts[1]) : filterString;
	},

	// Note that Boolean entries == false are not added to the filter string
	updateFilter: function (filterString, key, value) {
		let found       = false;
		let newFilter   = [];

		if (filterString) {
			let filterParts = filterString.split(this.custom.FIELD_SEPARATOR);

			if (filterParts.length > 0) {
				for (let i = 0; i < filterParts.length; i++) {
					let entryParts = filterParts[i].split(this.custom.VALUE_SEPARATOR);

					if (entryParts[0]) {
						if (entryParts[0] === key) {
							found = true;
							// ignore if blank
							if (value) {
								newFilter.push(this.buildFilterItem(key, value));
							}
						} else {
							newFilter.push(this.buildFilterItem(entryParts[0], entryParts[1]));
						}
					}
				}
			}
		}

		if (!found && value) {
			newFilter.push(this.buildFilterItem(key, value));
		}

		let filter =  newFilter.length ? newFilter.join(this.custom.FIELD_SEPARATOR) : filterString;
		console.log('Updated filter : ' + filter);

		return filter;
	},

	buildFilterItem: function (key, value) {
		return key + this.custom.VALUE_SEPARATOR + value;
	},

	setDataModel : function (component, model) {
		let dataModel = {
			name            : '',
			label           : '',
			requiredLabel   : '',
			ratingsLabel    : '',
			confidenceLabel : '',
			columns         : [],
			filters         : [],
			ratingIcons     : [],
			flows           : []
		};

		dataModel.name  = model.name;
		dataModel.label = model.label;

		dataModel.requiredLabel   = model.source.requiredLabel   || 'Required';
		dataModel.ratingLabel     = model.source.ratingLabel     || 'Rating';
		dataModel.confidenceLabel = model.source.confidenceLabel || 'Confidence';

		let count = this.setupMatchColumns (dataModel, component, model.source);

		// sort by sequence
		dataModel.columns.sort(function(a, b) {
			return (a.order > b.order) ? 1 :  ((b.order > a.order) ? -1 : 0);
		});

		let columnWidth = Math.max(1, Math.round(12 / count));

		dataModel.columns.forEach(function(column) {
			column.size = columnWidth;
		});

		if (model.source.filterList && model.source.filterList.filters.length) {
			model.source.filterList.filters.forEach(function (filter) {
				dataModel.filters.push({
					id         : filter.id,
					label      : filter.label,
					labelSet   : filter.labelSet,
					filterType : filter.filterType,
					fieldType  : filter.field.fieldType
				});
			});
		}

		// push the std match filters
		this.setupMatchFilters(model, dataModel, model.source);

		if (model.source.flowList && model.source.flowList.flows.length) {
			model.source.flowList.flows.forEach(function(flow){
				dataModel.flows.push({
					name    : flow.name,
					label   : flow.label,
					title   : flow.title,
					message : flow.message
				});
			});
		}
		return dataModel;
	},

	// COLUMNS
	setupMatchColumns : function (dataModel, component, dataObject) {
		let self    = this;
		let columns = [];
		let count   = 0;

		// add the metadata defined fields
		dataObject.fields.forEach(function (field) {
			columns.push(self.createField(field, count));
			count++;
		});

		// add the known columns
		if (component.get('v.showConfidence')) {
			columns.push(this.createField({
				label     : dataObject.confidenceLabel,
				name      : 'match',
				apiName   : 'match',
				fieldType : 'percent',
				sequence  : dataObject.confidenceSequence,
				align     : self.columnAlign.CENTER,
				info      : dataObject.confidenceInfo
			}, count));
			count++;
		}

		if (component.get('v.showRequired')){
			columns.push(this.createField({
				label     : dataObject.requiredLabel,
				name      : 'critical',
				apiName   : 'critical',
				fieldType : 'boolean',
				sequence  : dataObject.requiredSequence,
				align     : self.columnAlign.CENTER,
				info      : dataObject.requiredInfo,
				actions   : 'critical'
			}, count));
			count++;
		}

		if (component.get('v.showRating')) {
			const useIcons = dataObject.groupIcons.length;
			columns.push(this.createField({
				label     :  dataObject.ratingLabel,
				name      :  useIcons ? 'ratingIcon' : 'rating',
				apiName   : 'rating',
				fieldType :  useIcons ? 'icon' :'number',
				sequence  : dataObject.ratingSequence,
				align     : self.columnAlign.CENTER,
				info      : dataObject.ratingInfo
			}, count));
			count++;
		}

		dataModel.columns = columns;

		return count;
	},

	createField : function(field, count) {

		return {
			'label'     : field.label,
			'name'      : field.name,
			'field'     : field.apiName,
			'type'      : field.fieldType,
			'order'     : field.sequence || count,
			'align'     : field.align,
			'info'      : field.info || '',
			'sortable'  : true,
			'size'      : 1,
			'actions'   : field.actions || ''
		};
	},

	// FILTERS
	setupMatchFilters: function (model, dataModel, dataObject) {

		dataModel.filters.push({
			id         : 2,
			label      : dataObject.ratingLabel,
			filterType : 'Select',
			fieldType  : 'Text'
		});

		dataModel.filters.push({
			id         : 3,
			label      : dataObject.confidenceLabel,
			filterType : 'Select',
			fieldType  : 'Text'
		});
	},

	setFilterData: function(filterDataList, showCritical, showRating, showMatch) {
		let filterData = filterDataList.filterData;

		if (showCritical) {
			filterData.push({
				filterType  : 'Select',
				label       : filterDataList.labelRequired,
				name        : this.filters.CRITICAL,
				entries     : [{label: 'All', value: ''}, {label: 'Critical', value: 'true'}]
			});
		}

		if (showRating) {
			filterData.push({
				filterType  : 'Select',
				label       : filterDataList.labelRating,
				name        : this.filters.RATING,
				entries     : this.getRatingValues(filterDataList.ratingGroups)
			});
		}

		if (showMatch) {
			filterData.push({
				filterType  : 'Select',
				label       : filterDataList.labelConfidence,
				name        : this.filters.CONFIDENCE,
				entries     : this.getConfidenceSelectValues(filterDataList.confidenceFilterString || this.custom.DEFAULT_SELECT)
			});

		}
		return filterData;
	},

	getRatingValues: function(ratingGroups){
		let ratingValues = [];

		ratingValues.push({label: 'All', value: ''});

		for (let i = ratingGroups; i > 0; --i) {
			ratingValues.push({label: i, value: i});
		}

		return ratingValues;
	},

	getConfidenceSelectValues: function(selectFilterString) {
		let selectValues = [];

		selectValues.push({label: 'All', value: ''});

		let selectEntries = selectFilterString.split(this.custom.VALUE_DELIMITER);

		for (let i = selectEntries.length -1; i >= 0 ; --i) {
			selectValues.push({label: selectEntries[i], value: selectEntries[i]});
		}

		return selectValues;
	}
});