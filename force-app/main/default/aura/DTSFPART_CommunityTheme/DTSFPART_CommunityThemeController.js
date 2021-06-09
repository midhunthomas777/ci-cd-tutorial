({
    doInit : function(component, event, helper) {
        helper.setUserData(component);
        
        let communityMode = component.get('v.communityMode').replace(/[\W]+/g, '-').toLowerCase();
        component.set('v.mode', communityMode);
        component.set('v.combinedCssClass', ['motorola-theme', communityMode, component.get('v.cssClass')].join(' '));
        
        if ($A.get("$Site.context.viewType") === 'Editor') {
            component.set('v.quickActionsLabel', true);
        }
        if (!(component.get('v.globalHeader') && component.get('v.globalHeader')[0])) {
            return;
        }
        
        try {
            let globalHeader = component.get('v.globalHeader')[0].get('v.body')[0].get('v.body')[0];
            if (!globalHeader.isInstanceOf('c:DTSFPART_CommunityGlobalHeader')) {
                return;
            }
            globalHeader.set('v.search', component.get('v.search'));
            globalHeader.set('v.profileMenu', component.get('v.profileMenu'));
            globalHeader.set('v.mode', component.get('v.communityMode').toLowerCase());
            globalHeader.setMulesoftCredentials(component.get('v.mulesoftCredentials'));
        } catch (e) {
            /* Silent fail */
            console.log(e);
        }
    }
})