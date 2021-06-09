/*
 * Copyright (c) 2018. 7Summits Inc.
 * Changes - 1. Changed callout to doCallout
 */
({
	getFeaturedMembers: function (component) {
	    let self = this;
	    let params = {
            recordNickName1: component.get("v.recordNickName1"),
            recordNickName2: component.get("v.recordNickName2"),
            recordNickName3: component.get("v.recordNickName3"),
            recordNickName4: component.get("v.recordNickName4"),
            recordNickName5: component.get("v.recordNickName5"),
            recordNickName6: component.get("v.recordNickName6"),
            recordNickName7: component.get("v.recordNickName7"),
            recordNickName8: component.get("v.recordNickName8"),
        }
	    self.doCallout(component,'c.getFeaturedMembers',params).
	    then((membersListWrapper) => {
	        for (let i = 0; i < membersListWrapper.membersList.length; i++) {
                // am I following this member
                membersListWrapper.membersList[i].isFollowing = (membersListWrapper.mapUserId_Wrapper[membersListWrapper.membersList[i].Id]).isFollowing;

                // Store the number of followers to display on the component
                membersListWrapper.membersList[i].intNumberOfFollowers = (membersListWrapper.mapUserId_Wrapper[membersListWrapper.membersList[i].Id]).intNumberOfFollowers;

                // Store the number of like received to display on the component
                membersListWrapper.membersList[i].intLikeReceived = (membersListWrapper.mapUserId_Wrapper[membersListWrapper.membersList[i].Id]).intLikeReceived;

                // number of posts made
                membersListWrapper.membersList[i].intPostsMade = (membersListWrapper.mapUserId_Wrapper[membersListWrapper.membersList[i].Id]).intPostsMade;

                // Store the topics name for displaying on component
                membersListWrapper.membersList[i].strKnowledgeTopics = (membersListWrapper.mapUserId_Wrapper[membersListWrapper.membersList[i].Id]).strKnowledgeTopics;

                // Store the topics name for displaying on component
                membersListWrapper.membersList[i].strKnowledgeTopics1 = (membersListWrapper.mapUserId_Wrapper[membersListWrapper.membersList[i].Id]).strKnowledgeTopics1;

                // Store the topics name for displaying on component
                membersListWrapper.membersList[i].strKnowledgeTopics2 = (membersListWrapper.mapUserId_Wrapper[membersListWrapper.membersList[i].Id]).strKnowledgeTopics2;

                // Store the topics Id for displaying on component
                membersListWrapper.membersList[i].strKnowledgeTopicId = (membersListWrapper.mapUserId_Wrapper[membersListWrapper.membersList[i].Id]).strKnowledgeTopicId;

                // Store the topics Id for displaying on component
                membersListWrapper.membersList[i].strKnowledgeTopicId1 = (membersListWrapper.mapUserId_Wrapper[membersListWrapper.membersList[i].Id]).strKnowledgeTopicId1;

                // Store the topics Id for displaying on component
                membersListWrapper.membersList[i].strKnowledgeTopicId2 = (membersListWrapper.mapUserId_Wrapper[membersListWrapper.membersList[i].Id]).strKnowledgeTopicId2;
            }

            component.set("v.membersListWrapper", membersListWrapper);
        },(errors) => {
            //YOU CAN WRITE ANY ERROR CODE HERE...
        });

	},

	initializeSlider: function (component) {
		if (component.get('v.layout') === 'slider') {
			const globalId = component.getGlobalId();
			const items = component.get("v.itemsShown");
			// let sliderX = component.find('_carouselViewer').getElement();

			let carousel = document.getElementById(globalId + '_carouselViewer');

			let settings = {
				item: items,
				slideMove: items,
				useCSS: true,
				cssEasing: 'ease',
				easing: 'cubic-bezier(0.25, 0, 0.25, 1)',
				speed: 600,
			};

			if (carousel) {
				let slider = $(carousel).lightSlider(settings);
				slider.refresh();
				return;
			}

			window.setTimeout(
				$A.getCallback(function () {
					$('.responsive').lightSlider({
						item: items,
						slideMove: items,
						useCSS: true,
						cssEasing: 'ease',
						easing: 'cubic-bezier(0.25, 0, 0.25, 1)',
						speed: 600,
					});
				}), 100
			);
		}
	},

	//This method will be called when user will click on "follow" or "unfollow" button
    followRecord : function (component, followAction, recordId) {
        let self   = this;
        let params = {
            'recordId' : recordId
        }

        self.doCallout(component,followAction ? 'c.followRecord' : 'c.unfollowRecord',params).
        then((result) =>{

        },
        (errors) => {
            for (var i = 0; i < errors.length; i++) {

                self.debug(component, '    :', errors[i].message);

            }
            self.showMessage('error', 'List - Follow Button', 'Failed to follow/un-follow selected member');
        });



    }

});