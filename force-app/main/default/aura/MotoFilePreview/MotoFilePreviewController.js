({
	doInit : function(component, event, helper) {
		component.set("v.baseUrl", $A.get("$Site").siteUrlPrefix);

		if ( component.get("v.recordId") ) {
			$A.get('e.lightning:openFiles').fire({
				recordIds: [component.get("v.recordId")]
			});
		}
	}
})