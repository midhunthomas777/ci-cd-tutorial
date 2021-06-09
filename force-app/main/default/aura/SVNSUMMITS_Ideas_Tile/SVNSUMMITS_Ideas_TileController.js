/*
 * Copyright (c) 2019. 7Summits Inc.
 */
({
	handle_VoteUp : function(component, event, helper) {
        let ideaId = component.get("v.idea.Id");
        helper.submitSingleVote(component, ideaId, "Up");
    },

    handle_VoteDown : function(component, event, helper) {
        let ideaId = component.get("v.idea.Id");
        helper.submitSingleVote(component, ideaId, "Down");
    },

    gotoRecordDetail: function(component, event, helper) {
        let recordId   = event.currentTarget.dataset['id'];
        let recordUrl  = component.get('v.ideaDetailURL');
        let navService = component.find('tileNavigation');

        if (helper.inLexMode()) {
            let url = component.get('v.sitePrefix');
            url += recordUrl;
            url += '?' + helper.custom.urlParams.lexRecordId + '=' + recordId;

            let pageReference = {
                type: 'standard__webPage',
                attributes: {
                    url: url
                },
                replace: true
            };
            event.preventDefault();
            navService.navigate(pageReference);
        } else {
            helper.gotoRecordUrl(component, recordId, recordUrl);
        }
    }
});