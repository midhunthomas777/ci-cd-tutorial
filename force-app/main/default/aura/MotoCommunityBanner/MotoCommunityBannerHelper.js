({
    
    setUserInfo: function(component, event, helper) {
        let action = component.get("c.getUserDetails");
        action.setCallback(this, function(response) {
            if ( response.getState() == "SUCCESS" ) {
                let data = response.getReturnValue();
                component.set("v.accountName", data.accountName);
            }
            else {
                console.log(response);
            } 
        });
        $A.enqueueAction(action);
        
    },
    setOrderCount: function(component, event, helper) {
        
        let orderAction = component.get("c.getOrderCount");
        orderAction.setBackground();
        
        let orderRequestParams = {
            p_search_type : null,
            p_search_date_type : null,
            p_ordered_by : null,
            p_search_text : null,
            customer_number : '',
            dt_from_date : null,
            dt_to_date : null,
            pageSize : 1,
            pageIndex : 1,
            p_order_status : '1',
            p_SortField : "order_date",
            p_SortDirection : "DESC",
            p_lc_identifier: "VST"
        };
        
        
        orderAction.setParams({"requestParamsStr": JSON.stringify(orderRequestParams)});
        orderAction.setCallback(this, function(response) {
            var errorCodes = ['ERROR','NOACCESS','APIError','Read timed out','INTERNAL', -1];
            if ( response.getState() == "SUCCESS" && !errorCodes.includes(response.getReturnValue())) {
                let count = response.getReturnValue();
                if ( count >= 0 ) {
                    component.set("v.orderCount", count);
                }
            }else {
                component.set("v.isOrderError",true);
            } 
        });
        $A.enqueueAction(orderAction);            
        
    }, 
    
    setCaseCount: function(component, event, helper) {
        
        let caseAction = component.get("c.getCaseCount");
        caseAction.setBackground();
        let caseRequestParams = {
            "sysparm_view":"extranet_export",
            "sysparm_display_value" : "true",
            "sysparm_count": "true",
            "sysparm_query": "partner.u_motorola_enterprise_id=1099999999^closed_atISEMPTY"
        };
        
        caseAction.setParams({
            "requestParams": caseRequestParams
        });
        
        caseAction.setCallback(this, function(response) {
            var errorCodes = ['ERROR','NOACCESS','APIError','Read timed out','INTERNAL', -1];
            if ( response.getState() == "SUCCESS" && !errorCodes.includes(response.getReturnValue())) {
                
                let count = response.getReturnValue();
                if ( count >= 0 ) {
                    component.set("v.caseCount", count);
                }
                
            } else {;
                component.set("v.isCaseError",true);
            } 
        });
        $A.enqueueAction(caseAction);        
        
    },
    
    setContractCount: function(component, event, helper) {
        let count = 0;
        let dateToday = new Date();
        let dateSixMonth = new Date();
        dateSixMonth.setMonth(dateSixMonth.getMonth()+6);
        
        let contractAction = component.get("c.getContracts");
        contractAction.setBackground();
        contractAction.setCallback(this, function(response) {
            var errorCodes = ['ERROR','NOACCESS','APIError','Read timed out','INTERNAL', -1];
            if ( response.getState() == "SUCCESS" && !errorCodes.includes(response.getReturnValue())) {
                var contracts = JSON.parse(response.getReturnValue());
                
                if(contracts.length>0){
                    contracts.forEach(function(record){
                        if(new Date(record.SERVICE_END_DATE) >= dateToday
                           && new Date(record.SERVICE_END_DATE) < dateSixMonth)
                        {
                            count = count + 1;
                        }
                    });
                }

                if ( count >= 0 ) {
                    component.set("v.contractCount", count);
                }
            }
            else {
                component.set("v.isContractsError",true);
            } 
        });
        $A.enqueueAction(contractAction);           
        
    },
    showComponent : function(component, event, helper) {
        var clickedBtn = event.getSource().getLocalId();
        debugger;
        switch (clickedBtn) {
            case 'Orders' :
                this.injectComponent('c:ExternalOrdersAuraComponent', component, clickedBtn);
                break;
            case 'Cases' :
                this.injectComponent('c:ExternalCasesComponent', component, clickedBtn);
                break;
            case 'Parts & Pricing':
                this.injectComponent('c:VestaPartsAndPricing', component, clickedBtn);
                break;
            case 'Contracts':
                this.injectComponent('', component, clickedBtn);
                break;
        }
    },
    injectComponent: function (name, component, cmpName) {
        $A.createComponent(name, {
            // no attrs
        }, function (contentComponent, status, error) {
            if (status === "SUCCESS") {
                component.set('v.body', contentComponent);
                component.set("v.componentName",cmpName);
            } else {
                throw new Error(error);
            }
        });
    }
})