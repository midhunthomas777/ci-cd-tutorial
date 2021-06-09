({
    getPriceBook: function (component, event, helper) {
        component.set("v.loadSpinner", true);
        var action = component.get("c.getPriceBookName");
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var currentPriceBook = response.getReturnValue();
                if (currentPriceBook) {
                    this.setColumns(component, event, helper, currentPriceBook);
                } else {
                    this.setColumnsNoPriceBook(component, event, helper);
                }
                component.set("v.loadSpinner", false);
            }
        });
        $A.enqueueAction(action);
    },
    setColumns: function (component, event, helper, currentPriceBook) {
        component.set("v.columns", [{
                label: "Part Number",
                fieldName: "Item_number__c",
                type: "text",
                sortable: true
            },
            {
                label: "Name",
                fieldName: "Name",
                type: "text",
                sortable: "true"
            },
            {
                label: "MSRP",
                initialWidth: 90,
                fieldName: "List_Price__c",
                type: "currency",
                sortable: "true"
            },
            {
                label: "Price",
                initialWidth: 90,
                fieldName: currentPriceBook,
                type: "currency",
                sortable: "true"
            }
        ]);
    },
    setColumnsNoPriceBook: function (component, event, helper) {
        component.set("v.columns", [{
                label: "Part Number",
                fieldName: "Item_number__c",
                type: "text",
                sortable: true
            },
            {
                label: "Name",
                fieldName: "Name",
                type: "text",
                sortable: "true"
            },
            {
                label: "MSRP",
                initialWidth: 90,
                fieldName: "List_Price__c",
                type: "currency",
                sortable: "true"
            }
        ]);
    },
    /****************************************************
      @description View all Parts and Pricing
      */
    viewAll: function (component, event, helper) {
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            url: "/partsandpricingpage"
        });
        urlEvent.fire();
    },
    /****************************************************
      @description Filter the Parts and Pricing based on search text
      */
    searchFilter: function (component, event, helper) {}
});