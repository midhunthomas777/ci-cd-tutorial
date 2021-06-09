/**
 * Created by Melinda Grad on 7/25/18.
 * Copyright (c) 2018. 7Summits Inc.
 */
({
    linkClick: function(component, event, helper) {
        var url = event.currentTarget.dataset.url;
        helper.goToUrl(component, event, helper, url);
    },
    openSingleFile: function(component, event, helper) {

        var file = component.get('v.moduleTask');
        var document = file.ContentDocumentLinks[0].ContentDocumentId;

        $A.get('e.lightning:openFiles').fire({
            recordIds: [document]
        });
    }
})