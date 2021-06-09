/*
 * Copyright (c) 2019. 7Summits Inc.
 */

/**
 * Created by francoiskorb on 2019-03-27.
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

			component.set('v.userProfileURL', '/lightning/r/User/' + idea.CreatedBy.Id + helper.custom.profileUrl.view);
		} else {
			component.set('v.ideaUrl', targetUrl + recordUrl + idea.Id + helper.custom.urlParams.view);
			component.set('v.userProfileURL', component.get('v.sitePath') + '/profile/' + idea.CreatedBy.Id);
		}

		component.set('v.ideaUserName', component.get('v.isNicknameDisplayEnabled')
			? idea.CreatedBy.CommunityNickname
			: idea.CreatedBy.Name);
	},

	gotoRecordDetail: function (component, event, helper) {
		let recordId   = event.currentTarget.dataset['id'];
		let recordUrl  = component.get('v.ideaDetailURL');
		let navService = component.find('tileNameNavigation');

		helper.navigateToRecordURL(component, navService, recordUrl, recordId);
	}
});