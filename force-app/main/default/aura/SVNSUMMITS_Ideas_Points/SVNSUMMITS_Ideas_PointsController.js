/*
 * Copyright (c) 2019. 7Summits Inc.
 */
({
	formatPoints: function (component, event, helper) {
		if (component.get("v.formatPoints") && component.get("v.points") !== null) {
			const points = component.get("v.points");
			let formattedPoints = points;
			if (points >= 1000000000) {
				formattedPoints = (points / 1000000000).toFixed(1).replace(/\.0$/, '') + 'b';
			} else if (points >= 1000000) {
				formattedPoints = (points / 1000000).toFixed(1).replace(/\.0$/, '') + 'm';
			} else if (points >= 1000) {
				formattedPoints = (points / 1000).toFixed(1).replace(/\.0$/, '') + 'k';
			} else if (points === 0) {
				formattedPoints = 0;
			}
			component.set("v.formattedPoints", formattedPoints);
		}
	}
});