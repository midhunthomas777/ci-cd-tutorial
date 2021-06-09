/*
 * Copyright (c) 2019. 7Summits Inc. All rights reserved. 
 *
 */

({
    init : function(component, event, helper) {
        if(component.get('v.isInit')) {
            helper.retrieveIsModalViewEnabled(component);
            helper.init(component, event, helper);
            helper.topicSlideRetrieval(component);
        }
    },

    handlePageChange: function(component, event, helper) {
        helper.handlePageChange(component, event, helper);
    },
    handleProgressClick: function(component, event, helper) {
        helper.openSlide(component, event, helper);
    },

    closeModal: function(component, event, helper) {
        component.set("v.displayOnboarding", false);
    },
    // if user clicks 'X' on final screen, we also want to check the Onboarding Complete field on their User record
    closeModalFinal: function(component, event, helper) {
        console.log('close modal first');
        component.set("v.displayOnboarding", false);
        helper.closeModalFinal(component, event, helper);
    },
    handleWelcomeClick: function (component, event, helper) {
        component.set("v.page","1");
        component.set("v.displayTopics", false);
    },
    handleProfileClick: function (component, event, helper) {
        component.set("v.page","2");
        component.set("v.displayTopics", false);
    },
    handleshowAdditionUserDataLabelClick: function (component, event, helper) {
        component.set("v.page","3");
        component.set("v.displayTopics", false);
    },
    handleTopicsClick: function (component, event, helper) {
        if(component.get("v.useTopicMetadata") === true) {
            var topicSlides = component.get("v.topicSlides");
            for(var i = 0; i < topicSlides.length; i++) {
                if($A.util.hasClass(event.getSource(), topicSlides[i].parentLabel) === true) {
                    component.set("v.currentSlide", topicSlides[i]);
                    component.set("v.topicSlideIndex", i);
                }
            }
            console.log(component.get("v.currentSlide"));
            var topicNumber = component.get("v.topicSlideIndex");
            topicNumber = 4 + topicNumber;
            var topicNumberString = topicNumber.toString();
            component.set("v.displayTopics", false);
            component.set("v.page", topicNumberString);
            component.set("v.displayTopics", true);
            console.log(topicNumberString);
        } else {
            component.set("v.page", "4");
        }
    },
    handleGroupsClick: function (component, event, helper) {
        component.set("v.page", "9");
        component.set("v.displayTopics", false);
    },
    handleNotificationClick: function (component, event, helper) {
        component.set("v.page", "10");
        component.set("v.displayTopics", false);
    },
    handleToursClick: function (component, event, helper) {
        component.set("v.page", "11");
        component.set("v.displayTopics", false);
    },
    handleFinalizeClick: function (component, event, helper) {
        component.set("v.page", "12");
        component.set("v.displayTopics", false);
    },
    toByeScreen: function(component, event, helper) {
        component.set("v.displaySteps", false);
        component.set("v.displayBye", true);
    },

    goBackToOnboarding: function(component, event, helper) {
        component.set("v.displaySteps", true);
        component.set("v.displayBye", false);
    }
})