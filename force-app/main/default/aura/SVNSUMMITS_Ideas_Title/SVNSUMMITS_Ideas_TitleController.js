/*
 * Copyright (c) 2019. 7Summits Inc.
 */
({
	fetchUrl: function (component, event, helper) {
		component.set("v.currentURL", encodeURIComponent(window.location.href));

		let recordId = component.get('v.recordId');

		// LEX mode - get the record from the URL if NOT on the OTB detail page
		// note the '?recordId=' needed on the builder control panel
		// https://fran-ideasr2-w18-developer-edition.gus.force.com/s/7s-idea?id=087B0000000DBEQIA4
		let lexMode = helper.inLexMode();
		console.log('Title - lex mode: ' + lexMode);

		if (!recordId) {
			let search = helper.getURLParam();

			if (search && search[helper.custom.urlParams.lexRecordId]) {
				recordId = search[helper.custom.urlParams.lexRecordId];
			}

			if (recordId) {
				component.set('v.recordId', recordId);
			}
		}
		console.log('Record Id: ' + recordId);

	    helper.doCallout(component, "c.getCommonSettings",
		{
			zoneName        : component.get('v.zoneName'),
			loadCustomFields: false,
			fieldSetName    : ''
		},
		true, '', true)
		.then((result) => {
			component.set("v.debugMode", result.debugMode);
			component.set("v.sitePath", result.sitePath);
			component.set("v.isNicknameDisplayEnabled", result.nicknameEnabled);
			component.set('v.zoneId', result.zoneId);

			let recordId = component.get("v.recordId");

			if (recordId) {
				/// TODO LEX hack to force a reload - does not work on the back button
				let exploreUrl = component.get('v.ideasListURL');
				if (helper.inLexMode()) {
					exploreUrl += '?sid=' + component.getGlobalId();
					component.set('v.exploreIdeas', exploreUrl);
				} else {
					component.set('v.exploreIdeas', result.sitePath + exploreUrl);
				}

				if (component.get('v.canEdit')) {
					helper.doCallout(component, "c.isRecordEditable",
						{
							recordId: recordId
						}, true, '', true)
						.then((result) => {
							component.set("v.canEdit", result);
						});
				}

				if (component.get('v.canDelete')) {
					helper.doCallout(component, "c.isRecordDeletable",
						{
							recordId: recordId
						}, true, '', true)
						.then((result) => {
							component.set("v.canDelete", result);
						});
				}

				helper.doCallout(component, 'c.getIdeaRecord',
					{
						zoneId: component.get('v.zoneId'),
						recordId: recordId,
						customFieldSetName: ''
					}, false, 'Idea Banner - Get Idea Record', false)
					.then((wrapper) => {
						let idea = helper.updateIdeaValues(component,
							helper.parseNamespace(component, wrapper.ideaList[0]),
							wrapper.topicNameToId,
							wrapper.sitePath,
							'');

						helper.debug(component, "Title Helper.getIdea:", idea);
						component.set("v.idea", idea);

						if (idea && idea.CreatedBy) {
							if (helper.inLexMode()) {
								component.set('v.userProfileURL', '/lightning/r/User/' + idea.CreatedBy.Id + '/view');
							} else {
								component.set('v.userProfileURL', component.get('v.sitePath') + '/profile/' + idea.CreatedBy.Id);
							}
							
							component.set('v.ideaUserName', component.get('v.isNicknameDisplayEnabled')
								? idea.CreatedBy.CommunityNickname
								: idea.CreatedBy.Name);
							
							// Check for Edit/Delete My Ideas Only
							//  only check if user has permission
							if (component.get('v.editMyIdea')) {
								const userId = $A.get("$SObjectType.CurrentUser.Id");
								const isOwner = idea.CreatedBy.Id === userId;
								
								if (component.get('v.canEdit')) {
									component.set('v.canEdit', isOwner);
								}
								
								if (component.get('v.canDelete')) {
									component.set('v.canDelete', isOwner);
								}
							}
							
							if (component.get('v.canFollow')) {
								helper.doCallout(component, 'c.isFollowingIdea',
									{
										ideaId: component.get('v.recordId')
									}, false, 'Get idea subscription', false)
									.then(result => {
										component.set('v.isFollowing', result);
									});
							}
						}
					});
			}
		});
	},

	closeEditPage: function (component) {
		component.set("v.isEditing", false);
	},

	handleEdit: function (component, event, helper) {
		let url = component.get('v.ideaNewURL');

		if (url.endsWith('/')) {
			url = url.substring(0, url.length - 1);
		}
		url += '?' + helper.custom.urlParams.edit + '=' + component.get('v.recordId');

		helper.gotoUrl(component, url);
	},

	handleDelete: function (component, event, helper) {
		helper.deleteIdea(component);
	},

	handleFollowClick: function(component, event, helper) {
		const isFollowing = component.get("v.isFollowing");

		helper.doCallout(component,
			isFollowing ? 'c.unFollowIdea' : 'c.followIdea',
			{
				ideaId : component.get('v.recordId')
			}, false, 'Idea subscription', false)
			.then(result => {
				if (result) {
					component.set('v.isFollowing', !isFollowing);
				}
			});
	},

	handleExploreIdeas: function (component, event, helper) {
		let itemId  = component.getGlobalId();
		let listUrl = component.get('v.ideasListURL');

		if (helper.inLexMode()) {
			let navService = component.find('titleNavigation');
			let pageReference = {
				type        : 'standard__webPage',
				attributes  : {
					url : listUrl + '?sid='+itemId
				},
				replace: true
			};

			navService.navigate(pageReference);
		} else {
			helper.gotoUrl(component, listUrl);
		}
	}
});