({
    doInit : function(component, event, helper){
        var fieldType = component.get("v.fieldType");
        if(fieldType != "BOOLEAN"){
            var optn = component.get("v.allOptions");
            for(var outerloop in optn){
                var options = optn[outerloop].picklistValues;
                component.set("v.options",options);
            }
            var vals = component.get("v.valueInString");
            var allValues = vals.split(";");
            component.set("v.value",allValues);
        }
    },
    handleChange : function(component, event, helper){
        var selectedOptionValue = event.getParam("value");
        component.set("v.valueInString",selectedOptionValue.toString().replace(/,/g ,';'));
    },
    handleCheck : function(component, event, helper){
        var isChecked = component.find("checkboxField").get("v.checked");
        var currentRecord = component.get("v.currentRecord");
        var fieldName = component.get("v.fieldName");
        var map = component.get("v.cappRecord");
        if(!$A.util.isUndefinedOrNull(currentRecord) || !$A.util.isEmpty(currentRecord)){
            for(var mapkey in currentRecord){
                var outerMap = currentRecord[mapkey];
                for(var innerkey in outerMap){
                    if(outerMap[innerkey] == fieldName){
                        if(isChecked){
                            outerMap['fieldValue'] = 'true';
                        }else{
                            outerMap['fieldValue'] = 'false';
                        }
                    }
                }
            }
        }
    },
})