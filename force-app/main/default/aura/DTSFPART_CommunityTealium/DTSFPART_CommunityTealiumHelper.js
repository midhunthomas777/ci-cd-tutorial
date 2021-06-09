({
    scriptsLoaded : function(component) {
        component.set('v.tealiumReady', true);
    },

    checkTemporaryQueue : function(component) {
        try {
            if (!component.get('v.temporaryEvent')) {
                return;
            }
            let temporaryEvent = component.get('v.temporaryEvent')
            temporaryEvent['data-page-uet']['customer-id'] = msiEmail.encodeEmail(temporaryEvent['data-page-uet']['customer-id'], true);
            this.pageViewEvent(component, temporaryEvent);
        } catch(e) {
            console.error(e);
        }
    },

    sendTealiumEvent: function(component, event) {
        const selectedEvent = new CustomEvent('msiSFCommunitiesDataTransfer', {
            bubbles: true,
            composed: true,
            detail: event.getParams()
        });
        this.debugEvent(component, event.getParams());
        document.dispatchEvent(selectedEvent);
    },

    pageViewEvent : function(component, data) {
        const selectedEvent = new CustomEvent('msiSFCommunitiesDataTransfer', {
            bubbles: true,
            composed: true,
            detail: data
        });

        let eventsQueue = component.get('v.eventsQueue');
        eventsQueue.push(selectedEvent);
        component.set('v.eventsQueue', eventsQueue);
        
        if (
            (component.get('v.lastPageName') === data['data-page-uet']['page-name'] ||
            data['data-page-uet']['page-type'] === 'home page') &&
            document.title !== 'Widget' &&
            !$A.util.isEmpty(component.get('v.currentUser'))
        ) {
            this.invokeEventsQueue(component);
        }
    },

    invokeEventsQueue : function(component) {
        if (component.get('v.lastPageName') === '' || component.get('v.lastPageName') === 'Widget' || !component.get('v.tealiumReady')) {
            return;
        }

        this.checkPIIData(component);

        let eventsQueue = component.get('v.eventsQueue');
        eventsQueue.forEach((ev) => {
            this.debugEvent(component, ev.detail);
            document.dispatchEvent(ev);
        });
        component.set('v.eventsQueue', []);  
    },

    updatePageName : function(component, params) {
        let eventsQueue = component.get('v.eventsQueue');
        if (eventsQueue.length === 0) {
            return;
        }
        
        eventsQueue.forEach((event) => {
            event.detail['data-page-uet']['page-name'] = params.title;
        });        

        if (component.get('v.tealiumReady')) {
            this.invokeEventsQueue(component);
        }
    },

    updateUserType : function(component) {
        let eventsQueue = component.get('v.eventsQueue');
        if (eventsQueue.length === 0) {
            return;
        }
        eventsQueue.forEach((event) => {
            event.detail['data-page-uet']['user-type'] = component.get('v.currentUser.personaType') ? component.get('v.currentUser.personaType') : '';
        });
        this.invokeEventsQueue(component);
    },

    debugEvent : function(component, eventParams) {
        if (!component.get('v.debugMode')) {
            return;
        }
        console.table(Object.assign({ _source: 'Community Components', action: eventParams['action'] }, eventParams.action === 'pageview' ? eventParams['data-page-uet'] : eventParams['data-uet']));
    },

    checkPIIData : function(component) {
        let eventsQueue = component.get('v.eventsQueue');
        eventsQueue.forEach((ev) => {
            if (ev.detail['data-page-uet']['page-type'] === 'record page') {
                let pageName = ev.detail['data-page-uet']['page-name'].split(':');
                ev.detail['data-page-uet']['page-name'] = pageName[0] + ': ' + component.get('v.currentRecordId');
            }
        });  
    },

    getPageType : function(routeType, metadata) {
        if (routeType === 'home') {
            return 'home page';
        }
        switch(metadata.page_type_info.page_reference_type) {
            case 'standard__objectPage':
                return 'object page';
            case 'standard__recordPage':
                return 'record page';
            case 'comm__namedPage':
                return 'custom page';
        }
    },

    getPageUrl : function(metadata) {
        if (metadata.page_type_info.page_reference_type === 'standard__recordPage') {
            let pageUri = window.location.pathname.split('/');
            pageUri.pop();
            return pageUri.join('/');
        } else {
            return window.location.pathname;
        }
    },

    getPageNameMapping : function(pageName) {
        const pageNames = {
            'My dashboard': 'Dashboard'
        };
        return pageNames[pageName] ? pageNames[pageName] : pageName
    }

});