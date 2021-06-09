/*
 * Copyright (c) 2019. 7Summits Inc.
 */

/**
 * Created by francois korb on 6/27/18.
 */
({
    doInit: function(component, event, helper) {
        let idea = component.get("v.idea");
        // Truncate the description so browsers that don't support line-clamp don't get HUGE lengths of text.
        if(idea.Body) {
            component.set("v.ideaBody",
	            helper.truncateHTMLString(idea.Body,
		            component.get("v.maxBodyCharLength"),
		            component.get("v.appendEllipsis")) );
        }
    },

	goToRecord: function (component, event, helper) {
		let recordId  = event.currentTarget.dataset['id'];
		let recordUrl = component.get('v.ideaDetailURL');
		helper.gotoRecordUrl(component, recordId, recordUrl);
	}
});