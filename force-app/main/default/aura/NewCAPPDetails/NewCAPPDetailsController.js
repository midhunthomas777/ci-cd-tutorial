({
    doInit: function(component, event, helper){
        var incomingKey = component.get("v.key");
        var map = component.get("v.fieldSetMap");
        var CAPPMeta = [];
        var singleMap = map[incomingKey];
        for (var key in singleMap) {
            CAPPMeta.push({
                value: singleMap[key],
                key: key
            });
        }
        component.set("v.value", CAPPMeta);
    },
})