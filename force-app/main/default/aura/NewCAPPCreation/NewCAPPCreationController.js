({
    openModal : function(component, event, helper){
        component.set("v.openModal",true);
        var btnValue = event.getSource().get("v.value");
        if(btnValue == "systemCreation"){
            component.set("v.isSystemCreation",true);
            helper.getfieldsforNewCAPP(component, event, helper);
        }else{
            component.set('v.isSystemCreation',false);
        }
    },
    closeModal : function(component, event, helper){
        component.set("v.openModal",false);
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
    createOrLinkCAPP : function(component, event, helper){
        component.set("v.openModal",false);
        var isCreation = component.get("v.isSystemCreation");
        if(isCreation){
            var newCAPPforCreation = [];
            var systemFieldsArray  = [];
            var accountFieldsArray = [];
            component.set("v.cappsData",[]);
            component.set("v.showSpinner",true);
            var systemRelatedData 	= component.get("v.systemRelatedFields");
            var accountSpecificData = component.get("v.accountSpecificFields");
            for(var index in systemRelatedData){
                systemFieldsArray.push({
                    "fieldName"  : systemRelatedData[index].fieldName,
                    "fieldType"	 : systemRelatedData[index].fieldType,
                    "fieldValue" : systemRelatedData[index].fieldValue
                });
            }
            newCAPPforCreation.push({
                "sectionName" 	  : component.get("v.key"),
                "currentRecordId" : component.get("v.currentRecordId"),
                "currentObjName"  : component.get("v.currentObjName"),
                "fields" 	      : systemFieldsArray,
                "recordID"		  : "CAPPRecordID"
            });
            if(!($A.util.isUndefinedOrNull(accountSpecificData) || $A.util.isEmpty(accountSpecificData))){
                for(var index in accountSpecificData){
                    accountFieldsArray.push({
                        "fieldName"  : accountSpecificData[index].fieldName,
                        "fieldType"	 : accountSpecificData[index].fieldType,
                        "fieldValue" : accountSpecificData[index].fieldValue
                    });
                }
                newCAPPforCreation.push({
                    "sectionName" 	  : component.get("v.key"),
                    "currentRecordId" : component.get("v.currentRecordId"),
                    "currentObjName"  : component.get("v.currentObjName"),
                    "fields" 	      : accountFieldsArray,
                    "recordID"		  : "SYSTEMRecordID"
                });
            }
            component.set("v.cappsData",newCAPPforCreation);
            helper.createCAPP(component, event, helper);
        }
    },
})