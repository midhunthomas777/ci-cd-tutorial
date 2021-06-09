/*
 * Copyright (c) 2019. 7Summits Inc.
 */

/**
 * Created by francoiskorb on 11/29/18.
 */
({
	doInit: function (component, event, helper) {
		helper.doCallout(component, "c.getComments",
			{
				ideaId: component.get('v.recordId')
			}, true, '', false)
			.then($A.getCallback(function (result) {
				component.set("v.summaryWrapper", result);
			}));
	}
});