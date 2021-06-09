/*
 * Copyright (c) 2019. 7Summits Inc. All rights reserved.
 *
 */

({
    init: function (component, event, helper){
        helper.getUpdatedUserRecord(component, event, helper);
        helper.getRegionPicklist(component, event);
        helper.getIndustryPicklist(component, event);
    },
    handleUploadFinished: function (component, event, helper) {
        // Get the list of uploaded files
        var uploadedFiles = event.getParam("files");
        console.log('DD: JSON>> ' , JSON.stringify(uploadedFiles[0]));
        var documentId = uploadedFiles[0].documentId;
        var fileName = uploadedFiles[0].name;
        helper.setPhoto(component, event, helper, documentId, fileName);
    },
    goToNext : function(component, event, helper) {
        helper.updateName(component, event, helper);
        helper.goToNext(component, event, helper);
    },
    goBack : function(component, event, helper) {
        helper.goBack(component, event, helper);
    }
})