({
	handleSelect : function(component, event, helper) {
        var BtnValue = event.getSource().get("v.value"); 
        var temp = false;
        if(BtnValue.includes("removeRow")){
            var tabvalue = component.get("v.tabIdentifier");
            var comEvent = component.getEvent("DeleteRowEvt");
            comEvent.setParams({
                "indexVar" : component.get("v.rowIndex"),
                "processIdentifier" : "addNewcontact",
                "tabValue"			: tabvalue
            });
            comEvent.fire();
        }
	},
    getEmailValue : function (component, event, helper) {
    	var src = event.getSource();
        if(src.get("v.name").includes("addContact")){
            if(src.get("v.value") == 'Other'){
                component.set("v.isEmailDisable",false);
            }else{
                component.set("v.isEmailDisable",true);
                component.set("v.ContactRecord.emailInput","");
            }
        }
    },
})