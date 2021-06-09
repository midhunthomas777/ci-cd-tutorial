({
    doInit : function(component, event, helper) {
        component.set("v.loadSpinner", true);
        component.set('v.selectedSubAccIDList',[]);
        component.set('v.hostColumns', [
            {label: 'Account Name', fieldName: 'AccountName', type: 'text'},
            {label: 'Motorola Customer Account', fieldName:'MCNAcc',type:'text'},
            {label: 'FTE Count', fieldName: 'FTECount', type: 'number',cellAttributes: { alignment: 'left' }},
            {label: 'Primary Billing Entity', fieldName: 'PurchasingEntityName', type: 'text'},                   
        ]);
            component.set('v.subAccColumns', [
            {label: 'SubAccount Name', fieldName: 'SubAccountName', type: 'text'},
            {label: 'Motorola Customer Account', fieldName:'MCNAcc',type:'text'},
            {label: 'FTE Count', fieldName: 'FTECount', type: 'number',cellAttributes: { alignment: 'left' }},
            {label: 'Billing Entity', fieldName: 'BillingAgency', type: 'text'},
            {label: 'Create Quote', fieldName: 'isCreateQuote', type: 'boolean'},   
        ]);
        component.set('v.MCNColumns', [
            {label: 'Name', fieldName: 'Name', type: 'text',initialWidth:400},
            {label: 'Motorola Customer No', fieldName:'Motorola_Customer_Number__c',type:'text',initialWidth:150},
            {label: 'Billing Street', fieldName: 'BillingStreet', type: 'text',initialWidth:200,cellAttributes: { alignment: 'left' }},
            {label: 'Billing City', fieldName: 'BillingCity', type: 'text',initialWidth:200},
            {label: 'Billing State', fieldName: 'BillingState', type: 'text',initialWidth:200},
            {label: 'Billing Country', fieldName: 'BillingCountry', type: 'text',initialWidth:200},
            {label: 'Payment Term', fieldName: 'Payment_Term__c', type: 'text',initialWidth:100},
            {label: 'Primary RouteTo Market', fieldName: 'Primary_Route_to_Market__c', type: 'text',initialWidth:100}
        ]);
        
        helper.getHostAccData(component,event,helper);
    },
    handleSelectedRows : function(component, event, helper) {
        var selectedData = event.getParam("selectedRecord");
        var subAccountStartingLetters = $A.get("$Label.c.Sub_Agency_Obj_Starting_Letters");
        var selectedSubAccIDList=[];
        for(var i=0;i<selectedData.length;i++){
            if(selectedData[i].Id.startsWith(subAccountStartingLetters)){
                console.log('selectedData = '+JSON.stringify(selectedData));
                selectedSubAccIDList.push(selectedData[i].Id);
                component.set('v.selectedSubAccIDList',selectedSubAccIDList);
                console.log('Selected SubAcc Id '+JSON.stringify(component.get('v.selectedSubAccIDList')));
            }
            if(selectedData[i].Id.startsWith('006')){
                component.set('v.selectedHostId',selectedData[i].Id);
            }
            if(selectedData[i].Id.startsWith('001')){
                component.set('v.showSave',true);
                component.set('v.selectedBillingEntity',selectedData[i].Id);
            }
        }
    },
    
    saveRows : function(component,event,helper) {
        helper.saveRows(component,event);
    },
})