({
    doInit : function(component, event, helper) {
        helper.fetchAccountType(component);
        helper.getUserType(component,event,helper);
    },
    open:function(component, event, helper) {
        component.set("v.openpop" , true);
    },
    close:function(component, event, helper){
        component.set("v.openpop",false);
    },
    handlePubsubReady: function (component) {
        const pubsub = component.find("pubsub");
        const callback = $A.getCallback(function () {
            component.set("v.openpop" , true);
        });
        pubsub.registerListener("openQuoteModal", callback);
    },
})