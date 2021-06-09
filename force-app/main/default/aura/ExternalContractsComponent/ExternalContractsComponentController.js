({
    doInit: function (component, event, helper) {
        //set filter for expiring contracts
        if (helper.getURLParameterValue().s === "open") {
            helper.setDateFilter(component);
        }
        helper.setColumns(component, event, helper);
        helper.getContractsList(component, event, helper);
    },
    handleFilter: function (component, event, helper) {
        helper.applyAllFilters(component, event, helper);
    },
    handlePageSizeChange: function (component, event, helper) {
        helper.changePageSize(component, event, helper);
    }
});