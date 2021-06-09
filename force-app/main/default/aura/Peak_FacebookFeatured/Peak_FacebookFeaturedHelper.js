/**
 * Created by jasondaluga on 7/10/18.
 */
({
    getMetaData : function(component, record) {
        var action = component.get("c.getMetaData");
        console.log(component.get('v.record'));
        action.setParams({ "recordLabel" : component.get('v.record') });
        action.setCallback(this, function(response) {
            var posts = response.getReturnValue().split(",");
            console.log(posts);
            var length = posts.length;

            if(length > 0)
            {
               component.set('v.post1href', posts[0]);
               if(length > 1)
               {
                   component.set('v.post2href', posts[1]);
                   if(length > 2)
                   {
                       component.set('v.post3href', posts[2]);
                   }
               }
            }
        });
        $A.enqueueAction(action);
    }
})