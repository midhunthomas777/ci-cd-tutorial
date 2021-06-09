({
    fetchRegions : function(component, event, helper) {
        var action = component.get('c.getRegions');
        action.setParams({
            "objectName" : 'Opportunity',
            "fieldName" : 'Region__c'
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === 'SUCCESS' && component.isValid()){
                var resp= response.getReturnValue();
                component.set("v.lstRegion", resp);
            }
        });
        $A.enqueueAction(action);
    },
    fetchRegionTerritory : function(component, event, helper) {
        var regionSelected = component.get("v.regionSelected");
        var action = component.get('c.getRegionTerritory');
        action.setParams({
            "region" : regionSelected,
            "objectName" : 'Opportunity',
            "controllingField" : 'Region__c',
            "dependentField" : 'Territory__c',
            "isStandardAddress" : false
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === 'SUCCESS' && component.isValid()){
                var resp= response.getReturnValue();
                console.log('resp'+JSON.stringify(resp));
                component.set("v.lstTerritory", resp);
            }
        });
        $A.enqueueAction(action);
    },
})