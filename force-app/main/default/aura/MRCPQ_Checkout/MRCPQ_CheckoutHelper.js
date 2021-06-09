({
    
    getCyberSourceVFPageURL : function(component) {
        var action = component.get("c.getPageURL");
        var quoteId = component.get("v.recordId");
        action.setParams({
            "quoteId" : quoteId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log(response.getReturnValue());
                component.set("v.getPageURL",response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
    },
    getAccess : function(component) {
        var action = component.get("c.checkoutValidations");
        var quoteId = component.get("v.recordId");
        action.setParams({
            "quoteId" : quoteId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                console.log('result is'+JSON.stringify(result));
                component.set("v.CheckoutValidation",result);
                var dismissActionPanel = $A.get("e.force:closeQuickAction"); 
                var paymentAlreadyDone = component.get("v.CheckoutValidation.paymentAlreadyDone");
                var hasCheckoutAccess = component.get("v.CheckoutValidation.hasCheckoutAccess");
                console.log('paymentAlreadyDone'+paymentAlreadyDone);
                console.log('hasCheckoutAccess'+hasCheckoutAccess);

                if(paymentAlreadyDone && paymentAlreadyDone!='undefined' && paymentAlreadyDone!=''){
                      console.log('In paymentAlreadyDone'+paymentAlreadyDone);
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title : 'Error Message',
                        message: $A.get("$Label.c.MRCPQ_Payment_Done"),
                        duration:' 30000',
                        key: 'info_alt',
                        type: 'error',
                        mode: 'dismissible'
                    });
                    toastEvent.fire(); 
                    dismissActionPanel.fire(); 

                } else if(hasCheckoutAccess!=true){
                    console.log('In hasCheckoutAccess'+hasCheckoutAccess);
                    dismissActionPanel.fire();
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title : 'Error Message',
                        message: $A.get("$Label.c.MRCPQ_Checkout_Insuffcient_Access"),
                        duration:' 30000',
                        key: 'info_alt',
                        type: 'error',
                        mode: 'dismissible'
                    });
                    toastEvent.fire(); 
                }else if(hasCheckoutAccess){
                    console.log('In hasCheckoutAccess true'+hasCheckoutAccess);
                    component.set("v.checkout",hasCheckoutAccess);
                }
            }
        });
        $A.enqueueAction(action);
    }
})