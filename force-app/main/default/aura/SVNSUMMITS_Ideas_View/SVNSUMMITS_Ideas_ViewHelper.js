/*
 * Copyright (c) 2019. 7Summits Inc.
 */
({
	getCommonSettings: function (component) {
		const self   = this;

		// sentinel to avoid multiple calls
		if (component.get('v.init')) {
			return;
		}

		this.doCallout(component, 'c.getCommonSettings',
			{
				zoneName        : component.get('v.zoneName'),
				loadCustomFields: true,
				fieldSetName    : component.get('v.customFieldSetName')
			},
			false, 'Get Common Settings', true)
			.then(common => {
				component.set('v.settings', common);
				component.set("v.debugMode", common.debugMode);
				component.set('v.showNickname', common.nicknameEnabled);
				component.set('v.customFields', common.customFields);
				component.set("v.zoneId", common.zoneId);
				component.set('v.sitePath', common.sitePath);

				let sitePath = common.sitePath;
				let position = sitePath.lastIndexOf('/s');
				component.set("v.sitePrefix", sitePath.substring(0, position));

				let isAuthenticated = common.isAuthenticated;

				if ((component.get("v.authenticatedOnly")
					&& isAuthenticated)
					|| !component.get("v.authenticatedOnly")) {

					this.doCallout(component, 'c.getIdeaRecord',
						{
							zoneId  : component.get("v.zoneId"),
							recordId: component.get("v.recordId"),
							customFieldSetName : component.get('v.customFieldSetName')
						}, false, 'getIdeaRecord', false)
						.then(wrapper => {
							let idea = self.updateIdeaValues(component,
								self.parseNamespace(component, wrapper.ideaList[0]),
								wrapper.topicNameToId,
								wrapper.sitePath,
								'');

							component.set("v.idea", idea);
							component.set('v.init', true);
							self.createCustomFields(component, idea);
						});
				}

			});
	},

	getMergedIdeas: function (component) {
		this.doCallout(component, 'c.getMergedIdeas',
			{
				recordId: component.get("v.recordId"),
				zoneId  : component.get("v.zoneId")
			}, false, 'Get merged ideas', false)
			.then( mergedIdeas => {
				component.set("v.mergedIdeas", mergedIdeas);
			});
	}
});