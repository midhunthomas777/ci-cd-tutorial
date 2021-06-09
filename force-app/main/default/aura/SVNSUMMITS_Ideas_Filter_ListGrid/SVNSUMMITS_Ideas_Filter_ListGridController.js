/*
 * Copyright (c) 2019. 7Summits Inc.
 */
/**
 * Created by francoiskorb on 9/21/16.
 */
({
	onInit: function (component, event, helper) {
		helper.setMode(component);
	},

	setInitialView: function (component, event, helper) {
		let viewMode = event.getParam("listViewMode");
		component.set("v.displayMode", viewMode);
		helper.setMode(component);
	},

	setListView: function (component, event, helper) {
		helper.debug(component, 'View mode:' + helper.custom.layout.LIST);

		component.set("v.displayMode", helper.custom.layout.LIST);
		helper.setMode(component);

		$A.get("e.c:SVNSUMMITS_Ideas_Set_Display_Mode_Filter")
			.setParams({
				listId     : component.get('v.listId'),
				displayMode: helper.custom.layout.LIST
			})
			.fire();
	},

	setGridView: function (component, event, helper) {
		helper.debug(component, 'View mode:' + helper.custom.layout.GRID);

		component.set("v.displayMode", helper.custom.layout.GRID);
		helper.setMode(component);

		$A.get("e.c:SVNSUMMITS_Ideas_Set_Display_Mode_Filter")
			.setParams({
				listId     : component.get('v.listId'),
				displayMode: helper.custom.layout.GRID
			})
			.fire();
	}
});