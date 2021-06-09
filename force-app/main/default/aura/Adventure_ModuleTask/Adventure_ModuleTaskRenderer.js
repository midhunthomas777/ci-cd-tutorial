/*
 * Copyright (c) 2018. 7Summits Inc.
 * Created by 7Summits - Joe Callin on 8/15/18.
*/
({
    afterRender: function (component, helper) {
        this.superAfterRender();
        var lastTask = component.get('v.lastTask');
        if(lastTask) {
            var renderEvent = component.getEvent('renderEvent');
            renderEvent.setParams({
                type: 'module'
            });
            renderEvent.fire();
        }
    },
})