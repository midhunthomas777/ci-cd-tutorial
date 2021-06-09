({
    doInit : function(component, event, helper){
        component.set('v.columns', [
            {label: 'Customer Name', fieldName: 'Name', type: 'text',sortable: true},
            {label: 'Motorola Customer Number', fieldName: 'Motorola_Customer_Number__c', type: 'text'},
            {label: 'City', fieldName: 'BillingCity', type: 'text',sortable: true},
            {label: 'State', fieldName: 'BillingState', type: 'text',sortable: true},
            {label: 'Country', fieldName: 'BillingCountry', type: 'text',sortable: true},
            {label: 'Postal Code', fieldName: 'BillingPostalCode', type: 'text',sortable: true},
            {label: 'Route to Market', fieldName: 'Primary_Route_to_Market__c', type: 'text',sortable: true}
        ]);
        helper.getAccounts(component);     
    }, 
    openMCNDetails : function(component, event, helper){
        var selectedRow = event.getParam('selectedRows');
        console.log('selectedRow[0].Motorola_Customer_Number__c');
        component.set("v.motorolaCustomerNumber",selectedRow[0].Motorola_Customer_Number__c);
        component.set("v.accountId",selectedRow[0].ParentId);
        component.set("v.mcnId",selectedRow[0].Id); 
        component.set("v.partnerId",selectedRow[0].Assigned_MR__c); 
        //For reloading child component after change in selction on MCN record.
        if(selectedRow[0].Primary_Route_to_Market__c=='Open' &&  component.get("v.isInternalUser") == true){
            component.set("v.partnerInfo",true);
            component.set("v.renderLtngDataTable", false);
        }else {
            component.set("v.showCommissionInfo", true);
            var childCompId = component.find('calculationDetail');
            childCompId.childmethod(component);
            component.set("v.renderLtngDataTable", false);
        }        
    },
    next: function (component, event, helper) {
        helper.next(component, event);
    },
    previous: function (component, event, helper) {
        helper.previous(component, event);
    },
    handleCloseEvent: function (component, event, helper){
        var getdeleteRecord = event.getParam("deleteRecord");
        console.log('getdeleteRecord'+getdeleteRecord);
        if(getdeleteRecord!=null || getdeleteRecord!='undefined'){
            component.set("v.deleteRecId", getdeleteRecord );
        }
    },
    close:function (component, event, helper){
        
        var recid = component.get("v.deleteRecId");
        console.log('recid:'+recid);
        if(recid!=null && recid!='undefined')
        {
            var action = component.get('c.deleteMRCalculator');
            action.setParams({
                'recordId': recid
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    component.set("v.showCommissionInfo", false);
                    component.set("v.renderLtngDataTable", true);
                    component.set("v.deleteRecId", null);
                }
            });
            $A.enqueueAction(action); 
        }
        else{
            component.set("v.showCommissionInfo", false);
            component.set("v.renderLtngDataTable", true);
        }
    },
    MRCommissionPartnerDetailEvent: function (component, event, helper){
        var getpartnerId = event.getParam("partnerId");
        component.set("v.partnerId",getpartnerId);
        component.set("v.showCommissionInfo", true);
    },
    closepartner: function (component, event, helper){
        component.set("v.partnerInfo", false);
        component.set("v.renderLtngDataTable", true);
    },
    sortColumn : function (component, event, helper){
        var fieldName = event.getParam('fieldName');
        var sortDirection = event.getParam('sortDirection');
        component.set("v.sortedBy", fieldName);
        component.set("v.sortedDirection", sortDirection);
        helper.sortData(component, fieldName, sortDirection);
    },
})