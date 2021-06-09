({
    doInit : function(component, event, helper){
        var key = component.get("v.key");
        var value = component.get("v.value");
        var finalMap = [];
        if(key.includes("SLF")){
            component.set("v.recordLevelHeading","System-Level Fields");
        }else if(key.includes("ASSF")){
            component.set("v.recordLevelHeading","Account/Site-Specific Fields");
        }
        
        for(var key in value){
            var recordsMap = value[key];
            for(var innerKey in recordsMap){
                finalMap.push({
                    value: recordsMap[innerKey],
                    key: innerKey
                });
            }
        }
        component.set("v.finalMap",finalMap);
    },
    toggleSection : function(component, event, helper){
        var sectionDiv = component.find("ASSF").getElement();
        var sectionState = sectionDiv.getAttribute("class").search("slds-is-open"); 
        if(sectionState == -1){
            sectionDiv.setAttribute("class","slds-section slds-is-open slds-m-left_small slds-m-right_small");
        }else{
            sectionDiv.setAttribute("class","slds-section slds-is-close slds-m-left_small slds-m-right_small");
        }
    },
})