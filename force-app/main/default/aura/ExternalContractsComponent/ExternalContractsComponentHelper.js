({
    /****************************************************
       @description Set the columns of the contract list table
       */
    setColumns: function (component, event, helper) {
        component.set("v.columns", [{
                label: "State",
                fieldName: "SITE_STATE",
                type: "text",
                sortable: "true"
            },
            {
                label: "End User Site Name",
                fieldName: "SITE_NAME",
                type: "text",
                sortable: "true"
            },
            {
                label: "Site ID",
                fieldName: "END_USER_SITE_NUMBER",
                type: "text",
                sortable: "true"
            },
            {
                label: "Contract Number",
                fieldName: "url",
                type: "url",
                sortable: "true",
                typeAttributes: {
                    target: "_blank",
                    label: {
                        fieldName: "CONTRACT_NUMBER"
                    },
                    name: {
                        fieldName: "CONTRACT_NUMBER"
                    }
                }
            },
            {
                label: "Part (Service) Description",
                fieldName: "ITEM_DESCRIPTION",
                type: "text",
                sortable: "true"
            },
            {
                label: "Start Date",
                fieldName: "SERVICE_START_DATE",
                type: "date",
                sortable: "true",
                typeAttributes: {
                    day: "2-digit",
                    month: "short",
                    year: "numeric"
                }
            },
            {
                label: "End Date",
                fieldName: "SERVICE_END_DATE",
                type: "date",
                sortable: "true",
                typeAttributes: {
                    day: "2-digit",
                    month: "short",
                    year: "numeric"
                }
            }
        ]);
    },
    /****************************************************
       @description Display all contracts
       */
    getContractsList: function (component, event, helper) {
        component.set("v.loadSpinner", true);
        var action = component.get("c.contractList");
        var currentAccountId = component.get("v.recordId");
        action.setParams({
            accountId: currentAccountId
        });

        action.setCallback(this, function (response) {
            var state = response.getState();
            var response = response.getReturnValue();
            var errorCodes = [
                "ERROR",
                "NOACCESS",
                "APIError",
                "Read timed out",
                "INTERNAL"
            ];
            if (state === "SUCCESS" && !errorCodes.includes(response)) {
                let contracts = JSON.parse(response);

                if (contracts.length > 0) {
                    let baseUrl = $A.get("$Site").siteUrlPrefix;
                    contracts.forEach(function (record) {
                        record.url =
                            baseUrl +
                            "/externalcontractdetail?contract_number=" +
                            record.CONTRACT_NUMBER;

                        if (!$A.util.isUndefinedOrNull(record.SERVICE_START_DATE))
                            record.SERVICE_START_DATE = new Date(record.SERVICE_START_DATE);

                        if (!$A.util.isUndefinedOrNull(record.SERVICE_END_DATE))
                            record.SERVICE_END_DATE = new Date(record.SERVICE_END_DATE);
                    });
                } else {
                    // no data
                    component.set("v.errorMsg", "No Records Found.");
                    component.set("v.loadNavigationBtns", false);
                }

                component.set("v.contractList", contracts);
                component.set("v.unfilteredContractList", contracts);

                // apply all filters
                this.applyAllFilters(component, event, helper);

                component.set("v.loadSpinner", false);
                component.set("v.refreshTable", true);
            } else {
                component.set("v.loadSpinner", false);
                component.set("v.refreshTable", true);
                this.displayResponse(component, event, response);
            }
        });
        $A.enqueueAction(action);
    },
    /****************************************************
       @description Display  message if any error from server
       */
    displayResponse: function (component, event, response) {
        var message = "";
        if (response == "NOACCESS") {
            message = "Insufficient Privileges, please try another one.";
        } else if (response == "APIError") {
            message =
                "Request has not been submitted successfully, please retry after some time.";
        } else {
            message = response;
        }
        this.showToast(component, message, "error");
        component.set("v.loadSpinner", false);
    },
    /****************************************************
       @description Display error message as toast
       */
    showToast: function (component, message, messageType) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title: messageType + "!",
            type: messageType,
            message: message
        });
        toastEvent.fire();
    },

    changePageSize: function (component, event, helper) {
        var selectedPageSize = component.get("v.selectedPageSize");
        component.set("v.dynamicPageSize", selectedPageSize);
    },

    applyAllFilters: function (component, event, helper) {
        component.set("v.refreshTable", false);
        var fromDate = component.get("v.fromValue");
        var toDate = component.get("v.toValue");
        var searchText = component.get("v.searchText");
        var columns = component.get("v.columns");

        var data = component.get("v.unfilteredContractList");

        var results = data;

        // setting To Date time attribute for the better comparison results as
        var toDateTime = new Date(toDate);
        toDateTime.setHours(23);
        toDateTime.setMinutes(59);
        toDateTime.setSeconds(59);

        var regex = new RegExp(searchText, "i");

        results = data.filter(row => {
            var flagDate = true;
            var flagSearch = false;

            // filter by from and to date
            if (fromDate && new Date(row.SERVICE_END_DATE) < new Date(fromDate)) {
                flagDate = false;
            }
            if (toDate && new Date(row.SERVICE_END_DATE) > toDateTime) {
                flagDate = false;
            }

            // filter by search text
            if (
                !$A.util.isUndefinedOrNull(searchText) &&
                !$A.util.isEmpty(searchText)
            ) {
                for (let i = 0; i < columns.length; i++) {
                    var field = columns[i];
                    if (regex.test(row[field.fieldName])) flagSearch = true;
                }
            } else {
                flagSearch = true;
            }

            // show the rows which met all filter criteria
            return flagDate && flagSearch;
        });

        component.set("v.contractList", results);
        component.set("v.refreshTable", true);
    },

    getURLParameterValue: function () {
        var querystring = location.search.substr(1);
        var paramValue = {};
        querystring.split("&").forEach(function (part) {
            var param = part.split("=");
            paramValue[param[0]] = decodeURIComponent(param[1]);
        });
        return paramValue;
    },
    setDateFilter: function (component) {
        let today = new Date();
        component.set("v.fromValue", today.toISOString());
        today.setMonth(today.getMonth() + 6);
        component.set("v.toValue", today.toISOString());
    }
});