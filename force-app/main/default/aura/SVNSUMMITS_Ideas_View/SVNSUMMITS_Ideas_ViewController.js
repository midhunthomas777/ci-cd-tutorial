/*
 * Copyright (c) 2019. 7Summits Inc.
 */
({
	doInit: function (component, event, helper) {
		component.set("v.currentURL", encodeURIComponent(window.location.href));

		let pageReference = component.get("v.pageReference");
		console.log('Page reference:' + pageReference);

		// get the record from the URL if NOT on the OTB detail page
		// note the '?recordId='  needed on the builder control panel
		let recordId = component.get('v.recordId');

		if (!recordId) {
			let search = helper.getURLParam();

			if (search && search[helper.custom.urlParams.lexRecordId]) {
				recordId = search[helper.custom.urlParams.lexRecordId];
			}

			if (recordId) {
				component.set('v.recordId', recordId);
			} else {
				// back to the list if not found
				if (helper.inLexMode()) {
					helper.gotoUrl(component, component.get('v.ideaListURL'));
				}
			}
		}

		if (recordId) {
			helper.getCommonSettings(component);
		}
	},

	// Handles showing and hiding main tab content.
	handleTabClick: function (component, event, helper) {

		let clickedTabId        = event.target.id;
		let clickedComponentLi  = component.find(clickedTabId + "-li");
		let clickedComponentDiv = component.find(clickedTabId + "-div");

		$A.util.addClass(clickedComponentLi, "slds-active");
		$A.util.addClass(clickedComponentDiv, "slds-show");
		$A.util.removeClass(clickedComponentDiv, "slds-hide");

		let otherTabId        = (clickedTabId === "tab-comments") ? "tab-overview" : "tab-comments";
		let otherComponentLi  = component.find(otherTabId + "-li");
		let otherComponentDiv = component.find(otherTabId + "-div");

		$A.util.removeClass(otherComponentLi, "slds-active");
		$A.util.addClass(otherComponentDiv, "slds-hide");
		$A.util.removeClass(otherComponentDiv, "slds-show");
	}
});