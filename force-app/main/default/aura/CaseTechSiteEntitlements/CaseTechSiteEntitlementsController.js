({
	doInit : function(component, event, helper) {
        helper.handleCustomerDetails(component, event, helper);
        helper.setColumns(component, event, helper);
	},
    handleSelectedRows : function(component, event, helper) {
        var selectedRows = event.getParam("selectedRecord");
        component.set("v.selectedRows",selectedRows);
    },
    updateCaseRecord : function(component, event, helper) {
        var rows = component.get("v.selectedRows");
        if($A.util.isEmpty(rows)){
            helper.showToast({
                "title"  : "Error!",
                "type"   : "Error",
                "message": "Please Select at least one row."
            });
        } else {
            var contractNumber = rows[0].CONTRACT_NUMBER;
            helper.updateCase(component, contractNumber);
        }
    }
})