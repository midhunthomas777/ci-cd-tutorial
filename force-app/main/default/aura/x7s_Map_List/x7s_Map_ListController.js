/*
 * Copyright (c) 2019. 7Summits Inc.
*/
({
	init: function (cmp, event, helper) {
		let titleSize = cmp.get("v.titleSize");
		cmp.set("v.titleSize", titleSize.toLowerCase());
		let titleAlignment = cmp.get("v.titleAlignment");
		cmp.set("v.titleAlignment", titleAlignment.toLowerCase());
		cmp.set("v.mapMarkers", '');
		helper.getMapLocators(cmp, event, helper);
	}
});