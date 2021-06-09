// Copyright (c) 2018. 7Summits Inc.

({
	doInit: function (component, event, helper) {
		component.set('v.pageTitle', document.title.replace('|', '%7C'));
		component.set('v.pageURL', window.location);
	},

	doPopup: function (component, event, helper) {
		helper.launchPopup(component.get('v.titletext'), event.currentTarget.dataset.href);
	}
});