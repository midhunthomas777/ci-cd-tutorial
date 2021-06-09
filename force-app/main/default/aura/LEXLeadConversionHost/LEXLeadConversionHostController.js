({
	init: function (component, event, helper) {
		let flow = component.find("lead_conversion_flow")
		let pageRef = component.get("v.pageReference");
		let leadId = pageRef.state.c__leadId
		component.set('v.leadId', leadId);
		
		helper.setupLaunchTab(component);
		let flowInputs = [{
			name: 'recordId',
			type: 'String',
			value: leadId
		}];
		flow.startFlow("Inside_Sales_Lead_Conversion", flowInputs)
	},
	flowStatusChange: function (component, event, helper) {
		let status = event.getParam('status')
		let flowOutputs = event.getParam('outputVariables')
		/*
		If the service responds with NO MCN, then it failed. Otherwise it should respond 
		with the Opportunity ID.

		Use Cases:
		- Route to Opportunity
		
		- Route to Account
			- {!attach_and_convert_is_successful}

		Solution: Create a route type.
			- route_on_finished_type: opportunity | account
		*/
		if (status === "FINISHED") {
			console.log('Flow Outputs')
			console.log(flowOutputs);
			let routeToType = helper.findFlowOutput(flowOutputs, 'route_on_finished_type')
			let accountId = helper.findFlowOutput(flowOutputs, 'attach_and_create_converted_account_id')
			let opportunityId = helper.findFlowOutput(flowOutputs, 'attach_and_created_converted_opp_id')
			
			if (typeof routeToType === 'undefined' || routeToType ===null){
				console.log('Error: The route_on_finished_type output was not set on the flow.')
				return;
			}
			let routeId;
			//TODO: Extract to helper function.
			switch(routeToType.value){
				case 'opportunity':
					routeId = opportunityId.value 
					break;
				case 'account':
					routeId = accountId.value
					break;
				default:
					console.log('LEXLeadConversionHostHelper Error: Unknown route type.'); 
			}
			
			/*
			Need to:
			1. Close the Lead we converted tab.
			2. Close the Wizard tab we're on.
			3. Open the target tab.
			*/
			let workspaceAPI = component.find("workspace");
			//close the wizard tab.
			workspaceAPI.getEnclosingTabId().then((response)=>{
				console.log(`The enclosing Tag:`)
				console.log(response);
				workspaceAPI.closeTab({
					tabId: response.tabId
				});
			});

			//Close the Lead tab.
			//Format of tab object: https://developer.salesforce.com/docs/atlas.en-us.api_console.meta/api_console/sforce_api_console_lightning_getAllTabInfo.htm
			let leadId = component.get('v.leadId');	
			workspaceAPI.getAllTabInfo().then((response) => {
				console.log(`Get All Tab Info:`)
				console.log(response);
				response.forEach((tab) => {
					if (tab.recordId === leadId){
						workspaceAPI.closeTab({
							tabId: tab.tabId
						})
					}
				});
			});

			//Open the targeted record page (Account or Opportunity)
			console.log(`Attempt to open tab for: ${routeId}`)
			helper.openTab(component, routeId);
		}
	},
	loadUrlParams: function(component, event, helper){
		let pageRef = component.get("v.pageReference");
		let leadId = pageRef.state.c__leadId
		component.set('v.leadId', leadId);
	}
})