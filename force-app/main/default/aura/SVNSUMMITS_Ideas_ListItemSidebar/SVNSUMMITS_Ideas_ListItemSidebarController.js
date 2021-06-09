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
        let ideaId = component.get("v.idea.Id");

        if (helper.inLexMode()) {
            let url = component.get('v.sitePrefix');

            url += component.get('v.ideaDetailURL');
            url += '?' + helper.custom.lexRecordId + '=' + ideaId;

            helper.gotoUrl(component, url);
        } else {
            helper.gotoRecord(component, ideaId);
        }
    }
})