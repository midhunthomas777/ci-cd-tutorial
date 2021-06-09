({
    getFileIds : function(component,event,helper,_source) {

        if(!component.get('v.isParentCalled') || _source === 'event') {

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
                }
            });
            $A.enqueueAction(action);
        }
    }
})