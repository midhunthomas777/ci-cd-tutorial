/*
 * Copyright (c) 2019. 7Summits Inc.
 */
({
	getComments: function(component)
	{
		this.doCallout(component, "c.getComments",
			{
				zoneName  : component.get('v.zoneName'),
				ideaId    : component.get('v.recordId'),
				pageSize  : component.get('v.numComments'),
				pageNumber: component.get('v.pageNumber'),
				sortOrder : component.get('v.sortOrder')
			}, false, 'get comments', false)
			.then($A.getCallback(function (model) {
				if (model.total ) {
					component.set("v.sitePrefix",   model.sitePrefix);
					component.set('v.showNickName', model.useNickName);

					model.items.forEach(function (item) {
						item.fromNow = moment(item.createdDate).fromNow();
					});

					component.set('v.comments',        model.items);
					component.set('v.totalRecords',    model.total);
					component.set('v.totalPages',      model.pageCount);
					component.set('v.hasNextPage',     model.pageHasNext);
					component.set('v.hasPreviousPage', model.pageHasPrevious);
				}
			}));
	},

	likeComment: function (component, id) {
		let self = this;

		console.log('Like: ' + id);
		this.doCallout(component, "c.likeIdeaComment",
			{
				commentId: id
			}, false, 'Like comment', false)
			.then($A.getCallback(function (result) {
				if (result) {
					self.getComments(component);
				}
			}));
	},

	unlikeComment: function (component, id) {
		let self = this;
		
		this.doCallout(component, 'c.unlikeIdeaComment',
			{
				voteId: id
			}, false, 'Unlike comment', false)
			.then($A.getCallback(function (result) {
				if (result) {
					self.getComments(component);
				}
			}));
	},

	saveComment: function (component) {
		let self = this;

		this.doCallout(component, "c.addComment",
			{
				ideaId:      component.get("v.recordId"),
				commentBody: component.get("v.newComment")
			}, false, 'add comment', false)
			.then($A.getCallback(function (result) {
				if (result) {
					component.set('v.allowHtml', true);
					component.set("v.newComment", "");
					self.getComments(component);
				}
			}));
	},

	showSpinner: function (component) {
		console.log('Spinner on...');
		$A.util.removeClass(component.find('listSpinner'), 'slds-hide');
	},

	hideSpinner: function (component) {
		console.log('Spinner off...');
		$A.util.addClass(component.find('listSpinner'), 'slds-hide');
	}
});