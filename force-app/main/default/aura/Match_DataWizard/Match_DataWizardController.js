/*
 * Copyright (c) 2018. 7Summits Inc.
 */

/**
 * Created by francoiskorb on 8/9/18.
 */
({
	init: function (component, event, helper) {
		helper.init(component);
	},

	goToWizard: function (component, event, helper) {
		component.set("v.screenIndex", 2);
	},

	goToSummary: function (component, event, helper) {
		let skillSelectionPicklist = component.find("skillSelectionPicklist");

		if (skillSelectionPicklist.get('v.validity').valid) {
			component.set("v.screenIndex", 3);
		} else {
			skillSelectionPicklist.showHelpMessageIfInvalid();
		}
	},

	goBackToPicklist: function (component, event) {
		let currentIndex = component.get("v.currentIndex");

		component.set("v.screenIndex", 2);

		helper.goToNextType(component, currentIndex);
	},

	handleChange: function (component, event) {
		let selectedOptionsId = event.getParam("value");
		let currentIndex = component.get("v.currentIndex");
		let mapOfAttributes = component.get("v.mapOfAttributes");
		let listOfAttributes = mapOfAttributes[currentIndex];

		listOfAttributes.listOfAttributes.forEach(function (item) {
			item.isSelected = selectedOptionsId.indexOf(item.attribute.Id) > -1;
		});

		component.set("v.mapOfAttributes", mapOfAttributes);
	},

	goToNextType: function (component, event, helper) {
		let skillSelectionPicklist = component.find("skillSelectionPicklist");

		if (skillSelectionPicklist.get('v.validity').valid) {
			const currentIndex = component.get("v.currentIndex") + 1;
			helper.goToNextType(component, currentIndex);
		} else {
			skillSelectionPicklist.showHelpMessageIfInvalid();
		}
	},

	goToPreviousType: function (component, event, helper) {
		let currentIndex = component.get("v.currentIndex") - 1;
		helper.goToNextType(component, currentIndex);
	},

	saveRecords: function (component, event, helper) {
		helper.saveRecordsToDatabase(component);
	}
});