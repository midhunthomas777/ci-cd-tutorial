({ 
    doInit:function(component, event, helper){
        helper.showButton(component);
        helper.getTermsConditions(component);
    },
    open: function(component, event, helper){
        helper.openPopup(component);
    },
    Agree:function(component, event, helper){
        helper.updateContact(component);
    },
    close:function(component, event, helper){
        component.set("v.openPopup",false);
    }
})