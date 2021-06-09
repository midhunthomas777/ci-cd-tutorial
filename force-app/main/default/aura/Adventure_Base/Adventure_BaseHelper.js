/**
 * Created by Melinda Grad on 8/1/18.
 * Copyright (c) 2018. 7Summits Inc.
 */
({
    getAdventure: function (component, event, helper) {
        var adventureId = component.get('v.recordId');
        if(!$A.util.isUndefinedOrNull(adventureId) && !$A.util.isEmpty(adventureId)){
            var params = {
                adventureId: adventureId
            };
            helper.doCallout(component, "c.getAdventure", params).then(function (response) {
                if (!response.success) {

                    helper.showMessage('Error', response.messages[0]);

                } else {

                    if (!response.isEmpty) {
                        var peakContentObject = response.peakResults[0];
                        component.set('v.peakContentObject', response.peakResults[0]);

                        console.log(response.peakResults[0]);

                        /* Set Adventure */
                        component.set('v.adventure', peakContentObject.adventure);

                        //Title image is image behind the title
                        //Header Image is image next to Adventure Step Title
                        //Banner is image behind the trail

                        if(!$A.util.isUndefinedOrNull(peakContentObject.adventure.ContentDocumentLinks) || !$A.util.isEmpty(peakContentObject.adventure.ContentDocumentLinks)) {

                            for (var i = 0; i < peakContentObject.adventure.ContentDocumentLinks.length; i++) {
                                if (!$A.util.isUndefinedOrNull(peakContentObject.adventure.ContentDocumentLinks[i]) || !$A.util.isEmpty(peakContentObject.adventure.ContentDocumentLinks[i])) {

                                    var title = peakContentObject.adventure.ContentDocumentLinks[i].ContentDocument.Title.toLowerCase();

                                    if(title.indexOf('title') !== -1){
                                        component.set('v.adventureTitleImage', peakContentObject.adventure.ContentDocumentLinks[i].ContentDocument.LatestPublishedVersionId);
                                    }
                                    if(title.indexOf('header') !== -1){
                                        component.set('v.adventureHeaderImage', peakContentObject.adventure.ContentDocumentLinks[i].ContentDocument.LatestPublishedVersionId);
                                    }
                                    if(title.indexOf('banner') !== -1){
                                        component.set('v.adventureBannerImage', peakContentObject.adventure.ContentDocumentLinks[i].ContentDocument.LatestPublishedVersionId);
                                    }
                                }
                            }
                        }
                    }
                }
            });
        }
    }
})