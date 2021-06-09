({
    doInit: function (component, event, helper) {
        helper.loadTable(component, event, helper);
    },
    getRecordDetails: function (component, event) {
        var dTable = component.find("dynamicTableId");
        var selectedRows = dTable.getSelectedRows();
        var selectedId = $A.get("e.c:DynamicDataTableEvent");
        selectedId.setParams({
            selectedRecord: selectedRows
        });
        selectedId.fire();
    },
    isValidated: function (component, event, helper) {
        var isValidated = event.getParam("isValidated");
        component.set("v.isValidated", isValidated);
    },

    onSave: function (component, event, helper) {
        var isValidated = component.get("v.isValidated");
        if (isValidated) {
            var editedRecords = component.find("dynamicTableId").get("v.draftValues");
            var editedValues = $A.get("e.c:DynamicDataTableOnSave");
            editedValues.setParams({
                editedValues: editedRecords
            });
            editedValues.fire();
        }
    },
    onCellChange: function (component, event, helper) {
        var editedRecords = component.find("dynamicTableId").get("v.draftValues");
        var editedValues = $A.get("e.c:DynamicDataTableEvent");
        editedValues.setParams({
            cellRecord: editedRecords
        });
        editedValues.fire();
    },
    cancel: function (component, event, helper) {
        var errorMsg = $A.get("e.c:DynamicDataTableEvent").fire();
    },
    sortColumn: function (component, event, helper) {
        var fieldName = event.getParam("fieldName");
        var sortDirection = event.getParam("sortDirection");
        helper.sortData(component, fieldName, sortDirection);
    },
    changePageSize: function (component, event, helper) {
        var pageSize = parseInt(component.get("v.selectedPageSize"));
        component.set("v.pageSize", pageSize);
        helper.loadTable(component, event, helper);
    },
    /* javaScript function for pagination */
    navigation: function (component, event, helper) {
        var sObjectList = component.get("v.resultList");

        var end = component.get("v.endPage");
        var start = component.get("v.startPage");
        var pageSize = component.get("v.pageSize");
        var whichBtn = event.getSource().get("v.name");

        // clear the jumpto any time a button is pressed
        component.set("v.pageValue", false);

        // check if whichBtn value is 'next' then call 'next' helper method
        if (whichBtn == "next") {
            component.set("v.currentPage", component.get("v.currentPage") + 1);
            helper.next(component, event, sObjectList, end, start, pageSize);
        }
        // check if whichBtn value is 'previous' then call 'previous' helper method
        else if (whichBtn == "previous") {
            component.set("v.currentPage", component.get("v.currentPage") - 1);
            helper.previous(component, event, sObjectList, end, start, pageSize);
        }
    },
    handleRowAction: function (cmp, event, helper) {
        var action = event.getParam("action");
        var row = event.getParam("row");
        switch (action.name) {
            case "show_details":
                alert("Showing Details: " + JSON.stringify(row));
                break;
            case "delete":
                helper.removeBook(cmp, row);
                break;
        }
    },
    handleJump: function (cmp, event, helper) {
        helper.jumpPage(cmp, event, helper);
    }
});