/*
 * Copyright (c) 2019. 7Summits Inc.
 */
({
	doInit: function (component, event, helper) {
       
        //debugger;
        let count = 0;
		
        if(component.get('v.showMyIdeas'))
		    count++;
		if(component.get('v.showVoteByMeFilter'))
            count++;
        if(component.get('v.showIdeasCommentedByMeFilter'))
            count++;
        if(component.get('v.showIdeasSubscribedByMeFilter'))
            count++;
        if(component.get('v.myCompaniesIdeas'))
            count++;
        if(component.get('v.myCompaniesVotedIdeas'))
            count++;
        if(component.get('v.myCompaniesCommentedIdeas'))
            count++;
        if(component.get('v.myCompaniesSubscribedIdeas'))
            count++;
        
        
		try {
			
			if (component.get('v.showMyIdeas') ||
                component.get('v.showVoteByMeFilter') || 
                component.get('v.showIdeasCommentedByMeFilter') || 
                component.get('v.showIdeasSubscribedByMeFilter') ||
                component.get('v.myCompaniesIdeas') ||
				component.get('v.myCompaniesVotedIdeas') ||
				component.get('v.myCompaniesCommentedIdeas') ||
				component.get('v.myCompaniesSubscribedIdeas')
			) {
				let action = component.get("c.showAccountFilter");

				action.setCallback(this, function (actionResult) {
					if (actionResult.getState() === 'SUCCESS') {
						let superUser = actionResult.getReturnValue();

						component.set("v.superUser", superUser);

						if (superUser && component.get('v.myCompaniesIdeas') &&
							component.get('v.requireSelectionIdeasFilter') &&
							(count > 1)
						) {
							console.log('Firing display my company  ideas only');
							component.set('v.filterValue', component.get('v.myAccountIdeasLabel'));
                            $A.get("e.c:SVNSUMMITS_Ideas_Filters_Event").setParams(
                                {
                                    listId: component.get('v.listId'),
                                    searchMyCompanyIdeas: 'Display My Company Ideas Only',
                                    searchMyCommentedIdeas: 'empty',
                                    searchMySubscribedIdeas: 'empty',
                                    searchMyIdeas: 'empty',
                                    searchMyCompanyVotedIdeas: 'empty',
                                    searchMyCompanyCommentedIdeas: 'empty',
                                    searchMyCompanySubscribedIdeas: 'empty'
                                }).fire();
                            
                        } else if (component.get('v.requireSelectionIdeasFilter') && (count > 1) && component.get('v.showMyIdeas')) {
                            component.set('v.filterValue', component.get('v.myIdeasLabel'));
                            $A.get("e.c:SVNSUMMITS_Ideas_Filters_Event").setParams(
                                {
                                    listId: component.get('v.listId'),
                                    searchMyIdeas: 'Display My Ideas Only',
                                    searchMyCommentedIdeas: 'empty',
                                    searchMySubscribedIdeas: 'empty',
                                    searchMyCompanyIdeas: 'empty',
                                    searchMyCompanyVotedIdeas: 'empty',
                                    searchMyCompanyCommentedIdeas: 'empty',
                                    searchMyCompanySubscribedIdeas: 'empty'
                                }).fire();
                        } else {
                           component.set('v.filterValue', 'none');
                        }
					}

				});
				$A.enqueueAction(action);

            } else {
                component.set('v.filterValue', 'none');
            }
		} catch
			(ex) {
			console.log('Filter exception: ' + ex);
		}
	}

});