/*
 * Copyright (c) 2018. 7Summits Inc.
 */

({
	doInit : function(component, event, helper) {
		helper.buildHeading(component);
		helper.getHandle(component);
		helper.getSitePrefix(component);
		helper.getSiteNamespace(component);
	}
});