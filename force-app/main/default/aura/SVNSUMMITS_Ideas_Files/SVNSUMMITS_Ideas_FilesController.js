/*
 * Copyright (c) 2019. 7Summits Inc.
 */

({
    doInit : function(component, event, helper) {
        let recordId = component.get('v.recordId');

        if (!recordId) {
            // get from the url (lex mode?)
            let search = helper.getURLParam();

            if (search && search[helper.custom.urlParams.lexRecordId]) {
                recordId = search[helper.custom.urlParams.lexRecordId];
            }

            if (recordId) {
                component.set('v.recordId', recordId);
            }
        }

        if(recordId) {
            let action = component.get("c.getExtensionId");

            action.setParams({ideaId : recordId});
            action.setCallback(this, function(actionResult) {
                if(actionResult.getState() === 'SUCCESS') {
                    let _resp = actionResult.getReturnValue();
                    //console.log('RESP: ' + JSON.stringify(_resp));
                    if(_resp)
                        component.set('v.idea', _resp);

                    helper.getFileIds(component,event,helper);

                }
            });
            $A.enqueueAction(action);
        }
    },
});