({
    doInit: function (component, event, helper) {
        let pageName = window.document.title;
        if (pageName == "Home") {
            $A.util.addClass(component.find("title"), "extra-space");
        }
        component.set("v.pageName", pageName);
        helper.getPriceBook(component, event, helper);
    },
    handleSearch: function (component, event, helper) {
        helper.searchFilter(component, event, helper);
    },
    viewAllPartsAndPricing: function (component, event, helper) {
        helper.viewAll(component, event, helper);
    }
});