({
    doInit : function(component, event, helper) {
        var oppLineItemId =component.get("v.recordId");
        var oppCurrency = component.get("v.oppCurrency");
        var reln= 'Product_Family__c = '+'\''+oppLineItemId+'\'';
        var andFilter =[];
        var orFilter = [];
        andFilter.push(reln);
        component.set('v.andFilters',andFilter);
        if(oppCurrency === 'USD') {
            component.set('v.columns', [
                {label:'REVENUE NAME', fieldName: 'Revenue_Url__c', type: 'url', typeAttributes: {label: { fieldName: 'Name' }, target: '_self'},
                 cellAttributes: { class: 'editableBack'  }},
                {label:'REVENUE YEAR', fieldName: 'Revenue_Year__c',editable:'true', type: 'text'},
               // {label:'REVENUE MONTH', fieldName: 'Revenue_Month__c',editable:'true', type: 'text'},
                {label:'REVENUE MONTH NUMBER', fieldName: 'Revenue_Month_Number__c',type: 'number',editable:'true'},
                {label:'REVENUE MONTH', fieldName: 'Revenue_Month__c', type: 'text',cellAttributes: { class: 'editableBack'  }},
                {label:'REVENUE AMOUNT('+oppCurrency+')', fieldName: 'Revenue_Amount__c',editable:'true', type: 'currency',
                 typeAttributes: { currencyCode: oppCurrency }}                
            ]); 
        } else {
            component.set('v.columns', [
                {label:'REVENUE NAME', fieldName: 'Revenue_Url__c', type: 'url', 
                 typeAttributes: {label: { fieldName: 'Name' }, target: '_self'}, cellAttributes: { class: 'editableBack'  }},
                {label:'REVENUE YEAR', fieldName: 'Revenue_Year__c',editable:'true', type: 'text'},
               // {label:'REVENUE MONTH', fieldName: 'Revenue_Month__c',editable:'true', type: 'text'},
                {label:'REVENUE MONTH NUMBER', fieldName: 'Revenue_Month_Number__c',editable:'true', type: 'number'},
                {label:'REVENUE MONTH', fieldName: 'Revenue_Month__c', type: 'text',cellAttributes: { class: 'editableBack'  }},
                {label:'REVENUE AMOUNT('+oppCurrency+')', fieldName: 'Revenue_Amount__c',editable:'true', type: 'currency',
                 typeAttributes: { currencyCode: oppCurrency }},
                {label:'REVENUE ACTUAL RATE(USD)', fieldName: 'Revenue_Amount_in_USD_P_L_Rate__c', type: 'currency', cellAttributes: { class: 'editableBack'  }},
                {label:'REVENUE PLAN RATE(USD)', fieldName: 'Revenue_Plan_Rate_USD_Amount__c',type: 'currency', cellAttributes: { class: 'editableBack'  }}
            ]);   
        }
        component.set("v.loadSpinner",false);
    },
    getselectedRecId :function(component, event, helper) {
        //SF-2078
        var revenueError = $A.get("$Label.c.Revenue_date_cannot_be_prior_to_Opportunity_Close_Date");
        var inlineErrorMsg = event.getParam("errorMsg");
        if(!$A.util.isUndefinedOrNull(inlineErrorMsg) && !$A.util.isEmpty(inlineErrorMsg)){
            if(inlineErrorMsg.includes('Revenue can not be entered before the fiscal period of the Close Date')){
                //component.set("v.errorMsg",'Revenue can not be entered before the fiscal period of the Close Date');
                component.set("v.errorMsg",revenueError);
            }
        }
        if($A.util.isUndefinedOrNull(inlineErrorMsg) || $A.util.isEmpty(inlineErrorMsg)){
            var serverCloseDate = component.get("v.oppCloseDateServer");
            if($A.util.isUndefinedOrNull(serverCloseDate) || $A.util.isEmpty(serverCloseDate)){
                helper.getUpdateOppDetails(component, event, helper);
            }
            else{
                helper.cellValidations(component, event, helper);
            }
        }
    }
})