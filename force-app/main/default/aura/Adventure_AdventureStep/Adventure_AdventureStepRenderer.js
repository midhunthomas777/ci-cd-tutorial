/*
 * Copyright (c) 2018. 7Summits Inc.
 * Created by 7Summits - Joe Callin on 8/19/18.
 */
({
    afterRender: function (component, helper) {
        this.superAfterRender();
        // interact with the DOM here
        var windowWidth = window.innerWidth;
        window.addEventListener("resize", function(){
            if(window.innerWidth !== windowWidth){
                helper.setHeader(component, helper);
                helper.setModule(component, helper);
            }
        });
    },
})