({
   showButton : function(component) {
        var action = component.get("c.showReviewButton");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log(response.getReturnValue());               
                if(response.getReturnValue() == true){
                    component.set("v.showTCButton",true);
                }
            }
        });
        $A.enqueueAction(action); 
    },
    getTermsConditions : function(component) {
        var action = component.get("c.fetchTermsCondition");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var metaData = response.getReturnValue();
                component.set("v.termsCondition", metaData[0].Long_Text_Area__c);
                component.set("v.tcLabel", metaData[0].Values__c);
            }
        });
        $A.enqueueAction(action); 
    },
    
    openPopup : function(component) { 
        var action = component.get("c.showReviewButton");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.openPopup", true); 
            }
        });
        $A.enqueueAction(action);
    },
    
    updateContact : function(component) { 
        var action = component.get("c.termsAccepted");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.openPopup", false); 
                window.location.reload();
            }
        });
        $A.enqueueAction(action); 
    }
})