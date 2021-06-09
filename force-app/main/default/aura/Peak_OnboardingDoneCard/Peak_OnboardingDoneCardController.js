/**
 * Created by jonbalza on 2019-09-13.
 */
({
    handleClick: function (component, event) {
        var link = component.get("v.link");
        var clickEvent = component.getEvent("onclick");
        clickEvent.setParams({
            value: link,
            id: "click"
        });
        clickEvent.fire();
    }
})