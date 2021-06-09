({
    doInit : function(component, event, helper) {
        console.log('Highlights INit');
        var recId = component.get('v.recordId');
        var fieldsetName =  component.get('v.fieldSetName');
        if (!$A.util.isUndefinedOrNull(fieldsetName) && !$A.util.isEmpty(fieldsetName) && !$A.util.isUndefinedOrNull(recId) && !$A.util.isEmpty(recId)){
            var action = component.get('c.getHighLightedFields'); 
            action.setParams({
                'recId': recId,
                'fieldSetName' : fieldsetName
            });        
            action.setCallback(this, function(response) { 
                var state = response.getState();
                component.set("v.showSpinner", false);
                if(state === 'SUCCESS'){ 
                    var respRes = response.getReturnValue();
                    component.set('v.result',respRes);
                    var childField='';
                    for(var key in respRes){
                        if(key === 'Name'){
                            component.set('v.title',respRes[key])
                        } else {
                            if(key === 'Id') {
                                continue;
                            }
                            childField += respRes[key]+ ' • '; 
                        }
                    } 
                    component.set('v.metaField',childField);
                }
            });
            $A.enqueueAction(action);
        }else{
            component.set("v.showSpinner", false);
            component.get('v.errorMsg', 'Record Id and FieldSet is required' );
        }
    },
    
    redirectToDetailPage : function (component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
        var workspaceAPI = component.find("workspace");
        var recId = component.get('v.recordId');
        workspaceAPI.isConsoleNavigation().then(function(isConsole) {
            //if console app
            if(isConsole){
                workspaceAPI.getFocusedTabInfo().then(function(response) {
                    var focusedTabId = response.tabId;
                    workspaceAPI.closeTab({tabId: focusedTabId});
                });
                workspaceAPI.openTab({
                    url: '/lightning/r/Account/'+recId+'/view',
                    label: 'Account'
                });
            } else {
				//Other than Console app
                window.open('/lightning/r/Account/'+recId+'/view', '_self');
            }
        })
        .catch(function(error) {
            console.log(error);
        });
        /* -- this is not working as expected
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": recId,
            "slideDevName": "detail"
        });
        navEvt.fire();*/
        
    }   
})