({ // eslint-disable-line
    doInit: function (cmp, event, helper) {
        if(cmp.get('v.recordId') == null){
            cmp.set('v.recordId', cmp.get('v.flowOppId'));
        }
        if(cmp.get('v.quoteCount') != null){
            cmp.set('v.pageSize', cmp.get('v.quoteCount')+ 1);
            console.log('pageSize: ' + cmp.get('v.pageSize'));
        }
        cmp.set('v.gridColumns', [
            {label: 'Quote Name', fieldName: 'name', type: 'text'},
            {label: 'CreatedBy', fieldName: 'createdBy', type: 'text'},
            {label: 'Created Date', fieldName: 'createdDate', type: 'date'},                       
            {label: 'Owner Name', fieldName: 'ownerName', type: 'text'},
            {label: 'Quote included', fieldName: 'isPrimary', type: 'boolean'}, 
            {label: 'Net Amount', fieldName: 'netAmount', type: 'currency'}
        ]);
        helper.getQuotes(cmp);
        helper.getSuccessMsg(cmp);
		console.log("CPQSuccessMsgLabel: " + JSON.stringify(cmp.get('v.CPQSuccessMsgLabel')));
    },

    rowSelection : function(cmp, event, helper){
        helper.processRowSelection(cmp);
        
    },

    includeProduct : function (component, event, helper) {
        helper.includeCPQProducts(component);
    },
    
    removeProducts : function (component, event, helper) {
        helper.removeCPQProducts(component);
    },

    cancelProductEdit : function (component, event, helper){
        helper.cancelEdit(component);
    }
});