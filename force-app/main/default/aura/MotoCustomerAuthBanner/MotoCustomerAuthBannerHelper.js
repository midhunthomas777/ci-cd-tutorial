({
    setUserInfo: function(component, event, helper) {
        let action = component.get("c.getAccountName");

        action.setCallback(this, function(response) {
            console.log(response.getState());
            if (response.getState() === "SUCCESS") {
                let data = response.getReturnValue();
                console.log('data',data);
                component.set("v.accountName", data.accountName);
            }
        });

        $A.enqueueAction(action);
    },
})