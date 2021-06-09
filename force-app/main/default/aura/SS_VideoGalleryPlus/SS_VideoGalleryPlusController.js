({
	doInit: function (component, event, helper) {
		if (component.get('v.youtubeChannelId')) {
			helper.loadVideosFromYouTubeChannel(component, event);
		}
		else if (component.get('v.youtubeUsername')) {
			helper.loadVideosFromYouTubeUsername(component, event);
		}
		else if (component.get('v.youtubePlaylistId')) {
			helper.loadVideosFromYouTubePlaylist(component, event);
		}
		else if (component.get('v.vimeoUsername')) {
			helper.loadVideosFromVimeoChannel(component, event);
		}
	},

	slideRight: function (component, event, helper) {
		helper.doSlide(component, 'next');
	},

	slideLeft: function (component, event, helper) {
		helper.doSlide(component, 'previous');
	}
});