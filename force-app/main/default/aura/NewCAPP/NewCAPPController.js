({
    doInit : function(component,event,helper){
        component.set("v.showSpinner",true);
        helper.identifyCurrentAPP(component, event, helper);
        helper.getcurrentObject(component,event,helper);
        helper.getCAPPControllingFields(component,event,helper);
        helper.getCAPPDetails(component,event,helper);
        helper.getCompetitorRecId(component, event, helper);
    },
    refreshNewCAPP : function(component,event,helper){
        $A.get("e.force:refreshView").fire();
        var tabName = event.getParam("tabName");
        component.set("v.selectedTabName",tabName);
    },
})