({
    doInit : function(component, event, helper) {
        var sectionfieldSetName = component.get('v.sectionfieldSetName');
        var sobjectName = component.get('v.sObjectName');
        var getFormAction = component.get('c.getForm');      
        getFormAction.setParams({
            "fieldSetName": sectionfieldSetName,
            "objectName": sobjectName
        });
        getFormAction.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                var form = response.getReturnValue();
                component.set("v.sectionFields", form.fields);
                var cmpEvt=component.getEvent("PartnerOnBoardingFieldSetEvent");
                cmpEvt.setParams({
                    "fieldSetResult": component.get("v.sectionFields"),
                    "sectionfieldSetName" : component.get("v.sectionfieldSetName")
                });
                cmpEvt.fire();
            }
        });                
        $A.enqueueAction(getFormAction);
    }
})