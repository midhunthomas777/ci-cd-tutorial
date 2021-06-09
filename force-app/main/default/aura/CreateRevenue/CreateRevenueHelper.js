({
    fetchOLIDetails: function(component,helper,event) {
        var action = component.get('c.getOLIDetails');
        action.setParams({
            "recordId" : component.get("v.recordId")
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            var resp = response.getReturnValue();
            if(state === 'SUCCESS'){
                component.set("v.oppCloseDate",resp[0].Opportunity.CloseDate);
                component.set("v.oppCurrency",resp[0].Opportunity.CurrencyIsoCode);
                component.set("v.oppRecordType",resp[0].Opportunity.RecordType.DeveloperName);
                component.set("v.oliUnitPrice",resp[0].UnitPrice); //SF-2176
                component.set("v.showRevenueList",true);
                this.getRevenueMonths(component, event, helper);
            }
        });
        $A.enqueueAction(action);
    },
    createObjectData: function(component,event,helper) {
        var oppFiscalMonth = component.get("v.oppFiscalMonth");
        var closeDate = component.get("v.oppCloseDate");
        var closeDateYear = new Date(closeDate).getFullYear();
        var oliUnitPrice = component.get("v.oliUnitPrice");
        var RowItemList = component.get("v.RevenueList");
        RowItemList.push({
            'sobjectType': 'Revenue__c',
            'Revenue_Month__c': '',
            'Revenue_Year__c': '',
            'Revenue_Amount__c': ''
        });
       // set the updated list to attribute (RevenueList) again    
        component.set("v.RevenueList", RowItemList);
        component.set("v.loadSpinner", false);
        
    },
    insertRevenue: function(component,helper,event) {  
        component.set("v.loadSpinner", true);
        var recId = component.get("v.recordId");
        var oppId = component.get("v.oppId"); //added by akhil
        var allRevenues= JSON.stringify(component.get("v.RevenueList"));
        console.log('allRevenues*****'+allRevenues);
        var action = component.get("c.insertRevenues"); 
        var userTheme = component.get("v.userTheme"); //added by akhil
        action.setParams({
            "oppLineItemId": recId,
            "jsonRevenue" : allRevenues
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            component.set("v.loadSpinner", false);
            console.log('State is '+state);
            if (state === "SUCCESS") {
                if( response.getReturnValue() === 'Success' ){
                    //component.set("v.revenueDelta",true);
                    this.updateLineItem(component,helper); //SF-2079
                    component.set("v.createRevenue",false);
                    component.set("v.showRevenueList",false);
                    component.set("v.showRevenueList",true);
                    component.set("v.showCreateBtn",true);
                    component.set("v.showSaveBtn",false)
                    component.set("v.RevenueList",null);
                    var RowItemList = [];
                    RowItemList.push({
                        'sobjectType': 'Revenue__c',
                        'Revenue_Month__c': '',
                        'Revenue_Year__c': '',
                        'Revenue_Amount__c': '',
                    });
                    component.set("v.RevenueList",RowItemList);
                    
                } else{
                    console.log('error occured');
                }
            }else{
                console.log('server error occured');
            }
        });
        $A.enqueueAction(action); 
    },
    revenueYears : function(component,helper,event) {
        var action=component.get('c.getrevenueYears');
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === 'SUCCESS'){
                component.set("v.revenueYears",response.getReturnValue());
                console.log('revenueyear'+response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
    },
    getRevenueMonths : function(component,helper,event) {
        var oppCloseDate = component.get("v.oppCloseDate");
        var dateMonth = new Date(oppCloseDate).getMonth();
        var action = component.get('c.getRevenuesmonth');
        action.setCallback(this, function(response){
            var state = response.getState();
            var resp = response.getReturnValue();
            if(state === 'SUCCESS'){
                component.set("v.revenueMonths",resp);
            }
        });
        $A.enqueueAction(action);
    },
    getUpdateOppDetails :function(component,helper,event) {
        var action = component.get('c.getOpportunityDetails');
        action.setParams({
            "recordId": component.get('v.recordId')
        });  
        action.setCallback(this, function(response){
            var state = response.getState();
            var resp = response.getReturnValue();
            if(state === 'SUCCESS'){
                component.set("v.oppCloseDate",resp[0].Opportunity.CloseDate);
                component.set("v.oppFiscalMonth",resp[0].Opportunity.Fiscal_Month__c);
                component.set("v.oliUnitPrice",resp[0].UnitPrice);
                component.set("v.createRevenue",true);
                component.set("v.showSaveBtn",true);
                component.set("v.showCreateBtn",false);
            }
        });
        $A.enqueueAction(action);
    },
    
    updateLineItem  : function(component, helper) {
        var action = component.get('c.getAllRevenuesPerOppo');
        action.setParams({
            'oppoId': component.get("v.oppId")
        });        
        action.setCallback(this, function(response) { 
            var state = response.getState();
            if(state=='SUCCESS'){ 
                var storeResponse = response.getReturnValue();
                //SF-2243
                var finalResult = storeResponse;
                for (var i = 0; i < finalResult.length; i++) {
                    if(finalResult[i].Revenue_Delta_New__c > 0){
                            finalResult[i].Revenue_Delta_New__c = '+' + finalResult[i].Revenue_Delta_New__c
                    }
                }
                component.set('v.oppoLineItems', finalResult);
                component.set("v.revenueDelta",true);
            }
        });
        $A.enqueueAction(action);
    },
    OLIDetails: function(component,helper,event) {
        //SF-2176
        var action = component.get('c.getOLIDetails');
        action.setParams({
            "recordId" : component.get("v.recordId")
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            var resp = response.getReturnValue();
            if(state === 'SUCCESS'){
                var oldRevYears = component.get("v.lstExistingRevYears"); 
                //console.log('getExistingRevenueYear'+JSON.stringify(oldRevYears));
                var oppCloseDate = resp[0].Opportunity.CloseDate;
                var closeDateYear = new Date(oppCloseDate).getFullYear().toString();
                if(!$A.util.isUndefinedOrNull(oldRevYears) && !$A.util.isEmpty(oldRevYears) && oldRevYears.includes(closeDateYear)){
                        this.createObjectData(component, event, helper);
                }else{
                    component.set("v.oppCloseDate",resp[0].Opportunity.CloseDate);
                    component.set("v.oppCurrency",resp[0].Opportunity.CurrencyIsoCode);
                    component.set("v.oppRecordType",resp[0].Opportunity.RecordType.DeveloperName);
                    component.set("v.oliUnitPrice",resp[0].UnitPrice);
                    component.set("v.showRevenueList",true);
                    // this.getRevenueMonths(component, event, helper);
                    var oppFiscalMonth = component.get("v.oppFiscalMonth");
                    //alert('oppFiscalMonth'+oppFiscalMonth);
                    var closeDate = component.get("v.oppCloseDate");
                    var closeDateYear = new Date(closeDate).getFullYear();
                    var oliUnitPrice = component.get("v.oliUnitPrice");
                    var RowItemList = component.get("v.RevenueList");
                    RowItemList.push({
                        'sobjectType': 'Revenue__c',
                        'Revenue_Month__c': oppFiscalMonth,
                        'Revenue_Year__c': closeDateYear,
                        'Revenue_Amount__c': oliUnitPrice,
                    });
                    // set the updated list to attribute (RevenueList) again    
                    component.set("v.RevenueList", RowItemList);
                }
                
            }
        });
        $A.enqueueAction(action);
    },
    
    getRevenueYears  : function(component, event, helper) {
        var action = component.get('c.getExistingRevenueYears');
        action.setParams({
            'recordId': component.get("v.recordId")
        });        
        action.setCallback(this, function(response) { 
            var state = response.getState();
            if(state=='SUCCESS'){ 
                var storeResponse = response.getReturnValue();
                component.set('v.lstExistingRevYears',storeResponse);
                helper.OLIDetails(component, event, helper);
                //console.log('getExistingRevenueYear'+JSON.stringify(storeResponse));
            }
        });
        $A.enqueueAction(action);
    },
    
})