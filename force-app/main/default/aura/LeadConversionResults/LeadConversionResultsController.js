({
	doInit : function(component, event, helper) {
        /*helper.getConvertedAccountJS(component,event);
        helper.getConvertedOpportunityJS(component,event);
        helper.getConvertedContactJS(component,event);*/
        component.set("v.url",window.location);
        console.log('Entered doInit');
        console.log('Entered doInit###'+component.get("v.url"));
        
        console.log('Entered doInit acc###'+component.get("v.convertedAccountId"));
        
        console.log('Entered doInit con###'+component.get("v.convertedContactId"));
        
        console.log('Entered doInit opp###'+component.get("v.convertedOpptyId"));
        
	},
    finishClick : function(component,event,helper){
        var accountId = component.get("v.convertedAccountId");
        $A.get("e.force:closeQuickAction").fire();
        //window.open('/lightning/r/Account/'+accountId+'/view', '_self');
        //$A.get('e.force:refreshView').fire();--Its not working as expected
        var workspaceAPI = component.find("workspace");
        workspaceAPI.isConsoleNavigation().then(function(isConsole) {
            //if console app
            if(isConsole){
                workspaceAPI.getFocusedTabInfo().then(function(response) {
                    var focusedTabId = response.tabId;
                    workspaceAPI.closeTab({tabId: focusedTabId});
                });
                workspaceAPI.openTab({
                    url: '/lightning/r/Account/'+accountId+'/view',
                    label: 'Account'
                });
            } else {
				//Other than Console app
                window.open('/lightning/r/Account/'+accountId+'/view', '_self');
            }
        })
        .catch(function(error) {
            console.log(error);
        });
    }
})