({
    handlePubsubReady: function(component, event, helper) {
        const pubsub = component.find('pubsub');
        const callback = $A.getCallback(function() {
            helper.refreshPage(component);
        });
        pubsub.registerListener('refreshPage', callback);
    }
});