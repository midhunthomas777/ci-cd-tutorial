/*
 * Copyright (c) 2019. 7Summits Inc.
 */
({
	handleVote: function (component, event, helper) {
	    helper.onVote(component, 'Up');
	},

	handleDownVote: function (component, event, helper) {
	    helper.onVote(component, 'Down');
	}
});