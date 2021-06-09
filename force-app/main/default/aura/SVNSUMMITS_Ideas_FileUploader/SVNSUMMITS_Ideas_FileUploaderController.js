/*
 * Copyright (c) 2019. 7Summits Inc.
 */

({
    handleUploadFinished: function (component, event, helper) {
        let appEvent = $A.get("e.c:SVNSUMMITS_Ideas_FileUpload_Event");
        appEvent.setParams({});
        appEvent.fire();
    }
});