({
    getData : function(component, event,helper) {
        var action = component.get("c.getFieldsData");
        action.setParams({
            accountId: component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS"){
                var fieldsArray = [];
                var parentFieldsName = [],childFieldsName = [],grandChildFieldsName =[];
                var counter = 0,grandChildCounter = 0,secondLevelSRCounter=0;
                var finalResponse = response.getReturnValue();
                var finalData = finalResponse.finalData;
                for(var data in finalData) {
                    var record = finalData[data];
                    var parentFields = record["fieldList"];
                    for(var individualField in parentFields){
                        var referenceName;
                        var individualRecord = parentFields[individualField];
                        var fieldName = individualRecord["fieldName"];
                        record[fieldName] = individualRecord["fieldValue"];
                        var fieldType = helper.defineFieldType(component, individualRecord["fieldType"]);
                        if(individualRecord["fieldType"] == "reference"){
                            referenceName = individualRecord["referenceName"];
                            record[referenceValue] = individualRecord[referenceName];
                        }
                        if(fieldName != "genericName"){
                            fieldsArray.push({
                                "fieldLabel" 	: individualRecord["fieldLabel"],
                                "fieldName"  	: individualRecord["fieldName"],
                                "fieldType"	 	: fieldType,
                                "referenceName" : referenceName
                            });
                            parentFieldsName.push(individualRecord["fieldName"]);
                        }
                    }
                    
                    var childRecords = record["items"];
                    for(var childIndex in childRecords) {
                        var eachChildRecord = childRecords[childIndex];
                        var childFields = eachChildRecord["fieldList"];
                        for(var fieldIndex in parentFieldsName){
                            var parentField = parentFieldsName[fieldIndex];
                            eachChildRecord[parentField] = "";
                        }
                        
                        for(var individualField in childFields){
                            var referenceName = '';
                            var fieldRecord = childFields[individualField];
                            var fieldName = fieldRecord["fieldName"];
                            eachChildRecord[fieldName] = fieldRecord["fieldValue"];
                            if(fieldName != "genericName"){
                                record[fieldName] = "";
                            }
                            var fieldType = helper.defineFieldType(component, fieldRecord["fieldType"]);
                            if(fieldRecord["fieldType"] == "reference" || fieldName == 'cappName'){
                                referenceName = fieldRecord["referenceName"];
                                eachChildRecord[referenceName] = fieldRecord["referenceValue"];
                            } 
                            if(counter == 0 && fieldName != "genericName"){
                                fieldsArray.push({
                                    "fieldLabel" 	: fieldRecord["fieldLabel"],
                                    "fieldName"  	: fieldRecord["fieldName"],
                                    "fieldType"	 	: fieldType,
                                    "referenceName" : referenceName
                                });
                                childFieldsName.push(fieldRecord["fieldName"]);
                            }
                        }
                        counter++;
                        var grandChildRecords = eachChildRecord["items"];
                        console.log('grandchildrec..'+JSON.stringify(grandChildRecords));
                        for(var grandChildIndex in grandChildRecords){
                            var grandChildRecord = grandChildRecords[grandChildIndex];
                            var grandChildFields = grandChildRecord["fieldList"];
                            for(var fieldIndex in parentFieldsName){
                                var parentField = parentFieldsName[fieldIndex];
                                grandChildRecord[parentField] = "";
                            }
                            for(var fieldIndex in childFieldsName) {
                                var childFieldName = childFieldsName[fieldIndex];
                                grandChildRecord[childFieldName] = "";
                            }
                            for(var individualField in grandChildFields){
                                var referenceName='';
                                var fieldRecord = grandChildFields[individualField];
                                var fieldName = fieldRecord["fieldName"];
                                grandChildRecord[fieldName] = fieldRecord["fieldValue"];
                                var fieldType = helper.defineFieldType(component, fieldRecord["fieldType"]);
                                if(fieldName != "genericName"){
                                    record[fieldName] = "";
                                    eachChildRecord[fieldName] = "";
                                } 
                                if(fieldType == 'reference' || fieldName == 'SR Name'){
                                    referenceName = fieldRecord["referenceName"];  
                                    grandChildRecord[referenceName] = fieldRecord["referenceValue"];
                                    eachChildRecord[referenceName] = '';
                                    record[referenceName] = '';     
                                }
                                if(grandChildCounter == 0 && fieldName != "genericName"){
                                    fieldsArray.push({
                                        "fieldLabel" 	: fieldRecord["fieldLabel"],
                                        "fieldName"  	: fieldRecord["fieldName"],
                                        "fieldType"	 	: fieldType,
                                        "referenceName" : referenceName
                                    }); 
                                }
                                grandChildFieldsName.push(grandChildRecord[fieldName]);   
                            }
                            grandChildCounter++;
                            
                            var secondLevelSRRecords = grandChildRecord["items"]; 
                            for(var secondLevelSRIndex in secondLevelSRRecords){
                                var secondLevelSRRecord = secondLevelSRRecords[secondLevelSRIndex];
                                var secondLevelSRFields = secondLevelSRRecord["fieldList"];
                                for(var fieldIndex in parentFieldsName){
                                    var parentField = parentFieldsName[fieldIndex];
                                    secondLevelSRRecord[parentField] = "";
                                }
                                for(var fieldIndex in childFieldsName) {
                                    var childFieldName = childFieldsName[fieldIndex];
                                    secondLevelSRRecord[childFieldName] = "";
                                }
                                if(fieldName != "genericName"){
                                    record[fieldName] = "";
                                    eachChildRecord[fieldName] = "";
                                } 
                                for(var individualField in secondLevelSRFields){
                                    var referenceName = '';  
                                    var fieldRecord = secondLevelSRFields[individualField];
                                    var fieldName = fieldRecord["fieldName"];
                                    secondLevelSRRecord[fieldName] = fieldRecord["fieldValue"];
                                    var fieldType = helper.defineFieldType(component, fieldRecord["fieldType"]);
                                    if(fieldType == 'reference'|| fieldName == 'SR Name') {
                                        referenceName = fieldRecord["referenceName"];
                                        secondLevelSRRecord[referenceName] = fieldRecord["referenceValue"];
                                        eachChildRecord[referenceName] = '';
                                        record[referenceName] = '';
                                    }                                 
                                }
                                secondLevelSRCounter++;
                                
                                var thirdLevelSRRecords = secondLevelSRRecord["items"];
                                for(var thirdLevelSRIndex in thirdLevelSRRecords){
                                    var thirdLevelSRRecord = thirdLevelSRRecords[thirdLevelSRIndex];
                                    var thirdLevelSRFields = thirdLevelSRRecord["fieldList"];
                                    for(var fieldIndex in parentFieldsName){
                                        var parentField = parentFieldsName[fieldIndex];
                                        thirdLevelSRRecord[parentField] = "";
                                    }
                                    for(var fieldIndex in childFieldsName) {
                                        var childFieldName = childFieldsName[fieldIndex];
                                        thirdLevelSRRecord[childFieldName] = "";
                                    }
                                    for(var individualField in thirdLevelSRFields){
                                        var referenceName = '';  
                                        var fieldRecord = thirdLevelSRFields[individualField];
                                        var fieldName = fieldRecord["fieldName"];
                                        thirdLevelSRRecord[fieldName] = fieldRecord["fieldValue"];
                                        var fieldType = helper.defineFieldType(component, fieldRecord["fieldType"]);
                                        if(fieldType == 'reference' || fieldName == 'SR Name') {
                                        referenceName = fieldRecord["referenceName"];
                                            thirdLevelSRRecord[referenceName] = fieldRecord["referenceValue"];
                                        eachChildRecord[referenceName] = '';
                                        record[referenceName] = '';
                                    }
                                }
                                    var fourthLevelSRRecords = thirdLevelSRRecord["items"];
                                    for(var fourthLevelSRIndex in fourthLevelSRRecords){
                                        var fourthLevelSRRecord = fourthLevelSRRecords[fourthLevelSRIndex];
                                        var fourthLevelSRFields = fourthLevelSRRecord["fieldList"];
                                        for(var fieldIndex in parentFieldsName){
                                            var parentField = parentFieldsName[fieldIndex];
                                            fourthLevelSRRecord[parentField] = "";
                                        }
                                        for(var fieldIndex in childFieldsName) {
                                            var childFieldName = childFieldsName[fieldIndex];
                                            fourthLevelSRRecord[childFieldName] = "";
                                        }
                                        for(var individualField in fourthLevelSRFields){
                                            var referenceName = '';
                                            var fieldRecord = fourthLevelSRFields[individualField];
                                            var fieldName = fieldRecord["fieldName"];
                                            fourthLevelSRRecord[fieldName] = fieldRecord["fieldValue"];
                                            var fieldType = helper.defineFieldType(component, fieldRecord["fieldType"]);
                                            if(fieldType == 'reference'|| fieldName == 'SR Name') {
                                                referenceName = fieldRecord["referenceName"];
                                                fourthLevelSRRecord[referenceName] = fieldRecord["referenceValue"];
                                            }
                                        }
                                        var fifthLevelSRRecords = fourthLevelSRRecord["items"]; 
                                        for(var fifthLevelSRIndex in fifthLevelSRRecords){
                                            var fifthLevelSRRecord = fifthLevelSRRecords[fifthLevelSRIndex];
                                            var fifthLevelSRFields = fifthLevelSRRecord["fieldList"];
                                            for(var fieldIndex in parentFieldsName){
                                                var parentField = parentFieldsName[fieldIndex];
                                                fifthLevelSRRecord[parentField] = "";
                                            }
                                            for(var fieldIndex in childFieldsName) {
                                                var childFieldName = childFieldsName[fieldIndex];
                                                fifthLevelSRRecord[childFieldName] = "";
                                            }
                                            for(var individualField in fifthLevelSRFields){
                                                var referenceName='';  
                                                var fieldRecord = fifthLevelSRFields[individualField];
                                                var fieldName = fieldRecord["fieldName"];
                                                fifthLevelSRRecord[fieldName] = fieldRecord["fieldValue"];
                                                var fieldType = helper.defineFieldType(component, fieldRecord["fieldType"]);
                                                if(fieldType == 'reference'|| fieldName == 'SR Name') {
                                                    referenceName = fieldRecord["referenceName"];
                                                    fifthLevelSRRecord[referenceName] = fieldRecord["referenceValue"];
                                                    eachChildRecord[referenceName] = '';
                                                    record[referenceName] = '';
                                                }
                                            }
                                        }//End of fifth Level SR Loop
                                    } //End FourthLevel SR Loop   
                                }  //End thirdLevelSR Loop
                            } //End grandGrandChild(SecondLevelSr) Loop
                        } //End grandChild Loop
                    }//End child Record Loop
                }//End Parent Loop 
                component.set("v.fieldsArray",fieldsArray);
                var stringifyAccData = JSON.stringify(finalData);
                var finalGridData = JSON.parse(JSON.stringify(stringifyAccData).split("items").join("_children"));
                component.set("v.gridData", JSON.parse(finalGridData));
                component.set("v.gridExpandedRows", finalResponse.expandedRows);
                helper.setGridColumns(component, event, helper);
                
            }
            else if(state === "ERROR"){
                component.set("v.loadSpinner", false);
                var errors = response.getError();
                if(!($A.util.isUndefinedOrNull(errors) || $A.util.isEmpty(errors))){
                    component.set("v.errorMsg",errors[0].message);
                }else{
                    component.set("v.errorMsg","Some Exception Occured");
                }
                console.log(errors);
            }
        });
        $A.enqueueAction(action);
    },
    defineFieldType : function(component, fieldType) {
        if(fieldType == "DATE") {
            fieldType = "date";
        }else if(fieldType == "DATETIME") {
            fieldType = "datetime";
        }else if(fieldType == "REFERENCE") {
            fieldType = 'reference';
        }else if(fieldType == "CURRENCY") {
            fieldType = "currency";
        }else if(fieldType == "PERCENT") {
            fieldType  = "percentage";
        }else if(fieldType == "PHONE") {
            fieldType = "phone";
        }else if(fieldType == "EMAIL"){
            fieldType = "email";
        }else{
            fieldType = "text";
        }
        return fieldType;
    },
    setGridColumns : function(component, event){
        var columnWidth = 150;
        var gridColumns = [];
        var urlTarget = component.get("v.urlTarget");
        var fieldsArray = component.get("v.fieldsArray");
        for(var index in fieldsArray){
            var singleField = fieldsArray[index];
            var fieldName = singleField["fieldName"];
            if(singleField["fieldType"] == "reference" || fieldName == 'cappName' || fieldName == 'SR Name'){
                var referenceName = singleField["referenceName"];
                gridColumns.push({ 
                    "label"			: singleField["fieldLabel"],
                    "fieldName" 	: singleField["fieldName"],
                    "type"			: "url",
                    "typeAttributes": {
                        "label":{"fieldName": referenceName},
                        "target": urlTarget
                    },
                    "initialWidth"  :columnWidth
                });
            }else{ 
                gridColumns.push({
                    "label"		: singleField["fieldLabel"],
                    "fieldName" : singleField["fieldName"],
                    "type"		: singleField["fieldType"],
                    "initialWidth"  : columnWidth
                });
            }
        }
        component.set("v.gridColumns", gridColumns);
    }   
})