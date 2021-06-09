({
    doInit: function (component, event, helper) {
        var col = component.get("v.columns");
        var additionalFields = component.get("v.additionalFields");
        var resp;
        var fieldNames = [];
        for (var key in col) {
            console.log("key is" + key);
            resp = col[key];
            for (var key in resp) {
                if (key === "fieldName") {
                    fieldNames.push(resp[key]);
                }
            }
        }
        if (!$A.util.isUndefinedOrNull(additionalFields)) {
            var addFieldsAPi = [];
            addFieldsAPi = additionalFields.split(",");
            for (var addnFlds in addFieldsAPi) {
                fieldNames.push(addFieldsAPi[addnFlds]);
            }
        }
        component.set("v.fieldAPIs", fieldNames);
        helper.getResult(component, event, helper);
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
        /*var editedRecords =  component.find("dynamicTableId").get("v.draftValues");
            var editedValues = $A.get("e.c:DynamicDataTableEvent");
            editedValues.setParams({
                "editedRecords" : editedRecords
            });
            editedValues.fire(); */
        var isValidated = event.getParam("isValidated");
        component.set("v.isValidated", isValidated);
    },

    onSave: function (component, event, helper) {
        var isValidated = component.get("v.isValidated");
        if (isValidated) {
            helper.saveDataTable(component, event, helper);
        }
    },
    onCellChange: function (component, event, helper) {
        var onCellChangeRecords = component
            .find("dynamicTableId")
            .get("v.draftValues");
        var editedValues = $A.get("e.c:DynamicDataTableEvent");
        var cellRecId;
        for (var key in onCellChangeRecords) {
            var resp;
            resp = onCellChangeRecords[key];
            for (var key in resp) {
                if (key === "Id") {
                    cellRecId = resp[key];
                }
            }
        }
        editedValues.setParams({
            cellRecord: onCellChangeRecords,
            callRecordId: cellRecId
        });
        editedValues.fire();
    },
    cancel: function (component, event, helper) {
        component.set("v.errorMsg", null);
        var errorMsg = $A.get("e.c:DynamicDataTableEvent").fire();
        /*   errorMsg.setParams({
                "errorMsg" : 'Null'
            });
            errorMsg.fire();*/
    },
    sortColumn: function (component, event, helper) {
        var fieldName = event.getParam("fieldName");
        var sortDirection = event.getParam("sortDirection");
        component.set("v.sortedBy", fieldName);
        component.set("v.sortedDirection", sortDirection);
        helper.sortData(component, fieldName, sortDirection);
    },
    changePageSize: function (component, event, helper) {
        var pageSize = parseInt(component.get("v.selectedPageSize"));
        component.set("v.pageSize", pageSize);
        component.set("v.currentPage", 1);
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
    handleSearch: function (component, event, helper) {
        // Reseting current page and page value : DTSFCOM-279
        component.set("v.currentPage", 1);
        component.set("v.pageValue", null);
        // Call searchFilter to filter the results and load the table
        helper.searchFilter(component, event, helper);
    },
    handleJump: function (cmp, event, helper) {
        helper.jumpPage(cmp, event, helper);
    }
});