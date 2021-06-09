({
    getResult: function (component, event, helper) {
        component.set("v.loadSpinner", true);
        var objectName = component.get("v.objectName");
        var lstFields = component.get("v.fieldAPIs");
        var andFilters = component.get("v.andFilters");
        var orFilters = component.get("v.orFilters");
        var andorFilters = component.get("v.andORFilters");
        var sortField = component.get("v.sortField");
        var sortOrder = component.get("v.sortOrder");

        var action = component.get("c.getQueryResult");
        action.setParams({
            theObject: objectName,
            theFields: lstFields,
            ANDFilters: andFilters,
            ORFilters: orFilters,
            ANDORFilter: andorFilters,
            sortField: sortField,
            sortOrder: sortOrder
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            component.set("v.loadSpinner", false);
            console.log("State is " + state);
            if (state === "SUCCESS") {
                component.set("v.resultList", response.getReturnValue());

                var finalResult = $A.get("e.c:DynamicDataTableEvent");
                finalResult.setParams({
                    resultList: component.get("v.resultList")
                });
                finalResult.fire();
                // if client side searching is enabled then store a copy of resultList
                // in variable unfilteredResultList so we have the master list to search
                // and then search results will be placed in resultList
                let searchEnabled = component.get("v.enableClientSideSearch");
                if (searchEnabled) {
                    component.set("v.unfilteredResultList", response.getReturnValue());
                }

                helper.loadTable(component, event, helper);
            }
        });
        $A.enqueueAction(action);
    },
    loadTable: function (component, event, helper) {
        if (component.get("v.resultList").length === 0) {
            component.set("v.PaginationList", []); //DTSFCOM-282
            component.set("v.errorMsg", "No Records Found.");
            component.set("v.loadNavigationBtns", false); //added to hide button on zero record
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
            component.set("v.errorMsg", ""); //DTSFCOM-282
        }
        component.set("v.loadSpinner", false);
    },
    saveDataTable: function (component, event, helper) {
        component.set("v.loadSpinner", true);
        var editedRecords = component.find("dynamicTableId").get("v.draftValues");
        var isValidated = component.get("v.isValidated");
        var totalRecordEdited = editedRecords.length;
        var toastMsg;
        if (totalRecordEdited === 1) {
            toastMsg = totalRecordEdited + " Record Updated";
        } else {
            toastMsg = totalRecordEdited + " Records Updated";
        }

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
                    if (response.getReturnValue() === "Success") {
                        helper.showToast({
                            title: "Record Update",
                            type: "success",
                            message: toastMsg //totalRecordEdited+ " Records Updated"
                        });
                        //$A.get('e.force:refreshView').fire();
                        this.reloadDataTable(component, event, helper);
                    } else {
                        //if update got failed
                        //alert('Failed to update the record');
                        var resp = response.getReturnValue();
                        if (resp.startsWith("Error")) {
                            var errorMSg = resp.split("Error")[1];
                            component.set("v.errorMsg", errorMSg);
                        }
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
    reloadDataTable: function (component, event, helper) {
        var workspaceAPI = component.find("workspace");
        var refreshEvent = $A.get("e.force:navigateToSObject");
        var recId = component.get("v.recordId");
        if (refreshEvent) {
            workspaceAPI
                .isConsoleNavigation()
                .then(function (isConsole) {
                    //if console app
                    if (isConsole) {
                        window.location.reload();
                        /* workspaceAPI.getFocusedTabInfo().then(function(response) {
                                var focusedTabId = response.tabId;
                               workspaceAPI.closeTab({tabId: focusedTabId});
                               // alert('closed tab');
                                workspaceAPI.openTab({
                                    url: '#/sObject/'+recId+'/view',
                                    focus: true

                                });
                                //alert('open tab');

                            });*/
                    } else if (refreshEvent) {
                        var navEvt = $A.get("e.force:navigateToSObject");
                        navEvt.setParams({
                            recordId: component.get("v.recordId")
                        });
                        navEvt.fire();
                    }
                })
                .catch(function (error) {
                    console.log(error);
                });
        } else {
            window.location.reload();
        }

        /* var refreshEvent = $A.get("e.force:navigateToSObject");
            if(refreshEvent){
                var navEvt = $A.get("e.force:navigateToSObject");
                navEvt.setParams({
                    "recordId": component.get("v.recordId"),
                });
                navEvt.fire();
            } else {
                window.location.reload();
            }*/
    },
    sortData: function (component, fieldName, sortDirection) {
        var data = component.get("v.resultList");
        var reverse = sortDirection !== "asc";
        //sorts the rows based on the column header that's clicked
        data.sort(this.sortBy(fieldName, reverse));
        var pageSize = component.get("v.pageSize");
        component.set("v.totalRecords", data.length);
        component.set("v.startPage", 0);
        component.set("v.endPage", pageSize - 1);
        component.set("v.currentPage", 1); // Reseting current page: DTSFCOM-284
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
                    typeof x[field] === "string" ?
                    x[field].toLowerCase() :
                    x[field] :
                    "aaa"
                );
            } :
            function (x) {
                return x.hasOwnProperty(field) ?
                    typeof x[field] === "string" ?
                    x[field].toLowerCase() :
                    x[field] :
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
    /****************************************************
      @description Filter the cases based on search text
      */
    searchFilter: function (component, event, helper) {
        var data = component.get("v.unfilteredResultList");
        var term = component.get("v.searchText");
        var columns = component.get("v.columns");
        var results = data;
        var regex;
        try {
            regex = new RegExp(term, "i");
            // filter checks each row, constructs new array where function returns true
            results = data.filter(row => {
                for (let i = 0; i < columns.length; i++) {
                    var field = columns[i];
                    if (regex.test(row[field.fieldName])) return true;
                }
                return false;
            });
        } catch (e) {
            // invalid regex, use full list
            console.log("Invalid regular expression");
        }

        component.set("v.resultList", results);
        this.loadTable(component, event, helper);
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