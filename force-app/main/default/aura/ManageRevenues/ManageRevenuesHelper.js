({
    getProducts : function(component, event, helper) {
        var action = component.get('c.getProductFamilies');
        action.setParams({
            "runRateId" : component.get('v.recordId')
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === 'SUCCESS' && component.isValid()){
                var resp= response.getReturnValue();
                component.set("v.lstproductFamily", resp);
            }
        });
        $A.enqueueAction(action);
    },
    getRunRateRevenueDetails : function(component, event, helper) {
        var action = component.get('c.getRunRateRevenue');
        action.setParams({
            "runRateId" : component.get('v.recordId')
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === 'SUCCESS' && component.isValid()){
                var resp = response.getReturnValue();
                var rrCurrency = resp.CurrencyIsoCode;
                component.set('v.currencyCode',rrCurrency);
                component.set('v.revenueEnabled',resp.Revenue_Enabled__c);
                if(resp.Revenue_Enabled__c === true && rrCurrency === 'USD'){
                    component.set('v.columns', [
                        {label: 'Opportunity Name', fieldName: 'Opportunity_Url__c', type: 'url',typeAttributes: {label: { fieldName: 'Opportunity_Name__c' },target: '_self'},
                         cellAttributes:{class: 'editableBack'}},
                        {label: 'Product Family', fieldName: 'Product_Family_Name__c', type: 'text', cellAttributes:{class: 'editableBack'}},
                        {label: 'Price (Order)', fieldName: 'UnitPrice',editable:'true',type: 'currency',typeAttributes:{currencyCode:rrCurrency}},
                        {label: 'Revenue', fieldName: 'Run_Rate_Revenue_Amount__c',editable:'true', type: 'currency',typeAttributes:{currencyCode:rrCurrency}}
                    ]);
                } else if(resp.Revenue_Enabled__c === false && rrCurrency === 'USD'){
                    component.set('v.columns', [
                        {label: 'Opportunity Name', fieldName: 'Opportunity_Url__c', type: 'url', 
                         typeAttributes: {label: { fieldName: 'Opportunity_Name__c' }, target: '_self'}, cellAttributes:{class: 'editableBack'}},
                        {label: 'Product Family', fieldName: 'Product_Family_Name__c', type: 'text', cellAttributes:{class: 'editableBack'}},
                        {label: 'Price (Order)', fieldName: 'UnitPrice',editable:'true',type: 'currency',
                         typeAttributes: { currencyCode: rrCurrency}}
                    ]);
                } else if(resp.Revenue_Enabled__c === false && rrCurrency != 'USD'){
                    component.set('v.columns', [
                        {label: 'Opportunity Name', fieldName: 'Opportunity_Url__c', type: 'url',
                         typeAttributes: {label: { fieldName: 'Opportunity_Name__c' }, target: '_self'}, cellAttributes:{class: 'editableBack'}},
                        {label: 'Product Family', fieldName: 'Product_Family_Name__c', type: 'text', cellAttributes:{class: 'editableBack'}},
                        {label: 'Price (Order)', fieldName: 'UnitPrice',editable:'true',type: 'currency',typeAttributes: { currencyCode: rrCurrency}},
                        {label: 'Price Actual Rate (USD)', fieldName: 'Total_Price_in_USD_P_L_Rate__c', type: 'currency', cellAttributes:{class: 'editableBack'}},
                        {label: 'Price Plan Rate (USD)', fieldName: 'Sales_Price_in_USD_Plan_Rate__c', type: 'currency', cellAttributes:{class: 'editableBack'}}
                    ]);
                } else {
                    component.set('v.columns', [
                        {label: 'Opportunity Name', fieldName: 'Opportunity_Url__c', type: 'url', typeAttributes: {label: { fieldName: 'Opportunity_Name__c' }, target: '_self'}, cellAttributes:{class: 'editableBack'}},
                        {label: 'Product Family', fieldName: 'Product_Family_Name__c', type: 'text', cellAttributes:{class: 'editableBack'}},
                        {label: 'Price (Order)', fieldName: 'UnitPrice',editable:'true',type: 'currency',
                         typeAttributes:{currencyCode:rrCurrency}},
                        {label: 'Revenue', fieldName: 'Run_Rate_Revenue_Amount__c',editable:'true', type: 'currency',
                         typeAttributes:{currencyCode:rrCurrency}},
                        {label: 'Price Actual Rate (USD)', fieldName: 'Total_Price_in_USD_P_L_Rate__c', type: 'currency', cellAttributes:{class: 'editableBack'}},
                        {label: 'Price Plan Rate (USD)', fieldName: 'Sales_Price_in_USD_Plan_Rate__c', type: 'currency', cellAttributes:{class: 'editableBack'}},
                        {label: 'Revenue Actual Rate (USD)', fieldName: 'Run_Rate_Revenue_Amount_in_USD_P_L_Rate__c', type: 'currency', cellAttributes:{class: 'editableBack'}},
                        {label: 'Revenue Plan Rate (USD)', fieldName: 'Run_Rate_Revenue_Amount_in_USD_Plan_Rate__c', type: 'currency', cellAttributes:{class: 'editableBack'}} 
                    ]);
                }
            }
        });
        $A.enqueueAction(action);
    },
    getProgressBarTracking : function(component, event, helper) {
        var progress = component.get('v.progress');
        var action = component.get('c.getProgress');
        var isBatchCompleted = false; 
        action.setParams({
            "runRateId" : component.get('v.recordId')
        });      
        component._interval = setInterval($A.getCallback(function () {
            if(!isBatchCompleted){
                //console.log('isBatchCompleted');
                action.setCallback(this, function(response){
                    var state = response.getState();
                    if(state === 'SUCCESS' && component.isValid()){
                        //console.log('valid comp');
                        var resp = response.getReturnValue();
                        var batchStatus = resp.Status;
                        //console.log('resp******'+JSON.stringify(resp));
                        if( batchStatus === 'Completed'){
                            isBatchCompleted = true;
                            component.set("v.hideprogressBar",false);
                            helper.navigateToSobject(component, event, helper);
                        } else {
                            // component.set("v.isProgressing",true);
                            component.set('v.progress', (resp.JobItemsProcessed/resp.TotalJobItems)*100);
                        }
                    }
                });
                $A.enqueueAction(action);
            }
        }), 10000);
        //  }
    },
    updateBatchStatus : function(component, event, helper, batchStatus) {
        //console.log('batchStatus in method'+batchStatus);
        var action = component.get('c.updateRRDBatchStatus');
        action.setParams({
            "runRateId" : component.get('v.recordId'),
            "batchStatus" : batchStatus
        }); 
        action.setCallback(this, function(response){
            var state = response.getState();
            //console.log('state in update method'+state);
            if(state === 'SUCCESS'){
                var resp = response.getReturnValue();
                this.navigateToSobject(component, event, helper);
                //console.log('resp in update method'+resp);
            }
        });
        $A.enqueueAction(action);
    },
    updateRevenue :function (component, event, helper) {
        var resList = component.get("v.resultList");
        var action = component.get('c.updateRevenueWithPrice');
        action.setParams({
            "oppLineItems" : resList
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            component.set("v.loadSpinner",false);
            if(state === 'SUCCESS'){
                var resp= response.getReturnValue();
                if(!$A.util.isUndefinedOrNull(resp)){
                    this.navigateToSobject(component, event, helper);
                }
            }
        });
        $A.enqueueAction(action);
        
    },
    navigateToSobject : function (component, event, helper) {
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": component.get('v.recordId'),
            "slideDevName": "related"
        });
        navEvt.fire();
    },
    
    
})