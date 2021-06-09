/*
 * Copyright (c) 2019. 7Summits Inc.
 */

/**
 * Created by francoiskorb on 2019-08-21.
 */

({
	handleActive: function(component, event) {
		const tab = event.getSource();

		switch(tab.get('v.id')) {
			case 'comments' :
				this.injectComponent('c:SVNSUMMITS_Ideas_Comments',
					{
						debugMode       : component.get("v.debugMode"),
						zoneName        : component.get("v.zoneName"),
						recordId        : component.get("v.recordId"),
						userProfileURL  : component.get("v.userProfileURL"),
						numComments     : component.get("v.numComments"),
						showPagination  : component.get("v.showPagination"),
						showSort        : component.get("v.showSort"),
						sortOrder       : component.get("v.sortOrder"),
						likesText       : component.get("v.commentsLikes"),
						allowComment    : component.get("v.showComments"),
						allowHtml       : component.get("v.idea.IsHtml")
					}, tab);
				component.set('v.commentsLoaded', true);
				break;

			case 'discussion':
				this.injectComponent("c:SVNSUMMITS_Ideas_Feeds",
					{
						recordId        : component.get("v.recordId"),
						idea            : component.get("v.idea"),
						title           : component.get("v.feedTitle")
					}, tab);
				component.set('v.chatterLoaded', true);
				break;

			case 'files':
				this.injectComponent('c:SVNSUMMITS_Ideas_Files',
					{
						recordId        : component.get("v.recordId"),
						idea            : component.get("v.idea"),
						title           : component.get("v.filesTitle"),
						accept          : component.get("v.filesAccept"),
						showFileUploader: component.get("v.showFileUploader"),
						showFileViewer  : component.get("v.showFileViewer")
					}, tab);
				component.set('v.filesLoaded', true);
				break;
		}
	},

	injectComponent: function (name, params, target) {
		$A.createComponent(name, params,
			function (contentComponent, status, error) {
				if (status === 'SUCCESS') {
					target.set('v.body', contentComponent);
				} else {
					throw new Error(error);
				}
			});
	}
});