({
    doInit:function(component,event,helper) {
        
        var CCMR= component.get("v.CCMRVal");
        
        var action = component.get('c.getFieldSets'); 
        action.setCallback(this, function(response) { 
            var state = response.getState();
            if(state=='SUCCESS'){
                var resp = response.getReturnValue();
                console.log(resp);
                Object.keys(resp).forEach(function(key) {
                    if(key=='boxleft'){
                        component.set('v.boxLeftFields',resp[key]);
                    } else if(key=='boxright'){
                        component.set('v.boxRightFields',resp[key]);
                    } else if(key=='systemleft'){
                        component.set('v.systemLeftFields',resp[key]);
                    } else if(key=='systemright'){
                        component.set('v.systemRightFields',resp[key]);
                    } else if(key=='command_center_mr_ccmr_left'){
                        component.set('v.commandCenterLeftFields',resp[key]);
                    } else if(key=='command_center_mr_ccmr_right'){
                        component.set('v.commandCenterRightFields',resp[key]);
                    } else if(key=='sec_left'){
                        component.set('v.softwareEnterpriseLeftFields',resp[key]);
                    } else if(key=='sec_right'){
                        component.set('v.softwareEnterpriseRightFields',resp[key]);
                    } else if(key=='service_only_left'){//SF-1801 --Start
                        component.set('v.serviceOnlyLeftFields',resp[key]);
                    } else if(key=='service_only_right'){
                        component.set('v.serviceOnlyRightFields',resp[key]);//SF-1801  --End
                    }else if(key=='aggregatevalues'){
                        component.set('v.aggregatevalues',resp[key]);
                    }
                });
            }
        });
        $A.enqueueAction(action);
        helper.getSitePrefix(component);
        helper.getCCMR(component);
    },
    handleSuccess : function(component, event, helper) {
        var payload = event.getParams().response;
        console.log(payload.id);
        var recId=payload.id;
        if(recId!='undefined' && recId!=null){
            console.log('In IF recId IS Start'+recId);
            component.set("v.recordId", recId); 
            var desoldRec = $A.get("e.c:MRCommissionOderCalculatorCloseEvent");
            desoldRec.setParams({
                "deleteRecord" :recId
            });
            desoldRec.fire();
        }
        component.set("v.editform", false);
        component.set("v.viewform", true);
        component.set("v.showSpinner", false);
    },
    handleLoad : function(component, event, helper) {
        component.set("v.showSpinner", false);   
    },
    handleSubmit : function(component, event, helper) {   
        event.preventDefault();
        var eventFields = event.getParam("fields");        
        console.log('Compelte Result='+JSON.stringify(eventFields));       
        //eventFields['Opportunity__c']='00621000007dLsrAAE';
        eventFields['Motorola_Customer_Number__c']=component.get("v.mcnId");
        eventFields['Partner_Account__c']=component.get("v.partnerId");
       //'0012100000W1eO8AAJ';
        
        component.find("inputMccForm").submit(eventFields); 
        var recId = component.get("v.recordId");
        console.log('recId'+recId);
        component.set("v.showSpinner", true);

        let tealiumTrigger = component.find('tealium-trigger').getElement();
        tealiumTrigger.ANALITYCS.MR_COMMISSION_CALC.CALCULATE();        
    },
    handleError :function(component, event, helper) {
        component.set("v.showSpinner", false);
    },
    doCancel: function(component, event) {        
    },
    doPrint: function(component, event) {        
        var baseURL= component.get("v.getURL");
        var recId = component.get("v.recordId");
        var isccmr= component.get("v.isCCMR");
        var motoNum = component.get("v.motorolaCustomerNumber");
        var partnerId =component.get("v.partnerId");
        var accountId = component.get("v.accountId");
        //var pdfPage='https://motorolasolutions--sfcpqdev--sitepreview.cs26.force.com/NA/s/commissioncalculator?recordId='+recId;
        var pdfPage=baseURL+'/apex/CommissionPdf?Id='+recId+'&motoNum='+motoNum+'&partnerId='+partnerId+'&accountId='+accountId+'&isccmr='+isccmr;
        window.open(pdfPage,"_blank");
        console.log('Executed Print');
    },
    Edit : function(component, event, helper){
        component.set("v.showSpinner", true);
        component.set("v.editform", true);
        component.set("v.viewform", false);      
        
    }
})