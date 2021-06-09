/*
 * Copyright (c) 2018. 7Summits Inc.
 * Created by 7Summits - Joe Callin on 8/14/18.
*/
({
    afterRender: function (component, helper) {
        this.superAfterRender();
        var lastStep = component.get('v.lastStep');
        if(lastStep){
            var renderEvent = component.getEvent('renderEvent');
            renderEvent.setParams({
                type: 'header'
            });
            renderEvent.fire();
        }

    },
})