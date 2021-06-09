/*
 * Copyright (c) 2019. 7Summits Inc.
 */
({
	onInit: function (component, event, helper) {

		// Not needed for un-managed IP
		//
		// let action = component.get("c.getModel");
		// //action.setStorable();
		//
		// action.setCallback(this, function (response) {
		// 	component.set("v.baseModel", JSON.stringify(response.getReturnValue()));
		// 	component.getEvent("baseReady").fire();
		//
		// 	svg4everybody();
		// });
		//
		// $A.enqueueAction(action);

		component.getEvent("baseReady").fire();
	}
});