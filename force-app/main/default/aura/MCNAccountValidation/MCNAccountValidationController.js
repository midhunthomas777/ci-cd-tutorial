({
	invoke : function(component, event, helper) {
        let eventArgs = event.getParam("arguments")
		let cancelToken = eventArgs.cancelToken
        return new Promise((resolve, reject) => {
			helper.validateMCNAccount(component, resolve, reject)
			cancelToken.promise.then(function(error) {
				reject("The creation request took longer than the allotted time.");
			});
		});
	}
})