/**
 * Created by jonbalza on 2019-09-15.
 */
({
    handleClick: function(component, event, helper) {
        var clickEvent = component.getEvent("onclick");
        clickEvent.setParams({
            message: component.get("v.pageNumber"),
            slide: component.get("v.pageName")
        });
        clickEvent.fire();
    }
})