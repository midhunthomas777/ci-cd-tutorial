/*
 * Copyright (c) 2019. 7Summits Inc. All rights reserved. 
 *
 */

({
    init : function(component, event, helper) {
        //console.log(JSON.stringify(component.get("v.topicSlides")));
        helper.getUpdatedUserRecord(component, event, helper);
        var useTopicMetadata = component.get("v.useTopicMetadata");
        if(useTopicMetadata) {
            var currentSlide = component.get("v.currentSlide");
            console.log(JSON.stringify(currentSlide));
            component.set("v.topicsMessage", currentSlide.message);
            component.set("v.topicsHeader", currentSlide.label);
            component.set("v.topicsAction", currentSlide.action);

            helper.getFollowingTopic(component, event, helper);
            //helper.setCurrentSlideData(component, event, helper);
        } else {
            helper.getTopics(component, event, helper);
        }
    },
    goToNext : function(component, event, helper) {
        helper.goToNext(component, event, helper);
    },
    goBack : function(component, event, helper){
        helper.goBack(component, event, helper);
    },
    userFollowTopic : function (cmp, event, helper) {
        var topicId = event.getParam("id");
        helper.userFollowTopic(cmp, event, helper, topicId);
    },
    userUnfollowTopic : function (cmp, event, helper) {
        var topicId = event.getParam("id");
        helper.userUnfollowTopic(cmp, event, helper, topicId);
    },
    handleRemove: function (cmp, event,helper) {
        var currentSlide = cmp.get("v.currentSlide");
        var topicId = event.getParam("name");
        console.log('handleRemove', topicId);
        // Remove the pill from view
        var chosenTopics = cmp.get("v.chosenTopics");
        var remainingTopics = cmp.get("v.remainingTopics");
        var leftoverTopics = cmp.get("v.leftoverTopics");
        for(var i = 0; i < chosenTopics.length; i++) {
            if(chosenTopics[i].id == topicId) {
                chosenTopics[i].following = false;
                if(remainingTopics.length < currentSlide.maxTopics) {
                    remainingTopics.push(chosenTopics[i]);
                } else {
                    leftoverTopics.push(chosenTopics[i]);
                }
                chosenTopics.splice(i, 1);
            }
        }
        cmp.set('v.chosenTopics', chosenTopics);
        cmp.set('v.remainingTopics', remainingTopics);
        cmp.set('v.leftoverTopics', leftoverTopics);
        helper.userUnfollowTopic(cmp, event, helper, topicId);
    }
})