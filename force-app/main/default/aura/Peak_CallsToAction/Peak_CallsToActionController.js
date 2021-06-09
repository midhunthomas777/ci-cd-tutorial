({
    doInit : function(component, event, helper) {
        helper.initComponent(component);
    },

    handleClick: function(component, event, helper) {
        var id = event.getParam("Id");

        var navEvt = $A.get("e.force:navigateToURL");
        navEvt.setParams({
            "url": id,
        });
        navEvt.fire();
    }
})