/*
 * Copyright (c) 2019. 7Summits Inc.
 */

/**
 * Created by francoiskorb on 2019-04-17.
 */
({
	doInit: function (component, event, helper) {
		let recordId = component.get('v.recordId');

		if (!recordId) {
			// get from the url (lex mode?)
			let search = helper.getURLParam();

			if (search && search[helper.custom.urlParams.lexRecordId]) {
				recordId = search[helper.custom.urlParams.lexRecordId];
			}

			if (recordId) {
				component.set('v.recordId', recordId);
			}
		}

		if (recordId) {
			helper.doCallout(component, 'c.getCommonSettings',
				{
					zoneName        : component.get('v.zoneName'),
					loadCustomFields: false,
					fieldSetName    : ''
				}, false, 'Ideas Feed')
				.then(common => {
					component.set('v.zoneId', common.zoneId);

					helper.doCallout(component, 'c.getIdeaRecord', {
						zoneId      : common.zoneId,
						recordId    : component.get('v.recordId'),
						customFieldSetName : ''
					}).then(wrapper => {
						let idea = helper.updateIdeaValues(component,
							helper.parseNamespace(component, wrapper.ideaList[0]),
							wrapper.topicNameToId,
							wrapper.sitePath,
							'');

						component.set("v.idea", idea);

						// check if the user is the originator, creator or in the profile or permission set membership
						const userId   = $A.get('$SObjectType.CurrentUser.Id');
						let   showTabs = false;

						if (idea) {
							if (idea.CreatedBy.Id === userId) {
								showTabs = true;
							} else {
								if (idea['Requested_By__c'] && idea.Requested_By__c.Id === userId) {
									showTabs = true;
								} else {
									helper.doCallout(component, 'c.userAuthorizedChatter', {}, true, '')
										.then(result => {
											showTabs = result;
											component.set('v.showTabs', showTabs);
											component.set('v.showFileUploader', showTabs);
										})
								}
							}
						}

						component.set('v.showTabs', showTabs);
						component.set('v.showFileUploader', showTabs);
					});
				});
		}
	},

	handleActive: function (component, event, helper) {
		helper.handleActive(component, event);
	}
});