({
    doInit : function(component, event, helper){
        var action=component.get('c.isPartnerUser');
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === 'SUCCESS'){
                component.set("v.isInternalUser",response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
    },
    validateStatePicklist : function(component, event, helper) {
        if(component.get("v.BillingCountrySelected") != '--None--'){
            helper.fetchStatePicklistValuesHelper(component,event,helper); 
            component.set("v.BillingStateSelected",'--None--');
        }
        else if(component.get("v.BillingCountrySelected") == '--None--')
        {
            component.set("v.BillingState",null);
            component.set("v.BillingStateSelected",'--None--');
            component.set("v.BillingStateDisabled",true);  
        }
    },
    SearchMCN :function(component, event, helper) {
        component.set("v.MCNList",[]);
        if(helper.validateSearchAccount(component, event, helper))
        {
             component.set("v.Showmnc",false);
            console.log('MCN list is *****'+component.get("v.MCNList"));
            helper.SearchMCNAccountsHelper(component,event,helper);  
        }

        let tealiumTrigger = component.find('tealium-trigger').getElement();
        tealiumTrigger.ANALITYCS.MR_COMMISSION_CALC.SEARCH();
    },
    closeAlertBox : function(component, event, helper){
        var appClose = component.find("Validation");
        appClose.close();
    },
    openConsolidatedBuy : function(component, event, helper){       
        //For reloading Consolidated Buy component
        component.set("v.showCB", true);
        var childCompId = component.find("mrCalcCB");    
    },
    close:function(component, event, helper){
        component.set("v.showCB", false); 
    }
})