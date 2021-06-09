/*
 * Copyright (c) 2019. 7Summits Inc.
 */
({
	custom: {
		layout : {
			LIST        : 'List View',
			GRID        : 'Tile View'
		},
		urlParams: {
			edit        : 'c__edit',
			recordId    : 'recordId',
			lexRecordId : 'c__lexRecordId', // the c__ namespace prefix is vital for this to work.
			view        : '/view'
		},
		profileUrl : {
			lex         : '/lightning/r/User/',
			view        : '/view',
			community   : '/profile/'
		},
		topicUrl : {
			lex         : '/lightning/r/Topic/',
			view        : 'view',
			community   : '/topic/'
		},
		VOTE_STATUS_DELIMITER : ',',
		MAX_FILE_SIZE   : 4500000, //Max file size 4.5 MB
		CHUNK_SIZE      : 750000,   //Chunk Max size 750Kb
		customFields: {
			fieldTypeText  : 'Text',
			fieldTypeRich  : 'Richtext',
			fieldTypeMulti : 'Mulitline'
		}
	},


	parseNamespace: function (component, obj) {
		const self = this;
		let model = (component.get("v.baseModel")) ? JSON.parse(component.get("v.baseModel")) : {};
		if (model) {
			if (model.namespacePrefix) {
				for (let k in obj) {
					if (typeof obj[k] === "object" && obj[k] !== null) {
						self.parseNamespace(component, obj[k]);
					}
					if (k.indexOf(model.namespacePrefix + '__') >= 0) {
						let withoutNamespace = k.replace(model.namespacePrefix + '__', '');
						obj[withoutNamespace] = obj[k];
					}
				}
			}
		}
		return obj;
	},

	setNamespace: function (component, obj) {
		const self = this;
		let model = (component.get("v.baseModel")) ? JSON.parse(component.get("v.baseModel")) : {};
		if (model) {
			if (model.namespacePrefix) {
				for (let k in obj) {
					if (typeof obj[k] === "object" && obj[k] !== null) {
						self.setNamespace(component, obj[k]);
					}
					if (k.indexOf(model.namespacePrefix + '__') >= 0) {
						let withoutNamespace = k.replace(model.namespacePrefix + '__', '');
						if (obj[withoutNamespace]) {
							obj[k] = obj[withoutNamespace];
							delete obj[withoutNamespace];
						}
					} else if (k.indexOf('__c') >= 0) {
						obj[model.namespacePrefix + '__' + k] = obj[k];
						delete obj[k];
					}
				}
			}
		}
		return obj;
	},

	doCallout: function (component, method, params, hideToast, toastTitle, cache) {
		const self = this;

		return new Promise($A.getCallback(function (resolve, reject) {
			let action = component.get(method);

			if (params) {
				action.setParams(params);
			}

			if (cache) {
				//action.setStorable();
			}

			action.setCallback(component, function (response) {
				let state = response.getState();

				if (component.isValid() && state === "SUCCESS") {
					resolve(response.getReturnValue());
				} else {
					let errors = response.getError();
					console.log(JSON.parse(JSON.stringify(errors)));

					if (errors && errors[0] && errors[0].message && !hideToast) {
						self.showMessage("error", toastTitle || 'Callback failed', errors[0].message);
					} else if (!hideToast) {
						self.showMessage("error", 'Callback failed', "Unknown Error");
					}

					reject(errors);
				}
			});

			$A.enqueueAction(action);
		}));
	},

	// NAVIGATION
	gotoUrl: function (component, url) {
		$A.get("e.force:navigateToURL")
			.setParams({
				url       : url,
				isredirect: true
			}).fire();
	},


	gotoRecord: function (component, recordId) {
		$A.get("e.force:navigateToSObject")
			.setParams({
				recordId: recordId
			}).fire();
	},

	gotoRecordUrl: function(component, recordId, recordUrl) {
		if (this.inLexMode()) {
			let url = component.get('v.sitePrefix');
			url += recordUrl;
			url += '?' + this.custom.urlParams.lexRecordId + '=' + recordId;
			this.gotoUrl(component, url);
		} else {
			this.gotoRecord(component, recordId);
		}
	},

	// NOTE: (from Salesforce)
	// LEX uses a page state whitelist to wipe all query parameters
	// they don't want present in the url to avoid any collisions with custom components.
	// Adding a namespace of `c__` to the beginning of you query parameter should allow it to remain.
	// So instead of using lexRecordId as your key you can use c__lexRecordId and the query param should persist.
	navigateToRecordURL : function(component, navService, recordUrl, recordId) {

		let pageReference = {};

		if (this.inLexMode()) {
			let globalId  = component.getGlobalId();
			pageReference = {
				type: 'standard__webPage',
				attributes: {
					url: component.get('v.sitePrefix')
						+ recordUrl
						+ '?'
						+ this.custom.urlParams.lexRecordId
						+ '='
						+ recordId
				},
				replace: true
			};

		} else {
			pageReference = {
				type: 'standard__recordPage',
				attributes: {
					recordId: recordId,
					objectApiName: 'Idea',
					actionName: 'view'
				}
			};
		}
		navService.navigate(pageReference);
	},

	getHtmlPlainText : function(component, htmlString) {
		return htmlString.replace(/<[^>]+>/g, '');
	},

	// NOTIFICATION
	showMessage: function (level, title, message) {
		console.log("Message (" + level + "): " + message);

		$A.get("e.force:showToast")
			.setParams({
				"title": title,
				"message": message,
				"type": level
			}).fire();
	},

	// IDEAS COMMON UTILITY FUNCTIONS
	updateIdeaValues : function (component, idea, topicMap, sitePath, sortBy, voteDisableStatus) {
		if (idea) {
			if (idea.Categories) {
				idea.Categories = idea.Categories.split(";");
			}

			idea.fromNow    = moment(idea.CreatedDate).fromNow();
			idea.submitDate = moment(idea.CreatedDate).format('D MMM YYYY');
			idea.enableVote = true;

			if (voteDisableStatus) {
				idea.enableVote = this.enableVoting(component, idea.Status, voteDisableStatus);
			}

			if (topicMap) {
				idea.topicName = idea.Related_Topic_Name__c;

				let topicId = topicMap[idea.topicName];

				if (idea.Related_Topic_Name__c) {
					if (topicId) {
						idea.topicLink = this.inLexMode() ? this.custom.topicUrl.lex : (sitePath + this.custom.topicUrl.community);
						idea.topicLink += topicId;
						idea.topicLink += "/";
						idea.topicLink += this.inLexMode() ? this.custom.topicUrl.view : encodeURIComponent(idea.topicName);
					} else {
						idea.topicLink = '#';
					}
				}
				console.log('topic url: ' + idea.topicLink);
			}

			if (sortBy && sortBy === "Recent Comments") {
				idea.LastComment.fromNow = moment(idea.LastComment.CreatedDate).fromNow();
			}
		}

		return idea;
	},

	// VOTING
	submitSingleVote: function (component, ideaId, voteType) {
		this.debug(component, 'listItem:submitVote', voteType);

		this.doCallout(component, 'c.submitVote', {
			ideaId  : component.get("v.idea.Id"),
			voteType: voteType
		}, false, 'Submit vote', false)
			.then(ideaListWrapper => {
				let topicMap = ideaListWrapper.topicNameToId;
				let currIdea = ideaListWrapper.ideaList[0];

				console.log('listItem:submitVote', currIdea);

				if (currIdea) {
					let idea = this.updateIdeaValues(component, currIdea, topicMap);
					component.set("v.idea", idea);
				}
			});
	},

	// FILTERS -
	setFilterValue : function(component, targetName, sourceName, filterValue) {
		if (filterValue) {
			let newFilterValue = filterValue.trim();

			// respect the preset filters
			if (filterValue.length === 0) {
				newFilterValue = component.get(sourceName);
			}
			component.set(targetName, newFilterValue);
		}
	},

	// DEBUG
	debug: function (component, msg, variable) {
		if (component.get("v.debugMode")) {
			if (msg) {
				console.log(msg);
			}
			if (variable) {
				console.log(variable);
			}
		}
	},

	// LEX functions
	inLexMode: function () {
		let lexMode = new RegExp('.*?\/s\/','g').exec(window.location.href) != null;
		return !lexMode;
	},

	// URL PARSING
	parseRecordId : function (component, url) {
		let urlParts = url.split(/[\/?=]/);
		let start = 0;
		const recordParam = this.inLexMode() ? this.custom.urlParams.lexRecordId : this.custom.urlParams.recordId;

		for (; start < urlParts.length; start++) {
			if (urlParts[start] === recordParam) {
				break;
			}
		}

		let recordId = urlParts[start + 1];
		console.log('record Id from URL: ' + recordId);

		return recordId;
	},

	getURLParam : function() {
		let query  = location.search.substr(1);
		let result = {};

		query.split("&").forEach(part => {
			let items = part.split("=");

			// replace string concatenation + character before decodeURI to preserve real '+' characters
			if (items.length > 1) {
				result[items[0]] = decodeURIComponent(items[1].replace(/\+/g, '%20'));
			}
		});

		return result;
	},

	// CUSTOM FIELDS
	createCustomFields : function(component, idea) {
		let customFields  = component.get('v.customFields');

		if (idea) {
			if (customFields.length) {
				customFields.forEach(field => {
					field['value'] = idea[field.apiName] || '';

					switch (field.align) {
						case 'center':
							field['alignClass'] = 'slds-align_absolute-center';
							break;
						case 'right':
							field['alignClass'] = 'slds-float_right';
							break;
						default:
							field['alignClass'] = 'slds-text-align_left';
							break;
					}
				});
			}

			component.set('v.customFields', customFields);
		}
	},

	// FILE UPLOAD - find the intersect between the specified extensions and the community settings
	getAllowedExtensions : function(communityExt, builderExt) {
		let communityExtList  = communityExt.split(',');
		let relatedExtList    = builderExt.split(',').map(x => x.replace('.', '').trim());
		let relatedExtensions = relatedExtList.filter(x => communityExtList.includes(x));

		return relatedExtensions.map(x => '.' + x).join(',');
	},

	// VOTING
	enableVoting: function (component, ideaStatus, voteDisableStatusList) {
		let enableVote = true;

		if (voteDisableStatusList) {
			let statusList = voteDisableStatusList.split(this.VOTE_STATUS_DELIMITER);
			if (statusList.includes(ideaStatus)) {
				enableVote = false;
			}
		}

		return enableVote;
	}
});