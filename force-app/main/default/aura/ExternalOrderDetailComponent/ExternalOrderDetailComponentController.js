({
    doInit : function(component, event, helper) {
        helper.setOrderLineItemColumns(component, event, helper);
        helper.getOrderByNumber(component, event, helper);
    },    
    handleFilter:function(component, event, helper){
        helper.filterOrderLineItems(component, event, helper);
    },
    viewAllOrders:function(component, event, helper){
        helper.viewAllOrders(component, event, helper); 
    },
    viewTrackOrder:function(component, event, helper){
        helper.viewTrackOrder(component, event, helper); 
    }
})