/**
 * Created by melindagrad on 8/13/18.
 * Copyright (c) 2018. 7Summits Inc.
 */
({
    init: function(component, event, helper) {
        var numberOfLinks = component.get('v.numberOfLinks');

        var linkList = [];

        for(var i = 1; i <= numberOfLinks; i++){
            var label = component.get('v.label' + i);
            var link = component.get('v.link' + i);
            var icon = component.get('v.icon' + i);

            if(!$A.util.isUndefinedOrNull(link) && !$A.util.isEmpty(link)){
                    linkList.push({
                        link : link,
                        label : label,
                        icon : icon
                    });
            }
        }
        component.set('v.linkList', linkList);
    },

    linkClick: function(component, event, helper) {
        var url = event.currentTarget.dataset.url;
        helper.goToUrl(component, event, helper, url);
    }
})