({
    doInit: function(component, event, helper) {
        var incomingKey = component.get("v.key");
        var map = component.get("v.map");
        var CAPPMeta = map[incomingKey];
        component.set("v.value", CAPPMeta);
    }
})