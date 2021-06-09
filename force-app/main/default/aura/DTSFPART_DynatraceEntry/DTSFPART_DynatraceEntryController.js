/**
 * Created by WGVR43 on 23.09.2020.
 */

 ({
	doInit : function(component, event, helper) {
		component.set('v._dynatraceUrl', component.get('v.dynatraceUrl') ? component.get('v.dynatraceUrl') : $A.get('$Label.c.DynatraceEntryURL'));
	},

	handleDynatraceEvent: function(component, event, helper) {
		helper.handleDynatraceEvent(component, event);
	},

	dynatraceScriptLoaded: function(component, event, helper) {
		helper.getUserData(component);
	}
});

// $Label.c.DynatraceEntryURL