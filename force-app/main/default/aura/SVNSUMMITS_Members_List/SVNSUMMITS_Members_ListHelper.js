/*
 * Copyright (c) 2018. 7Summits Inc.
 * Changes done - 1. Removed getMemberCount() as it was not referenced anywhere
 * 2. Changed callouts to use doCallout from base component
 */
({

	showSpinner: function (component) {
		console.log('Spinner on...');
		$A.util.removeClass(component.find('listSpinner'), 'slds-hide');
	},

	hideSpinner: function (component) {
		console.log('Spinner off...');
		$A.util.addClass(component.find('listSpinner'), 'slds-hide');
	},

	setListFilters: function (component) {
		// set initial list filters
		var searchString = ':;';
		var topicString  = '';

		var titleSearch = component.get('v.titleSearchValue');
		if (titleSearch) {
			searchString +=  this.contact.fields.title + ':' + titleSearch + ';';
		}

		var countryFilter = component.get('v.countryFilter');
		if (countryFilter) {
			searchString += this.contact.fields.country + ':' + countryFilter + ';';
		}

		var stateFilter = component.get('v.stateFilter');
		if (stateFilter) {
			searchString += this.contact.fields.state +':' + stateFilter + ';';
		}

		var cityFilter = component.get('v.cityFilter');

		if (cityFilter) {
			searchString +=  this.contact.fields.city +':' + cityFilter + ';';
		}

		var accountFilter = component.get('v.accountFilter');

		if (accountFilter.length) {
			searchString += this.contact.fields.account +':' + accountFilter + ';';
		}

		var topicSearch = component.get('v.topicFilter');

		if (topicSearch.length) {
			topicString = topicSearch;
		}

		// Custom fields
		for (var pos = 1; pos <= this.custom.MAX_FIELDS; pos++) {
			var customFilter = component.get('v.customFilter'+pos);

			if (customFilter.length) {
				var customValue = component.get('v.customValue'+pos);

				if (customValue.length) {
					searchString += customFilter + ':' + customValue + ';';
				}
			}
		}

		component.set('v.searchString', searchString);
		component.set('v.topicString',  topicString);
	},

	getExcludedIDs: function (component) {
		var idList      = [];
		var splitChar = ',';
		var excludedIds = component.get("v.excludedMembers");

		if (excludedIds.indexOf(splitChar) !== -1) {
			var ids = excludedIds.split(splitChar);
			for (var pos = 0; pos < ids.length; ++pos) {
				if (ids[pos].length > 0) {
					idList.push(ids[pos]);
				}
			}
		}
		else {
			idList.push(excludedIds);
		}

		return idList;
	},

	getCustomFieldList : function(component) {
		var customFieldList = [];

		for (var pos = 1; pos <= this.custom.MAX_FIELDS; pos++) {
			var customField = component.get('v.customField'+pos);

			if (customField) {
				customFieldList.push(customField);
			}
		}

		return customFieldList;
	},


	getMemberList: function (component, event, currentPage) {
		var self = this;
		self.showSpinner(component);
		//set the params

		var excludedList    = this.getExcludedIDs(component);
        var customFieldList = this.getCustomFieldList(component);

		var params = {
            pageSize        : component.get("v.numberOfMembers"),
            currentPage     : currentPage,
            sortBy          : component.get("v.sortBy"),
            searchMyMembers : component.get("v.searchMyMembers"),
            searchString    : component.get("v.searchString") || "",
            topicId         : component.get('v.topicString'),
            hideInternal    : component.get("v.hideInternal"),
            excludeList     : excludedList,
            customFields    : customFieldList
        };

		self.doCallout(component,'c.getMemberListC',params).
		then((membersListWrapper) =>{
            var updatedWrapper     = self.updateMemberList(component, membersListWrapper);

            if (updatedWrapper.totalResults === 0) {
                updatedWrapper.totalPages = 0;
            }

            self.updateHeader(component, updatedWrapper.totalResults);
            component.set("v.membersListWrapper", updatedWrapper);
        },
        (errors) => {
            for (var i = 0; i < errors.length; i++) {
                self.debug(component, '    :', errors[i].message);
            }
        });
	},

	clearMemberList: function(component) {
		var membersListWrapper = component.get('v.membersListWrapper');

		membersListWrapper.membersList    = [];
		membersListWrapper.totalResults   = 0;
		membersListWrapper.pageNumber     = 0;
		membersListWrapper.totalPages     = 0;
		membersListWrapper.hasNextSet     = false;
		membersListWrapper.hasPreviousSet = false;

		component.set('v.membersListWrapper', membersListWrapper);
		this.updateHeader(component, membersListWrapper.totalResults);
	},

	updateHeader : function (component, totalResults) {
		var appEvent = $A.get("e.c:SVNSUMMITS_Members_Header_Event");

		appEvent.setParams({
			"totalResults": totalResults === -1 ? '' : totalResults
		});

		appEvent.fire();
	},

	updateMemberList: function (component, membersListWrapper) {
		for (var i = 0; i < membersListWrapper.membersList.length; i++) {

			// am I following this member
			membersListWrapper.membersList[i].isFollowing = (membersListWrapper.mapUserId_Wrapper[membersListWrapper.membersList[i].Id]).isFollowing;

			// Store the number of followers to display on the component
			membersListWrapper.membersList[i].intNumberOfFollowers = (membersListWrapper.mapUserId_Wrapper[membersListWrapper.membersList[i].Id]).intNumberOfFollowers;

			// Store the number of like received to display on the component
			membersListWrapper.membersList[i].intLikeReceived = (membersListWrapper.mapUserId_Wrapper[membersListWrapper.membersList[i].Id]).intLikeReceived;

			// number of posts made
			membersListWrapper.membersList[i].intPostsMade = (membersListWrapper.mapUserId_Wrapper[membersListWrapper.membersList[i].Id]).intPostsMade;

			// Store the topics name for displaying on component
			membersListWrapper.membersList[i].strKnowledgeTopics = (membersListWrapper.mapUserId_Wrapper[membersListWrapper.membersList[i].Id]).strKnowledgeTopics;

			// Store the topics name for displaying on component
			membersListWrapper.membersList[i].strKnowledgeTopics1 = (membersListWrapper.mapUserId_Wrapper[membersListWrapper.membersList[i].Id]).strKnowledgeTopics1;

			// Store the topics name for displaying on component
			membersListWrapper.membersList[i].strKnowledgeTopics2 = (membersListWrapper.mapUserId_Wrapper[membersListWrapper.membersList[i].Id]).strKnowledgeTopics2;

			// Store the topics Id for displaying on component
			membersListWrapper.membersList[i].strKnowledgeTopicId = (membersListWrapper.mapUserId_Wrapper[membersListWrapper.membersList[i].Id]).strKnowledgeTopicId;

			// Store the topics Id for displaying on component
			membersListWrapper.membersList[i].strKnowledgeTopicId1 = (membersListWrapper.mapUserId_Wrapper[membersListWrapper.membersList[i].Id]).strKnowledgeTopicId1;

			// Store the topics Id for displaying on component
			membersListWrapper.membersList[i].strKnowledgeTopicId2 = (membersListWrapper.mapUserId_Wrapper[membersListWrapper.membersList[i].Id]).strKnowledgeTopicId2;

			this.setCustomFields(component, membersListWrapper, i);
		}

		return membersListWrapper;
	},

	setCustomFields : function (component, membersListWrapper, index) {
		for (var pos = 1; pos <= this.custom.MAX_FIELDS; pos++) {
			var customField = component.get('v.customField' + pos);

			if (customField.length) {
				var fieldSet   = true;
				var fieldParts = customField.split('.');
				var fieldValue = membersListWrapper.membersList[index];

				for (var part = 0; part < fieldParts.length; part++) {
					if (fieldValue[fieldParts[part]]) {
						fieldValue = fieldValue[fieldParts[part]];
					}
					else {
						fieldSet = false;
						break;
					}
				}

				membersListWrapper.membersList[index]['customField' + pos] = fieldSet ? fieldValue : '';
			}
		}
	},

    //This method will be called when user will click on "follow" or "unfollow" button
	followRecord : function (component, followAction, recordId, currentPage) {
		this.showSpinner(component);

		let self   = this;
        let params = {
            'recordId' : recordId
        }

		self.doCallout(component,followAction ? 'c.followRecord' : 'c.unfollowRecord',params).
        then((result) =>{
            self.hideSpinner(component);
        },
        (errors) => {
            console.log(JSON.stringify(errors));
            self.hideSpinner(component);
            for (var i = 0; i < errors.length; i++) {

                self.debug(component, '    :', errors[i].message);

            }
            self.showMessage('error', 'List - Follow Button', 'Failed to follow/un-follow selected member');
        });



	}
});