/*
 * Copyright (c) 2018. 7Summits Inc.
 */

({
	doInit: function (component, event, helper) {
		if (component.get("v.useFromRecord")) {
			helper.getInitialDataFromApex(component);
		} else {
			component.set("v.showVideos", true);
		}
	}
});