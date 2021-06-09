/*
 * Copyright (c) 2019. 7Summits Inc.
 */
({

	validateDescription : function (component) {
		const htmlString = component.get('v.currIdea.Body');
		const valid      = !!htmlString && !!this.getHtmlPlainText(component, htmlString).trim();

		component.set('v.validDescription', valid);
		return valid;
	},

	validateStatus: function (component) {
		let valid = true;

		if (component.get('v.requireComment')) {
			const prevStatus = component.get('v.currentStatus');

			if (prevStatus && (component.get('v.currIdea.Status') !== prevStatus)) {
				const htmlString = component.get('v.currIdea.Status_Comment__c');
				valid = !!htmlString && !!this.getHtmlPlainText(component, htmlString).trim();
			}
		}

		component.set('v.validComment', valid);
		return valid;
	},

	submitIdea: function (component, currIdea) {
		let self = this;
		let attachmentUpload = component.get("v.attachmentUpload");

		if (attachmentUpload) {
			this.loadFileContent(component, attachmentUpload)
				.then(fileContent => {
					if (fileContent.indexOf("image") > -1) {
						currIdea.AttachmentContentType = attachmentUpload.type;
						currIdea.AttachmentName = attachmentUpload.name.length > 40
							? attachmentUpload.name.substring(0, 40)
							: attachmentUpload.name;

						self.saveRelated(component, currIdea, fileContent.split(",")[1]);
					}
				}, error => console.log(error));

		} else {
			this.saveRelated(component, currIdea, '');
		}
	},

	loadFileContent: function (component, fileUpload) {
		return new Promise((resolve, reject) => {
			const reader = new FileReader();

			reader.readAsDataURL(fileUpload);
			//reader.readAsArrayBuffer(fileUpload);

			reader.onload  = () => resolve(reader.result);
			reader.onerror = error => reject(error);
		});
	},

	saveRelated: function(component, currIdea, image) {
		let self = this;

		let relatedFiles = [];
		let relatedCount = 0;
		let relatedTotal = 0;

		let relatedUpload = component.get('v.relatedFilesUpload');

		if (relatedUpload) {
			relatedTotal = relatedUpload.length;

			relatedUpload.forEach(file => {
				this.loadFileContent(component, file)
					.then(fileContent => {
						relatedFiles.push({
							name        : (file.name.split('\\').pop().split('/').pop().split('.'))[0],
							fileName    : file.name,
							dataString  : fileContent.split(",")[1]
						});
						relatedCount += 1;

						if (relatedCount === relatedTotal) {
							self.saveIdea(component, currIdea, image, relatedFiles);
						}
					});
			});
		} else {
			this.saveIdea(component, currIdea, image, relatedFiles);
		}
	},

	saveIdea : function(component, currIdea, image, related) {
		let self = this;

		// update the Apex RelatedFiles object
		let relatedItems = component.get('v.relatedFiles');
		relatedItems.files = [];

		let relatedString;

		if (related) {
			related.forEach(file => {
				let relatedItem = component.get('v.relatedFile');

				relatedItem.name        = file.name;
				relatedItem.fileName    = file.fileName;
				relatedItem.dataString  = file.dataString;

				relatedItems.files.push(relatedItem);
			});

			relatedString = JSON.stringify(relatedItems);
			console.log('Related files (' + relatedItems.files.length + ')');
			console.log('    ' + relatedItems.files);

			relatedItems.files.forEach(item => {
				console.log('    file: ' + item.name);
			});
		}


		// TODO handle visibility
		let relatedVisibility = 'AllUsers';

		// ignore status comments if status is not changed
		if (component.get('v.currentStatus') === currIdea.Status) {
			currIdea.Status_Comment__c = '';
		}

		//let action  = component.get("v.isEditing") ? "c.updateIdea" : "c.createIdeaNew";
		let params  = {
			currIdeaList        : new Array(currIdea),
			imageString         : image,
			relatedFileString   : relatedString,
			visibility          : relatedVisibility,
			customFieldSetName  : component.get('v.customFieldSetName')
		};

		this.doCallout(component, 'c.createIdeaNew', params, false, 'Save idea', false)
			.then(resId => {
				self.gotoIdeaDetail(component, resId);
			});
	},

	gotoIdeaDetail: function(component, recordId) {
		let recordUrl = component.get('v.ideaDetailURL');
		this.gotoRecordUrl(component, recordId, recordUrl);
	},

	getIdeaRecord: function (component) {
		let self = this;

		this.doCallout(component, 'c.getIdeaRecord',
			{
				zoneId  : component.get("v.zoneId"),
				recordId: component.get("v.recordId"),
				customFieldSetName : component.get('v.customFieldSetName')
			}, false, 'Get Idea', false).then(
			wrapper => {
				let idea = self.updateIdeaValues(component,
					self.parseNamespace(component, wrapper.ideaList[0]),
					wrapper.topicNameToId,
					wrapper.sitePath,
					'');

				idea.Status_Comment__c = '';
				component.set('v.currentStatus', idea.Status);
				component.set('v.attachmentName', idea.AttachmentName);

				self.createCustomFields(component, idea);

				component.set("v.currIdea", idea);
				if(idea.Requested_By__c) {
				    let params  = {
                        userId :  idea.Requested_By__c
                    };
				    this.doCallout(component, 'c.getRequestedByRecord', params, false, '', false)
                        .then(resp => {
                            component.set('v.selectedUser', resp);
                        });
                }
			}
		);
	},

	showSpinner: function (component) {
		let spinnerSubmit = component.find("spinnerSubmit");
		$A.util.removeClass(spinnerSubmit, 'slds-hide');
	},

	hideSpinner: function (component) {
		let spinnerSubmit = component.find("spinnerSubmit");
		$A.util.addClass(spinnerSubmit, 'slds-hide');
	}
});