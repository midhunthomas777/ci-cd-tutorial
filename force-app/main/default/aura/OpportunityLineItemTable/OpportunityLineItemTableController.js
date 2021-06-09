({
    doInit : function(component, event, helper){
        component.set("v.loadSpinner", true);
        var rowActions = [{'label': 'Delete', 'iconName': 'utility:delete', 'name': 'delete'}];
        component.set("v.columns", [
            {label: 'Product Family Name', fieldName: 'name', type: 'text', initialWidth: 300},
            {label: 'Line Description', fieldName: 'description', type: 'text', editable: true, initialWidth: 300},
            {label: 'Unit Price', fieldName: 'unitPrice', type: 'currency', editable: true, initialWidth: 120},
            {label: 'Start Date', fieldName: 'startDate', type: 'date-local', editable: true, initialWidth: 150},
            {label: 'End Date', fieldName: 'endDate', type: 'date-local', editable: true, initialWidth: 150},   
            {type: 'action', typeAttributes: {rowActions: rowActions}}
        ]);
        helper.fetchMetaMessages(component, helper);
    },
    onCellChange : function(component, event, helper){
        var existingData = component.get("v.productList");
        var modifiedRecord = component.find("tableId").get("v.draftValues");
        var modifiedRowIds = [];
        for(var i=0;i<modifiedRecord.length;i++){
            var modifiedRow = modifiedRecord[i];
            for(var item in modifiedRow){
                if(item == "Id"){
                    modifiedRowIds.push(modifiedRow[item]);
                    break;
                } 
            }
        }
        for(var i=0;i<existingData.length;i++){
            var row = existingData[i];
            for(var item in row){
                if(item == "rowId" && modifiedRowIds.includes(row["rowId"])){
                    for(var j=0;j<modifiedRecord.length;j++){
                        var modifiedRow = modifiedRecord[j];
                        for(var modifiedCol in modifiedRow){
                            if(modifiedCol != "Id" && row["rowId"] == modifiedRow["Id"]){
                                row[modifiedCol] = modifiedRow[modifiedCol];
                            }
                        }
                    }
                }
            }
        }
        component.set("v.productList", existingData);
    },
    onRowAction : function(component, event, helper){
        var action = event.getParam("action");
        if(action.name == "delete"){
            helper.removeProductRow(component, event, helper);
        }
    },
    redirectToOpportunity : function(component, event, helper){
        component.find("navService").navigate({
            type: "standard__recordPage",
            attributes: {
                recordId   	  : component.get("v.oldOpportunityId"),
                objectApiName : "Opportunity",
                actionName    : "view"
            }
        });
    },
    validateProducts : function (component, event, helper){
        var metaMessages = component.get("v.metaMessages");
        component.set("v.loadSpinner", true);
        component.set("v.errorMsg", "");
        var isValidated = true;
        var data = component.get("v.productList");
        for(var i=0;i<data.length;i++){
            var row = data[i];
            if(row.startDate > row.endDate){
                isValidated = false;
                component.set("v.errorMsg", metaMessages['Renewal_Start_End_Date_Check'].Message__c);
                component.set("v.loadSpinner", false);
                break;
            }
        }
        
        if(isValidated){
            helper.renewalOpportunity(component, event, helper);
        }
    },
});