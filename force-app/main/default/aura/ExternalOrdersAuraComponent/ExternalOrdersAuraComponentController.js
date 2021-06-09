({
    doInit: function (component, event, helper) {
        var payload = helper.createItemFromObj(component, event, helper);
        var currentAccountId = component.get("v.recordId");
        component.set("v.pageName", window.document.title);
        var pageName = component.get("v.pageName");
        if (pageName == "Home") {
            payload.pageSize = 10;
            $A.util.addClass(component.find("title"), "extra-space");
        }

        //get only open orders if coming from open order link
        var paramName = helper.getURLParameterValue().s;
        if (paramName == "open") {
            // payload.p_order_status = "1";
            component.set("v.selectedStatus", "Open (Multiple Statuses)");
        }
        helper.getOpenOrdersParameters(component);
        helper.setColumns(component, event, helper);
        // this is for Home Page i.e. for Parnter Users
        if (
            $A.util.isUndefinedOrNull(currentAccountId) ||
            $A.util.isEmpty(currentAccountId)
        ) {
            helper.getOrdersList(component, event, helper, payload);
        } else {
            // this is for Field Technician
            var params = {
                accountId: currentAccountId
            };
            var accountDataPromise = helper.serverCallUsingPromise(
                component,
                "c.getAllMCNs",
                params
            );
            accountDataPromise.then(
                $A.getCallback(function (result) {
                    payload.customer_number = result;
                    helper.getOrdersList(component, event, helper, payload);
                }),
                $A.getCallback(function (error) {
                    console.log(
                        "An error occurred getting the account : " + error.message
                    );
                })
            );
        }
    },
    handleFilter: function (component, event, helper) {
        //  helper.filterOrdersByDate(component, event, helper);
        helper.applyAllFilters(component, event, helper);
    },
    viewAllOrders: function (component, event, helper) {
        helper.viewAllOrders(component, event, helper);
    },

    handlePageSizeChange: function (component, event, helper) {
        helper.changePageSize(component, event, helper);
    }
});