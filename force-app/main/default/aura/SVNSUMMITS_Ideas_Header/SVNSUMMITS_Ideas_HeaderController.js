/*
 * Copyright (c) 2019. 7Summits Inc.
 */
({
	onInit: function (component, event, helper) {

		helper.showFilterRow(component, event, helper);
		helper.getCommonSettings(component);

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

        if(count > 1)
            component.set('v.multipleFiltersActive', true);
        else
            component.set('v.multipleFiltersActive', false);
	},

	setNoOfIdeasGet: function (component, event, helper) {
		helper.getIdeaText(component);

		if (event.getParam("listId") === component.get('v.listId')) {
			component.set("v.numberOfIdeas", event.getParam("totalResults"));
		}
	},

	handleFilter: function (component, event, helper) {
		component.set('v.showFilter', !component.get('v.showFilter'));
	},

	getSearchString: function (component, event, helper) {
		let appEvent = $A.get("e.c:SVNSUMMITS_Ideas_Filters_Event");

		let searchString = component.get("v.searchText");
		helper.debug(component, "Search " + searchString);
		component.set("v.searchString", searchString);

		appEvent.setParams({
			listId       : component.get('v.listId'),
			searchString : searchString,
			searchMode   : true
		});

		appEvent.fire();
	},

	gotoUrl: function (component, event, helper) {
		helper.gotoUrl(component, component.get('v.newIdeaURL'));
	}
});