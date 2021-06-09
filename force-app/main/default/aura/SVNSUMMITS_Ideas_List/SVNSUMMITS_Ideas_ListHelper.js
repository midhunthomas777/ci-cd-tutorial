/*
 * Copyright (c) 2019. 7Summits Inc.
 */
({
    isNicknameDisplayEnabled : function(component) {
    	this.doCallout(component, 'c.isNicknameDisplayEnabled', {}, false, 'Is Nickname Displayed', true)
		    .then(result => {
			    component.set("v.isNicknameDisplayEnabled", result);
		    });
    },

    getAccountVotingLimits : function(component) {

        this.doCallout(component, 'c.getVotingDetails', {ideaId : ''}, false, '', true)
        .then(result => {
            if(result!= null) {
                //component.set('v.totalVoteCount', result.totalVotes);
                //component.set('v.currentVoteCount', result.currentVoteCount);
                component.set('v.accountLimitReachedMessage', result.accountVoteLimitMessage);
            }
        });
    },

    getUserId : function(component) {
    	component.set('v.userId', $A.get("$SObjectType.CurrentUser.Id"));
    },

    getSitePrefix : function(component) {
    	this.doCallout(component, 'c.getSitePrefix', {}, false, 'Get Site Prefix', true)
		    .then(sitePath => {
			    component.set("v.sitePath", sitePath);

			    let position = sitePath.lastIndexOf('/s');
			    component.set("v.sitePrefix", sitePath.substring(0, position));
		    });
    },

    getZoneId : function(component) {
        let self = this;
	    this.doCallout(component, 'c.getZoneId',
		    {
			    nameValue: component.get("v.zoneName")
		    }, false, 'Get Zone Id', true)
		    .then(value => {
			    if (value !== '') {
				    component.set("v.zoneId", value);
				    //self.getPickListValues(component);
				    self.getIdeasList(component);
			    } else {
				    component.set('v.zoneError', "Zone not set in builder");
			    }
		    });
    },

    getCommonSettings: function(component) {
    	this.doCallout(component, 'c.getCommonSettings',
		    {}, false, 'Get Common Settings', true)
		    .then(settings => {
		    	component.set('v.debugMode',         settings.debugMode);
			    component.set('v.enableDownVoting',  settings.allowDownVoting);
			    component.set('v.voteDisableStatus', settings.voteDisableStatus);
			    component.set('v.showAlternateCTA',  settings.showAlternateCTA);
		    });
    },

    getIdeasList: function(component) {
        this.dumpIdeaListOptions('getIdeasList', component);

        let self     = this;
	    let featured = component.get('v.displayMode') === 'Featured';

        this.doCallout(component,
	        featured ? 'c.getFeaturedIdeas' : 'c.getIdeas',
	        featured ? this.updateFeaturedParams(component) : this.updateListParams(component),
	        false, 'getIdeasList', false)
	        .then(result => {
	        	let ideaListWrapper = self.updateListWrapper(component, result);
		        component.set("v.ideaListWrapper", ideaListWrapper);

		        //component.set("v.debugMode", ideaListWrapper.debugMode);
		        //component.set("v.enableDownVoting", ideaListWrapper.allowDownVoting);

		        let displayMode = component.get('v.displayMode');

		        if (displayMode !== 'Featured' && displayMode !== 'Compact') {
			        let appEvent = $A.get("e.c:SVNSUMMITS_Ideas_Header_Event");
			        appEvent.setParams({
				        listId      : component.get('v.listId'),
				        totalResults: ideaListWrapper.totalResults,
			        });
			        appEvent.fire();
		        }

		        let sortEvent = $A.get("e.c:SVNSUMMITS_Ideas_Filter_Sort_Event");
		        sortEvent.setParams({
			        listId : component.get('v.listId'),
			        sortBy : component.get("v.sortBy")
		        });
		        sortEvent.fire();

				component.set("v.init", true);

		        self.hideSpinner(component);
	        });
    },

	updateFeaturedParams: function (component) {
		const useFlag = component.get('v.useRecordFlag');

		return useFlag
			? {
				zoneId: component.get("v.zoneId"),
				recordId1 : '',
				recordId2 : '',
				recordId3 : ''
			} : {
				zoneId    : component.get("v.zoneId"),
				recordId1 : component.get("v.recordId1"),
				recordId2 : component.get("v.recordId2"),
				recordId3 : component.get("v.recordId3")
			};
	},

	updateListParams: function(component, paginate) {

		const searchByTopic = (component.get("v.topicValue") && component.get("v.topicValue").trim().length > 0)
			? component.get("v.topicValue")
			: component.get("v.searchByTopics");

		const filterByTopic = (component.get("v.topicValue") && component.get("v.topicValue").trim().length > 0);

		let params = {
			listSize            : component.get("v.listSize"),
			categories          : component.get("v.categories"),
			zoneId              : component.get("v.zoneId"),
			filterByTopic       : filterByTopic,
			topicName           : component.get("v.topicValue"),
			filterBySearchTerm  : component.get("v.filterOn") === 'Search Term' ? true : false,
			searchTerm          : component.get("v.searchString"),
			searchMyIdeas       : component.get("v.searchMyIdeas")  === 'Display My Voted Ideas Only' ? '' : component.get("v.searchMyIdeas"),
			searchByCategories  : component.get("v.searchByCategories"),
			searchByTopics      : component.get("v.searchByTopics"),
			searchByStatus      : component.get("v.searchByStatus"),
			searchByThemes      : component.get("v.searchByTheme"),
			filterOnUserOwned   : component.get("v.searchMyIdeas") === 'Display My Ideas Only' ? true : false,
			filterOnUserVoted   : component.get("v.searchMyIdeas") === 'Display My Voted Ideas Only' ? true : false,
			sortBy              : component.get("v.sortBy"),
			filterByMergeIdea   : component.get("v.displayMergeIdeas"),
			limitVoteToEmailDomain  : component.get("v.limitVoteToEmailDomain"),
			filterByMyVotedIdeas : component.get("v.searchMyVotedIdeas") === 'Display My Voted Ideas' ? true : false,
			searchByMyVotedIdeas : component.get("v.searchMyVotedIdeas"),
			filterMyCommentedIdeas : component.get('v.searchMyCommentedIdeas') === 'Display My Commented Ideas Only' ? true : false,
			searchMyCommentedIdeas : component.get('v.searchMyCommentedIdeas'),
			filterMySubscribedIdeas : component.get('v.searchMySubscribedIdeas') === 'Display My Subscribed Ideas Only' ? true : false,
			searchMySubscribedIdeas : component.get('v.searchMySubscribedIdeas'),
			filterMyCompanyIdeas : component.get('v.searchMyCompanyIdeas') === 'Display My Company Ideas Only' ? true : false,
			searchMyCompanyIdeas : component.get('v.searchMyCompanyIdeas'),
			filterMyCompanyVotedIdeas : component.get('v.searchMyCompanyVotedIdeas') === 'Display My Company Voted Ideas Only' ? true : false,
			searchMyCompanyVotedIdeas : component.get('v.searchMyCompanyVotedIdeas'),
			filterMyCompanyCommentedIdeas : component.get('v.searchMyCompanyCommentedIdeas') === 'Display My Company Commented Ideas Only' ? true : false,
			searchMyCompanyCommentedIdeas : component.get('v.searchMyCompanyCommentedIdeas'),
			filterMyCompanySubscribedIdeas : component.get('v.searchMyCompanySubscribedIdeas') === 'Display My Company Subscribed Ideas Only' ? true : false,
			searchMyCompanySubscribedIdeas : component.get('v.searchMyCompanySubscribedIdeas')
		};

		if (paginate) {
			params['pageNumber'] = component.get("v.ideaListWrapper").pageNumber;
		}

		return params;
	},

	updateListWrapper: function(component, result) {
		let ideaListWrapper = this.parseNamespace(component, result);
		let topicMap        = ideaListWrapper.topicNameToId;

		let sortBy          = component.get("v.sortBy");
		let sitePath        = component.get('v.sitePath');

		for (let i = 0; i < ideaListWrapper.ideaList.length; i++) {
			ideaListWrapper.ideaList[i] = this.updateIdeaValues(
				component,
				ideaListWrapper.ideaList[i],
				topicMap,
				sitePath,
				sortBy,
				component.get('v.voteDisableStatus'));
		}

		return ideaListWrapper;
	},

	getNextPage: function (component) {
		this.dumpIdeaListOptions('getNextPage', component);
		let self = this;

		this.doCallout(component, 'c.nextPage',
			this.updateListParams(component, true), false, 'getNextPage', false)
			.then(result => {
				component.set("v.ideaListWrapper", self.updateListWrapper(component, result));
				self.hideSpinner(component);
			});
	},

	getPreviousPage: function (component) {
		this.dumpIdeaListOptions('getPreviousPage', component);
		let self = this;

		this.doCallout(component, 'c.previousPage',
			this.updateListParams(component, true), false, 'getPreviousPage', false)
			.then(result => {
				component.set("v.ideaListWrapper", self.updateListWrapper(component, result));
				self.hideSpinner(component);
			});
	},

	showSpinner: function (component) {
		this.debug(component, 'Spinner on...');
		component.set('v.showSpinner', true);
	},

	hideSpinner: function (component) {
		this.debug(component, 'Spinner off...');
		component.set('v.showSpinner', false);
	},

    dumpIdeaListOptions: function(title, component) {
        this.debug(component, ' ');
        this.debug(component, title);
        this.debug(component, '======================================');
        this.debug(component, 'DisplayMode:     ' + component.get("v.displayMode"));
        this.debug(component, 'ListSize:        ' + component.get("v.listSize"));
        this.debug(component, 'Categories:      ' + component.get("v.categories"));
        this.debug(component, 'ZoneId:          ' + component.get("v.zoneId"));
        this.debug(component, 'LimitVote:       ' + component.get("v.limitVoteToEmailDomain"));
        this.debug(component, component.get("v.filterOn") === 'Topic' ? 'Topic filter:    true' : 'Topic filter:    false');
        this.debug(component, 'Topic Value:     ' + component.get("v.topicValue"));
        this.debug(component, component.get("v.filterOn") === 'Search Term' ? 'Search Term:     true' : 'Search Term:     false');
        this.debug(component, 'Search string:   ' + component.get("v.searchString"));
        this.debug(component, component.get("v.searchMyIdeas") === 'Display My Ideas Only'       ? 'MyIdeas:         true' : 'MyIdeas:         false');
        this.debug(component, component.get("v.searchMyIdeas") === 'Display My Voted Ideas Only' ? 'MyVotedIdeas:    true' : 'MyVotedIdeas:    false');
        this.debug(component, 'SearchMyIdeas:   ' + component.get("v.searchMyIdeas"));
        this.debug(component, 'SearchCategories:' + component.get("v.searchByCategories"));
        this.debug(component, 'SearchTopics:    ' + component.get("v.searchByTopics"));
        this.debug(component, 'SearchStatus:    ' + component.get("v.searchByStatus"));
        this.debug(component, 'SearchTheme:     ' + component.get("v.searchByTheme"));
        this.debug(component, 'SortBy:          ' + component.get("v.sortBy"));
        this.debug(component, component.get("v.searchMyVotedIdeas") === 'Display My Voted Ideas' ? 'Ideas I’ve Voted On:         true' : 'Ideas I’ve Voted On:         false');
        this.debug(component, 'SearchMyVotedIdeas:  ' + component.get("v.searchMyVotedIdeas"));
        this.debug(component, component.get("v.searchMyCommentedIdeas") === 'Display My Commented Ideas Only' ? 'Ideas I’ve Commented On:     true' : 'Ideas I’ve Commented On:     false');
        this.debug(component, 'SearchMyCommentedIdeas:  ' + component.get("v.searchMyCommentedIdeas"));
        this.debug(component, component.get("v.searchMySubscribedIdeas") === 'Display My Subscribed Ideas Only' ? 'Ideas I’ve Subscribed On:     true' : 'Ideas I’ve Subscribed On:     false');
        this.debug(component, 'searchMySubscribedIdeas:  ' + component.get("v.searchMySubscribedIdeas"));
        this.debug(component, component.get("v.searchMyCompanyIdeas") === 'Display My Company Ideas Only' ? 'My Company Ideas:     true' : 'My Company Ideas:     false');
        this.debug(component, 'searchMyCompanyIdeas:  ' + component.get("v.searchMyCompanyIdeas"));
        this.debug(component, component.get("v.searchMyCompanyVotedIdeas") === 'Display My Company Voted Ideas Only' ? 'My Company Voted Ideas:     true' : 'My Company Voted Ideas:     false');
        this.debug(component, 'searchMyCompanyVotedIdeas:  ' + component.get("v.searchMyCompanyVotedIdeas"));

        this.debug(component, '---------------------------------------');
    }

});