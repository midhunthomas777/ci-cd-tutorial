({
	doInit : function(component, event, helper) {

		let action = component.get("c.getVotingLimitsForAccount");
        action.setParams({
            ideaId: component.get("v.recordId")
        });
        action.setCallback(this, function (actionResult) {
            if(actionResult.getState() === 'SUCCESS') {
                let _resp = actionResult.getReturnValue();
                console.log('Voting LIMIT: ' + JSON.stringify(_resp));
                component.set('v.totalVoteCount', _resp.totalVotes);
                component.set('v.currentVoteCount', _resp.currentVoteCount);
            }
        });
        $A.enqueueAction(action);
	}
});