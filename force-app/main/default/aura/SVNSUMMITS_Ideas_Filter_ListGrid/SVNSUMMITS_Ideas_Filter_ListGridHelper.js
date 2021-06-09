/*
 * Copyright (c) 2019. 7Summits Inc.
 */

/**
 * Created by francoiskorb on 11/20/18.
 */
({
	setMode: function (component) {
		const currentMode = component.get('v.displayMode');
		this.debug(component, 'setMode - current mode: ' + currentMode);

		component.set('v.listView', currentMode === this.custom.layout.LIST);
		component.set('v.gridView', currentMode === this.custom.layout.GRID);
	}
});