/*
 * Copyright (c) 2019. 7Summits Inc.
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
			helper.getComments(component);
		}
	},

	addIdeaComment: function (component, event, helper) {
		let htmlString = component.get('v.newComment');
		const valid    = !!htmlString && !!helper.getHtmlPlainText(component, htmlString).trim();

		if (valid) {
			component.set('v.validity', true);
			helper.saveComment(component);
		} else {
			component.set('v.validity', false);
		}
	},

	onSort :function(component, event, helper) {
		helper.getComments(component);
	},

	getNextPage: function(component, event, helper) {
		component.set('v.pageNumber', component.get('v.pageNumber') + 1);
		helper.getComments(component);
	},

	getPreviousPage: function(component, event, helper) {
		component.set('v.pageNumber', component.get('v.pageNumber') - 1);
		helper.getComments(component);
	},

	likeComment: function (component, event, helper) {
		if (event) {
			let target = event.currentTarget;

			if (target) {
				helper.likeComment(component, target.dataset.recordid);
			}
		}
	},

	unlikeComment: function (component, event, helper) {
		let target = event.currentTarget;

		if (target) {
			helper.unlikeComment(component, target.dataset.recordid);
		}
	}
});