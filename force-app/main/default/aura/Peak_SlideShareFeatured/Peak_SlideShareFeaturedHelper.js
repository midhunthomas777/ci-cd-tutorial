({
	getPost : function(component, url) {
        var action = component.get("c.getSlideSharePresentation");
        
        action.setParams({postUrl : url});
        action.setCallback(this, function(response) {
            var value = response.getReturnValue()
            if(value == 'ERROR')
            {
                component.set('v.error', 'Please set up a Remote Site Setting for https://www.slideshare.net');
                return;
            }
           	var data = JSON.parse(value);
            
            data['embedUrl'] = data['html'].match(/\bhttps?:\/\/www.slideshare.net\/slideshow\/embed_code\S+/gi)[0].replace('"', '');
            data['url'] = url;
            
            var posts = component.get('v.posts');

            posts.push(data);
            component.set('v.posts', posts);
        });
        $A.enqueueAction(action);
    }
});