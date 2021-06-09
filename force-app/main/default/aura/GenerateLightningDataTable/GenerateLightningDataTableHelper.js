({
    loadTable: function (component, event, helper) {
        if (component.get("v.resultList").length === 0) {
            var errorMsg = "No Records Found.";
            var inlineErrorMsg = $A.get("e.c:DynamicDataTableEvent");
            inlineErrorMsg.setParams({
                errorMsg: errorMsg
            });
            inlineErrorMsg.fire();
            component.set("v.errorMsg", errorMsg);
        } else {
            component.set("v.loadNavigationBtns", false);
            var pageSize = component.get("v.pageSize");
            component.set("v.totalRecords", component.get("v.resultList").length);
            component.set("v.startPage", 0);
            component.set("v.endPage", pageSize - 1);
            var PaginationList = [];
            for (var i = 0; i < pageSize; i++) {
                if (component.get("v.resultList").length > i) {
                    PaginationList.push(component.get("v.resultList")[i]);
                }
            }
            component.set("v.PaginationList", PaginationList);
            //use Math.ceil() to Round a number upward to its nearest integer
            component.set(
                "v.totalPagesCount",
                Math.ceil(component.get("v.resultList").length / pageSize)
            );
            component.set("v.loadNavigationBtns", true);
            var fieldName = component.get("v.sortField");
            var sortDirection = component.get("v.sortOrder");
            helper.sortData(component, fieldName, sortDirection);
        }
        component.set("v.loadSpinner", false);
    },
    saveDataTable: function (component, event, helper) {
        component.set("v.loadSpinner", true);
        var editedRecords = component.find("dynamicTableId").get("v.draftValues");
        var isValidated = component.get("v.isValidated");
        var totalRecordEdited = editedRecords.length;
        if (isValidated) {
            var action = component.get("c.updateRecords");
            action.setParams({
                editedValues: editedRecords
            });
            action.setCallback(this, function (response) {
                var state = response.getState();
                component.set("v.loadSpinner", false);
                if (state === "SUCCESS") {
                    //if update is successful
                    if (response.getReturnValue() === true) {
                        helper.showToast({
                            title: "Record Update",
                            type: "success",
                            message: totalRecordEdited + "Records Updated"
                        });
                        helper.reloadDataTable(component);
                    } else {
                        //if update got failed
                        alert("Failed to update the record");
                    }
                }
            });
            $A.enqueueAction(action);
        }
    },
    showToast: function (params) {
        var toastEvent = $A.get("e.force:showToast");
        if (toastEvent) {
            toastEvent.setParams(params);
            toastEvent.fire();
        } else {
            // alert(params.message);
        }
    },

    /*
     * reload data table
     * */
    reloadDataTable: function (component) {
        var refreshEvent = $A.get("e.force:navigateToSObject");
        if (refreshEvent) {
            var navEvt = $A.get("e.force:navigateToSObject");
            navEvt.setParams({
                recordId: component.get("v.recordId")
            });
            navEvt.fire();
        } else {
            window.location.reload();
        }
    },
    sortData: function (component, fieldName, sortDirection) {
        component.set("v.sortedBy", fieldName);
        component.set("v.sortedDirection", sortDirection);
        var data = component.get("v.resultList");
        var reverse = sortDirection !== "asc";
        //sorts the rows based on the column header that's clicked
        data.sort(this.sortBy(fieldName, reverse));
        var pageSize = component.get("v.pageSize");
        component.set("v.totalRecords", data.length);
        component.set("v.startPage", 0);
        component.set("v.endPage", pageSize - 1);
        var PaginationList = [];
        for (var i = 0; i < pageSize; i++) {
            if (data.length > i) {
                PaginationList.push(data[i]);
            }
        }
        component.set("v.PaginationList", PaginationList);
        // component.set("v.PaginationList", data);
    },
    sortBy: function (field, reverse, primer) {
        var key = primer ?
            function (x) {
                return primer(
                    x.hasOwnProperty(field) ?
                    !$A.util.isUndefined(x[field]) ?
                    typeof x[field] === "string" ?
                    x[field].toLowerCase() :
                    x[field] :
                    "" :
                    "aaa"
                );
            } :
            function (x) {
                return x.hasOwnProperty(field) ?
                    !$A.util.isUndefined(x[field]) ?
                    typeof x[field] === "string" ?
                    x[field].toLowerCase() :
                    x[field] :
                    "" :
                    "aaa";
            };
        reverse = !reverse ? 1 : -1;
        return function (a, b) {
            return (a = key(a)), (b = key(b)), reverse * ((a > b) - (b > a));
        };
    },
    // navigate to next pagination record set
    next: function (component, event, sObjectList, end, start, pageSize) {
        var Paginationlist = [];
        var counter = 0;
        for (var i = end + 1; i < end + pageSize + 1; i++) {
            if (sObjectList.length > i) {
                Paginationlist.push(sObjectList[i]);
            }
            counter++;
        }
        start = start + counter;
        end = end + counter;
        component.set("v.startPage", start);
        component.set("v.endPage", end);
        component.set("v.PaginationList", Paginationlist);
    },
    // navigate to previous pagination record set
    previous: function (component, event, sObjectList, end, start, pageSize) {
        var Paginationlist = [];
        var counter = 0;
        for (var i = start - pageSize; i < start; i++) {
            if (i > -1) {
                Paginationlist.push(sObjectList[i]);

                counter++;
            } else {
                start++;
            }
        }
        start = start - counter;
        end = end - counter;
        component.set("v.startPage", start);
        component.set("v.endPage", end);
        component.set("v.PaginationList", Paginationlist);
    },

    jumpPage: function (component, event, helper) {
        var page = component.get("v.pageValue");
        var counter = 0;

        //var existingPage= component.get("v.currentPage");
        if ($A.util.isUndefinedOrNull(page) || $A.util.isEmpty(page)) {
            page = 1;
        }
        var totalPages = component.get("v.totalPagesCount");
        var sObjectList = component.get("v.resultList");
        var pageSize = component.get("v.pageSize");
        var start = pageSize * (page - 1);
        var end = start + pageSize;

        // For the number of records on last page
        if (end > sObjectList.length) end = sObjectList.length;

        if (page <= totalPages) {
            var Paginationlist = [];
            for (var i = start; i < end; i++) {
                Paginationlist.push(sObjectList[i]);
                counter++;
            }

            component.set("v.PaginationList", Paginationlist);
            component.set("v.currentPage", parseInt(page));
            component.set("v.startPage", start);
            component.set("v.endPage", start + counter - 1);
        }
    }
});