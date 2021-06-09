({
    doInit : function(component, event, helper){
        var picklistValues = component.get("v.picklistValues");
        component.set("v.isFieldDisable",picklistValues[0].isFieldDisable);
    },
    handlePicklistValueChange : function(component, event, helper){
        var fieldName = event.getSource().get("v.name");
        var fieldValue = event.getSource().get("v.value");
        var objNameWithFields = component.get("v.controllingFieldsMap");
        var objectName = component.get("v.sobjectName");
        var cappRecordTypeName = component.get("v.cappRecordType");
        var cappFieldsMap = objNameWithFields["Customer_Portfolio_Presence__c"];
        var systemFieldsMap = objNameWithFields["System_Relationship__c"];
        var cappControllingList = [];
        var systemControllingList = [];
        for(var key in cappFieldsMap){
            cappControllingList.push(key);
        }
        for(var key in systemFieldsMap){
            systemControllingList.push(key);
        }
        
        var isControlling = helper.validateFieldDependency(component, event, fieldName, cappControllingList, systemControllingList);
        if(isControlling){
            var dependentFieldName;
            if(objectName == "Customer_Portfolio_Presence__c"){
                 dependentFieldName = cappFieldsMap[fieldName];
            }else if(objectName == "System_Relationship__c"){
                 dependentFieldName = systemFieldsMap[fieldName];
            }
            var action = component.get("c.handlePicklistChange");
            action.setParams({ 
                objName 		 : objectName,
                recordTypeName	 : cappRecordTypeName,
                controllingField : fieldName,
                dependentField	 : dependentFieldName,
                fieldValue		 : fieldValue
            });
            action.setCallback(this, function(response){ 
                var state = response.getState();
                if(state == "SUCCESS"){ 
                    var storeResponse = response.getReturnValue();
                    var map = component.get("v.cappRecord");
                    if($A.util.isUndefinedOrNull(storeResponse) || $A.util.isEmpty(storeResponse)){
                        var emptyArray = [];
                        for(var mapkey in map){
                            var outerMap = map[mapkey];
                            for(var innerkey in outerMap){
                                if(outerMap[innerkey] == dependentFieldName){
                                    outerMap["fieldValue"] = "";
                                    var PickListMap = outerMap["pickValues"];
                                    for(var innerKeyOne in PickListMap){
                                        var innerKeyVar = PickListMap[innerKeyOne];
                                        innerKeyVar["isFieldDisable"] = true;
                                        innerKeyVar["picklistValues"] = [];
                                    }
                                }
                            }
                        }
                    }else{
                        for(var mapkey in map){
                            var outerMap = map[mapkey];
                            for(var innerkey in outerMap){
                                if(outerMap[innerkey] == dependentFieldName){
                                    var PickListMap = outerMap["pickValues"];
                                    for(var innerKeyOne in PickListMap){
                                        var innerKeyVar = PickListMap[innerKeyOne];
                                        if(outerMap["isReadOnly"]){
                                            innerKeyVar["isFieldDisable"] = true;
                                        }else{
                                            innerKeyVar["isFieldDisable"] = false;
                                        }
                                        innerKeyVar["picklistValues"] = storeResponse;
                                    }
                                }
                            }
                        }
                    }
                    var callParentMethod = component.get("v.refreshDependentPicklist");
                    $A.enqueueAction(callParentMethod);
                }else{
                    console.log("Error while getting dependent values = "+response.getReturnValue());
                }
            });
            $A.enqueueAction(action);
        }
    },
})