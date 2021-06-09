({
    doInit : function(component, event, helper){
        console.log('-- In doInit --');
        console.log('record id =='+component.get("v.recordId"));
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
        var oppId = component.get('v.oppId');
        console.log('MRCPQ_MCNList oppId: ' + component.get('v.oppId')); 
        console.log('MRCPQ_MCNList quoteId: ' + component.get('v.quoteId'));
        var recordId = component.get("v.recordId");
        console.log('Parent Record: ' + recordId);
        
        if(recordId.startsWith('001') || oppId == null){//SF-2509 //oppId added for 2884
            console.log('-- call get accounts --');
            helper.getAccounts(component); 
        }
    },   
    openMCNDetails : function (component, event) {
        console.log('-- In openMCNDetails --');
        var current = component.get("v.currentPage");    
        var dTable = component.find("accountTable");
        var selectedRows = dTable.getSelectedRows();
        console.log("selectedRows in selction "+JSON.stringify(selectedRows)); 
        var custs = [];
        var resp;
        for(var key in selectedRows){
            resp=selectedRows[key];
        }
        for(var key in resp){
            if(key==='Motorola_Customer_Number__c'){
                component.set("v.motorolaCustomerNumber",resp[key]);
            }
            if(key==='ParentId'){
                component.set("v.accountId",resp[key]);
            }
            if(key==='Id'){
                component.set("v.mcnId",resp[key]);
            }
        }
        var oppoAccId = component.get('v.oppoAccId');
        var isEditQuote = component.get('v.fromEditQuote');
        console.log('isEditQuote in controller = '+isEditQuote);
        if(isEditQuote){
            console.log('isEditQuote true - IF');
            component.set("v.showProceedQuoteEdit",true);
            var childCompId = component.find("editQuoteDetailID");
            console.log('childCompId ='+childCompId);
        	childCompId.proceedToQuoteInitmethod(component); 
        }
        
        else{
            console.log('isEditQuote true - ELSE');
            component.set("v.showCommissionInfo",true);
            var childCompId = component.find("cmsDetailID");
        	childCompId.childmethod(component);
        }
         
        
         
        /*console.log("Value are in selction "+JSON.stringify(resp));
        console.log('v.motorolaCustomerNumber'+component.get("v.motorolaCustomerNumber"));
        console.log('v.accountId'+component.get("v.accountId"));
        console.log('v.mcnId'+component.get("v.mcnId"));*/
        
    },
    next: function (component, event, helper) {
        helper.next(component, event);
    },
    previous: function (component, event, helper) {
        helper.previous(component, event);
    },
    handleRecordUpdated: function(component, event, helper) {//SF-2509
        console.log('-- In handleRecordUpdated --');
        var eventParams = event.getParams();
        if(eventParams.changeType === "LOADED") {
            component.set("v.loadSpinner",false);
            var recId = component.get("v.recordId");
            if(recId.startsWith('006')){
                var oppoAccID = component.get("v.recordInfo.AccountId");            
                component.set("v.oppoAccId", oppoAccID); 
                component.set("v.oppId", recId); 
                console.log('2 MCNList oppoAccId****'+component.get("v.oppoAccId"));
                helper.getAccounts(component);
            }
        } else if(eventParams.changeType === "CHANGED") {
            // record is changed
        } else if(eventParams.changeType === "REMOVED") {
            // record is deleted
        } else if(eventParams.changeType === "ERROR") {
            // there’s an error while loading, saving, or deleting the record
        }
    }
})