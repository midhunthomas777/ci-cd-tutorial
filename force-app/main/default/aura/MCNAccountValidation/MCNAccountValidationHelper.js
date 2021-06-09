({
	validateMCNAccount : function(component, resolve, reject) {
		let action = component.get("c.findAccountByLeadCustNo");
        action.setParams({
            'leadId' : component.get("v.leadrecordId")
        });
        action.setCallback(this, function(response){
			var state = response.getState();
            var responseValue = response.getReturnValue();
			let errorMsg = '';	
			switch(state){
				case "SUCCESS":
						component.set('v.responseMessage',responseValue);
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
			resolve();
		});
		$A.enqueueAction(action);
	}
})