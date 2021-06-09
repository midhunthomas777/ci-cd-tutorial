/*
 * Copyright (c) 2019. 7Summits Inc.
 */
({
    onInit : function(component, event, helper) {
	    let recordId = '';
	    let search   = helper.getURLParam();

	    if (search && search[helper.custom.urlParams.edit]) {
		    recordId = search[helper.custom.urlParams.edit];
	    }

	    if (recordId) {
		    component.set('v.recordId', recordId);
		    component.set('v.isEditing', true);
	    }

	    // do not load Topics, Categories or Status if specified in the builder
	    let useTopics       = component.get("v.useTopics") && !component.get('v.topicSet');
	    let useCategories   = component.get("v.allowCategories") && component.get('v.categoriesAllowed') === '';
	    let useStatus       = component.get('v.statusAllowed') === '';

	    helper.doCallout(component, 'c.getIdeasNewModel',
		    {
			    zoneName        : component.get("v.zoneName"),
			    fieldSetName    : component.get('v.customFieldSetName'),
			    useTopics       : useTopics,
			    useCategories   : useCategories,
			    useStatus       : useStatus
		    },
		    false, 'Get new data model', true)
		    .then($A.getCallback(function (model) {
			    // file upload settings
			    component.set('v.maxFileSizeKb', model.maxFileSizeKb);

			    // get the intersect between builder and community allowed file extensions
			    if (model.allowedExtensions) {

				    component.set('v.relatedFilesAccept',
					    helper.getAllowedExtensions(
					    	model.allowedExtensions,
						    component.get('v.relatedFilesAccept')));


				    component.set('v.attachmentAccept',
					    helper.getAllowedExtensions(
					    	model.allowedExtensions,
						    component.get('v.attachmentAccept')));
			    }

			    const  settings = model.settings;

			    component.set("v.debugMode",    settings.debugMode);
			    component.set("v.zoneId",       settings.zoneId);
			    component.set('v.sitePrefix',   settings.sitePath);
			    component.set('v.customFields', settings.customFields);

			    let currIdea = component.get('v.currIdea');

			    currIdea.CommunityId = settings.zoneId;

			    if (component.get("v.allowThemes")) {
			    	let themes = model.themes;
			    	if (themes && themes.length) {
					    component.set("v.themeSet", themes);
					    currIdea.IdeaThemeId = themes[0].Id;
				    }
			    }

			    if (component.get("v.useTopics")) {
                    let topicValues = component.get('v.topicSet');
                    let topicList   = [];

                    if (topicValues && topicValues.trim() !== '') {
                        topicValues.split(',').forEach(topic => topicList.push({'Name' : topic.trim()}));
                    } else {
                        topicList = model.topics;
                    }

                    component.set("v.topicNamesList", topicList);
                    currIdea.Related_Topic_Name__c = topicList.length ? topicList[0].Name : '';
			    }

			    if (component.get("v.allowCategories")) {
			    	let categoryValues = component.get('v.categoriesAllowed');
			    	let categories     = [];

			    	if (categoryValues && categoryValues.trim() !== '') {
			    		 categoryValues.split(',').forEach(category => categories.push(category.trim()));
				    } else {
					    categories = model.categories;
				    }
				    component.set('v.categoriesSet', categories);
				    currIdea.Categories = categories ? categories[0] : '';
			    }

			    let statusValues = component.get('v.statusAllowed');
		        let statusList   = [];

			    if (statusValues && statusValues.trim() !== '') {
			    	statusValues.split(',').forEach(status => statusList.push(status.trim()));
			    } else {
			    	statusList = model.statusus;
			    }
			    component.set('v.statusSet', statusList);
			    currIdea.Status = model.defaultStatus;


				// load or set defaults
			    if (component.get("v.isEditing")) {
			    	//component.set('v.isNewIdea', false);
				    helper.getIdeaRecord(component);
			    } else {
			    	component.set('v.currIdea', currIdea);
			    }
		    }));

        helper.hideSpinner(component);
    },

    check_DuplicateIdeas : function(component, event, helper) {
	    if (!component.get('v.isEditing') &&
		     component.get('v.showDuplicates')) {
		    let idea         = component.get('v.currIdea');
		    const minLength  = component.get('v.minTitleLength');
		    const statusList = component.get('v.statusAllowed');
		    let inputTitle   = component.find('ideaInput');
		    let title        = idea.Title.trim();

		    if (!title || title.length < minLength) {
			    inputTitle.setCustomValidity(component.get('v.errorShortTitle'));
		    } else {
			    inputTitle.setCustomValidity("");

			    const zoneId = component.get("v.zoneId");
			    let limit    = Math.max(1, component.get("v.simIdeasLimit"));

			    helper.showSpinner(component);
			    helper.doCallout(component, 'c.checkDuplicateIdeas',
				    {
					    title           : title,
					    zoneId          : zoneId,
					    simIdeasLimit   : limit,
					    statusList      : statusList
				    }, false, 'Find similar ideas', false)
				    .then((ideasList) => {
					    component.set("v.ideasList", ideasList);
					    helper.hideSpinner(component);
				    });
		    }
		    inputTitle.reportValidity();
	    }
    },

	onAttachmentUpload : function(component, event, helper) {
	    let files = event.getSource().get("v.files");

        if (files.length > 0) {
        	let file = files[0];

        	if (file.size > helper.custom.MAX_FILE_SIZE ) {
		        component.set("v.attachmentName", 'ALERT : File size cannot exceed '
			        + helper.custom.MAX_FILE_SIZE + ' bytes. '
			        + ' Selected file size: ' + file.size)
	        } else {
		        component.set('v.attachmentUpload', file);
		        component.set('v.attachmentName',   file.name);
	        }
        }
    },

	onRelatedUpload : function (component, event, helper) {
		let files = event.getSource().get("v.files");

		if (files.length > 0) {
			let relatedNames = [];
			let relatedFiles = [];

			for (let pos = 0; pos < files.length; ++pos) {
				let file = files[pos];

				if (file.size > helper.custom.MAX_FILE_SIZE) {
					component.set("v.relatedNames[0]", 'ALERT : File size cannot exceed '
						+ helper.custom.MAX_FILE_SIZE + ' bytes. '
						+ ' Selected file size: ' + file.size);
					return;
				} else {
					relatedFiles.push(file);
					relatedNames.push(file.name);
				}
			}

			component.set('v.relatedFilesUpload', relatedFiles);
			component.set('v.relatedNames', relatedNames.join(', '));
		}
	},

	handleSubmitIdea: function (component, event, helper) {
    	component.set('v.showSpinner', true);
		helper.showSpinner(component);

	    let validIdea = helper.validateDescription(component);

		if (validIdea && component.get('v.isEditing') && component.get('v.requireComment')) {
			validIdea = helper.validateStatus(component);
		}

		// single field validation
		if (validIdea) {
			let inputTitle = component.find('ideaInput');

			validIdea = inputTitle.checkValidity();

			// Uncomment when there is more than 1 field to validate
			// let validIdea = component.find('ideaInput') .reduce((validSoFar, inputComponent) => {
			// 		inputComponent.reportValidity();
			// 		return validSoFar && inputComponent.checkValidity();}, true);

		}

		if (validIdea) {
			let newIdea = helper.setNamespace(component, component.get("v.currIdea"));

			if (component.get('v.showCustomFields')) {
				const customFields = component.get('v.customFields');
				customFields.forEach(field => {
					if (field.value) {
						newIdea[field.apiName] = field.value;
					}
				});
			}

			let requestedBy = component.get('v.selectedUser');

			if (requestedBy) {
				newIdea.Requested_By__c = requestedBy.Id;
			}

			let presetField = component.get('v.presetField');
			if (presetField) {
				newIdea[presetField] = component.get('v.presetValue');
			}

			helper.submitIdea(component, newIdea);
		} else {
			component.set('v.showSpinner', false);
			helper.hideSpinner(component);
		}

	},

	gotoRecord: function (component, event, helper) {
		let recordId  = event.currentTarget.dataset['id'];
		let recordUrl = component.get('v.ideaDetailURL');

		helper.gotoRecordUrl(component, recordId, recordUrl);
	},

	goBack: function (component, event, helper) {
		if (component.get('v.createIdeaClick')) {
			component.set('v.createIdeaClick', false);
		} else {

			if (component.get('v.isEditing')) {
				helper.gotoRecordUrl(component, component.get('v.recordId'), component.get('v.ideaDetailURL'));
			} else {
				window.history.back();
			}
		}
	}
});