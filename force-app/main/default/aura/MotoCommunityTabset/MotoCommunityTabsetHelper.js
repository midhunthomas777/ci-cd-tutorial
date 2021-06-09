({
    getDynamicTabs : function(component,helper) {
        component.set("v.showSpinner", true);
        var currentAccountId  = component.get('v.recordId');
        if ( typeof currentAccountId == "undefined" ) {
            currentAccountId = null;
        }
        console.log(currentAccountId);
        var action = component.get('c.getTabsMetadata'); 
        action.setParams({
            'currentRecId': currentAccountId
        }); 
        action.setCallback(this, function(response) { 
            var state = response.getState();
            if(state == 'SUCCESS'){ 
                var storeResponse = response.getReturnValue();
                component.set('v.tabsMeta', storeResponse);
            }
            component.set("v.showSpinner", false);
        });
        $A.enqueueAction(action);
    },
    handleActive: function (cmp, event) {
        var tab = event.getSource();
        switch (tab.get('v.id')) {
            case 'Orders' :
                this.injectComponent('c:ExternalOrdersAuraComponent', cmp, tab);
                break;
            case 'Cases' :
                this.injectComponent('c:ExternalCasesComponent', cmp, tab);
                break;
            //case 'Repair':
                //this.injectComponent('lightningcomponentdemo:exampleIcon', cmp, tab);
                //break;
            case 'Contracts':
                this.injectComponent('c:ExternalContractsComponent',cmp, tab);
                break;
            //case 'Parts & Pricing':
                //this.injectComponent('c:VestaPartsAndPricing',cmp,  tab);
                //break;
        }
    },
    injectComponent: function (name, cmp, target) {
        var attributes = {
            "recordId": cmp.get("v.recordId")
        }
        $A.createComponent(name, attributes, function (contentComponent, status, error) {
            if (status === "SUCCESS") {
                target.set('v.body', contentComponent);
            } else {
                throw new Error(error);
            }
        });
    }
})