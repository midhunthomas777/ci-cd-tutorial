({
    getAccountDetail : function(component,helper) {
        component.set("v.calculatorRecordProcessing",true);
        var action = component.get("c.fetchAccountDetails"); 
        var motoNum = component.get("v.motorolaCustomerNumber");
        var accId= component.get("v.accountId");
        var partnerId= component.get("v.partnerId");
        console.log('#######motoNum##########');
        console.log(motoNum);
        console.log('#######accId##########');
        console.log(accId);
        console.log('partnerId#########' + partnerId);
       
        
        action.setParams({
            motoNum : motoNum,
            accId : accId,
            partnerAccountID :partnerId
        });
        action.setCallback(this, function(actionResult) {
            var state = actionResult.getState();
            console.log('state is'+state);
            if( state === "SUCCESS"){
                component.set('v.detailWrap', actionResult.getReturnValue());
                component.set("v.calculatorRecordProcessing",false);
            } 
            else{
                component.set("v.calculatorRecordProcessing",false);
            }
        });
        $A.enqueueAction(action);
        
    }
})