/*
 * Copyright (c) 2019. 7Summits Inc.
 */

({
	buildHeading: function(component) {
		const defaultValue = 'default';
		const align = component.get('v.align');
		const size  = component.get('v.size');
		const headingClass = (size !== defaultValue ? 'slds-text-heading_' + size : '') +  ' slds-text-align_' + align;

		component.set('v.headingClass', headingClass);
		component.set('v.tag', component.get('v.tag').substring(0,2).toLowerCase());
	},

	getHandle: function (component) {
		const recordId = component.get('v.recordId');

		if (recordId) {
			const fieldObject = component.get('v.handleObject');
			const fieldHandle = component.get('v.handleField');

			// need at least one
			if (fieldObject || fieldHandle) {
				const action = component.get('c.getUserTwitterHandle');

				action.setParams ({
					recordId    : recordId,
					objectName  : fieldObject,
					fieldName   : fieldHandle
				});

				action.setCallback(this, result => {
					if (result.getReturnValue()) {
						component.set('v.handle', result.getReturnValue());
						component.set('v.isInit', true);
					}
				});
				$A.enqueueAction(action);

				return;
			}
		}

		const handle = component.get('v.handle');

		if (!handle) {
			const handleAction = component.get('c.getGlobalTwitterHandle');
			handleAction.setCallback(this, result => {
				if (result.getReturnValue()) {
					component.set('v.handle', result.getReturnValue());
					component.set('v.isInit', true);
				}
			});
			$A.enqueueAction(handleAction);
		}

		component.set('v.isInit', true);
	},

	getSitePrefix: function(component) {
        const domainAction = component.get("c.getDomain");
		domainAction.setCallback(this, function(actionResult) {
            const domain = actionResult.getReturnValue();
            //console.log(domain);
            component.set("v.domain", domain);
        });
        $A.enqueueAction(domainAction);

        const prefixAction = component.get("c.getSitePrefix");
		prefixAction.setCallback(this, function(actionResult) {
            const path = actionResult.getReturnValue();
            const cleanPath = path.substring(0,path.lastIndexOf('/'));
            //console.log(path);
            console.log(cleanPath);
            component.set("v.sitePath", cleanPath);
        });
        $A.enqueueAction(prefixAction);
    },

    getSiteNamespace: function(component){
		const ns = component.getConcreteComponent().getType();
		const parts = ns.split(':');
		const nameSpace = parts ? parts[0] + '__' : '';
		component.set('v.nameSpace', nameSpace);
    }
});