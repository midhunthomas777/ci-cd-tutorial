({
    doInit : function(component, event, helper) {
        window.TEALIUM_URL = component.get('v.tealiumLibraryUrl');
        window.utag_data = {};

        component.addEventHandler("selfService:routeChange", component.getReference("c.handleRouteChange"));
        component.addEventHandler("siteforce:setSEOProperties", component.getReference("c.handleSeoEvent"));
    },

    scriptsLoaded : function(component, event, helper) {
        helper.checkTemporaryQueue(component);

        window.addEventListener('tealiumloaded', () => { 
            if (utag && (utag.data.tealium_environment === 'dev' || utag.data.tealium_environment === 'qa')) {
                component.set('v.debugMode', true);
            }
            if (utag.loader.cfg && utag.loader.cfgsort && utag.loader.cfg[utag.loader.cfgsort[0]]) {
                utag.loader.cfg[utag.loader.cfgsort[0]].cb = () => {
                    helper.scriptsLoaded(component);
                    helper.invokeEventsQueue(component);
                };
            } else {
                setTimeout(() => {
                    let scriptElement = document.querySelector(`script[src*="${utag.cfg.v}"]`);
                    if (!scriptElement) {
                        helper.scriptsLoaded(component);
                        helper.invokeEventsQueue(component);
                        return;
                    }
                    scriptElement.onload = () => {
                        helper.scriptsLoaded(component);
                        helper.invokeEventsQueue(component);
                    };
                });
            }
        });
    },

    handleSeoEvent : function(component, event, helper) {
        let params = event.getParams();
        if (params && params.title !== '' && params.title !== 'Widget') {
            component.set('v.lastPageName', params.title);
            helper.updatePageName(component, params);
        }
    },
    
    handleRouteChange : function(component, event, helper) {
        const eventParams = event.getParams();
        
        component.set('v.currentRecordId', eventParams.routeParams.recordId);

        let tealiumEvent = {
            'action': 'pageview',
            'data-page-uet': {
                'customer-id': $A.get('$SObjectType.CurrentUser.Email'),
                'page-name': helper.getPageNameMapping(eventParams.routeMetadata.seo_title),
                'page-uri': helper.getPageUrl(eventParams.routeMetadata),
                'user-type': component.get('v.currentUser.personaType') ? component.get('v.currentUser.personaType') : '',
                'locale': $A.get('$Locale.langLocale').toLowerCase(),
                'page-category': component.get('v.mode').toLowerCase(),
                'page-type': helper.getPageType(eventParams.routeType, eventParams.routeMetadata)
            }
        };        

        try {
            tealiumEvent['data-page-uet']['customer-id'] = msiEmail.encodeEmail($A.get('$SObjectType.CurrentUser.Email'), true);
            helper.pageViewEvent(component, tealiumEvent);
        } catch (e) {
            component.set('v.temporaryEvent', tealiumEvent);
        }
        
    },

    handleTealiumEvent : function(component, event, helper) {
        helper.sendTealiumEvent(component, event);
    },

    setCurrentUser: function(component, event, helper) {
        component.set('v.currentUser', event.getParam('arguments').currentUser);
        helper.updateUserType(component);
    }
});