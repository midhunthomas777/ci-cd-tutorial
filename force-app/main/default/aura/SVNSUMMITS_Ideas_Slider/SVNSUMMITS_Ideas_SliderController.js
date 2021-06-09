/*
 * Copyright (c) 2019. 7Summits Inc.
 */
({
    onInit: function(component, event, helper) {
        // Figure out what screensize we're looking at
        window.addEventListener("resize", function () {
            helper.setScreenSize(component, event, helper);
        });
        helper.setScreenSize(component, event, helper);
    },

    handlePagination: function(component, event, helper) {
        const nextPage = event.currentTarget.dataset.page;

        component.set("v.currentSlide", parseInt(nextPage));
        helper.setPagination(component, event, helper);
    }
})