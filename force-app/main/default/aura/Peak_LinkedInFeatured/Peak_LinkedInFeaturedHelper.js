/**
 * Created by jasondaluga on 7/11/18.
 */
({
    getMetaData : function(component, record) {
            var action = component.get("c.getMetaData");

            action.setParams({"recordLabel" : record});
            action.setCallback(this, function(response) {
                var posts = response.getReturnValue();
                if(posts != null)
                {
                    component.set('v.posts', posts.split(","));
            	}
            });
            $A.enqueueAction(action);
    }
})