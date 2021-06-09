/**
 * Copyright (c) 2019. 7Summits Inc.
 */
({
	onVote: function (component, voteType) {
		let self = this;

		let currentVoteCount = component.get('v.currentVoteCount');
		let totalVoteCount   = component.get('v.totalVoteCount');

		let action = component.get("c.getVotingDetails");
		action.setParams({
			ideaId: component.get("v.ideaId")
		});
		action.setCallback(this, function (actionResult) {
			if (actionResult.getState() === 'SUCCESS') {
				let _resp = actionResult.getReturnValue();
				console.log('Voting LIMIT: ' + JSON.stringify(_resp));

				if (_resp.totalVotes) {
					totalVoteCount = _resp.totalVotes;
				}
				if (_resp.currentVoteCount) {
					currentVoteCount = _resp.currentVoteCount;
				}

				if (currentVoteCount < totalVoteCount || totalVoteCount === 0) {
					let voteEvent = voteType === 'Up' ? component.getEvent('onVote') : component.getEvent('onDownVote');
					voteEvent.setParams({
						ideaId      : component.get("v.ideaId"),
						voteType    : voteType,
						voteCount   : totalVoteCount
					});
					voteEvent.fire();
				} else {
					self.showMessage("info", '', component.get('v.accountLimitReachedMessage'));
				}
			}
		});
		$A.enqueueAction(action);
	}
});