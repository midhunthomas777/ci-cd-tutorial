({
    doInit : function(component, event, helper) {
        console.log('doInit');
        if(component.get('v.onSameObject')) {
            helper.findIdIfParent(component, helper);
        } else {
            helper.getFieldsetFields(component, helper);
        }
    }
})