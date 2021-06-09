/*
 * Copyright (c) 2019. 7Summits Inc.
 */
({
    doInit : function(component, event, helper) {
        let baseLoaded = component.get("v.baseLoaded");

        // searchString       = Filter by Search string
	    // searchByTopics     = Filter by Topic string
	    // searchByTheme      = Filter by Theme string
	    // searchByStatus     = filter by status string
	    // searchByCategories = filter by category string
	    // searchMyIdeas      = No,Display My Ideas Only,Display My Voted Ideas Only

	    if (!baseLoaded) {
            component.set("v.baseLoaded", true);

		    // Capture the initial filter settings
		    component.set('v.filterTopicValue',  component.get('v.searchByTopics'));
		    component.set('v.filterCatValue',    component.get('v.searchByCategories'));
		    component.set('v.filterStatusValue', component.get('v.searchByStatus'));
		    component.set('v.filterThemeValue',  component.get('v.searchByTheme'));

		    helper.getCommonSettings(component);

	        let url = window.location.href;
	        component.set("v.currentURL", encodeURIComponent(url));
	        helper.debug(component, "List URL = " + encodeURIComponent(url));

		    let topicValue = '';
		    let urlParts  = url.split(/[\/?]/);
	        let start = 0;

	        // parameters start after /s/
	        for(; start < urlParts.length; start++) {
	        	if (urlParts[start] === 's') {
	        		break;
		        }
	        }

	        if (urlParts[start+1] === 'topic') {
	        	topicValue = urlParts[start+3];
		        topicValue = decodeURIComponent(topicValue);
	        }

	        let searchByTopics = component.get("v.searchByTopics");

	        if (topicValue) {
				component.set("v.topicValue", topicValue);
	        } else {
		        //component.set("v.topicValue", searchByTopics);
	        }

	        let searchTerm = component.get('v.searchString');
	        if (searchTerm) {
		        component.set("v.searchTermValue", searchTerm);
	        }

	        if (component.get("v.filterOn") === 'Search Term') {
	            component.set("v.searchTermValue", topicValue);
	        }

	        if (component.get("v.searchMyIdeas") === 'Topic') {
	            component.set("v.topicValue", topicValue);
	            helper.debug(component, "Search by Topic: " + component.get("v.searchByTopics"));
	        }

		    $A.get("e.c:SVNSUMMITS_Ideas_Set_Default_Display_Mode")
			    .setParams({
				    listId      : component.get('v.listId'),
				    listViewMode: component.get("v.displayMode")
			    })
			    .fire();

			helper.showSpinner(component);
	        helper.getUserId(component);
	        helper.isNicknameDisplayEnabled(component);
	        helper.getSitePrefix(component);
	        helper.getZoneId(component);
	        helper.getAccountVotingLimits(component);
         }
    },

    setDisplayMode : function(component, event, helper) {
	    if (event.getParam("listId") !== component.get('v.listId')) { return;}

        const displayStyle = event.getParam("displayMode");
        component.set("v.displayMode", displayStyle);
    },

    setIdeasFilters : function(component, event, helper) {
    	// ignore other ideas lists
    	if (event.getParam("listId") !== component.get('v.listId')) { return;}

        let searchString        = event.getParam("searchString");
        let searchMyIdeas       = event.getParam("searchMyIdeas");
        let searchByCategories  = event.getParam("searchByCategories");
        let searchByTopics      = event.getParam("searchByTopics");
        let searchByStatus      = event.getParam("searchByStatus");
        let searchByThemes      = event.getParam("searchByThemes");
        let sortBy              = event.getParam("sortBy");
        let searchMode          = event.getParam('searchMode');
        let searchMyVotedIdeas  = event.getParam('searchMyVotedIdeas');
        let searchMyCommentedIdeas = event.getParam('searchMyCommentedIdeas');
        let searchMySubscribedIdeas = event.getParam('searchMySubscribedIdeas');
        let searchMyCompanyIdeas = event.getParam('searchMyCompanyIdeas');
        let searchMyCompanyVotedIdeas = event.getParam('searchMyCompanyVotedIdeas');
        let searchMyCompanyCommentedIdeas = event.getParam('searchMyCompanyCommentedIdeas');
        let searchMyCompanySubscribedIdeas = event.getParam('searchMyCompanySubscribedIdeas');

		if (searchMode) {
			component.set("v.searchString",   searchString.replace('%', '\%').trim());
		}

		//send a ' ' character to clear the filter
        if (searchMyIdeas && searchMyIdeas !== 'empty') {
        	component.set("v.searchMyIdeas",      searchMyIdeas.trim());
        }
        else if(searchMyIdeas === 'empty') {
        	component.set("v.searchMyIdeas",      '');
        }

        // Filters
        if (searchByCategories) {
        	let newCategorySearch = searchByCategories.trim();

        	if (newCategorySearch.length === 0) {
		        newCategorySearch = component.get('v.filterCatValue');
	        }

        	component.set("v.searchByCategories", newCategorySearch);
        }

        if (searchByTopics) {
        	let newTopicSearch = searchByTopics.trim();

        	if (newTopicSearch.length === 0) {
        		newTopicSearch = component.get('v.filterTopicValue');
	        }

        	component.set("v.searchByTopics", newTopicSearch);
        }

	    if (searchByStatus) {
		    let newStatusSearch = searchByStatus.trim();
		    let filterStatusValue = component.get('v.filterStatusValue');

		    if (newStatusSearch.length === 0) {
			    newStatusSearch = filterStatusValue;
		    } else {
		    	if (filterStatusValue && filterStatusValue.length > 0) {
		    		const filterEntries = filterStatusValue.split(',');
		    		if (!filterEntries.includes(newStatusSearch)) {
					    newStatusSearch = filterStatusValue;
				    }
			    }
		    }

		    component.set("v.searchByStatus", newStatusSearch);
	    }

	    if (searchByThemes) {
	    	let newThemeSearch = searchByThemes.trim();

	    	if (newThemeSearch.length === 0) {
	    		newThemeSearch = component.get('v.filterThemeValue');
		    }

		    component.set("v.searchByTheme", newThemeSearch);
	    }

        // Sort
        if (sortBy) {
        	component.set("v.sortBy",             sortBy.trim());
        }

	    if (searchMyVotedIdeas && searchMyVotedIdeas !== 'empty') {
		    component.set("v.searchMyVotedIdeas", searchMyVotedIdeas.trim());
	    } else if (searchMyVotedIdeas === 'empty') {
		    component.set("v.searchMyVotedIdeas", '');
	    }

        if (searchMyCommentedIdeas && searchMyCommentedIdeas !== 'empty') {
        	component.set("v.searchMyCommentedIdeas", searchMyCommentedIdeas.trim());
        }
        else if (searchMyCommentedIdeas === 'empty') {
        	component.set("v.searchMyCommentedIdeas", '');
        }

        if (searchMySubscribedIdeas && searchMySubscribedIdeas !== 'empty') {
        	component.set("v.searchMySubscribedIdeas", searchMySubscribedIdeas.trim());
        }
        else if (searchMySubscribedIdeas === 'empty') {
        	component.set("v.searchMySubscribedIdeas", '');
        }

        if (searchMyCompanyIdeas && searchMyCompanyIdeas !== 'empty') {
        	component.set("v.searchMyCompanyIdeas", searchMyCompanyIdeas.trim());
        }
        else if (searchMyCompanyIdeas === 'empty') {
        	component.set("v.searchMyCompanyIdeas", '');
        }

	    if (searchMyCompanyVotedIdeas && searchMyCompanyVotedIdeas !== 'empty') {
		    component.set("v.searchMyCompanyVotedIdeas", searchMyCompanyVotedIdeas.trim());
	    } else if (searchMyCompanyVotedIdeas === 'empty') {
		    component.set("v.searchMyCompanyVotedIdeas", '');
	    }

	    if (searchMyCompanyCommentedIdeas && searchMyCompanyCommentedIdeas !== 'empty') {
		    component.set("v.searchMyCompanyCommentedIdeas", searchMyCompanyCommentedIdeas.trim());
	    } else if (searchMyCompanyCommentedIdeas === 'empty') {
		    component.set("v.searchMyCompanyCommentedIdeas", '');
	    }

	    if (searchMyCompanySubscribedIdeas && searchMyCompanySubscribedIdeas !== 'empty') {
		    component.set("v.searchMyCompanySubscribedIdeas", searchMyCompanySubscribedIdeas.trim());
	    } else if (searchMyCompanySubscribedIdeas === 'empty') {
		    component.set("v.searchMyCompanySubscribedIdeas", '');
	    }

	    if (!searchString) {
		    helper.showSpinner(component);
	    }

        helper.getIdeasList(component);
    },

    handleSortChange : function(component, event, helper) {
        helper.debug(component,"handleSortChange called");
        component.set("v.ideaListWrapper.ideaList",null);

        let sortByCmp = component.find("sortByInput");
	    component.set("v.sortBy",sortByCmp.get("v.value"));

	    helper.showSpinner(component);
        helper.getIdeasList(component);
    },

    getNextPage : function(component, event, helper) {
        helper.debug(component,"nextPage called", null);
        component.set("v.ideaListWrapper.ideaList",null);

	    helper.showSpinner(component);
        helper.getNextPage(component);
    },

    getPreviousPage : function(component, event, helper) {
        helper.debug(component,"previousPage called",null);
        component.set("v.ideaListWrapper.ideaList",null);

	    helper.showSpinner(component);
        helper.getPreviousPage(component);
    },

    updateCategories : function(component,event,helper){
        component.set("v.ideaListWrapper.ideaList",null);

        let cmpCategoriesFilter = component.find("categoriesFilter");
        let selectedCategories  = cmpCategoriesFilter.get("v.value");

        component.set("v.categories", selectedCategories);

	    helper.showSpinner(component);
        helper.getIdeasList(component);
    },

	gotoListView : function(component, event, helper) {
    	helper.gotoUrl(component, component.get('v.ideasListURL'));
	}
});