({
	getPost: function (component, url) {
		const action = component.get("c.getInstagramPost");

		action.setParams({postUrl: this.normalizeUrl(component, url)});

		action.setCallback(this, function (response) {
			if (response.getReturnValue() === 'No Media Match') {
				component.set('v.error', 'Invalid Instagram URL. Check your URL and privacy settings');
				return;
			}

			let returnValue = response.getReturnValue();
			if (returnValue) {
				let data = JSON.parse(returnValue);
				data['url'] = url;

				let posts = component.get('v.posts');
				posts.push(data);
				component.set('v.posts', posts);
				console.log(posts);
			}
		});
		$A.enqueueAction(action);
	},

	getMetaData: function (component, record) {
		const action = component.get("c.getMetaData");

		action.setParams({"recordLabel": record});
		action.setCallback(this, function (response) {
			let posts = response.getReturnValue().split(",");
			if (posts != null) {
				posts.forEach(function (element) {
					let action = component.get("c.getInstagramPost");

					action.setParams({postUrl: this.normalizeUrl(component, element)});
					action.setCallback(this, function (response) {
						if (response.getReturnValue() === 'No Media Match') {
							component.set('v.error', 'Invalid Instagram URL exists. Check your URL and privacy settings');
							return;
						}

						let returnValue = response.getReturnValue();

						if (returnValue) {
							let data = JSON.parse(returnValue);
							data['url'] = element;

							let posts = component.get('v.posts');
							posts.push(data);
							component.set('v.posts', posts);
						}
					});
					$A.enqueueAction(action);
				});
			}
		});
		$A.enqueueAction(action);
	},

	normalizeUrl: function(component, url){
		let newUrl = url;

		// ignore parameters
		let paramIndex = url.lastIndexOf('?');
		if (paramIndex !== -1) {
			newUrl = newUrl.slice(0, paramIndex);
		}

		// trailing slash
		if (newUrl.slice(-1)[0] !== '/') {
			newUrl += '/';
		}

		return newUrl;
	}
});