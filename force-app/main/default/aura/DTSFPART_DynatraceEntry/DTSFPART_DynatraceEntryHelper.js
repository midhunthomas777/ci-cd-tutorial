({
	getUserData: function(component) {
		const action = component.get("c.getUserInfo");
		action.setCallback(this, function(response) {
			let state = response.getState();
			if (state === 'SUCCESS'){
				let user = response.getReturnValue();

				component.set("v.currentUser", user);
				this.identifyUser(user);
			} else {
				console.error('Cannot get user data!');
			}
		});
		$A.enqueueAction(action);
	},

	identifyUser: function(user) {
		const coreId = user.Core_ID__c;
		const userName = user.Username;

		if (!this.isDynatraceLoaded()) {
			return;
		}

		if (coreId || userName) {
			const identifier = coreId ? coreId : userName;
			dtrum.identifyUser(identifier);
			console.log("Dynatrace agent started for: " + identifier);
		} else {
			console.log("Dynatrace agent started");
		}
	},

	isDynatraceLoaded: function() {
		if (typeof dtrum === "undefined") {
			console.error('Dynatrace not loaded.');
			return false;
		}
		return true;
	},

	// Dynatrace Methods

	handleDynatraceEvent: function(component, event) {
		if (!this.isDynatraceLoaded()) { 
        	return; 
    	}

		let eventParams = event.getParams();

		switch (eventParams.type) {
			case 'error':
				this.reportErrorToDynatrace(eventParams.data);
				break;
			default: 
				break;
		}	
	},

	reportErrorToDynatrace: function(eventData) {
		try {
		    dtrum.reportCustomError(
				eventData.errorName, 
				eventData.errorMessage, 
				eventData.errorDetails,
				true
			);
		} catch (error) {
			console.error(error);
		}
	},
});