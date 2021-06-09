({
    doInit : function(component, event, helper) {
        //console.log('--doInit--');
        var action = component.get('c.getBatchStatus');
        action.setParams({
            "runRateId" : component.get('v.recordId'),
        }); 
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === 'SUCCESS'){
                var resp = response.getReturnValue();
                if(resp === 'Completed') {
                    component.set("v.hideprogressBar",false);
                } else {
                    helper.getProgressBarTracking(component, event, helper);
                }
            }
        });
        $A.enqueueAction(action);
        helper.getProducts(component, event, helper);
        helper.getRunRateRevenueDetails(component, event, helper);
        var rrp = component.get("v.recordId");
        var reln = 'Opportunity.Run_Rate_Definition__c = '+'\''+rrp+'\'';
        var noPursuitStage = "Opportunity.StageName != 'No Pursuit'";
        var andFilter = [];
        var orFilter = [];
        andFilter.push(reln);
        andFilter.push (noPursuitStage);
        component.set('v.andFilters',andFilter);
        component.set("v.loadSpinner",false);
    },
    refreshTable:function(component, event, helper) {
        //console.log('--refreshTable--');
        var andFilter =[];
        var OrFilter =[];
        var reln= 'Opportunity.Run_Rate_Definition__c = '+'\''+component.get("v.recordId")+'\'';
        var noPursuitStage = "Opportunity.StageName != 'No Pursuit'";
        if(component.get("v.yearSelected") != '--None--'){
            var selyear = 'CALENDAR_YEAR(Opportunity.closeDate) = ' + component.get("v.yearSelected");
            andFilter.push (selyear);
        }
        if(component.get("v.productFamilySelected") != '--None--'){
            var selProd = 'Product2Id =' +'\''+component.get("v.productFamilySelected")+'\'';
            OrFilter.push (selProd);
        }
        var productTerm = component.find("productTerm").get("v.value");
        if(!$A.util.isUndefinedOrNull(productTerm) && !$A.util.isEmpty(productTerm)){
            var productTermCond = "Product2.Name Like '%" +productTerm+ "%'";
            OrFilter.push(productTermCond);
        }
        var opportunityName = component.find("oppName").get("v.value");
        if(!$A.util.isUndefinedOrNull(opportunityName) && !$A.util.isEmpty(opportunityName)){
            var opportunityNameCond = "Opportunity.Name Like '%" +opportunityName+ "%'";
            var fiscalMonth = "Fiscal_Month__c Like '%" +opportunityName+ "%'";
            OrFilter.push(opportunityNameCond);
            OrFilter.push(fiscalMonth);
        }
        
        andFilter.push (reln);
        andFilter.push (noPursuitStage);
        component.set('v.andFilters',andFilter);
        component.set('v.orFilters',OrFilter);
        component.set('v.loadTable',false);
        component.set('v.loadTable',true);
    },
    getselectedRecId :function(component, event, helper) {
        //console.log('--getselectedRecId--');
        component.set("v.errorMsg",null);
        var selectedRec = event.getParam("selectedRecord");
        var editedValues = event.getParam("cellRecord");
        var resultList = event.getParam("resultList");
        if(!$A.util.isUndefinedOrNull(editedValues)){ 
            var resp;
            if($A.util.isUndefinedOrNull(component.get("v.errorMsg"))){
                var validationSuccess = $A.get("e.c:DynamicDataTableValidation");
                validationSuccess.setParams({
                    "isValidated" : true
                });
                validationSuccess.fire();
            }
        }
        if(!$A.util.isUndefinedOrNull(resultList)){ //SF-2011
            var totalSumOrder =0;
            var totalSumRevenue =0;
            var delta = 0;
            
            var totalActualRate =0;
            var revenueActualRate =0;
            var deltaActualRate =0;

            var totalPlanRate =0;
            var revenuePlanRate =0;
            var deltaPlanRate =0;
            
                 for(var i =0; i < resultList.length; i++){
                     totalSumOrder += resultList[i].UnitPrice;
                     if(resultList[i].Run_Rate_Revenue_Amount__c != null && resultList[i].Run_Rate_Revenue_Amount__c !=''){
                         totalSumRevenue +=resultList[i].Run_Rate_Revenue_Amount__c;
                     }
                     //SF-2428
                     if(resultList[i].Total_Price_in_USD_P_L_Rate__c != null && resultList[i].Total_Price_in_USD_P_L_Rate__c !=''){
                         totalActualRate +=resultList[i].Total_Price_in_USD_P_L_Rate__c;
                     }
                     if(resultList[i].Run_Rate_Revenue_Amount_in_USD_P_L_Rate__c != null && resultList[i].Run_Rate_Revenue_Amount_in_USD_P_L_Rate__c !=''){
                         revenueActualRate +=resultList[i].Run_Rate_Revenue_Amount_in_USD_P_L_Rate__c;
                     }
                     if(resultList[i].Sales_Price_in_USD_Plan_Rate__c != null && resultList[i].Sales_Price_in_USD_Plan_Rate__c !=''){
                        totalPlanRate +=resultList[i].Sales_Price_in_USD_Plan_Rate__c;
                    }
                    if(resultList[i].Run_Rate_Revenue_Amount_in_USD_Plan_Rate__c != null && resultList[i].Run_Rate_Revenue_Amount_in_USD_Plan_Rate__c !=''){
                        revenuePlanRate +=resultList[i].Run_Rate_Revenue_Amount_in_USD_Plan_Rate__c;
                    }
                     
                 }
            component.set('v.priceOrderSum',totalSumOrder);
            component.set('v.revenueSum',totalSumRevenue);

            //delta = totalSumOrder - totalSumRevenue;
            //SF-2228
            delta =  totalSumRevenue - totalSumOrder;
            //var stringed = (delta > 0) ? "+" + delta : "" + delta;
            component.set('v.delta',delta);
            component.set('v.resultList',resultList);
            
            //SF-2428
            component.set('v.totalActualRateUSD',totalActualRate);
            component.set('v.revenueActualRateUSD',revenueActualRate);
            deltaActualRate =  revenueActualRate - totalActualRate;
            component.set('v.deltaActuaRateUSD',deltaActualRate);
            
            component.set('v.totalPlanRateUSD',totalPlanRate);
            component.set('v.revenuePlanRateUSD',revenuePlanRate);
            deltaPlanRate =  totalPlanRate - revenuePlanRate;
            component.set('v.deltaPlanRateUSD',deltaPlanRate);

        }
    },
    matchRevenuePrice :function(component, event, helper) {
        //console.log('--matchRevenuePrice--');
        component.set("v.openpop",true);
    },
     close:function(component, event, helper){
        //console.log('--close--');
        component.set("v.openpop",false);
    },
    matchRevenueWithPrice :function(component, event, helper) {
        //console.log('--matchRevenueWithPrice--');
        component.set("v.openpop",false);
        component.set("v.loadSpinner",true);
        var resultList = component.get("v.resultList");
        if(!$A.util.isUndefinedOrNull(resultList)){ //SF-2040
            for(var i =0; i < resultList.length; i++){
                if(resultList[i].UnitPrice > 0 ){
                    resultList[i].Run_Rate_Revenue_Amount__c = resultList[i].UnitPrice;
                }
            }
            component.set('v.resultList',resultList);
            helper.updateRevenue(component, event, helper);
        }
    }
})