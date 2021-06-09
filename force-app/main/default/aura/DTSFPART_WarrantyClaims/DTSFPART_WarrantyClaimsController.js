({
    handleButton : function(component, event, helper) {
        const url = component.get('v.businessonlineUrl') + '/member/WarrantyClaims/WCSubmitForm.asp?FromApp=CP&hdnMode=New';
        let childWindow = window.open(url, '_blank', 'location=no, width=1000, height=700, left=250, top=650');
        
        let timer = setInterval(() => {
            if (childWindow.closed) {
                clearInterval(timer);
                component.find('refresh').refreshWarrantyClaims();
            }
        }, 1000);

        const tealiumTrigger = component.find('tealium-trigger').getElement();
        tealiumTrigger.ANALITYCS.BUTTONS.NEW_WARRANTY_CLAIM(url);        
    },

    settingsReady : function(component, event, helper) {
        const settings = event.getSource();
        component.set('v.businessonlineUrl', settings.service().getUrls().businessonlineUrl);
    }
})