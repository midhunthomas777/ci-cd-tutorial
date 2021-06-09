({
	validateFieldDependency : function(component, event, fieldName, cappControllingList, systemControllingList){
		var objectName = component.get("v.sobjectName");
        if(objectName == "Customer_Portfolio_Presence__c"){
            if(cappControllingList.indexOf(fieldName) > -1){
                return true;
            }
        }else if(objectName == "System_Relationship__c"){
            if(systemControllingList.indexOf(fieldName) > -1){
                return true;
            }
        }
        return false;
	},
})