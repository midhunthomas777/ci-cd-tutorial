({
	convertLeadWithAccount : function(component, event, resolve, reject) {
		let recordId = component.get("v.recordId")
		let action = component.get("c.convertLeadWithAccount")

		// Note: Keep in mind that the typeof null is 'object'.
		if (typeof recordId === 'undefined' || recordId === null){
			reject('An error occurred while attempting to convert a lead. No lead ID was provided.')
			return;
		}

		action.setParams({
			leadId: recordId,
            oppRecordTypeId : component.get("v.recordTypeId"),
            oppSalesProcess : component.get("v.salesProcess")
		});
		
		action.setCallback(this, function(response){
            let state = response.getState()
            let responseValue = response.getReturnValue();
            console.log('state==>'+state);
            switch(state){
				case "SUCCESS":
                    //Commented by Satish
					/*component.set('v.result', responseValue);
					resolve();
					break*/
					//Code added by Satish
					console.log('The conversion result was:');					
					try{
						var dataWrapper = responseValue;
                        //alert('v.responseIsSuccess'+dataWrapper.isSuccess);
                        //alert('v.convertedAccountId'+ dataWrapper.accountId);
                        //alert('v.convertedOpportunityId'+ dataWrapper.opportunityId);
                        //alert('v.convertedContactId'+ dataWrapper.contactId);
						//component.set('v.responseIsSuccess', true);//Modified for AccountLead
						//let responseMessage = (dataWrapper.isSuccess)? dataWrapper.successMsg : dataWrapper.errorMsg ; 
                        //alert('v.responseMessage'+responseMessage);
                        component.set('v.responseMessage', dataWrapper.errorMsg);
						component.set('v.convertedAccountId', dataWrapper.accountId);
						component.set('v.convertedOpportunityId', dataWrapper.opportunityId);
                        component.set('v.convertedContactId', dataWrapper.contactId);
                        console.log('responseMessage==>'+component.get("v.responseMessage"));
                        console.log('responseIsSuccess==>' + component.get("v.responseIsSuccess"));
                        //Modified for ConvertwithAccount LeadError
                        if(!$A.util.isUndefinedOrNull(component.get("v.responseMessage")) && !$A.util.isEmpty(component.get("v.responseMessage"))){
                            var errorMsg = 'An error occurred processing the results of the conversion.'
                            component.set('v.responseMessage', errorMsg);
                            component.set('v.responseIsSuccess', false);
                            console.log('Error responseIsSuccess==>' + component.get("v.responseIsSuccess"));
                            //reject(errorMsg)
                        }else{
                            component.set('v.responseIsSuccess', true);
                            console.log('Success responseIsSuccess==>' + component.get("v.responseIsSuccess"));                           
                        }
                        resolve();
						
					}catch(e){
						component.set('v.responseIsSuccess', false);
						var errorMsg = 'An error occurred processing the results of the conversion.'
						component.set('v.responseMessage', errorMsg);
						console.log(e);
						reject(errorMsg)
					}
					break
				case "ERROR":
					component.set('v.result', 'error state');
					reject("An error occurred while attempting to convert the Lead.")
					break
				case "INCOMPLETE":
					component.set('v.result', 'incomplete state');
					reject("The conversion process did not complete.")        
					break
				default: 
					component.set('v.result', 'unexpected result');
					reject(`Calling the server resulted in the unexpected state: ${state}`)        
					break
			}
		});

		$A.enqueueAction(action);
	}
})