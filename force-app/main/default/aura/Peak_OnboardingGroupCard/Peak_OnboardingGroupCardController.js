/**
 * Created by jonbalza on 2019-09-03.
 */
({
    handleRemove: function (component, event) {
        var removeEvent = component.getEvent("onRemove");
        removeEvent.setParams({
            value: "remove",
            id: component.get("v.id")
        });
        removeEvent.fire();
    },

    handleJoin: function (component, event) {
        var joinEvent = component.getEvent("onJoin");
        joinEvent.setParams({
            value: "join",
            id: component.get("v.id")
        });
        joinEvent.fire();
    },

    handleNotificationSettingChange: function (component, event) {
        var changeEvent = component.getEvent("onChange");
        changeEvent.setParams({
            value: event.getSource().get("v.value"),
            id: component.get("v.id")
        });
        changeEvent.fire();
    },

})