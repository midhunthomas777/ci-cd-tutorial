/**
 * Created by jasondaluga on 7/10/18.
 */
({
    doInit : function(component, event, helper) {
        if(component.get('v.useMetaData'))
        {
            console.log("here");
            helper.getMetaData(component,component.get('v.record'));
        }
    }
})