({
    identifyCurrentAPP : function(component, event, helper){
        var workspaceAPI = component.find("workspace");
        workspaceAPI.isConsoleNavigation().then(function(response){
            if(response){
                component.set("v.urlTarget","_parent");
            }
            helper.getData(component, event, helper);
        })
        .catch(function(error){
            console.log("error while identfing the current logged in app = "+error);
        });
    },
    getData : function(component, event, helper){
        var action = component.get("c.getData");
        var params = {"cappRecordId" :component.get("v.recordId")};
        if(params){action.setParams(params);}
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
                var additionalFieldsArry = [];
                var counter = 0;
                var data = response.getReturnValue();
                var systemRelationsData = data.SRData;
                for(var parentKey in systemRelationsData){
                    var parentRecord = systemRelationsData[parentKey];
                    var additionalFields = parentRecord["fields"];
                    if(!($A.util.isUndefinedOrNull(additionalFields) || $A.util.isEmpty(additionalFields))){
                        for(var fieldIndex in additionalFields){
                            var singleField = additionalFields[fieldIndex];
                            var fieldName = singleField["fieldName"];
                            parentRecord[fieldName] = singleField["fieldValue"];
                            if(singleField["fieldType"] == "REFERENCE"){
                                var referenceName = fieldName+'_ref';
                                parentRecord[referenceName] = singleField["referenceName"];
                            }
                            if(counter == 0){
                                var fieldType = singleField["fieldType"];
                                var referenceName;
                                if(fieldType == "DATE"){
                                    fieldType = "date";
                                }else if(fieldType == "DATETIME"){
                                    fieldType = "datetime";
                                }else if(fieldType == "REFERENCE"){
                                    referenceName = singleField["fieldName"]+'_ref';
                                }else if(fieldType == "CURRENCY"){
                                    fieldType = "currency";
                                }else if(fieldType == "PERCENT"){
                                    fieldType = "percentage";
                                }else if(fieldType == "PHONE"){
                                    fieldType = "phone";
                                }else if(fieldType == "EMAIL"){
                                    fieldType = "email";
                                }else{
                                    fieldType = "text";
                                }
                                additionalFieldsArry.push({
                                    "fieldLabel" 	: singleField["fieldLabel"],
                                    "fieldName"  	: singleField["fieldName"],
                                    "fieldType"	 	: fieldType,
                                    "referenceName" : referenceName
                                }); 
                            }
                        }
                        counter++;
                        var child = parentRecord["items"];
                        if(!($A.util.isUndefinedOrNull(child) || $A.util.isEmpty(child))){
                            for(var childKey in child){
                                var childRecord = child[childKey];
                                var additionalFields = childRecord["fields"];
                                for(var fieldIndex in additionalFields){
                                    var singleField = additionalFields[fieldIndex];
                                    var fieldName = singleField["fieldName"];
                                    childRecord[fieldName] = singleField["fieldValue"];
                                    if(singleField["fieldType"] == "REFERENCE"){
                                        var referenceName = fieldName+'_ref';
                                        childRecord[referenceName] = singleField["referenceName"];
                                    }
                                }
                                var grandChild = childRecord["items"];
                                if(!($A.util.isUndefinedOrNull(grandChild) || $A.util.isEmpty(grandChild))){
                                    for(var grandChildKey in grandChild){
                                        var grandChildRecord = grandChild[grandChildKey];
                                        var additionalFields = grandChildRecord["fields"];
                                        for(var fieldIndex in additionalFields){
                                            var singleField = additionalFields[fieldIndex];
                                            var fieldName = singleField["fieldName"];
                                            grandChildRecord[fieldName] = singleField["fieldValue"];
                                            if(singleField["fieldType"] == "REFERENCE"){
                                                var referenceName = fieldName+'_ref';
                                                grandChildRecord[referenceName] = singleField["referenceName"];
                                            }
                                        }
                                        var grandGrandChild = grandChildRecord["items"];
                                        if(!($A.util.isUndefinedOrNull(grandGrandChild) || $A.util.isEmpty(grandGrandChild))){
                                            for(var grandGrandChildKey in grandGrandChild){
                                                var grandGrandChildRecord = grandGrandChild[grandGrandChildKey];
                                                var additionalFields = grandGrandChildRecord["fields"];
                                                for(var fieldIndex in additionalFields){
                                                    var singleField = additionalFields[fieldIndex];
                                                    var fieldName = singleField["fieldName"];
                                                    grandGrandChildRecord[fieldName] = singleField["fieldValue"];
                                                    if(singleField["fieldType"] == "REFERENCE"){
                                                        var referenceName = fieldName+'_ref';
                                                        grandGrandChildRecord[referenceName] = singleField["referenceName"];
                                                    }
                                                }
                                                var superGrandChild = grandGrandChildRecord["items"];
                                                if(!($A.util.isUndefinedOrNull(superGrandChild) || $A.util.isEmpty(superGrandChild))){
                                                	for(var superGrandChildKey in superGrandChild){
                                                        var superGrandChildRecord = superGrandChild[superGrandChildKey];
                                                        var additionalFields = superGrandChildRecord["fields"];
                                                        for(var fieldIndex in additionalFields){
                                                            var singleField = additionalFields[fieldIndex];
                                                            var fieldName = singleField["fieldName"];
                                                            superGrandChildRecord[fieldName] = singleField["fieldValue"];
                                                            if(singleField["fieldType"] == "REFERENCE"){
                                                                var referenceName = fieldName+'_ref';
                                                                superGrandChildRecord[referenceName] = singleField["referenceName"];
                                                            }
                                                        }
                                                    }// superGrandChild FOR LOOP END
                                                }
                                            }// grandGrandChild FOR LOOP END
                                        }
                                    }// grandChild FOR LOOP END
                                }
                            }// child FOR LOOP END
                        }
                    }
                }
                component.set("v.additionalFields",additionalFieldsArry);
                var stringifySRs = JSON.stringify(systemRelationsData);
                var systemRelations = JSON.parse(JSON.stringify(stringifySRs).split("items").join("_children"));
                component.set("v.gridData", JSON.parse(systemRelations));
                component.set("v.gridExpandedRows", data.expandedRows);
                component.set("v.loadSpinner", false);
                helper.setGridColumns(component, event, helper);
            }else if(state === "ERROR"){
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
    setGridColumns : function(component, event, helper){
        var nameWidth,urlWidth = 0;
        var urlTarget = component.get("v.urlTarget");
        var additionalFields = component.get("v.additionalFields");
        if(additionalFields.length >= 3){
            nameWidth = 140;urlWidth = 120;
        }
        var gridColumns = [
            {label: "Name", fieldName: "srRecordURL", type: "url", initialWidth: nameWidth, typeAttributes: {label: {fieldName: "name"}, target: urlTarget}},
            {label: "Account", fieldName: "accountURL", type: "url", initialWidth: urlWidth, typeAttributes: {label: {fieldName: "account"}, target: urlTarget}},
            {label: "Site", fieldName: "siteURL", type: "url", initialWidth: urlWidth, typeAttributes: {label: {fieldName: "site"}, target: urlTarget}}         
        ];
        
        for(var index in additionalFields){
            var singleField = additionalFields[index];
            var fieldName = singleField["fieldName"];
            if(singleField["fieldType"] == "REFERENCE"){
                gridColumns.push({ 
                    "label"			: singleField["fieldLabel"],
                    "fieldName" 	: singleField["fieldName"],
                    "type"			: "url",
                    "typeAttributes": {
                        "label":{"fieldName": singleField["referenceName"]},
                        "target": urlTarget
                    }
                });
            }else{
                gridColumns.push({
                    "label"		: singleField["fieldLabel"],
                    "fieldName" : singleField["fieldName"],
                    "type"		: singleField["fieldType"]
                });
            }
        }
        component.set("v.gridColumns", gridColumns);
    },
})