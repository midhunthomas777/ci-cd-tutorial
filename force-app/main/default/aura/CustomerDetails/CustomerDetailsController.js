({
    getcustomerDetails : function(component,event,helper) {
        var args = event.getParam("arguments");
        var customerNumber = args.customNum;
        var requestType = args.requestType;
        component.set("v.customNumber",customerNumber);
        component.set("v.requestType",requestType);
        
    },
    
    createTracking : function(component,event,helper) {
        var isvalidated = helper.validate(component,event,helper);
        if(isvalidated){
            
            component.set("v.loadSpinner", true);
            var requestType    = component.get("v.requestType");
            var customerNum    = component.get("v.customNumber");
            var requesterEmail = component.get("v.userEmail");
            var coreId     	   = component.get("v.userCoreId");
            var isCallByBtn    = component.get("v.isButtonVisible");
            if(typeof requesterEmail == 'undefined' && typeof coreId == 'undefined'){
                requesterEmail 	= component.find("reqEmailId").get("v.value");
                coreId 			= component.find("reqCoreId").get("v.value");
            }
            var action = component.get("c.handleInvoiceRecords");
            action.setParams({
                "customerNum" 	 : customerNum,
                "requesterEmail" : requesterEmail,
                "requestType" 	 : requestType,
                "coreId"		 : coreId
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                var message = '';
                var type = 'Error';
                if(state === 'SUCCESS' && response.getReturnValue() == 'INVOICECREATED'){
                    console.log(response.getReturnValue());
            		message = 'This customer is not ready for opt-in. This customer would be identified for potential flip to Print';
                    type = 'Success';
                } else if(response.getReturnValue() == 'ERROR') {
                    console.log(response.getReturnValue());
                    message = response.getReturnValue();
                } else {
                    console.log(response.getReturnValue());
                    message = response.getReturnValue();
                }
                
                if(isCallByBtn){
                    var delayInMilliseconds = 5000;
                    var theme = component.get("v.userTheme");
                    var isCommunity = component.get("v.isCommunity");
                    if(isCommunity){
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title"  : type+"!",
                            "type"   : type,
                            "message": message
                        });
                        toastEvent.fire();
                    }else{
                        if(theme == 'Theme4d'){
                            sforce.one.showToast({
                                "title"  : type+"!",
                                "type"   : type,
                                "message": message
                            });
                        }else{
                            if(type == 'Error' || type == 'error')
                                component.set("v.errorMsg", message);
                            else if(type == 'Success' || type == 'success')
                                component.set("v.successMsg", message);
                        }
                    }
                    component.set("v.loadSpinner", false);
                    window.setTimeout(
                        $A.getCallback(function() {
                            window.location.reload();
                        }), delayInMilliseconds
                    );
                }
                
            });
            $A.enqueueAction(action);
        }
    },
    
})