/*
 * Copyright (c) 2019. 7Summits Inc.
 */
({
	onInit: function (component, event, helper) {
		let recordId = component.get('v.recordId');

		if (!recordId) {
			let search = helper.getURLParam();

			if (search && search[helper.custom.urlParams.lexRecordId]) {
				recordId = search[helper.custom.urlParams.lexRecordId];
			}

			if (recordId) {
				component.set('v.recordId', recordId);
			}
		}

		if (recordId) {
			helper.doCallout(component, "c.getCommonSettings",
				{
					zoneName        : component.get('v.zoneName'),
					loadCustomFields: false,
					fieldSetName    : ''
				}, true, 'Ideas Status - get common settings', true)
				.then(common => {
					component.set("v.debugMode", common.debugMode);
					component.set("v.zoneId", common.zoneId);

					let statusValues = component.get("v.StatusAllowed");

					if (statusValues && statusValues.trim() !== '') {
						component.set("v.statusSet", statusValues.split(','));
					} else {
						helper.doCallout(component, 'c.getPicklistValues',
							{
								objName: "Idea",
								fieldName: "Status"
							}, true, 'Ideas Status - get picklist values', true)
							.then(list => {
								component.set("v.statusSet", list)
							});
					}

					helper.doCallout(component, "c.getIdeaRecord",
						{
							recordId: component.get("v.recordId"),
							zoneId: component.get("v.zoneId"),
							customFieldSetName : ''
						}, false, 'Ideas Status - Get Idea', false)
						.then(wrapper => {
							let idea = helper.updateIdeaValues(component,
								helper.parseNamespace(component, wrapper.ideaList[0]),
								wrapper.topicNameToId,
								wrapper.sitePath,
								'');

							component.set("v.idea", idea);
							component.set('v.currentStep', idea.Status);
							//helper.getCurrentStep(component);
						})
				});
		}
	}
});