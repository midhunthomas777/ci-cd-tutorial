({
    handleChange : function(component, event, helper) {
        helper.shiptoInfo(component, event, helper);
    },
    handlechangeinvalue : function(component, event, helper) {
        var selected = component.find("selected").get("v.value");
        if(selected === "yes")
            component.set("v.RMARequestFormWrapper.userenDetails.shipToInformation", "no");
    },
    addLineItem : function(component, event, helper){
        helper.addlineItemrow(component, event, helper);
    },
    removeRow : function(component, event, helper){
        helper.removeLineItem(component, event, helper);
    },
    reviewRMAForm: function(component, event, helper){
        helper.validateUserInput(component, event, helper);
    },
    resetForm : function(component, event, helper) {
        helper.loadDefaultValues(component, event, helper);
    }
})