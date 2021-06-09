({
    doInit: function (component, event, helper) {
        const myViewUrl = helper.getMyViewUrl(component) + '/';
        window.MYVIEW_DOMAIN = myViewUrl;

        if (component.get('v.hash') !== '#' && !window.location.hash.includes(component.get('v.hash'))) {
            window.location.hash = component.get('v.hash');
        }

        const currentUrl = new URL(window.location.href);
        if (currentUrl.searchParams.has('myview')) {
            const myViewLocation = currentUrl.searchParams.get('myview');
            currentUrl.search = '';
            currentUrl.hash = myViewLocation;
            history.replaceState({}, null, currentUrl.href);
        }
        const hasHubParam = currentUrl.href.includes('/hub');
        
        const mvModuleMap = {
            'Coverage': 'device-service-coverage',
            'Repairs': 'repairs',
            'Entitlements': 'entitlements'
        };

        window.MYVIEW_CONFIG = {
            scriptsURL: myViewUrl,
            useHashRouter: true,
            showNav: true,
            urlRewrite: (location) => {
                const parts = (
                    typeof location === 'string' ?
                        location : `${location.pathname || ''}${location.search || ''}${location.hash || ''}`
                ).split('/');
                if (!parts[2]) {
                    return null;
                }
                parts[1] = hasHubParam ? 'hub/s' : 's';
                if (!mvModuleMap.hasOwnProperty(parts[2])) {
                    return false;
                }
                parts[2] = mvModuleMap[parts[2]];
                return `${parts.slice(0, 3).join('/')}?myview=/${parts.slice(3).join('/')}&module=${parts[2]}`;
            }
        };

        window.callMuleProxy = function (data) {
            const myView = component.find('myView');
            return myView.callMuleProxy(data);
        };

        $A.createComponent(
            "ltng:require",
            {
                scripts: $A.get('$Resource.DTSFPART_MyView'),
                afterScriptsLoaded: component.getReference('c.onScriptsLoad')
            },
            function(scripts, status, error) {
                if (status === 'SUCCESS') {
                    let body = component.get('v.body');
                    body.push(scripts);
                    component.set('v.body', body);
                } else {
                    console.error(error);
                }
            }
        );
    },

    onScriptsLoad : function(component, event, helper) {
        const myView = component.find('myView');
        const serviceHash = myView.getHash();
        loadMyViewResources();
        if (serviceHash) {
            setTimeout($A.getCallback(() => {
                window.location.hash = `#${serviceHash}`;
            }));            
        }
    },

    handleDestroy : function(component, event, helper) {
        if (window.cleanupMv) {
            window.cleanupMv();
        }
    },

    onMyViewClick : function(component, event, helper) {
        if (event.srcElement.nodeName !== 'A' || !event.srcElement.href.includes('?myview=')) {
            return;
        }
        event.preventDefault();
        
        const myView = component.find('myView');
        
        const moduleToApiName = {
            'device-service-coverage': 'Device_Service_Coverage__c',
            'repairs': 'Device_Repairs__c',
            'entitlements': 'Entitlements__c',
        };
        
        const myViewUrl = new URL(event.srcElement.href);
        const myViewLocation = myViewUrl.searchParams.get('myview');
        const myViewModule = myViewUrl.searchParams.get('module');
        
        const pageReference = {
            type: 'comm__namedPage',
            attributes: {
                name: moduleToApiName[myViewModule]
            }
        };

        myView.navigate(pageReference, myViewLocation);
    }
})