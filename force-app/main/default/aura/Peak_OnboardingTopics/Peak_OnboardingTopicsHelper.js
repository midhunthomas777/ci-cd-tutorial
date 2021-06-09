/*
 * Copyright (c) 2019. 7Summits Inc. All rights reserved. 
 *
 */

({
	setCurrentSlideData: function (component, event, helper) {
		let followingTopics = component.get("v.topicSlides");
		for (let i = 0; i < followingTopics.length; i++) {
			if (followingTopics[i].parentLabel === 'Topics') {
				component.set("v.currentSlide", followingTopics[i]);
				break;
			}
		}
	},
 
	getFollowingTopic: function (component, event, helper) {
		let currentSlide = component.get("v.currentSlide");
		let allTopics = currentSlide.topics;
		let remainingTopics = [];
		let chosenTopics = [];
		let leftoverTopics = [];
		console.log(currentSlide);
		
		for (let i = 0; i < allTopics.length; i++) {
			if (allTopics[i].following === true) {
				chosenTopics.push(allTopics[i]);
			} else {
				if (remainingTopics.length < currentSlide.maxTopics) {
					remainingTopics.push(allTopics[i]);
				} else {
					leftoverTopics.push(allTopics[i]);
				}
			}
		}
		
		component.set("v.remainingTopics", remainingTopics);
		component.set("v.chosenTopics", chosenTopics);
		component.set("v.leftoverTopics", leftoverTopics);
	},
 
	getUpdatedUserRecord: function (component, event, helper) {
		//update user record so we do not lose any changes from previous step
		let action = component.get("c.getUserRecord");
		
		action.setCallback(this, function (response) {
			let state = response.getState();
			if (component.isValid() && state === "SUCCESS") {
				let user = response.getReturnValue();
				component.set("v.user", user);
				console.log('Users>>>>>' + JSON.stringify(component.get("v.user", user)));
			} else {
				console.log("Failed with state: " + state);
			}
		});
		
		$A.enqueueAction(action);
	},
 
	goToNext: function (component, event, helper) {
		let user = component.get("v.user");
		let followingTopics = component.get("v.topicSlides");
		
		for (let i = 0; i < followingTopics.length; i++) {
			user.Last_Topic_Slide_Completed__c = followingTopics[i].parentLabel;
		}
		component.set("v.user", user);
		
		let action = component.get("c.updateUserNames");
		action.setParams({
			"currentUser": component.get("v.user")
		});
		
		action.setCallback(this, function (response) {
			let state = response.getState();
			if (component.isValid() && state === "SUCCESS") {
				console.log('Success');
			} else {
				console.log("Failed with state: " + state);
			}
		});
		$A.enqueueAction(action);
		
		let compEvent = component.getEvent("pageChange");
		compEvent.setParams({"message": "5", "slide": "Topic"});
		compEvent.fire();
	},
 
	goBack: function (component, event, helper) {
		let compEvent = component.getEvent("pageChange");
		compEvent.setParams({"message": "3", "slide": ""});
		compEvent.fire();
	},
	
	getTopics: function (component, event, helper) {
		helper.getTopicList(component, 'topics1');
		helper.getTopicList(component, 'topics2');
	},
	
	getTopicList: function (component, topicsToRetrieve) {
		const topicIDs = component.get('v.' + topicsToRetrieve + 'Ids');
		
		if (topicIDs && topicIDs !== '') {
			let topicsList = topicIDs.replace(/\s/g, '').split(',');
			
			let action = component.get("c.getTopics");
			action.setParams({
				"topicIds": topicsList
			});
			
			action.setCallback(this, function (response) {
				let state = response.getState();
				if (component.isValid() && state === "SUCCESS") {
					let returnedTopics = response.getReturnValue();
					component.set("v." + topicsToRetrieve, returnedTopics);
				} else {
					console.log("Failed with state: " + state);
				}
			});
			$A.enqueueAction(action);
		}
	},
	
	userFollowTopic: function (component, event, helper, topicId) {
		if (!topicId || topicId === '') {
			topicId = event.getSource().get("v.name");
		}
		
		let action = component.get("c.followTopic");
		console.log('userFollowTopic', topicId);
		action.setParams({
			"topicId": topicId
		});
		
		action.setCallback(this, function (response) {
			let state = response.getState();
			if (component.isValid() && state === "SUCCESS") {
				console.log('success');
				
				let useTopicMetadata = component.get("v.useTopicMetadata");
				if (useTopicMetadata) {
					let chosenTopics = component.get("v.chosenTopics");
					let remainingTopics = component.get("v.remainingTopics");
					let leftoverTopics = component.get("v.leftoverTopics");
					for (let i = 0; i < remainingTopics.length; i++) {
						if (remainingTopics[i].id === topicId) {
							chosenTopics.push(remainingTopics[i]);
							if (leftoverTopics && leftoverTopics.length > 0) {
								remainingTopics.splice(i, 1, leftoverTopics[0]);
								leftoverTopics.splice(0, 1);
							} else {
								remainingTopics.splice(i, 1);
							}
						}
					}
					console.log(remainingTopics);
					component.set('v.chosenTopics', chosenTopics);
					component.set('v.remainingTopics', remainingTopics);
					component.set('v.leftoverTopics', leftoverTopics);
				} else {
					//after the topic follow is committed, re initialize the two lists in the component so the state updates to 'Follow' or 'Followed'
					this.getTopics(component, event, helper);
				}
			} else {
				console.log("Failed with state: " + state);
			}
		});
		$A.enqueueAction(action);
	},
	
	userUnfollowTopic: function (component, event, helper, topicId) {
		let action = component.get("c.unfollowTopic");
		
		console.log('userUnfollowTopic', topicId);
		action.setParams({
			"topicId": topicId
		});
		
		action.setCallback(this, function (response) {
			let state = response.getState();
			if (component.isValid() && state === "SUCCESS") {
				console.log('success');
				//after the topic follow deletion is committed, re initialize the two lists in the component so the state updates to 'Follow' or 'Followed'
				let useTopicMetadata = component.get("v.useTopicMetadata");
				if (!useTopicMetadata) {
					this.getTopics(component, event, helper);
				}
				
			} else {
				console.log("Failed with state: " + state);
			}
		});
		
		$A.enqueueAction(action);
		//after the topic follow deletion is committed, re initialize the two lists in the component so the state updates to 'Follow' or 'Followed'
		let useTopicMetadata = component.get("v.useTopicMetadata");
		if (!useTopicMetadata) {
			this.getTopics(component, event, helper);
		}
	}
});