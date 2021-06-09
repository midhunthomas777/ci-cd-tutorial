({
	/**
	 * Invokes the Lead Conversion process.
	 * Designed to be called from a Lightning Flow.
	 * 
	 * @param {LightingComponent} component 
	 * @param {Event} event - The event that trigger this function. Contains the parameters needed.
	 * @param {Class} helper
	*/
	invoke : function(component, event, helper) {
        console.log('Inside Lead Conversion Initiation####'+component.get("v.recordId"));
		let eventArgs = event.getParam("arguments")
		let cancelToken = eventArgs.cancelToken	

		return new Promise((resolve, reject) => {
			helper.convertLeadWithAccount(component, event, resolve, reject)

			cancelToken.promise.then(function(error) {
				reject("The conversion request took longer than the allotted time.");
			});
		});
	}
})