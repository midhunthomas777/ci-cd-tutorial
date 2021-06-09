/*
 * Copyright (c) 2018. 7Summits Inc.
 */

/**
 * Created by francois korb on 6/15/18.
 */
({

	// SORT
	getSortData : function(component, dataModel, sortCritical, sortRating, sortMatch) {
		let dataObject    = dataModel.model.source;
		let sortModelList = dataObject.sortList;
		let labelSort     = component.get('v.labelSort');

		let sortData = {
			label   : sortModelList.label || labelSort,
			entries : []
		};

		if (sortModelList) {
			sortModelList.sorts.forEach(function (sortItem) {
				sortData.entries.push({label: sortItem.field.label, value: sortItem.field.apiName});
			});
		}

		// if (sortCritical) {
		// 	sortData.entries.push({label: dataObject.requiredLabel, value: this.filters.CRITICAL})
		// }
		// if (sortRating) {
		// 	sortData.entries.push({label: dataObject.ratingLabel, value: this.filters.RATING})
		// }

		if (sortMatch) {
			sortData.entries.push({label: dataObject.confidenceLabel, value: this.filters.CONFIDENCE})
		}

		return sortData;
	}

});