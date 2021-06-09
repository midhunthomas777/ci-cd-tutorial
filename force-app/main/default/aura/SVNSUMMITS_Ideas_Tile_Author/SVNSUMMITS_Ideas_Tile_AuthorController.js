/*
 * Copyright (c) 2019. 7Summits Inc.
 */

/**
 * Created by francoiskorb on 2019-04-02.
 */
({
	init: function (component, event, helper) {
		const idea = component.get('v.idea');

		if (idea && idea.CreatedBy) {
			if (helper.inLexMode()) {
				component.set('v.userProfileURL',
					helper.custom.profileUrl.lex + idea.CreatedBy.Id + helper.custom.profileUrl.view);
			} else {
				component.set('v.userProfileURL',
					component.get('v.sitePath') + helper.custom.profileUrl.community + idea.CreatedBy.Id);
			}

			component.set('v.ideaUserName',
				component.get('v.showNickName') ? idea.CreatedBy.CommunityNickname : idea.CreatedBy.Name);
		}
	}
});