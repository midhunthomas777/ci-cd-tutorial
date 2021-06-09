({
    doInit : function(component, event, helper) {
        helper.setContractLineItemColumns(component, event, helper);
        helper.getContractByNumber(component, event, helper);
    },    
    handleFilter:function(component, event, helper){
        helper.filterContractLineItems(component, event, helper);
    },
    viewAllOrders:function(component, event, helper){
        helper.viewAllContracts(component, event, helper); 
    }
})