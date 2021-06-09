/*
 * Copyright (c) 2019. 7Summits Inc.
 */

/**
 * Created by francoiskorb on 2019-03-28.
 */
({
	init : function(component, event, helper) {
		let recordUrl  = component.get('v.ideaDetailURL');
		let idea       = component.get('v.idea');
		let targetUrl  = component.get('v.sitePath');

		if (helper.inLexMode()) {
			targetUrl = recordUrl;
			targetUrl += '?' + helper.custom.urlParams.lexRecordId + '=' + idea.Id;
			component.set('v.ideaUrl', targetUrl);
		} else {
			component.set('v.ideaUrl', targetUrl + recordUrl + idea.Id + helper.custom.urlParams.view);
		}
	},

	gotoRecordDetail: function (component, event, helper) {
		let recordId   = event.currentTarget.dataset['id'];
		let recordUrl  = component.get('v.ideaDetailURL');
		let navService = component.find('tileImageNavigation');

		helper.navigateToRecordURL(component, navService, recordUrl, recordId);
	}
});