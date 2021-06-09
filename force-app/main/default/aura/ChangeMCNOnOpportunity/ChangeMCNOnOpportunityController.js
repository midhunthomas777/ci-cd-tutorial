({
    doInit : function(component, event, helper) {
        component.set("v.loadSpinner", true);
        var recordIdLocal = component.get("v.recordId");
        var objectName = component.get("v.sObjectName");
        if(!$A.util.isUndefinedOrNull(recordIdLocal) && objectName == 'Opportunity'){
            var andFilterOppo = 'Id = '+'\''+recordIdLocal+'\'';
            var action = component.get("c.getQueryResult");
            var lstFields = component.get("v.oppoFields");
            action.setParams({
                "theObject": objectName,
                "theFields" : lstFields,
                "ANDFilters" : andFilterOppo
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                var resp = response.getReturnValue();
                if (state === "SUCCESS" && resp.length > 0) {
                    var accId = resp[0].AccountId;
                    console.log('Success==>' + accId);
                    var reln = 'ParentId = '+'\''+accId+'\'';
                    var andFilter = [];
                    andFilter.push(reln);                    
                    andFilter.push("RecordType.DeveloperName = 'Motorola_Customer_Number'");
                    //SF-2274--Start
                    //andFilter.push('ERP_Active__c=true'); 
                    var orFilter= [];
                    orFilter.push('ERP_Active__c=true');
                    orFilter.push("Parent.RecordType.DeveloperName ='Prospect'");
                    component.set('v.orFilters',orFilter);
                    //SF-2274--End
                    component.set('v.andFilters',andFilter);
                    component.set('v.columns', [
                        {label: 'Customer Name', fieldName: 'Name', type: 'text'},
                        {label: 'Motorola Customer Number', fieldName: 'Motorola_Customer_Number__c', type: 'text'},
                        {label: 'Street', fieldName: 'BillingStreet', type: 'percent'},
                        {label: 'City', fieldName: 'BillingCity', type: 'text'},
                        {label: 'State', fieldName: 'BillingState', type: 'text',sortable: true},
                        {label: 'Country', fieldName: 'BillingCountry', type: 'text'},
                        {label: 'Payment Term', fieldName: 'Payment_Term__c', type: 'text'},
                        {label: 'Route to Market', fieldName: 'Primary_Route_to_Market__c', type: 'text'}
                    ]);
                    component.set("v.loadSpinner",false);
                } else {
                    component.set("v.recordError",'Error occured while accessing record');
                    component.set("v.loadSpinner", false);
                }
            });
            $A.enqueueAction(action);
        } else {
            var custId = component.get("v.customerAccId");
            var reln= 'ParentId = '+'\''+custId+'\'';
            var andFilter =[];
            var orFilter = [];
            console.log('Else Success==>' + custId);
            andFilter.push(reln);
            andFilter.push('ERP_Active__c=true');
            andFilter.push("RecordType.DeveloperName = 'Motorola_Customer_Number'");
            component.set('v.andFilters',andFilter);
            component.set('v.columns', [
                {label: 'Customer Name', fieldName: 'Name', type: 'text'},
                {label: 'Motorola Customer Number', fieldName: 'Motorola_Customer_Number__c', type: 'text'},
                {label: 'Street', fieldName: 'BillingStreet', type: 'percent'},
                {label: 'City', fieldName: 'BillingCity', type: 'text'},
                {label: 'State', fieldName: 'BillingState', type: 'text',sortable: true},
                {label: 'Country', fieldName: 'BillingCountry', type: 'text'},
                {label: 'Payment Term', fieldName: 'Payment_Term__c', type: 'text'},
                {label: 'Route to Market', fieldName: 'Primary_Route_to_Market__c', type: 'text'}
            ]);
            component.set("v.loadSpinner", false);
        }
    },
    getselectedRecId :function(component, event, helper) {
       component.set("v.recordError",null);
        var recId = component.get("v.recordId");
        var selectedRec = event.getParam("selectedRecord");
        var resp;
        if(!$A.util.isUndefinedOrNull(selectedRec) && !$A.util.isEmpty(selectedRec)){
            for(var key in selectedRec){
                resp=selectedRec[key];
            }
            for(var key in resp){
                if(key==='Id'){
                    component.set("v.selectedRecId",resp[key]);
                    console.log('Select ID'+component.get("v.selectedRecId"));
                }
                if(key==='Motorola_Customer_Number__c'){
                    component.set("v.motorolaCustomerNumber",resp[key]);
                    //console.log('Select ID'+component.get("v.selectedRecId"));
                }
            }
            if($A.util.isUndefinedOrNull(recId)){
                var passDataToNewOpp = $A.get("e.c:NewOpportunityEvent");
                passDataToNewOpp.setParams({
                    "motorolaCustomerNumber" : component.get("v.motorolaCustomerNumber"),
                    "mcnId" : component.get("v.selectedRecId")
                });
                passDataToNewOpp.fire();
            }
        }
    },
    
    Save : function(component, event, helper) {
        component.set("v.loadSpinner",true);
        component.set("v.recordError",null);
        var recId = component.get("v.recordId");
        var origin = component.get("v.executionOrigin");
        if(!$A.util.isUndefinedOrNull(recId)){
            component.set("v.opportunityRecord.CDH_Account__c",component.get("v.selectedRecId"));
            //component.set("v.opportunityRecord.CDH_Account__c",'test');
            component.find("recordHandler").saveRecord($A.getCallback(function(saveResult) {
                component.set("v.loadSpinner",false);
                if (saveResult.state === "SUCCESS" || saveResult.state === "DRAFT") {
                    if(origin != 'VF'){
                        $A.get("e.force:closeQuickAction").fire();
                    }
                    helper.redirectToSobject(component, event, helper,recId);
                } else if (saveResult.state === "INCOMPLETE") {
                    console.log("User is offline, device doesn't support drafts.");
                } else if (saveResult.state === "ERROR") {
                    component.set("v.recordError",'Error occured while saving record');
                } else {
                    component.set("v.recordError",'Error occured while saving record');
                }
            })); 
        }else{
            component.set("v.loadSpinner",false);
            component.set("v.recordError",'Error occured while saving record');
        }
    },
    
    cancel : function(component, event, helper) {
        var recId = component.get("v.recordId");
        if(!$A.util.isUndefinedOrNull(recId)){
            helper.redirectToSobject(component, event, helper,recId);
        }else{
            document.getElementById("newOppForm").style.display = "block";
            component.set("v.changeMCN",false); 
        }
    }
})