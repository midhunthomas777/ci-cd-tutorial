/*
 * Copyright (c) 2019. 7Summits Inc. All rights reserved. 
 *
 */

({
    init : function(component, event, helper) {
        var action = component.get("c.getUserRecord");
        action.setCallback(this, function(response){
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                var user = response.getReturnValue();
                component.set("v.user", user);
                component.set("v.userId", user.Id.substring(0,15));

                // console.log(JSON.parse(JSON.stringify(user)));
                var displayMode = component.get("v.displayMode");
                // if user is on the own page for Onboarding, the flow should always start at screen 1
                if(displayMode === 'Always Show Onboarding') {
                    component.set("v.displayOnboarding", true);
                    component.set("v.page", '1');
                    // if user is on home page, flow should only pop up if the user hasn't completed it.  The user should also be directed to the first slide they haven't completed (if they login, complete part of the onboarding process, then log back in later )
                } else if (!user.Onboarding_Complete__c) {
                    component.set("v.displayOnboarding", true);

                    //set the current page to the first uncompleted page
                    if(!user.Completed_Welcome_Slide__c){
                        component.set("v.page", '1');
                    }else if(!user.Completed_Profile_Slide__c){
                        component.set("v.page", '2');
                    }else if(!user.Completed_Additional_User_Data__c){
                        component.set("v.page", '3');
                    }else if(!user.Completed_Topics_Slide__c){
                        component.set("v.page", '4');
                    }else if(!user.Completed_Groups_Slide__c){
                        component.set("v.page", '9');
                    }else if(!user.Completed_Notification_Slide__c){
                        component.set("v.page", '10');
                    }else if(!user.Completed_Tours_Slide__c){
                        component.set("v.page", '11');
                    }else if(!user.Onboarding_Complete__c){
                        component.set("v.page", '12');
                    } else {
                        component.set("v.page", '1');
                    }
                }
                console.log(component.get("v.page"));
            } else {
                console.log("Failed with state: " + state);
            }
        });
        $A.enqueueAction(action);

        var excludeSteps = "";

        var showStep1 = component.get("v.showStep1");
        var showStep2 = component.get("v.showStep2");
        var showStep3 = component.get("v.showStep3");
        var showStep4 = component.get("v.showStep4");
        var showStep5 = component.get("v.showStep5");
        var showStep6 = component.get("v.showStep6");
        var showStep7 = component.get("v.showStep7");
        var showStep8 = component.get("v.showStep8");

        if(!showStep1){
            excludeSteps += "Welcome "
            console.log("Marking step 1 (Welcome) as complete.");
        }
        if(!showStep2){
            excludeSteps += "Profile "
            console.log("Marking step 2 (Profile) as complete.");
        }
        if(!showStep3){
            excludeSteps += "Additional "
            console.log("Marking step 3 (Additional User Data) as complete.");
        }
        if(!showStep4){
            excludeSteps += "Topic "
            console.log("Marking step 4 (Topic) as complete.");
        }
        if(!showStep5){
            excludeSteps += "Group "
            console.log("Marking step 5 (Group) as complete.");
        }
        if(!showStep6){
            excludeSteps += "Notification "
            console.log("Marking step 6 (Notification) as complete.");
        }
        if(!showStep7){
            excludeSteps += "Tours "
            console.log("Marking step 7 (Tours) as complete.");
        }
        if(!showStep8){
            excludeSteps += "Done "
            console.log("Marking step 8 (Done) as complete.");
        }

        if(excludeSteps && excludeSteps !== ""){
            var stepList = excludeSteps.trim().split(" ");
            var currentStep;

            if(stepList.length > 0) {
                for(currentStep = 0; currentStep < stepList.length; currentStep++){

                    var completeExcludedAction = component.get("c.completeSlide");
                    completeExcludedAction.setParams({
                        "slide": stepList[currentStep]
                    });
                    completeExcludedAction.setCallback(this, function (response) {
                        var state = response.getState();
                        if (component.isValid() && state === "SUCCESS") {
                            console.log('in success');
                        } else {
                            console.log("Failed with state: " + JSON.stringify(state));
                        }
                    });
                    $A.enqueueAction(completeExcludedAction);
                }
            }
        }
    },

    retrieveIsModalViewEnabled : function(component) {
        var action = component.get("c.getIsModalViewEnabled");
        action.setCallback(this, function(response){
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                var isModalViewEnabled = response.getReturnValue();
                component.set('v.isModalViewEnabled', isModalViewEnabled);
            } else {
                console.log("Failed with state: " + state);
            }
        });
        $A.enqueueAction(action);
    },

    topicSlideRetrieval : function(component) {
        component.set("v.page", "1");
        var useMetadata = component.get("v.useTopicMetadata");
        if(useMetadata === true) {
            var action = component.get("c.grabTopics");
            action.setCallback(this, function(response){
                var state = response.getState();
                if (component.isValid() && state === "SUCCESS") {
                    var topics = response.getReturnValue();
                    component.set("v.topicSlides", topics);
                    var numberTopicSlides = topics.length;
                    component.set("v.numberOfTopicSlides", topics.length);
                    if(numberTopicSlides > 0) {
                        component.set("v.currentSlide", topics[0]);
                        component.set("v.topicSlideIndex", 0);
                    }
                    this.countTotalSteps(component);
                } else {
                    console.log("Failed with state: " + state);
                }
            });
            $A.enqueueAction(action);
        } else {
            this.countTotalSteps(component);
        }
    },

    countTotalSteps : function(component) {
        var count = 0;
        if(component.get('v.showStep1')) {
            count++;
        }
        if(component.get('v.showStep2')) {
            count++;
        }
        if(component.get('v.showStep3')) {
            count++;
        }
        if(component.get('v.showStep4')) {
            if(component.get('v.useTopicMetadata')) {
                count = count + component.get('v.numberOfTopicSlides');
            } else {
                count++;
            }
        }
        if(component.get('v.showStep5')) {
            count++;
        }
        if(component.get('v.showStep6')) {
            count++;
        }
        if(component.get('v.showStep7')) {
            count++;
        }
        if(component.get('v.showStep8')) {
            count++;
        }
        component.set('v.totalSteps',count);
    },

    handleNextStepChange : function(component, pageNumber) {
        console.log('handleNextStepChange:pageNumber', pageNumber);
        var topicSlides = component.get("v.topicSlides");
        var current = component.get("v.currentSlide");
        if((pageNumber === 1 || pageNumber === 0) && component.get('v.showStep1')) {
            component.set("v.page","1");
            component.set("v.displayTopics", false);
        } else if(pageNumber <= 2 && component.get('v.showStep2')) {
            component.set("v.page","2");
            component.set("v.displayTopics", false);
        }else if(pageNumber <= 3 && component.get('v.showStep3')) {
            component.set("v.page","3");
            component.set("v.displayTopics", false);
        } else if(pageNumber <= 4 && component.get('v.showStep4')) {
            component.set("v.page","5");
            component.set("v.page","4");
            component.set("v.displayTopics", true);
            if(component.get("v.useTopicMetadata") === true) {
                component.set("v.topicSlideIndex", 0);
                component.set("v.currentSlide", topicSlides[0]);
            }
        } else if(pageNumber === 5 || pageNumber === '5') {
            if(component.get("v.useTopicMetadata") === true) {
                var topicIndex = component.get("v.topicSlideIndex");
                if(topicIndex + 1 < component.get("v.numberOfTopicSlides")) {
                    var newTopicIndex = topicIndex + 1;
                    component.set("v.currentSlide", topicSlides[newTopicIndex]);
                    component.set("v.topicSlideIndex", newTopicIndex);
                    newTopicIndex = newTopicIndex +4;
                    var topicIndexString = newTopicIndex.toString();
                    component.set("v.page",topicIndexString);
                    component.set("v.displayTopics", false);
                    component.set("v.displayTopics", true);
                } else {
                    component.set("v.page","9");
                    component.set("v.displayTopics", false);
                }
            } else {
                component.set("v.page","9");
                component.set("v.displayTopics", false);
            }
        } else if(pageNumber <= 9 && component.get('v.showStep5')) {
            component.set("v.page","9");
            component.set("v.displayTopics", false);
        } else if(pageNumber <= 10 && component.get('v.showStep6')) {
            component.set("v.page","10");
        } else if(pageNumber <= 11 && component.get('v.showStep7')) {
            component.set("v.page","11");
        } else if(pageNumber <= 12 && component.get('v.showStep8')) {
            component.set("v.page","12");
        }
    },

    handlePreviousStepChange : function(component, pageNumber) {
        console.log('handlePreviousStepChange:pageNumber', pageNumber);
        var useTopicMetadata = component.get("v.useTopicMetadata");
        var topicIndex = component.get("v.topicSlideIndex");
        var topicSlides = component.get("v.topicSlides");
        if(pageNumber >= 11 && component.get('v.showStep7')) {
            component.set("v.displayTopics", false);
            component.set("v.page","11");
        } else if(pageNumber >= 10 && component.get('v.showStep6')) {
            component.set("v.displayTopics", false);
            component.set("v.page","10");
        } else if(pageNumber >= 9 && component.get('v.showStep5')) {
            component.set("v.displayTopics", false);
            component.set("v.page","9");
        } else if(pageNumber >= 4 && component.get('v.showStep4')) {
            if(useTopicMetadata === true) {
                var numberOfTopicSlides = component.get("v.numberOfTopicSlides");
                if(numberOfTopicSlides > 0) {
                    topicIndex = numberOfTopicSlides - 1;
                    component.set("v.topicSlideIndex", topicIndex);
                    component.set("v.currentSlide", topicSlides[topicIndex]);
                    var topicSlideIndexString = (topicIndex + 4).toString();
                    component.set("v.page", topicSlideIndexString);
                }
            } else {
                component.set("v.page","4");
            }
            component.set("v.displayTopics", true);
        } else if((pageNumber >= 3 && component.get('v.showStep3')) ||
            (pageNumber >= 3 && useTopicMetadata === true && topicIndex > 0)) {
            component.set("v.page","3");
            component.set("v.displayTopics", false);
            if(useTopicMetadata === true && topicIndex > 0) {
                topicIndex = topicIndex - 1;
                component.set("v.topicSlideIndex", topicIndex);
                topicSlides = component.get("v.topicSlides");
                component.set("v.currentSlide", topicSlides[topicIndex]);
                topicIndex = topicIndex + 4;
                var topicSlideIndexString = topicIndex.toString();
                component.set("v.page",topicSlideIndexString);
                component.set("v.displayTopics", true);
            }
        } else if(pageNumber >= 2 && component.get('v.showStep2')) {
            component.set("v.displayTopics", false);
            component.set("v.page","2");
        } else if(pageNumber >= 1 && component.get('v.showStep1')) {
            component.set("v.displayTopics", false);
            component.set("v.page","1");
        }

    },

    openSlide: function(component, event, helper) {
        component.set("v.displayBye", false);
        component.set("v.displaySteps", true);

        var completedSlide = event.getParam("slide");
        var pageNumber = event.getParam("message");

        var action = component.get("c.completeSlide");

        if(completedSlide === 'Topic') {
            var topicSlides = component.get("v.topicSlides");
            var topicIndex = component.get("v.topicSlideIndex");
            if(topicIndex < topicSlides.length) {
                component.set("v.topicIndex", topicIndex);
                console.log('helper:openSlide:pageNumber', pageNumber);
                this.handleNextStepChange(component, pageNumber);
                return;
            }
        }
        action.setParams({
            "slide": completedSlide
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                console.log('success:pageChange:' + completedSlide);
                this.handleNextStepChange(component, pageNumber);
                component.set("v.displayOnboarding", true);
            } else {
                console.log("Complete slide failed with state: " + state);
            }
        });
        $A.enqueueAction(action);
    },

    handlePageChange : function(component, event, helper) {
        var completedSlide = event.getParam("slide");
        var pageNumber = event.getParam("message");
        console.log('helper:handlePageChange', completedSlide, pageNumber);
        var action = component.get("c.completeSlide");
        // if "message" equals "close", the user has just completed the entire modal, so the 'Complete_Modal__c' field should be checked and the modal closed
        if(pageNumber === 'Close'){
            action.setParams({
                "slide": completedSlide
            });
            action.setCallback(this, function (response) {
                var state = response.getState();
                if (component.isValid() && state === "SUCCESS") {
                    console.log('success:pageChange:close');
                    component.set("v.page", pageNumber);
                } else {
                    console.log("Close failed with state: " + state);
                }
            });
            $A.enqueueAction(action);
            this.closeModal(component, event, helper);
            // if "slide' is not blank, the user just completed a slide, and the database needs to be called to check the corresponding field on the User record
        } else if(completedSlide !== ''){
            if(completedSlide === 'Topic') {
                var topicSlides = component.get("v.topicSlides");
                var topicIndex = component.get("v.topicSlideIndex");
                topicIndex = topicIndex +1;
                if(topicIndex < topicSlides.length) {
                    component.set("v.topicIndex", topicIndex);
                    this.handleNextStepChange(component, pageNumber);
                    return;
                }
            }
            action.setParams({
                "slide": completedSlide
            });
            action.setCallback(this, function (response) {
                var state = response.getState();
                if (component.isValid() && state === "SUCCESS") {
                    console.log('success:pageChange:' + completedSlide);
                    this.handleNextStepChange(component, pageNumber);
                } else {
                    console.log("Complete slide failed with state: " + state);
                }
            });
            $A.enqueueAction(action);

            // if "slide" is blank, the user is going back to a previous screen and therefore the database doesn't need to be called to check a slide complete field on the User record.
        } else {
            this.handlePreviousStepChange(component,pageNumber);
            // component.set("v.page", pageNumber);
        }
    },
    closeModalFinal : function(component, event, helper) {
        console.log('closeModalFinal');
        var action = component.get("c.completeSlide");
        action.setParams({
            "slide": "Done"
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                console.log('modal completed');
            } else {
                console.log("Failed with state: " + state);
            }
        });
        $A.enqueueAction(action);
    },

    closeModal: function(component, event, helper) {
        component.set("v.displayOnboarding", false);
    }
})