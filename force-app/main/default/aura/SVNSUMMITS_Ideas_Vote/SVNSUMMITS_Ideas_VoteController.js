/*
 * Copyright (c) 2019. 7Summits Inc.
 */
({
	doInit: function (component, event, helper) {
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
			helper.doCallout(component, 'c.getCommonSettings',
				{
					zoneName        : component.get('v.zoneName'),
					loadCustomFields: false,
					fieldSetName    : ''
				},
				false, 'Ideas Vote - Get Common Settings', true)
				.then(common => {
					component.set("v.debugMode",         common.debugMode);
					component.set('v.zoneId',            common.zoneId);
					component.set('v.disableDownVoting', !common.allowDownVoting);
					component.set('v.voteDisableStatus', common.voteDisableStatus || '');
					component.set('v.showAlternateCTA',  common.showAlternateCTA);

					helper.doCallout(component, 'c.getIdeaRecord',
						{
							recordId: component.get("v.recordId"),
							zoneId: component.get("v.zoneId"),
							customFieldSetName : ''
						}, false, 'Ideas Vote - get Idea', false)
						.then(wrapper => {
							let idea = helper.updateIdeaValues(component,
												helper.parseNamespace(component, wrapper.ideaList[0]),
												wrapper.topicNameToId,
												wrapper.sitePath,
												'',
												component.get('v.voteDisableStatus'));
							component.set('v.idea', idea);
						});

					helper.doCallout(component, 'c.getVote',
						{
							recordId: component.get("v.recordId")
						}, false, 'Ideas Vote -  get Vote', false)
						.then(vote => {
							component.set('v.currentVote', vote);
						});
				});
		}
	},

	voteChanged : function (component, event, helper) {
		let voteTotal = event.getParam('voteTotal');
		component.set('v.totalVoteCount', voteTotal);
	},

	voteUp: function (component, event, helper) {
		const voteType = event.getParam('voteType');
		helper.vote(component, voteType === 'Up');
	},

	voteDown: function (component, event, helper) {
		const voteType = event.getParam('voteType');
		helper.vote(component, voteType === 'Up');
	}
});