({
    handleUserLoaded: function (component, event, helper) {
        component.set("v.isUserLoaded", true);
    },
    handleAccountLoaded: function (component, event, helper) {
        component.set("v.isAccountLoaded", true);
    }
})