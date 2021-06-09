({
    handleCustomerDetails : function(component, event, helper) {
        var recordid = component.get("v.recordId");
        var selectedDecision = component.get("v.decision");
        var chosenDecision = '';
        console.log('selectedDecision*****'+selectedDecision);
        if(selectedDecision == "SITE") {
            component.set('v.headingName', 'This Entitlement section is by Site');
            chosenDecision = 'Site';
        } else {
            component.set('v.headingName', 'This Entitlement section is by Serial#');
            chosenDecision = 'Serial Number';
        }
        component.set("v.loadSpinner", true);
        if($A.util.isUndefinedOrNull(recordid) || $A.util.isEmpty(recordid)){
            this.showToast({
                "title"  : "Error!",
                "type"   : "Error",
                "message": "Unable to get Case Record ID."
            });
            component.set("v.loadSpinner", false);
        }else{
            var action = component.get("c.fetchTechSiteEntitlements");
            action.setParams({
                "caseRecordId" : recordid,
                "decision" : selectedDecision
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                var response = response.getReturnValue();
                console.log('###response###'+response);
                var errorCodes = ["NOTECHSITE","APIError","NOSERIALNUMBER"];
                var genericMessage = 'No contract lines found for this '+chosenDecision;
                if(response != '' && state === "SUCCESS" && !errorCodes.includes(response)){
                    //($A.util.isUndefinedOrNull(response) || $A.util.isEmpty(response)) &&
                    var newItems = JSON.parse(response);
                    console.log(newItems);
                    if(!$A.util.isEmpty(newItems) || !$A.util.isUndefinedOrNull(newItems)){
                        component.set('v.resultList', newItems);
                        component.set('v.resultListLength', newItems.length);
                    }else{
                        component.set('v.errorMsg', 'There is no contract linked with this case.');
                    }
                } else if(response == "NOTECHSITE" && selectedDecision == 'SITE'){
                    component.set('v.warningType', 'There is no Site linked with this Case.');
                } else if(response == "NOSERIALNUMBER" && selectedDecision == 'SERIAL'){
                    component.set('v.warningType', 'There is no Serial# linked with this Case.');
                } else if(response == "" && selectedDecision == 'SITE'){
                    component.set('v.warningType', 'There is no Site linked with this Case.');
                } else if(response == "" && selectedDecision == 'SERIAL'){
                    component.set('v.warningType', 'There is no Serial# linked with this Case.');
                } else if(response == "APIError"){
                    component.set('v.errorMsg', 'Request has not been submitted due to API Error, please retry after some time.');
                } else if(state === "ERROR") {
                    component.set('v.errorMsg', 'Request has not been submitted due to API Error, please retry after some time.');
                } else{
                    component.set('v.errorMsg', genericMessage);
                    console.log('###error###');
                }
                component.set("v.loadSpinner", false);
            });
            $A.enqueueAction(action);
        }
    },
    showToast : function(param){
        var toastEvent = $A.get("e.force:showToast");
        if($A.util.isUndefinedOrNull(toastEvent)){
            console.log('unable to run toast message.');
        }else{
            toastEvent.setParams(param);
            toastEvent.fire();
        }
    },    
    updateCase : function(component, param) {
        component.set("v.loadSpinner", true);
        var recordid = component.get("v.recordId");
        if($A.util.isUndefinedOrNull(recordid) || $A.util.isEmpty(recordid)){
            this.showToast({
                "title"  : "Error!",
                "type"   : "Error",
                "message": "Unable to get Case Record ID."
            });
            component.set("v.loadSpinner", false); 
        } else {
            var action = component.get("c.updateCase");
            action.setParams({
                "caseRecordId" : recordid,
                "contractNumber" : param
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                var response = response.getReturnValue();
                var errorCodes = ["500"];
                if(state === "SUCCESS" && !errorCodes.includes(response)){
                    this.showToast({
                        "title"  : "Success!",
                        "type"   : "Success",
                        "message": "Contract Number: "+param+" got updated on Case"
                    });
                    $A.get('e.force:refreshView').fire();                    
                }else if(response == "500"){
                    this.showToast({
                        "title"  : "Error!",
                        "type"   : "Error",
                        "message": "Error in updating the Case"
                    });
                }
                component.set("v.loadSpinner", false);
            });
            $A.get('e.force:refreshView').fire();
            $A.enqueueAction(action);
        }
    },
    
    setColumns : function(component, event, helper) {
        var columnDesign = component.get("v.decision");
        if(columnDesign == "SITE") {
            component.set('v.columns', [
                {label: 'Service Description', fieldName: 'SERVICE_DESC', type: 'text',sortable : true},
                {label: 'Code', fieldName: 'STS_CODE', type: 'text',sortable : true},
                {label: 'Contract Number', fieldName: 'CONTRACT_NUMBER', type: 'text'},
                {label: 'StartDate', fieldName: 'SUBINE_START_DATE', type: 'text',sortable : true},
                {label: 'EndDate', fieldName: 'SUBLINE_END_DATE', type: 'text',sortable : true}
            ]);
        } else if(columnDesign == "SERIAL"){
            component.set('v.columns', [
                {label: 'Contract Number', fieldName: 'CONTRACT_NUMBER', type: 'text'},
                {label: 'Service Description', fieldName: 'SERVICE_DESCRIPTION', type: 'text'},
                {label: 'Customer Number', fieldName: 'CUSTOMER_NUMBER', type: 'text'},
                {label: 'StartDate', fieldName: 'CONTRACT_START_DATE', type: 'text'},
                {label: 'EndDate', fieldName: 'CONTRACT_END_DATE', type: 'text'}
            ]);
        }
    }
})