({
    doInit: function(component, event, helper) {
        helper.getChatConfigurationAndSetChatSettings(component);
    },

    handlePubsubReady: function (component, event, helper) {
        const pubsub = component.find("pubsub");
        const callback = $A.getCallback(function() {
            helper.openChat();
        });
        pubsub.registerListener("openChat", callback);
    }
})