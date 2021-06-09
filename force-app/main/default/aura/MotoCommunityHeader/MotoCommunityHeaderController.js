({
    doInit: function(component, event, helper) {
        helper.setUrl(component, event, helper);
        helper.getUserDetails(component, event, helper);
    }, 
    handlePhoneIconClick: function(component, event, helper) {
        helper.navigateToSupport(component, event, helper);
    },
    handleMenuItems: function(component, event, helper) {
        var source = event.getSource();
        var label = source.get("v.label");
        if (label==="Account Preferences") {
            helper.navigateToAccountPreferences(component, event, helper);
        }
        if (label==="Sign out") {
           helper.navigateToLogout(component, event, helper);
        }
        if (label==="My Company") {
            helper.navigateToAccount(component, event, helper);
        }
        if (label==="Reset Password") {
            helper.navigateToResetPassword(component, event, helper);
        }
    },
    handleSignIn: function(component, event, helper) {
        helper.navigateToSignIn(component, event, helper);
    }
})