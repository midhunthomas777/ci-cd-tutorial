({
    initPeakContentTile: function (component, event, helper) {
        var className = "";
        var darkText = component.get("v.darkText");

        if (darkText) {
            className += " darktext ";
        }

        component.set("v.className", className);
    }
});