({

	loadVideosFromYouTubeChannel: function (component, event) {
		const action = component.get("c.getYouTubeVideosByChannel");
		action.setParams({
			results: component.get("v.numberOfVideos"),
			channel: component.get("v.youtubeChannelId"),
			key: component.get("v.apiKey"),
			order: component.get("v.order")
		});

		action.setCallback(this, function (response) {
			if (response.getReturnValue() === 'false') {
				component.set('v.error', 'Invalid Request to YouTube. Please check your channel ID and API Key.');
				return;
			}

			let data = JSON.parse(response.getReturnValue());

			if (data.error !== undefined) {
				component.set('v.error', data.error.errors[0].message + ' | Reason: ' + data.error.errors[0].reason);
				return;
			}

			component.set('v.Videos', data.items);

			if (component.get('v.carouselMode')) {
				this.doSlide(component, 'next');
			}
			else {
				component.set('v.activeVideos', component.get('v.Videos'));
			}
		});
		$A.enqueueAction(action);
	},

	loadVideosFromYouTubeUsername: function (component, event) {
		const action = component.get("c.getYouTubeVideosByUsername");
		action.setParams({
			results: component.get("v.numberOfVideos"),
			username: component.get("v.youtubeUsername"),
			key: component.get("v.apiKey"),
			order: component.get("v.order")
		});
		action.setCallback(this, function (response) {
			if (response.getReturnValue() === 'false') {
				component.set('v.error', 'Invalid Request to YouTube. Please check your username and API Key.');
				return;
			}

			let data = JSON.parse(response.getReturnValue());
			console.log(data);
			if (data.error !== undefined) {
				component.set('v.error', data.error.errors[0].message + ' | Reason: ' + data.error.errors[0].reason);
				return;
			}

			component.set('v.Videos', data.items);

			if (component.get('v.carouselMode')) {
				this.doSlide(component, 'next');
			}
			else {
				component.set('v.activeVideos', component.get('v.Videos'));
			}
		});
		$A.enqueueAction(action);
	},

	loadVideosFromYouTubePlaylist: function (component, event) {
		const action = component.get("c.getYouTubeVideosByPlaylist");
		action.setParams({
			results: component.get("v.numberOfVideos"),
			playlistId: component.get("v.youtubePlaylistId"),
			key: component.get("v.apiKey")
		});
		action.setCallback(this, function (response) {
			if (response.getReturnValue() === 'false') {
				component.set('v.error', 'Invalid Request to YouTube. Please check your playlist ID and API Key.');
				return;
			}

			let data = JSON.parse(response.getReturnValue());

			if (data.error !== undefined) {
				component.set('v.error', data.error.errors[0].message + ' | Reason: ' + data.error.errors[0].reason);
				return;
			}

			component.set('v.Videos', data.items);

			if (component.get('v.carouselMode')) {
				this.doSlide(component, 'next');
			}
			else {
				component.set('v.activeVideos', component.get('v.Videos'));
			}
		});
		$A.enqueueAction(action);
	},

	loadVideosFromVimeoChannel: function (component, event) {
		const action = component.get("c.getVimeoVideos");
		action.setParams({channel: component.get("v.vimeoUsername")});
		action.setCallback(this, function (response) {
			if (response.getReturnValue() === 'false') {
				component.set('v.error', 'Invalid Request to Vimeo. Please check the channel name.');
				return;
			}

			let data = JSON.parse(response.getReturnValue());
			component.set('v.Videos', data.slice(0, component.get("v.numberOfVideos")));

			if (component.get('v.carouselMode')) {
				this.doSlide(component, 'next');
			}
			else {
				component.set('v.activeVideos', component.get('v.Videos'));
			}
		});
		$A.enqueueAction(action);
	},

	doSlide: function (component, direction) {
		let videos = component.get('v.Videos');
		let numberOfVideos = videos.length;
		let current = parseInt(component.get('v.currentVideoPosition'));
		let per = parseInt(component.get('v.videosPerRow'));
		let startId = per;

		if (direction === "next") {
			startId = current + per;
		}

		if (direction === "previous") {
			startId = current - per;
			current = current - (per * 2);
		}

		component.set('v.currentVideoPosition', startId);
		component.set('v.activeVideos', videos.slice(current, startId));

		if ((current + per) >= numberOfVideos) {
			$A.util.addClass(component.find("nextButton"), "hidden");
		}
		else {
			$A.util.removeClass(component.find("nextButton"), "hidden");
		}

		if ((current + per) === per) {
			$A.util.addClass(component.find("previousButton"), "hidden");
		}
		else {
			$A.util.removeClass(component.find("previousButton"), "hidden");
		}
	}
});