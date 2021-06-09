({
    setUserData : function(component) {
        let action = component.get('c.getCurrentUserData');
        action.setCallback(this, function(response) {
            let state = response.getState();
            if (state === "SUCCESS") {
                let respVal = response.getReturnValue();
                const currentUserHelper = component.find('currentUser');
                currentUserHelper.setUserData(respVal);

                const tealiumComponent = component.find('tealium');
                tealiumComponent.setCurrentUser(respVal);
            }
            else if (state === "ERROR") {
                let errors = response.getError();
                console.error(errors);
            }
        });
        action.setBackground();
        action.setStorable();
        $A.enqueueAction(action);
    }
})