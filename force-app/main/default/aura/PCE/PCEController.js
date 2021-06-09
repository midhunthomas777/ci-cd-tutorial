({
    onClientEvent: function (component, message, helper) {
        var eventData = message.getParams();
        if (eventData) {
            var message = JSON.stringify(eventData);
            helper.outputToConsole(component, message);
            if (eventData.type === 'Interaction' && eventData.data.id) {
                component.set("v.interactionId", eventData.data.id);
            }
            //check
            var categoryValue = eventData.category;
            var callState = eventData.data.state;
            var pureCloudId = eventData.data.id;
            var userId = $A.get("$SObjectType.CurrentUser.Id");
            console.warn('###agentID####'+userId);
            var timezone = $A.get("$Locale.timezone");
            var mydate = new Date().toLocaleString("en-US", { timeZone: timezone })
            console.log('##callState##' + callState);
            console.log('##pureCloudId##' + pureCloudId);
            console.log('##mydate##' + mydate);
            if (pureCloudId != '' && categoryValue == 'disconnect' && callState == 'DISCONNECTED') {
                helper.releaseCapacity(component, pureCloudId,userId);
            }
        }
    },

    statusBreak: function (component, event, helper) {
        helper.statusUpdate(component, 'Break');
    },

    statusAvailable: function (component, event, helper) {
        helper.statusUpdate(component, 'Available');
    },

    disconnect: function (component, event, helper) {
        helper.stateUpdate(component, 'disconnect');
    },

    pickup: function (component, event, helper) {
        helper.stateUpdate(component, 'pickup');
    },

    mute: function (component, event, helper) {
        helper.stateUpdate(component, 'mute');
    },

    hold: function (component, event, helper) {
        helper.stateUpdate(component, 'hold');
    },

    securePause: function (component, event, helper) {
        helper.stateUpdate(component, 'securePause');
    },

    addAttributes: function (component, event, helper) {
        helper.addAttributes(component);
    }
})