({
    doInit : function(component, event, helper) {   
        console.log('******accountId is'+ component.get("v.accountId"));
        var theme =component.get('v.UserTheme');
        console.log('UserTheme = '+theme);
        var isPartnerUser = component.get('v.isPartnerUser');
        helper.getSitePrefix(component);
        helper.getCPQSiteId(component); 
        if(isPartnerUser){
            helper.getOrderType(component); 
            helper.getAccountDetails(component); 
        }
    },
    redirectToCPQ:function(component, event, helper){
        helper.launchCPQ(component); 
        // Close the action panel //SF-2509
        var dismissActionPanel = $A.get("e.force:closeQuickAction");
        dismissActionPanel.fire();
    },
    orderChange: function (component, event , helper) {
        var selectedOrder = component.find("orderSelect").get("v.value");
        if(selectedOrder!=null){
            component.set("v.selectedOrderType" ,selectedOrder);
            helper.getPartnerCommissionInfo(component);
        }
    }
})