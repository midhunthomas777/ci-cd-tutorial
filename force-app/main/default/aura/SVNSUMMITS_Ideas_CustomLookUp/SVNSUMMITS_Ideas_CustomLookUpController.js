({
	doInit: function (component, event, helper) {
		let isNewIdea  = component.get('v.isNewIdea');
		let objectType = component.get('v.objectType');
		let isEditing  = component.get('v.isEditing');

		if (objectType === 'User') {
			let pillTarget = component.find("lookup-pill");
			if (isNewIdea && !isEditing) {
				$A.util.addClass(pillTarget, 'slds-hide');
				$A.util.removeClass(pillTarget, 'slds-show');
			} else {
				$A.util.addClass(pillTarget, 'slds-show');
				$A.util.removeClass(pillTarget, 'slds-hide');
			}

			let searchRes = component.find("searchRes");
			$A.util.addClass(searchRes, 'slds-is-close');
			$A.util.removeClass(searchRes, 'slds-is-open');


			let lookUpTarget = component.find("lookupField");
			if (isNewIdea && !isEditing) {
				$A.util.addClass(lookUpTarget, 'slds-show');
				$A.util.removeClass(lookUpTarget, 'slds-hide');
			} else {
				$A.util.addClass(lookUpTarget, 'slds-hide');
				$A.util.removeClass(lookUpTarget, 'slds-show');
			}
		}

		if (!component.get('v.selectedUser')) {
			helper.clearSelection(component);
		}
	},

	onblur: function (component, event, helper) {
		component.set("v.listOfSearchRecords", null);
		let forClose = component.find("searchRes");
		$A.util.addClass(forClose, 'slds-is-close');
		$A.util.removeClass(forClose, 'slds-is-open');
	},

	clear: function (component, event, helper) {
		helper.clearSelection(component);
	},

	onfocus: function (component, event, helper) {
		$A.util.addClass(component.find("mySpinner"), "slds-show");

		let forOpen = component.find("searchRes");
		$A.util.addClass(forOpen, 'slds-is-open');
		$A.util.removeClass(forOpen, 'slds-is-close');

		// Get Default 5 Records order by createdDate DESC
		let getInputkeyWord = '';
		helper.fetchObjectList(component, event, helper);

	},

	doDropdownClose: function (component, event, helper) {
		let mainBox = component.find('searchRes');
		component.set("v.showDropdown", false);
		$A.util.removeClass(mainBox, 'slds-is-open');
	},

	handleComponentEvent: function (component, event, helper) {
		component.set('v.disableInput', true);

		// get the selected Account record from the COMPONENT event
		let selectedUser = event.getParam("selectedUser");
		let _refObj = component.get('v.objectType');

		if (_refObj === 'User') {
			component.set('v.selectedUser', selectedUser);
			component.set('v.selectedUserId', selectedUser.Id);
		}

		let forClose = component.find("lookup-pill");
		$A.util.addClass(forClose, 'slds-show');
		$A.util.removeClass(forClose, 'slds-hide');

		let searchRes = component.find("searchRes");
		$A.util.addClass(searchRes, 'slds-is-close');
		$A.util.removeClass(searchRes, 'slds-is-open');

		let lookUpTarget = component.find("lookupField");
		$A.util.addClass(lookUpTarget, 'slds-hide');
		$A.util.removeClass(lookUpTarget, 'slds-show');
	}
});