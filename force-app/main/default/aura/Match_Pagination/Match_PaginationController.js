/*
 * Copyright (c) 2018. 7Summits Inc.
 */

/**
 * Created by francoiskorb on 6/25/18.
 */
({
	init: function (component, event, helper) {
		component.set('v.isInit', true);

		// default alignment is start but cannot be specified - rip it out
		let align = component.get('v.align');

		if (align === 'start') {
			$A.util.removeClass(component.find('paginationControl'), 'horizontalAlign');
		}
	},

	paginate: function (component, event, helper) {
		let buttonName = event.getSource().get('v.name');

		component.getEvent('paginateEvent').setParams({'buttonClicked': buttonName}).fire();
	}

});