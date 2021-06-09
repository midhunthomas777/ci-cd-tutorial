({
    handleFileUploadChange : function(component,event,helper) {
        helper.getFileIds(component,event,helper,'event');
    },

    doInit : function(component,event,helper) {
        helper.getFileIds(component,event,helper,'init');
    },

})