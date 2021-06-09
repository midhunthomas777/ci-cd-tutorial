({
    doInit : function(component, event, helper){
        component.set('v.columns', [
            {label: 'Quote Name', fieldName: 'name', type: 'text'},
            {label: 'CreatedBy', fieldName: 'createdBy', type: 'text'},
            {label: 'Created Date', fieldName: 'createdDate', type: 'date'},                       
            {label: 'Owner Name', fieldName: 'ownerName', type: 'text'},
            {label: 'Is Primary', fieldName: 'isPrimary', type: 'boolean'}, 
            {label: 'Net Amount', fieldName: 'netAmount', type: 'currency'}
        ]);
        helper.getQuoteOrders(component);
        helper.getSuccessMsg(component);//Added by Venkat as on story SF-1879
    },   
    openQuoteDetails : function(component, event, helper){
        //var selectedRow = event.getParam('selectedRows');
       // component.set("v.quoteId",selectedRow[0].quoteId);
       console.log('Get Selected Rows..'+JSON.stringify(event.getParam('selectedRows')));
        var dTable = component.find("quoteTable");
        var selectedRows = dTable.getSelectedRows();
        console.log("selectedRows in selection "+JSON.stringify(selectedRows)); 
        var resp;
        for(var key in selectedRows){
            resp = selectedRows[key];
        }
        for(var key in resp){
            if(key === 'quoteId'){
                component.set("v.quoteId",resp[key]);
            }
        }
        component.set("v.displayProductFamilyButtons",true);
    },
    next: function (component, event, helper) {
        helper.next(component, event);
    },
    previous: function (component, event, helper) {
        helper.previous(component, event);
    },
    includeProduct : function (component, event, helper) {
        helper.includeCPQProducts(component, event);
    },
    removeProduct : function (component, event, helper) {
        helper.removeCPQProducts(component, event);
    }
})