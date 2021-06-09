({
    doInit : function(component, event, helper) {
        helper.getDynamicTabs(component, event, helper);
    },
    handleActive: function (component, event, helper) {
        helper.handleActive(component, event);
    }
})