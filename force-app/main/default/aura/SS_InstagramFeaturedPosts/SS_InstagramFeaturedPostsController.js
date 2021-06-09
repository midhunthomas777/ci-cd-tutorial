({
	doInit: function (component, event, helper) {
		let posts;

		if (component.get('v.useMetaData')) {
			helper.getMetaData(component, component.get('v.record'));
		}
		else {
			const postUrls = component.get('v.postURLs');

			if (postUrls && postUrls.length > 1) {
				posts = postUrls.split(",");
				posts.forEach(function (element) {
					if (element.trim()) {
						helper.getPost(component, element);
					}
				});
			} else {
				component.set('v.error', 'Invalid Instagram Post URL. Check your Instagram Post URL setting in the builder');
			}
		}
	}
});