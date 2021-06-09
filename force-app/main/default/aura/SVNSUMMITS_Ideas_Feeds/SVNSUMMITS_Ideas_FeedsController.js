/*
 * Copyright (c) 2019. 7Summits Inc.
 */

({
	doInit: function (component, event, helper) {
		if (component.get('v.recordId')) {
			let action = component.get("c.getExtensionId");
			action.setParams({ideaId: component.get('v.recordId')});
			action.setCallback(this, function (actionResult) {
				if (actionResult.getState() === 'SUCCESS') {
					let _resp = actionResult.getReturnValue();
					console.log('RESP: ' + JSON.stringify(_resp));
					component.set('v.idea', _resp);
				}
			});
			$A.enqueueAction(action);
		}
	}
});