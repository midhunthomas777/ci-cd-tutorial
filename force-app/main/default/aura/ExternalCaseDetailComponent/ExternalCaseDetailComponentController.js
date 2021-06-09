({
    doInit : function(component, event, helper) {
        helper.getCaseByNumber(component, event, helper);
    },    
   /* handleFilter:function(component, event, helper){
        helper.filterCaseLineItems(component, event, helper);
    },*/
    viewAllCases:function(component, event, helper){
        helper.viewAllCases(component, event, helper); 
    }
})