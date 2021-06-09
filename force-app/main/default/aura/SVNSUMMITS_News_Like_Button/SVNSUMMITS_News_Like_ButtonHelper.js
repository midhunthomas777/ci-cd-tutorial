// Copyright ©2016-2017 7Summits Inc. All rights reserved.
({
    like: function (component) {
        var action = component.get("c.likeNews");

        action.setParams({
            recordId: component.get("v.recordId")
        });
        console.log('like');
        action.setCallback(this, function (actionResult) {
            if (actionResult.getReturnValue()) {
                component.set("v.isLiking", true);
                component.set("v.likeCount", component.get("v.likeCount") + 1);
            }
        });

        $A.enqueueAction(action);
    },

    unLike: function (component) {
        var action = component.get("c.unLikeNews");

        action.setParams({
            recordId: component.get("v.recordId")
        });

        action.setCallback(this, function (actionResult) {
            if (actionResult.getReturnValue()) {
                component.set("v.isLiking", false);
                component.set("v.likeCount", component.get("v.likeCount") - 1);
            }
        });

        $A.enqueueAction(action);
    },

    setIsLiking: function (component) {
        var action = component.get("c.isLiking");

        action.setParams({
            recordId: component.get("v.recordId")
        });

        action.setCallback(this, function (actionResult) {
            component.set("v.isLiking", action.getReturnValue());
        });

        $A.enqueueAction(action);
    }
})