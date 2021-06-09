({
	//Returns a promise to close the active tab.
	closeActiveTab: function (component) {
		let workspaceAPI = component.find("workspace");
		return new Promise((resolve, reject) => {
			workspaceAPI.getFocusedTabInfo().then(function (response) {
				let focusedTabId = response.tabId;
				workspaceAPI.closeTab({
					tabId: focusedTabId
				}).then(() => resolve() );
			});
		});
	},
	setupLaunchTab: function(component){
		let workspaceAPI = component.find("workspace");
		return new Promise((resolve, reject) => {
			workspaceAPI.getEnclosingTabId().then(function (response) {
				let focusedTabId = response.tabId;
				console.log(`got focused tab: ${focusedTabId}`)
				workspaceAPI.setTabLabel({
					tabId: focusedTabId,
					label: "Convert Lead"
				}).then((response) => {
					workspaceAPI.setTabIcon({
						tabId: focusedTabId,
						icon: "standard:timesheet",
						iconAlt: "Focused Tab"
					}).then(() => {
						resolve()
					});
				});
			});
		});
	},
	//Returns a promise to open the tab.
	openTab: function(component, recordId){
		let workspaceAPI = component.find("workspace");
		return new Promise((resolve, reject) =>{
			workspaceAPI.openTab({
				pageReference: {
					type: "standard__recordPage",
					attributes: {
						recordId: recordId,
						actionName:"view"
					},
					state: {}
				},
				focus: true
			}).then( () => resolve() );
		});
	},
	//TODO: Remove this function and related attribute.
	navigateToOpportunity: function (component, opportunityId) {
		let navService = component.find("navService");
		var pageReference = {
			type: 'standard__recordPage',
			attributes: {
				objectApiName: 'Opportunity',
				recordId: opportunityId,
				actionName: 'view'
			}
		};
		navService.navigate(pageReference);
	},
	findFlowOutput: function (flowOutputs, outputName) {
		return flowOutputs.find((element) => {
			return element.name === outputName
		});
	}
})