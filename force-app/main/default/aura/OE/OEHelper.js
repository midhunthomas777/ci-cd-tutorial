({
    changePureCloudStatus: function (component, userId, statusApiName) {
        var action = component.get("c.changePureCloudStatus");
        action.setParams({
            "userId": userId,
            "statusApiName": statusApiName
        });
        action.setCallback(this, function (response) {
            console.log('###In the helper method##');
        })
        $A.enqueueAction(action);
    },

    changePureCloudStatusOnCapacity: function (component, userId, param) {
        var action = component.get("c.changePureCloudStatusOnCapacity1");
        console.log('IN the cmp helper: Val of Param is '+param);
        action.setParams({
            "userId": userId,
            "parameter": param
        });
        action.setCallback(this, function (response) {
            console.log('###In the helper method##');
        })
        $A.enqueueAction(action);
    }
})