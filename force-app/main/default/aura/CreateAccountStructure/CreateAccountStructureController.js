({
    doInit: function (component) {
        component.set("v.loadSpinner", true);
        var action = component.get("c.validMCNForUnmerging");
        var recordId = component.get("v.recordId");
        action.setParams({ accountId : recordId});
        
        action.setCallback(this, function(response) {
            console.log('entered callback function');
            if (response.getState() === "SUCCESS") {
                console.log(response.getReturnValue()  === "");
                console.log('RESPONSE###11'+response.getReturnValue());
                if(response.getReturnValue()  === "") {
                    console.log('Entered blank response12');
                    component.set("v.validMCN", true);
                } else {
                    console.log('Entered normal response');
                    component.set("v.validMCN", false);  
                    component.set("v.displayMessage",response.getReturnValue());
                } 
            } else {
                component.set("v.validMCN", false);  
                component.set("v.displayMessage",'There is an unexpected exception, please contact administrator');
                console.log('Error in validating the MCN Account');
            }
        });
        
        component.set("v.loadSpinner", false);
        $A.enqueueAction(action);
    },
    
    UnMergeAccount : function(component, event, helper) {
        console.log('entered unmergeAccount function');
        var accId = component.get("v.recordId");
        var action = component.get('c.restructureTheMCNaccount'); 
        action.setParams ({
            accountId : accId
        });
        $A.enqueueAction(action); 
        $A.get("e.force:closeQuickAction").fire();
        helper.showToast();
    }
})