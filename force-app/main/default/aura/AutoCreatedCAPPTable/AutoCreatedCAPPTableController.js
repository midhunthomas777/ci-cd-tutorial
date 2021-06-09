({
    doInit : function(component, event, helper){
        console.log('doInit');
        component.set("v.loadSpinner", true);
        component.set("v.columns", [
            {label: 'Name', fieldName: 'linkName', type: 'url', 
             typeAttributes: {label: { fieldName: 'name' }, target: '_blank'}, sortable: true, initialWidth: 130},
            {label: 'CAPP Change', fieldName: 'CAPPChange', type: 'text', sortable: true, initialWidth: 130},
            {label: 'Record Type', fieldName: 'RecordTypeName', type: 'text', sortable: true, initialWidth: 200},
            {label: 'Vendor', fieldName: 'linkVendor', type: 'url', 
             typeAttributes: {label: { fieldName: 'Vendor' }, target: '_blank'}, sortable: true, initialWidth: 200},
            {label: 'Purchase Year', fieldName: 'PurchaseYear', type: 'text', editable: false, sortable: true, initialWidth: 130},
            {label: 'Vendor Product Line', fieldName: 'linkVendorProduct', type: 'url', 
             typeAttributes: {label: { fieldName: 'VendorProductLine' }, target: '_blank'}, sortable: true, initialWidth: 200},
            {label: 'Type', fieldName: 'Type', type: 'text', editable: false, sortable: true, initialWidth: 200},   
        		]);
            helper.getCAPPRecords(component, helper);
     }, 
            
     updateReviewedbySales : function(component, event, helper){
            //alert('Update Reviewed by Sales');
            var action = component.get("c.updateCAPPRecords");
            var fields = 'Id, Opportunity_Auto_Created_or_Modified_Fr__c, Reviewed_by_Sales__c';
            action.setParams({
            "fields": fields,
            "OpptyId": component.get("v.recordId")
            });
            action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS" && component.isValid()){
                console.log('CAPP Records updated>>');
                };
        });
        $A.enqueueAction(action);
        $A.get('e.force:refreshView').fire();
     }
})