({
    doInit : function(component, event, helper){
        var individualRecord = [];
        var recordsMap = component.get("v.value");
        for(var key in recordsMap){
            if(key == "ASSF"){
                var valueArray = recordsMap[key];
                if(($A.util.isUndefinedOrNull(valueArray[0]) || $A.util.isEmpty(valueArray[0])) && valueArray.length == 1){
                    component.set("v.isSystemHeadingDisplay",false);
                }
            }
            individualRecord.push({
                value: recordsMap[key],
                key: key
            });
        }
        component.set("v.individualRecord",individualRecord);
    },
})