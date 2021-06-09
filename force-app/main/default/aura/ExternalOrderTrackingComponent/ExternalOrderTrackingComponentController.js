({
    doInit : function(component, event, helper) {
        helper.setOrderDetailURL(component, event, helper);
        helper.setTrackingLineItemColumns(component, event, helper);
        helper.getOrderTrackingDetails(component, event, helper);
    }
})