({
    getActiveAnnouncements: function (component, event, helper) {
        let queryLimit = component.get("v.numberOfResults");
        let displayChannel = component.get("v.displayChannel");
        let displayType = component.get("v.displayType");
        let hiddenAnnouncements = component.get("v.hiddenAnnouncements");
        let params = {
            "numResultsString": queryLimit,
            "displayChannelString": displayChannel,
            "displayTypeString": displayType,
            "hiddenAnnouncementString": hiddenAnnouncements,
        };
        return new Promise(function (resolve, reject) {
            helper.doCallout(component, "c.getActiveAnnouncements", params, true).then(function (response) {
                if (response) {
                    resolve(response);
                    component.set("v.peakResponse",response);
                    component.set("v.isInit", true);
                } else {
                    reject(response);
                }
                console.log('++ response ++', response);
            })
        })
    },

    slickCarousel:function(component) {
        setTimeout(function() {
            jQuery(component.find("carousel").getElement()).slick({
                    dots: true,
                    infinite: true,
                    speed: 300,
                    slidesToShow: 1,
                    slidesToScroll: 1,
                    adaptiveHeight: true,
                    responsive: [
                        {
                            breakpoint: 640,
                            settings: {
                                slidesToShow: 1,
                                infinite: true,
                                dots: false
                            }
                        }
                    ]
            });
        });

        // prevent default "pull-to-refresh" behavior when running in S1
        // jQuery(component.find("carousel").getElement()).on("touchmove", function () {
        //     return false;
        // });
    },

    removeDissmissedSlide:function(component) {
        let currentSlide = jQuery(component.find("carousel").getElement()).slick('slickCurrentSlide');
        jQuery(component.find("carousel").getElement()).slick('slickRemove', currentSlide);
    },

    getCookieValues: function(component) {
        let userId = $A.get("$SObjectType.CurrentUser.Id");
        let networkId = component.get("v.networkId");
        let name = "announcements" + userId + networkId;
        return (name = (document.cookie + ';').match(new RegExp(name + '=.*;'))) && name[0].split(/=|;/)[1];
    },

    getIdentifyingData: function(component, event, helper) {
        return new Promise(function (resolve, reject) {
            helper.doCallout(component, "c.getNetworkId", null, true).then(function (response) {
                if (response) {
                    resolve(response);
                    component.set("v.networkId",response);
                } else {
                    reject(response);
                }
                //console.log('++ response ++', response);
            });
        });
    }
});