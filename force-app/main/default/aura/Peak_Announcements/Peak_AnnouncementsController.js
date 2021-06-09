({
    doInit : function(component, event, helper) {

        // console.log(document.cookie);

        let useCarousel = component.get("v.useCarousel");

        helper.getIdentifyingData(component, event, helper).then(function(){
            component.set("v.hiddenAnnouncements", helper.getCookieValues(component));

            // get the announcements
            helper.getActiveAnnouncements(component, event, helper).then(function(data){

                // if we have more than 1 announcement and the ueCarousel attribute = true, initialize carousel JS
                if(useCarousel && data.results.length > 1) {
                    helper.slickCarousel(component);
                }
            }, function(){
                console.log("failed")
            });
        });

    },

    navigate : function(component, event, helper) {
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": event.getSource().get("v.value"),
        });
        urlEvent.fire();
    },

    dismissAnnouncement : function(component, event, helper) {
        let useCarousel = component.get("v.useCarousel");
        let userId = $A.get("$SObjectType.CurrentUser.Id");
        let networkId = component.get("v.networkId");
        let announcementId = event.getSource().get("v.value");
        let announcement = document.getElementById('announcement-' + announcementId);
        let expire = new Date();
            expire = new Date(expire.getTime() +1000*60*60*24*365);
        let cookieValues = helper.getCookieValues(component);
        if (cookieValues != null) {
            cookieValues += "," + announcementId;
        } else {
            cookieValues = announcementId;
        }
        // console.log("build cookie");

        document.cookie = 'announcements' +userId+networkId+ '=' + cookieValues + ';expires=' + expire.toGMTString() + ';';

        // hide dismissed slide
        if(useCarousel) {
            // if we're using the JS carousel, remove the carousel slide by current slide index
            helper.removeDissmissedSlide(component);
        } else {
            // if we're not using the carousel, just hide it with CSS
            announcement.classList.add("slds-hide");
        }


    }

});