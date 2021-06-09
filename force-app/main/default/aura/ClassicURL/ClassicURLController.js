({
    doInit : function(component, event, helper) {
        helper.getClassicURL(component);
    },
    copyHardcoreText : function(component, event, helper) {
        var textForCopy = component.find('oURL').get("v.value");
        helper.copyTextHelper(component,event,textForCopy);
    }
})