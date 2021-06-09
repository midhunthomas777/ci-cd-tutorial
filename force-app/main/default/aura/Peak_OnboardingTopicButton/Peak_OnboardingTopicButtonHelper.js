/**
 * Created by jonbalza on 2019-09-15.
 */
({
    handleFollow: function (component, event) {
        component.set("v._loading", true);
        var followEvent = component.getEvent("onFollow");
        followEvent.setParams({
            value: "follow",
            id: component.get("v.id")
        });
        followEvent.fire();
    },

    handleUnfollow: function (component, event) {
        component.set("v._loading", true);
        var unfollowEvent = component.getEvent("onUnfollow");
        unfollowEvent.setParams({
            value: "unfollow",
            id: component.get("v.id")
        });
        unfollowEvent.fire();
    }
})