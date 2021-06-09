({
    doInit : function(component, event, helper){
        var action = component.get("c.isValidated");
        action.setParams({
            'quoteId': component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            // hide spinner when response coming from server 
            component.find("Id_spinner").set("v.class" , 'slds-hide');
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                if(storeResponse !='Success'){
                    var recordId= component.get('v.recordId');
                    var theme = component.get('v.userTheme');
                    if(theme !='Classic'){
                        var dismissActionPanel = $A.get("e.force:closeQuickAction"); 
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            title : 'Error Message',
                            message: storeResponse,
                            duration:' 30000',
                            key: 'info_alt',
                            type: 'error',
                            mode: 'dismissible'
                        });
                        toastEvent.fire(); 
                        dismissActionPanel.fire();                 
                    }else{
                        alert(storeResponse);
                        var urlVar = '/'+recordId;
                        window.open(urlVar,'_self');  
                    }
                }
            }
        });
        $A.enqueueAction(action);
    },
    
    Search: function(component, event, helper) {
        component.set("v.Message", false);
        helper.Reset(component);
        component.set('v.columns', [
            {label: 'Customer Account Name', fieldName: 'Name', type: 'text'},
            {label: 'Motorola Customer Number(s)', fieldName: 'MCN_Account_Number__c', type: 'text'}
        ]);
        var searchField = component.find('searchField');
        var isValueMissing = searchField.get('v.validity').valueMissing;
        console.log('isValueMissing##'+isValueMissing);
        // if value is missing show error message and focus on field
        if(isValueMissing) {
            searchField.showHelpMessageIfInvalid();
            searchField.focus();
        }else{
            // else call helper function
            console.log('calling helper'); 
            component.set("v.displayMCNList", false);
            helper.SearchHelper(component, event);
        }
    },
    
    displayChildren: function(component, event, helper) {
        component.set("v.Message", false);
        component.set('v.childColumns', [
            {label: 'MCN Account Name', fieldName: 'Name', type: 'text'},
            {label: 'Motorola Customer Number', fieldName: 'Motorola_Customer_Number__c', type: 'text'}
        ]);
        helper.ChildHelper(component, event);
    },
    
    MoveQuote:function(component, event, helper) {
        var selectedParent = component.get('v.selectedParent');
        var selectedChild = component.get('v.selectedChild');
        var mcnResponse = component.get('v.mcnDisplayMessage');
        var recordId= component.get('v.recordId');
        console.log('selectedParent##'+selectedParent);
        console.log('selectedChild##'+selectedChild);
        var searchField = component.find('searchField');
        var isValueMissing = searchField.get('v.validity').valueMissing;
         if(isValueMissing) {
            searchField.showHelpMessageIfInvalid();
            searchField.focus();
         }
        else if ($A.util.isUndefinedOrNull(selectedParent)) {  
            component.set("v.Message", true);
            component.set("v.errorMessage","Please select Account");
        }else if($A.util.isUndefinedOrNull(selectedChild) && mcnResponse == true){
            component.set("v.Message", true);
            component.set("v.errorMessage","Please select MCN record");
        }
        if(!$A.util.isUndefinedOrNull(selectedParent)&& (!$A.util.isUndefinedOrNull(selectedChild) && mcnResponse == true))
        {
            helper.updateDetailsOnQuote(component);
            
        }
    },
    mcnOperation:function(component, event, helper) {
        component.set("v.Message", false);
        var dTable = component.find("mcnTable");
        var selectedRows = dTable.getSelectedRows();
        var resp;
        for(var key in selectedRows){
            resp=selectedRows[key];
        }
        for(var key in resp){
            if(key==='Motorola_Customer_Number__c'){
                component.set("v.selectedChild",resp[key]);
            }
        }
    },
    
    goBack:function(component, event, helper){
        var theme = component.get('v.userTheme');
        var recordId= component.get('v.recordId');
        if(theme !='Classic'){
            window.location.reload();
        }else{
            var urlVar = '/'+recordId;
            window.open(urlVar,'_top');  
        }
    },
    next: function (component, event, helper) {
        helper.next(component, event);
    },
    previous: function (component, event, helper) {
        helper.previous(component, event);
    },
    mcnNext: function (component, event, helper) {
        helper.mcnNext(component, event);
    },
    mcnPrevious: function (component, event, helper) {
        helper.mcnPrevious(component, event);
    }
})