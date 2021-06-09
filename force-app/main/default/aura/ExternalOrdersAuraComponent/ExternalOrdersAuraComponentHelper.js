({
    getOrdersList: function (component, event, helper, payload) {
        // init the status list for filters
        let lststatus = ["All", "Open (Multiple Statuses)"];
        component.set("v.statuses", lststatus);

        // possible error codes returned from the controller even if we get a
        // HTTP 200
        let errorCodes = [
            "ERROR",
            "NOACCESS",
            "APIError",
            "Read timed out",
            "INTERNAL"
        ];

        // first get the order line status code values for the filters
        // then get the actual orders and derive status to filter on
        // and then set the order lists
        let actionStatus = component.get("c.getOrderStatusMapping");
        actionStatus.setCallback(this, function (response) {
            let state = response.getState();
            let statusMapping = response.getReturnValue();

            if (state === "SUCCESS" && !errorCodes.includes(statusMapping)) {
                // here we've successfully called and returned the status codes,
                // now get the orders

                let actionOrders = component.get("c.ordersList");
                actionOrders.setParams({
                    orderWrapper: JSON.stringify(payload)
                });
                actionOrders.setCallback(this, function (resp) {
                    let state = resp.getState();
                    let response = resp.getReturnValue();

                    if (state === "SUCCESS" && !errorCodes.includes(response)) {
                        // here we've successfully retrieved orders
                        let orders = JSON.parse(response);
                        orders.OrderHistory_data.forEach(function (record) {
                            record.url =
                                document.location.protocol +
                                "//" +
                                document.location.host +
                                $A.get("$Site").siteUrlPrefix +
                                "/" +
                                "externalorderdetail?confirmation_number=" +
                                record.confirmation_number;

                            // order status is one level down, pull it out and flatted the object
                            record.order_status_value = record.order[0].status_value;

                            //JIRA DTSFCOM-290: converting string to date
                            if (typeof record.order_date !== undefined && record.order_date) {
                                record.order_date = new Date(record.order_date);
                            }

                            // transform order_status_value to its corresponding label via statusmapping
                            if (
                                statusMapping[record.order_status_value] != null &&
                                statusMapping[record.order_status_value] != "undefined"
                            ) {
                                record.order_status_value =
                                    statusMapping[record.order_status_value];
                            }

                            // add this order status value to the lststatus filter if it doesn't already exist
                            if (!lststatus.includes(record.order_status_value)) {
                                lststatus.push(record.order_status_value);
                            }
                        });

                        // set the statuses list for the filter, ordersList and a master
                        // unfiltered orders list
                        component.set("v.statuses", lststatus);
                        component.set("v.ordersList", orders.OrderHistory_data);
                        component.set("v.unfilteredOrdersList", orders.OrderHistory_data);

                        // apply all filters once we have got the data
                        this.applyAllFilters(component, event, helper);
                    } else {
                        // error getting orders
                        this.displayResponse(component, event, response);
                    }
                    // turn off progress indicators
                    component.set("v.loadSpinner", false);
                    component.set("v.refreshTable", true);
                }); // end of get orders callback

                // Turn on progress indicators and queue call to get orders
                component.set("v.loadSpinner", true);
                component.set("v.refreshTable", false);
                $A.enqueueAction(actionOrders);
            } else {
                // error getting order statuses
                component.set("v.loadSpinner", false);
                component.set("v.refreshTable", true);

                this.displayResponse(component, event, statusMapping);
            }
        });

        // turn on progress indicators just before enqueue
        component.set("v.loadSpinner", true);
        component.set("v.refreshTable", false);
        $A.enqueueAction(actionStatus);
    },
    getOpenOrdersParameters: function (component) {
        let action = component.get("c.getOpenOrdersParameters");
        action.setCallback(this, response => {
            if (response.getState() === "SUCCESS") {
                component.set(
                    "v.openOrdersParameters",
                    JSON.parse(response.getReturnValue()).values
                );
            }
        });

        $A.enqueueAction(action);
    },
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
    createItemFromObj: function () {
        return {
            p_search_type: null,
            p_search_date_type: null,
            p_ordered_by: null,
            p_search_text: null,
            customer_number: "",
            dt_from_date: null,
            dt_to_date: null,
            pageSize: 1000000,
            pageIndex: 1,
            p_order_status: "All",
            p_SortField: "order_date",
            p_SortDirection: "DESC",
            p_lc_identifier: "VST"
        };
    },

    showToast: function (component, message, messageType) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title: messageType + "!",
            type: messageType,
            message: message
        });
        toastEvent.fire();
    },
    viewAllOrders: function (component, event, helper) {
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            url: "/orderlistpage"
        });
        urlEvent.fire();
    },
    setColumns: function (component, event, helper) {
        component.set("v.columns", [{
                label: "Sales Order Number",
                fieldName: "url",
                type: "url",
                sortable: true,
                typeAttributes: {
                    label: {
                        fieldName: "confirmation_number"
                    },
                    name: {
                        fieldName: "confirmation_number"
                    },
                    target: "_blank"
                }
            },
            {
                label: "End User Site Name",
                fieldName: "endUserSiteName",
                type: "text",
                sortable: true
            },
            {
                label: "Site ID",
                fieldName: "endUserSiteID",
                type: "text",
                sortable: true
            },
            {
                label: "State",
                fieldName: "endUserSiteState",
                type: "text",
                sortable: true
            },
            {
                label: "Customer",
                fieldName: "customer_name",
                type: "text",
                sortable: true
            },
            {
                label: "Customer Order Number",
                fieldName: "purchase_order",
                type: "text",
                sortable: true
            },
            {
                label: "Order Date",
                fieldName: "order_date",
                type: "date",
                sortable: true,
                typeAttributes: {
                    day: "2-digit",
                    month: "short",
                    year: "numeric"
                }
            },
            {
                label: "Status",
                fieldName: "order_status_value",
                type: "text",
                sortable: true
            },
            {
                label: "Account #",
                fieldName: "account_number",
                type: "text",
                sortable: true
            }
        ]);
    },

    applyAllFilters: function (component, event, helper) {
        component.set("v.refreshTable", false);
        var fromDate = component.get("v.fromValue");
        var toDate = component.get("v.toValue");
        var searchText = component.get("v.searchText");
        var columns = component.get("v.columns");
        var selectedStatus = component.get("v.selectedStatus");

        var data = component.get("v.unfilteredOrdersList");

        var results = data;

        // open order statuses
        //WIP- Mario to get back on the open order statuses
        // let openOrderStatuses = ["In Process", "Partially Shipped", "Hold", "Partially Returned"];

        // setting To Date time attribute for the better comparison results as
        // Order Date is date time field
        var toDateTime = new Date(toDate);
        toDateTime.setHours(23);
        toDateTime.setMinutes(59);
        toDateTime.setSeconds(59);

        var regex = new RegExp(searchText, "i");
        let openParameters = component.get("v.openOrdersParameters");

        results = data.filter(row => {
            var flagDate = true;
            var flagStatus = false;
            var flagSearch = false;

            // filter by from and to date
            if (fromDate && new Date(row.order_date) < new Date(fromDate)) {
                flagDate = false;
            }

            if (toDate && new Date(row.order_date) > toDateTime) {
                flagDate = false;
            }

            // filter by status
            if (!selectedStatus || selectedStatus == "All") {
                flagStatus = true;
            } else if (selectedStatus == "Open (Multiple Statuses)") {
                flagStatus =
                    typeof row.last_ship_complete_status === "undefined" ?
                    true :
                    openParameters.includes(row.last_ship_complete_status);
            } else {
                flagStatus = row.order_status_value == selectedStatus;
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

            return flagDate && flagStatus && flagSearch;
        });

        component.set("v.ordersList", results);
        component.set("v.refreshTable", true);
    },
    serverCallUsingPromise: function (component, method, params) {
        var promiseInstance = new Promise(
            $A.getCallback(function (resolve, reject) {
                var action = component.get(method);
                if (params) {
                    action.setParams(params);
                }
                action.setCallback(this, function (response) {
                    var state = response.getState();
                    if (state === "SUCCESS") {
                        resolve(response.getReturnValue());
                    } else if (state === "ERROR") {
                        var errors = response.getError();
                        console.error(errors);
                        reject(response.getError());
                    }
                });
                $A.enqueueAction(action);
            })
        );
        return promiseInstance;
    },
    getURLParameterValue: function () {
        var querystring = location.search.substr(1);
        var paramValue = {};
        querystring.split("&").forEach(function (part) {
            var param = part.split("=");
            paramValue[param[0]] = decodeURIComponent(param[1]);
        });
        return paramValue;
    }
});