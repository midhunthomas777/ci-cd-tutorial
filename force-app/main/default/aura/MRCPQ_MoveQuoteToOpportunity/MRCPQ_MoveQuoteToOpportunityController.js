({
    doInit : function(component,event,helper){
        //MR Quoting change for showing error message if quoting is in In Progress Status
        var quoteId = component.get('v.recordId');
        var userTheme = component.get('v.userTheme');
        console.log(quoteId);
        var action = component.get("c.canMoveQuote");
        action.setParams({
            "quoteId": quoteId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log(response);
            console.log(state);
            if (state === "SUCCESS") {
                console.log("Inside Success");
                var canMoveQuote = response.getReturnValue();
                if(canMoveQuote === true){  
                    if(userTheme ==='Classic'){
                       alert('Quote cannot be moved in the following status Approval Pending ,Order Creation In Progress,Order Creation Successful,Completed');
                       window.open('/'+quoteId,'_self');
                    } else{
                        var dismissActionPanel = $A.get("e.force:closeQuickAction");
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            title : 'Error Message',
                            message: "Quote cannot be moved in the following status Approval Pending ,Order Creation In Progress,Order Creation Successful,Completed",
                            duration:' 30000',
                            key: 'info_alt',
                            type: 'error',
                            mode: 'dismissible'
                        });
                        toastEvent.fire(); 
                        dismissActionPanel.fire();  
                    }
                }
            }
        });
        
        $A.enqueueAction(action);
        helper.getSitePrefix(component);
    },
    movequote : function(component, event, helper){
        component.set("v.message",false);
        helper.moveToOpportunity(component);
    },
    createnewopp : function(component, event, helper){
        helper.newOpportunity(component);
    },
    lookupSearch : function(component, event, helper) {
        component.set("v.message",false);
        const serverSearchAction = component.get('c.search');
        component.find('lookup').search(serverSearchAction);
    },
    getOpportunityId : function(component, event, helper){
        var selectedOpp = event.getParam("selectedId");
        component.set("v.selectedOpportunityId",selectedOpp);
    }
})