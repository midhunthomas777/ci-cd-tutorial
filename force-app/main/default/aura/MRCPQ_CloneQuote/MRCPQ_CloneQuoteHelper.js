({
    getCPQPageURL : function(component) {
        var action1 = component.get("c.getPageUrl");
        var recId = component.get("v.recordId");
        action1.setParams({
            "parentAccID" : recId                     
        });
        action1.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.getPageURL",response.getReturnValue());
            }
        });
        $A.enqueueAction(action1);
    }
})