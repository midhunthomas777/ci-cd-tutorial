/**
 * Copyright (c) 2019. 7Summits Inc.
 */
({
    fetchObjectList : function(component,event,helper) {

        let searchKeyWord = component.get('v.searchKeyWord');
        let _params = {
            inputKeyword : searchKeyWord
        };

        let _refObj = component.get('v.objectType');
        let methodName = '';

        if(_refObj === 'User') {
            methodName = 'c.fetchUsers';
        }

        helper.doCallout(component,methodName,_params,function(response) {
            let state = response.getState();
            if(state === 'SUCCESS') {
                let _resp = response.getReturnValue();
                if(_resp)
                    component.set('v.listOfSearchRecords',_resp);
                console.log('resp frm select object: ', _resp);
            }
        });
    },

    doCallout : function(component, methodName, params, callBackFunc){
        let action = component.get(methodName);
        action.setParams(params);
        action.setCallback(this, callBackFunc);
        $A.enqueueAction(action);
    },

    clearSelection : function(component) {
        component.set('v.disableInput', false);
        component.set('v.selectedUserId', '');

        let pillTarget   = component.find("lookup-pill");
        let lookUpTarget = component.find("lookupField");

        $A.util.addClass(pillTarget, 'slds-hide');
        $A.util.removeClass(pillTarget, 'slds-show');

        $A.util.addClass(lookUpTarget, 'slds-show');
        $A.util.removeClass(lookUpTarget, 'slds-hide');

        component.set("v.searchKeyWord", '');
        component.set("v.listOfSearchRecords", null);

        let _refObj = component.get('v.objectType');

        if (_refObj === 'User') {
            component.set('v.selectedUser', '');
        } else if (_refObj === 'Account') {
            component.set('v.selectedAccount', '');
        } else if (_refObj === 'Contact') {
            component.set('v.selectedContact', '');
        }
    }
});