({
    validateMCNAccount : function(component, event, helper) {
        component.set("v.showSpinner",true);
        let action = component.get("c.findAccountByLeadCustNo");
        console.log('LeadId==>'+component.get("v.leadId"));
        action.setParams({
            'leadId' : component.get("v.leadId")
        });
        action.setCallback(this, function(response){
           component.set("v.showSpinner",false);
            var state = response.getState();
            var responseValue = response.getReturnValue();
            let errorMsg = '';	
            switch(state){
                case "SUCCESS":
                    if(responseValue){
                        this.JSconvertLeadWithAccount(component, event, helper);
                        //component.set('v.responseMessage',responseValue);
                        
                    }else{
                        component.set('v.loadSBC',true);
                    }
                    break;
                case "ERROR":
                    errorMsg = 'ERROR : An error occurred processing the results of the conversion.';
                    component.set('v.responseMessage', errorMsg);
                    console.log('An error occurred while processing the request. ERROR')
                    console.log(response.getReturnValue());
                    break;
                case "INCOMPLETE":
                    errorMsg = "The conversion request did not complete.";
                    component.set('v.responseMessage', errorMsg);
                    console.log('An error occurred while processing the request. INCOMPLETE');
                    break;
                default: 
                    errorMsg = `Calling the server resulted in the unexpected state: ${state}`
                    component.set('v.responseMessage', errorMsg);
                    console.log('An error occurred while processing the request. UNKNOWN STATE');
                    break;
            }
        });
        $A.enqueueAction(action);
    },
    JSconvertLeadWithAccount : function(component, event, helper) {
        let action = component.get("c.convertLeadWithAccount")
        
        action.setParams({
            leadId: component.get("v.leadId")
        });
        
        action.setCallback(this, function(response){
            component.set("v.showSpinner",false);
            let state = response.getState()
            let responseValue = response.getReturnValue();
            switch(state){
                case "SUCCESS":
                    try{
                        var dataWrapper = responseValue;
                        //Modified for ConvertwithAccount LeadError
                        if(!$A.util.isUndefinedOrNull(dataWrapper.errorMsg) && !$A.util.isEmpty(dataWrapper.errorMsg)){
                            var errorMsg = 'An error occurred processing the results of the conversion.'
                            component.set('v.errorMsg', errorMsg);
                        }else{
                            if(!$A.util.isUndefinedOrNull(dataWrapper.accountId) || !$A.util.isEmpty(dataWrapper.accountId)){
                                window.open("/"+dataWrapper.accountId,"_self");
                            }
                        }                        
                    }catch(e){
                        var errorMsg = 'An error occurred processing the results of the conversion.'
                        component.set('v.errorMsg', errorMsg);
                    }
                    break
                    case "ERROR":
                    component.set('v.errorMsg', 'An error occurred while attempting to convert the Lead.');
                    break
                    case "INCOMPLETE":
                    component.set('v.errorMsg', 'incomplete state');
                    break
                    default: 
                    component.set('v.errorMsg', 'unexpected result');
                    break
            }
        });
        
        $A.enqueueAction(action);
    }
})