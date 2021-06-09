/*
 * Copyright (c) 2018. 7Summits Inc.
 */

/**
 * Created by francoiskorb on 8/9/18.
 */
({
	init: function (component) {
		let self = this;

		if (component.get("v.showIntroScreen")) {
			component.set("v.screenIndex", 1);
		} else {
			component.set("v.screenIndex", 2);
		}

		let fieldValue = this.getParentFieldValue(component);
		let params = {
			applicableTypes: component.get("v.attributeTypes"),
			targetObjectName: component.get("v.targetObject"),
			parentFieldName: component.get("v.fieldName"),
			parentFieldValue: fieldValue
		};

		this.doCallout(component, "c.getAttributesGroupByType", params, true, '')
			.then($A.getCallback(function (response) {
				let result = JSON.parse(response);
				console.log(result);
				component.set("v.mapOfAttributes", result);
				component.set("v.totalAttributeTypes", result.length);
				self.setAttributes(component, result, 0);

				let listOfTypes = [];
				for (let key in result) {
					listOfTypes.push(result.category);
				}
				component.set("v.listOfTypes", listOfTypes);
				console.log(listOfTypes);
			}));
	},

	setAttributes: function (component, data, index) {
		let categoryWithAttributes = data[index];

		if (categoryWithAttributes) {
			component.set("v.currentIndex", index);
			component.set("v.currentAttributeType", categoryWithAttributes.category);

			if (categoryWithAttributes.listOfAttributes) {
				let options = [];
				let selectedOptions = [];

				categoryWithAttributes.listOfAttributes.forEach(function (item) {
					if (item.isSelected) {
						selectedOptions.push(item.attribute.Id);
					}
					options.push({
						label: item.attribute.Name,
						value: item.attribute.Id
					});
				});
				component.set("v.listOptions", options);
				component.set("v.defaultOptions", selectedOptions);
			}
		}
	},

	goToNextType: function (component, currentIndex) {
		this.setAttributes(component, component.get("v.mapOfAttributes"), currentIndex);
	},

	saveRecordsToDatabase: function (component) {
		let self = this;
		let mapOfAttributes = component.get("v.mapOfAttributes");
		let listOfAttributes = [];
		mapOfAttributes.forEach(function (category) {
			listOfAttributes.push(...category.listOfAttributes);

		});

		let fieldValue = this.getParentFieldValue(component);
		let params = {
			targetObjectName: component.get("v.targetObject"),
			recordsAsJSON: JSON.stringify(listOfAttributes),
			parentFieldName: component.get("v.fieldName"),
			parentFieldValue: fieldValue
		};

		console.log(JSON.stringify(listOfAttributes));
		this.doCallout(component, "c.saveUserAttributes", params, true, '')
			.then($A.getCallback(function (response) {
				if (response.isSuccess) {
					component.set("v.screenIndex", 4);
				} else {
					self.showMessage('error', 'Save', response.message);
				}
			}));
	},

	getParentFieldValue: function (component) {
		let fieldValue = component.get("v.fieldValue");

		if (fieldValue === '{userId}') {
			fieldValue = $A.get("$SObjectType.CurrentUser.Id");
		}
		else if (fieldValue === '{recordId}') {
			fieldValue = component.get("v.recordId");
		}

		return fieldValue;
	}
});