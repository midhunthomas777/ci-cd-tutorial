/*
 * Copyright (c) 2019. 7Summits Inc.
 */
({
    vote : function(component, isUp) {
        let self = this;

        this.doCallout(component, 'c.vote', {
            recordId: component.get("v.recordId"),
            isUp:     isUp
        }, false, 'Vote', false)
            .then(vote => {
                component.set('v.currentVote', vote);

                self.doCallout(component, 'c.getIdeaRecord', {
                    recordId: component.get("v.recordId"),
                    zoneId  : component.get("v.zoneId"),
                    customFieldSetName : ''
                }, false, 'get Idea', false)
                    .then(wrapper => {
                        let idea = self.updateIdeaValues(component,
                            self.parseNamespace(component, wrapper.ideaList[0]),
                            wrapper.topicNameToId,
                            wrapper.sitePath,
                            '');

                        // Incrementing the current vote count
                        let currentVoteCount = component.get('v.currentVoteCount');
                        currentVoteCount = currentVoteCount + 1;
                        component.set('v.currentVoteCount', currentVoteCount);
                        component.set('v.idea', idea);
                    });
            });
    }
});