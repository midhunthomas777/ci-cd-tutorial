({
    getNavigationItems : function(component) {
        let action = component.get('c.callMulesoftWithCache');
        action.setParams({
            params: 'format=grouped',
            mulesoftAction: 'DTSFPART_C360_NavigationLinks',
            namedCredential: component.get('v.mulesoftCredentials'),
            useFederationId: true
        });
 
        action.setCallback(this, function(response) {
            let state = response.getState();
            if (state === "SUCCESS") {
                let respVal = response.getReturnValue();
                this.parseNavigationLinks(component, JSON.parse(respVal.body));
            }
            else if (state === "ERROR") {
                let errors = response.getError();
                console.error(errors);
            }
        });
        action.setBackground();
        $A.enqueueAction(action);
    },

    parseNavigationLinks : function(component, links) {
        component.set('v.navigationLinks', links._embedded.categories.reduce((acc, category) => ({ ...acc, [category.category]: category.groups }), {}));
    },

    getCartCookieValue : function(component) {
        let cartCookieValue = this.getCookie(component.get('v.cartCookieName'));
        component.set('v.cartCookieValue', cartCookieValue ? cartCookieValue : 0);
    },

    setCookieListener : function(component) {
        let hidden, visibilityChange;

        if (typeof document.hidden !== "undefined") {
            hidden = "hidden";
            visibilityChange = "visibilitychange";
        } else if (typeof document.msHidden !== "undefined") {
            hidden = "msHidden";
            visibilityChange = "msvisibilitychange";
        } else if (typeof document.webkitHidden !== "undefined") {
            hidden = "webkitHidden";
            visibilityChange = "webkitvisibilitychange";
        }

        if (typeof document.addEventListener !== "undefined" && hidden !== undefined) {
            document.addEventListener(visibilityChange, this.getCartCookieValue.bind(this, component), false);
        }
    },

    getCookie : function(cname) {
        let name = cname + "=";
        let decodedCookie = decodeURIComponent(document.cookie);
        let ca = decodedCookie.split(';');
        for (let i = 0; i < ca.length; i++) {
          let c = ca[i];
          while (c.charAt(0) == ' ') {
            c = c.substring(1);
          }
          if (c.indexOf(name) == 0) {
            return c.substring(name.length, c.length);
          }
        }
        return "";
    },

    closeSearch : function(component) {
        let closeButton = component.find('header-search-close-button').getElement();
        if (closeButton && window.getComputedStyle(closeButton).display !== 'none') {
            closeButton.click();
        }        
    }

})