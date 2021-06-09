({
    getCountries : function(component,event,helper){
        var action = component.get("c.fetchCountry");
        action.setCallback(this, function(response) { 
            var state = response.getState();
            if(state === 'SUCCESS'){
                var respRes = response.getReturnValue();
                component.set("v.countryList",respRes);
            }else{
                console.log(response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
    },
    setDefaultDropdowns : function(component, event, helper, dropdown){
        helper.setStateToDefault(component, event, helper);
    },
    setStateToDefault : function(component, event, helper){
        component.find("state").set("v.value","");
        var states = component.get("v.stateList");
        states.push({
            "label" : "--None--",
            "value" : ""
        });
        component.set("v.stateList",states);
    },
    getProvinceOptions : function(component, event, helper, country){
        var action = component.get('c.fetchStates');
        action.setParams({
            "countryLabel" : country,
            "isStandardAddress" : true
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            console.log('States are'+state);
            if(state === 'SUCCESS'){
                var resp= response.getReturnValue();
                console.log('States are resp'+resp);
                component.set("v.stateList", resp);
                component.find("state").set("v.value","");
                    if(resp.length > 1){
                        component.set("v.stateDisabled",false);
                    }else{
                        component.set("v.stateDisabled",true);
                    }
            }
        });
        $A.enqueueAction(action)
    },
})