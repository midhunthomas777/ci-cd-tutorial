({
    findIdIfParent : function(component, helper) {
        console.log('findIdIfParent');
        var currentRecordId = component.get("v.recordId");
        var parentObjectAPI = component.get("v.parentApiName");        
        var action = component.get('c.findParentId');
        action.setParams({
            "currentRecord" :	currentRecordId,
            "parentObject"	:	parentObjectAPI
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('State is'+state);
            if (state === "SUCCESS") {
                component.set('v.parentId', response.getReturnValue().parentId);
                component.set('v.objectAPIName', response.getReturnValue().objectAPIName);
                component.set('v.objectAPINameLC', response.getReturnValue().lowerCaseName);
                let objName = component.get('v.objectAPIName');
                if (!$A.util.isUndefinedOrNull(objName) && !$A.util.isEmpty(objName)) {
                     this.getFieldsetFields(component, helper);
                }
            }
        });
        $A.enqueueAction(action);
    },
    
    getFieldsetFields : function(component, helper) {
        var objectAPIName = component.get("v.objectAPIName");
        var fieldSetName = component.get("v.fieldSetName");
        var action = component.get('c.readFieldSet');
        action.setParams({
            "fieldSetName" :	fieldSetName,
            "ObjectName"	:	objectAPIName
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log('response getFieldsetFields***'+response.getReturnValue());
                component.set('v.fields', response.getReturnValue());
                console.log('final*****'+component.get('v.fields'));
            }
        });
        $A.enqueueAction(action);
    }
})