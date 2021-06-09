/*
 * Copyright (c) 2019. 7Summits Inc.
 */

({
    onInit : function(component, event, helper) {
        let action = component.get("c.getQuestionDetail");
        action.setParams({recordId : component.get('v.recordId')});
        action.setCallback(this, function (response) {
            if(response.getState() === 'SUCCESS') {
                let _resp = response.getReturnValue();
                console.log('RESP from Ideas: ' + JSON.stringify(_resp));
                if (_resp.requestedBy) {
                    _resp.Requested_By__c = _resp.requestedBy.Id;
                }

                component.set('v.selectedUser', _resp.requestedBy);
                if (_resp.requestedBy) {
                    component.set('v.selectedUserId', _resp.requestedBy.Id);
                }

                component.set('v.currIdea', _resp);
            }
        });
        $A.enqueueAction(action);
    },

    handleConvertToIdeaCancel : function(component) {
        component.set('v.createIdeaClick', true);
    },

    closeIdeaPage: function (component) {
        component.set("v.createIdeaClick", false);
    },

})