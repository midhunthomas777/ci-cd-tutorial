({
    doInit:function(component, event, helper){
        var oppCloseDate = component.get("v.oppCloseDate");
        helper.getRevenueYears(component, event, helper);
        if($A.util.isUndefinedOrNull(oppCloseDate) || $A.util.isEmpty(oppCloseDate)){
            component.set("v.showRevenueList",false);
            helper.fetchOLIDetails(component, event, helper);
        }else{
            helper.getRevenueMonths(component, event, helper);
        }
    },
    validateRevenues :function(component, event, helper) {
        var isError = event.getParam("errorMsg");
        component.set("v.errorMsg",isError);
    },
    addFirstRow: function(component, event, helper) {
        //SF-2176
        component.set("v.loadSpinner", true);
        helper.OLIDetails(component, event, helper);
        component.set("v.loadSpinner", false);
    },
    addNewRow: function(component, event, helper) {
        component.set("v.loadSpinner", true);
        helper.createObjectData(component, event, helper);
    },
    removeDeletedRow : function(component, event, helper) {
        var index = event.getParam("indexVar");
        var AllRowsList = component.get("v.RevenueList");
        AllRowsList.splice(index, 1);
        component.set("v.RevenueList", AllRowsList);
        
    },
    saveRevenue : function(component, event, helper) {
        var errorMsg = component.get("v.errorMsg");
        var revListSize = component.get("v.RevenueList");
        console.log('revListSize***'+JSON.stringify(revListSize));
        for(var i = 0;i< revListSize.length ; i++){
            if(($A.util.isUndefinedOrNull(revListSize[i].Revenue_Month__c) || $A.util.isUndefinedOrNull(revListSize[i].Revenue_Year__c) || $A.util.isUndefinedOrNull(revListSize[i].Revenue_Amount__c)) || 
               ($A.util.isEmpty(revListSize[i].Revenue_Month__c ) || $A.util.isEmpty(revListSize[i].Revenue_Year__c) ||$A.util.isEmpty(revListSize[i].Revenue_Amount__c))){
                component.set("v.errMsg", "Please enter Revenue Year,Revenue Month and Revenue Amount");
                errorMsg = true;
            }
        }
        if(!errorMsg){
            component.set("v.errMsg",null);
            helper.insertRevenue(component, event, helper);
        }
    },
    cancel : function(component, event, helper) {
        component.set("v.createRevenue",false);
        component.set("v.showRevenueList",true);
        component.set("v.showSaveBtn",false);
        component.set("v.showCreateBtn",true);
        component.set("v.errMsg",null);
    },
    createRevenue : function(component, event, helper) {
        helper.getUpdateOppDetails(component, event, helper);
    },
    changePageSize  : function(component, event, helper){
    }
    
})