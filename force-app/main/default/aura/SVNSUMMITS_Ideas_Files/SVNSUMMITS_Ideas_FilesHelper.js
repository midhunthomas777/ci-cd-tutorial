/*
 * Copyright (c) 2019. 7Summits Inc.
 */

({
    getFileIds : function(component,event,helper) {
        if(component.get('v.recordId')) {

        let action = component.get("c.getAllRelatedFilesId");

        action.setParams(
            {
                ideaId      :   component.get('v.recordId'),
                isExtension :   component.get('v.isParentCalled'),
                visibility  :   component.get('v.visibility')
            });
        action.setCallback(this, function(actionResult) {
            if(actionResult.getState() === 'SUCCESS') {
                let _resp = actionResult.getReturnValue();
                console.log('RESP from File Change: ' + JSON.stringify(_resp));
                if(_resp)
                    component.set('v.files', _resp);
                component.set('v.isParentCalled', true);
            }
        });
        $A.enqueueAction(action);

        }
    }
});