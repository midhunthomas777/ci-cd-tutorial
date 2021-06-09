({
    doInit : function(component, event, helper) {
        var posts = component.get('v.postURLs').split(",");
        
        posts.forEach(function(element) {
            helper.getPost(component, element);
        });
    }
});