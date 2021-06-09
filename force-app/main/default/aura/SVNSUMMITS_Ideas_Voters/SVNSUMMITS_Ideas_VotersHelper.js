/*
 * Copyright (c) 2019. 7Summits Inc.
 */
({
    getIdeaVoters : function(component) {
        let actionCount = component.get("c.getTotalVoterCount");
        actionCount.setParams({
            recordId: component.get("v.recordId")
        });

        actionCount.setCallback(this, function(actionResult) {
            let totalVoters = actionResult.getReturnValue();
            component.set("v.totalVoterCount", totalVoters);

            if (totalVoters > 0) {
                let actionVoters = component.get("c.getIdeaVoters");

                actionVoters.setParams({
                    recordId  : component.get("v.recordId"),
                    numResults: component.get("v.numResults")
                });

                actionVoters.setCallback(this, function(actionResult) {
                    component.set("v.voters", actionResult.getReturnValue());
                });
                $A.enqueueAction(actionVoters);
            }
        });
        $A.enqueueAction(actionCount);
    }
});