({
    getUserDetails: function (component, event, helper) {
        var action = component.get("c.getUserDetails");
        action.setParams({ "communityName" : $A.get("$Site").communityName});
        var menuItems = [];
        action.setCallback(this, function (response) {
            var state = response.getState();
            var response = response.getReturnValue();
            var errorCodes = ['ERROR', 'NOACCESS', 'APIError', 'Read timed out', 'INTERNAL'];
            console.log(response);
            if (state === 'SUCCESS' && !errorCodes.includes(response)) {
                component.set('v.currentUser', response);
                if(response.sso){
                    component.set('v.loginUrl', response.sso.LoginUrl);
                    component.set('v.logoutUrl',$A.get("$Site").coreUrlPrefix+'/secur/logout.jsp');
                }
                if (response.isVestaPartnerAdmin) {
                    if (component.get('v.showUserMenuAdminAccount')) {
                        menuItems.push('My Company');
                    }
                }
                if (component.get('v.showUserMenuAccountPreferences')) {
                    menuItems.push('Account Preferences');
                }
                if (component.get('v.showUserMenuResetPassword')) {
                    menuItems.push('Reset Password');
                }
                menuItems.push('Sign out');
                
                component.set('v.options', menuItems);
            } else {
                console.log(response);
            }
        });
        
        $A.enqueueAction(action);
        
    },
    navigateToAccount: function (component, event, helper) {
        var currentUser = component.get("v.currentUser");
        var navService = component.find("navService");
        var pageReference = {
            type: 'standard__recordPage',
            attributes: {
                objectApiName: 'Account',
                actionName: 'view',
                recordId: currentUser.accountId
            }
        };
        event.preventDefault();
        navService.navigate(pageReference, true);
    },
    navigateToSupport: function (component, event, helper) {
        var urlEvent = $A.get("e.force:navigateToURL");
        var supportUrl = "/" + component.get("v.supportUrl");
        console.log(supportUrl);
        urlEvent.setParams({
            "url": supportUrl
        });
        urlEvent.fire();
    },
    navigateToAccountPreferences: function (component, event, helper) {
        var staticLabel = $A.get("$Label.c.AEM_Preferences");
        window.open(staticLabel, '_top');
    },
    navigateToResetPassword: function (component, event, helper) {
        var staticLabel = $A.get("$Label.c.AEM_Password");
        window.open(staticLabel, '_top');        
    },
    navigateToLogout: function (component, event, helper) {
        var logout = component.get("v.logoutUrl");
        window.open(logout, '_top');
    },
    navigateToSignIn: function (component, event, helper) {
        var login = component.get("v.loginUrl");
        window.open(login, '_self');
    },
    setUrl: function (component, event, helper) {
        component.set("v.rootPath", $A.get("$Site").siteUrlPrefix);
    }
})