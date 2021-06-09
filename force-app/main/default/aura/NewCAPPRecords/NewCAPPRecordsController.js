({
    doInit : function(component, event, helper){
        var recordsMeta = helper.getcurrentValue(component, event, helper);
        component.set("v.value", recordsMeta);
    },
    handleSave : function(component, event, helper){
        component.set("v.cappsData",[]);
        component.set("v.showSpinner",true);
        var recordsForUpdate = [];
        var updatedData = component.get("v.value");
        for(var outerIndex in updatedData){
            var value = updatedData[outerIndex].value;
            for(var recordLevelType in value){
                var recordMapArray = value[recordLevelType];
                for(var mapIndex in recordMapArray){
                    var recordMap = recordMapArray[mapIndex];
                    for(var recordId in recordMap){
                        var fieldsArray = [];
                        var recordDetails = recordMap[recordId];
                        for(var fieldsIterator in recordDetails){
                            if(!recordDetails[fieldsIterator].isFormula){
                                fieldsArray.push({
                                    "fieldName"  : recordDetails[fieldsIterator].fieldName,
                                    "fieldType"	 : recordDetails[fieldsIterator].fieldType,
                                    "fieldValue" : recordDetails[fieldsIterator].fieldValue
                                });
                            }
                        }
                        recordsForUpdate.push({
                            "recordID": recordId,
                            "fields"  : fieldsArray
                        });
                    }
                }
            }   
        }
        component.set("v.cappsData",recordsForUpdate);
        helper.updateRecords(component, event, helper);
    },
})