/**
 * Created by jonbalza on 2019-09-12.
 */
({
    handleClick: function(component, event, helper) {
        let following = component.get("v.following");
        if(following) {
            helper.handleUnfollow(component, event);
        } else {
            helper.handleFollow(component, event);
        }
    }
})