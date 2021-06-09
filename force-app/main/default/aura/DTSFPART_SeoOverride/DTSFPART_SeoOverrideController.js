({
    overrideSeo : function(component, event) {
        if (document.title !== 'Widget' || $A.get("$Site.context.viewType") === 'Editor') {
            return;
        }
        let SEOEvt = $A.getEvt("markup://siteforce:setSEOProperties");
    
        if (SEOEvt) {
            SEOEvt.setParams({
                title: event.getParams().label,
            }).fire();
        }
    }
})