/*
 * Copyright (c) 2018. 7Summits Inc.
 */

({
	getInitialDataFromApex: function (component) {
		let params = {
			'recordId': component.get("v.recordId")
		};

		this.doCallout(component, "c.getInitialData", params).then($A.getCallback(function (result) {
			if (result.success) {
				if (result.results.length === 0) {
					component.set("v.showVideos", false);
				} else {
					for (let x = 1; x < result.results.length + 1; x++) {
						let videoId = result.results[x - 1];
						component.set("v.videoType" + x, videoId.length === 11 ? 'YouTube' : 'Vimeo');
						component.set("v.VideoURL" + x, videoId);
					}
					component.set("v.showVideos", true);
					component.set("v.hideDescriptions", true);

				}
			} else {
				component.set("v.errorMsg", result.messages.join());
			}
		}));
	}
});