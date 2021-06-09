/*
 * Copyright (c) 2019. 7Summits Inc.
 */
({
    setPagination: function(component, event, helper) {
        const currentSlide = component.get("v.currentSlide");
        const totalItems = component.get("v.totalItems");
        const itemsPerSlide = component.get("v.itemsPerSlide");

        let paginatorList = [];
        let x;
        // Math.ceil because sometimes someone sets the number of items to something other than 12, and we need to round
        for (x = 1; x <= Math.ceil(totalItems / itemsPerSlide); x++) {
            paginatorList.push({
                slideNum: x,
                active: currentSlide === x
            });
        }

        component.set("v.paginator", paginatorList);
    },

    setScreenSize: function(component, event, helper) {
        const screenWidth = window.innerWidth || document.documentElement.clientWidth || document.body.clientWidth;
        let itemsPerSlide = 1;
        if (screenWidth >= 1280) {
            itemsPerSlide = 4;
        } else if (screenWidth >= 1024) {
            itemsPerSlide = 3;
        } else if (screenWidth >= 768) {
            itemsPerSlide = 2;
        }

        // Reset pagination back to 1, otherwise, sometimes the page no longer exists
        component.set("v.currentSlide", 1);
        component.set("v.itemsPerSlide", itemsPerSlide);

        // Redraw the pagination since we're adjusting it
        this.setPagination(component, event, helper);
    }
})