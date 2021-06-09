({
    doInit : function(component, event, helper) {
        helper.retrieveSound(component);
        helper.retrieveSounds(component);
    }, 
    onWorkAssigned : function(component, event, helper) {
        helper.playSound(component);
    },
    handleChange: function(component, event, helper) {
        helper.handleChangedSound(component, event); 
    }
})