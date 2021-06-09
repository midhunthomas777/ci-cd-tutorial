/**
 * Created by melindagrad on 8/19/18.
 *  Copyright (c) 2018. 7Summits Inc.
 */
({
    linkClick: function(component, event, helper) {
        var url = event.currentTarget.dataset.url;
        helper.goToUrl(component, event, helper, url);
    }
})