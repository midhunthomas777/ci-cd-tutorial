({
    doInit : function(component, event, helper) {
        var posts = "";
        if(component.get('v.useMetaData')) helper.getMetaData(component, component.get('v.record'));
        else component.set('v.posts', component.get('v.postURLs').split(","));
    }
})