({
	getQuotes : function(cmp) {
		var action = cmp.get("c.getQuotePackages");
		var oppId = cmp.get("v.recordId");
		cmp.set('v.loadSpinner', true);
		console.log('oppId: ' + oppId);
		action.setParams({"oppId" : oppId});
		action.setCallback(this, function(response){
			var state = response.getState();
			var selectedRows = [];
			var expandedRows = [];
			var hasPrimary = false;
			if(state === "SUCCESS" ){
				var data = response.getReturnValue();
				console.log('data: ' + JSON.stringify(data));
				var delList = [];
				var hostIds = [];
				for(var i=0; i<data.length; i++) {
					var qChildren = [];
					if(!expandedRows.includes(data[i].quoteId)){
						expandedRows.push(data[i].quoteId);
					}
					if(data[i].isPrimary){
						if(!selectedRows.includes(data[i].quoteId)){
							selectedRows.push(data[i].quoteId);
						}
						
						if(data[i].hostQuoteId && !expandedRows.includes(data[i].hostQuoteId)){
							expandedRows.push(data[i].hostQuoteId);
						}
						hasPrimary = true;

					}
					if(data[i].hostQuoteId && !hostIds.includes(data[i].hostQuoteId)){
						hostIds.push(data[i].hostQuoteId);
					}
					for(var j=0; j<data.length; j++) {
						if(data[i].quoteId == data[j].hostQuoteId) {
							console.log('j: ' + j);
							qChildren.push(data[j]);
							delList.push(data[j].quoteId);
							console.log('dataj: ' + JSON.stringify(data));
						}
					}
					data[i]._children = qChildren;
				}
				var gridData = [];
				console.log('delList: ' + JSON.stringify(delList));
				for(var k=0; k<data.length; k++){
					var delFlag=false;
					for(var l=0; l<delList.length; l++){
						if(delList[l] == data[k].quoteId) {
							delFlag = true;
							break;
						}
					}
					if(!delFlag){
						gridData.push(data[k]);
					}
				}
				console.log('gridData: ' + JSON.stringify(gridData));
				console.log('selectedRows: ' + JSON.stringify(selectedRows));
				console.log('expandedRows: ' + JSON.stringify(expandedRows));
				console.log('displayProductFamilyButtons: ' + JSON.stringify(cmp.get('v.displayProductFamilyButtons')));
				cmp.set('v.gridData', gridData);
				cmp.set('v.gridSelectedRows', selectedRows);
				cmp.set('v.gridExpandedRows', expandedRows);
				cmp.set('v.hostIds', hostIds);
				cmp.set('v.quoteList', selectedRows);
				cmp.set('v.currrentProductsIncluded', hasPrimary);
				if(selectedRows.length>0){
					cmp.set('v.displayProductFamilyButtons', true);
					cmp.set('v.displayRemoveFamilyButton', false);
				}else{					
					cmp.set('v.displayProductFamilyButtons', false);
					cmp.set('v.displayRemoveFamilyButton', cmp.get('v.currrentProductsIncluded'));
				}
				console.log('displayProductFamilyButtons: ' + JSON.stringify(cmp.get('v.displayProductFamilyButtons')));
				cmp.set('v.loadSpinner', false);
			}
		});
		$A.enqueueAction(action);
	},

	removeCPQProducts : function(cmp){
		cmp.set("v.loadSpinner", true);
		var oppId = cmp.get('v.recordId');
		var act = cmp.get('c.removeAllProducts');
		act.setParams({"oppId" : oppId});
		act.setCallback(this, function(response) {
			var state = response.getState();
			if(state === "SUCCESS"){
				cmp.set("v.loadSpinner", false);
				cmp.set('v.successMsg', response.getReturnValue());
				if(cmp.get('v.successMsg') === 'Success'){
					cmp.find('notifLib').showNotice({
						"variant" : "info",
						"header" : "Success",
						"message" : cmp.get('v.CPQRemoveAllMsg'),
						closeCallback : function() {
							var navEvt = $A.get("e.force:navigateToSObject");
							navEvt.setParams({
								"recordId" : oppId
							});
							navEvt.fire();
						}
					})
				}
				else {
					cmp.find('notifLib').showNotice({
						"variant": "error",
						"header": "Error",
						"message": cmp.get('v.successMsg')
					});
				}
			}
			else{
				var ProductFamilyError = $A.get("{!$Label.c.ErrorIncludingProductFamily}");//Added by Meher as part of SF-1879
                cmp.set("v.loadSpinner", false);
                cmp.find('notifLib').showNotice({
                    "variant": "error",
                    "header": "Error",
                    //"message": "Error occurred while including in Product Family"
                    "message": ProductFamilyError
				});
			}
		});
		$A.enqueueAction(act);
	},

	includeCPQProducts : function(cmp){
		cmp.set("v.loadSpinner", true);
		var act = cmp.get('c.UpdateOppQuoteProducts');
		var oppId = cmp.get('v.recordId');
		var quoteIds = cmp.get('v.quoteList');
		act.setParams({
			"oppId" : oppId,
			"quotes" : quoteIds
		});
		act.setCallback(this, function(response) {
			var state = response.getState();
			if(state === "SUCCESS"){
				cmp.set("v.loadSpinner", false);
				cmp.set('v.successMsg', response.getReturnValue());
				if(cmp.get('v.successMsg') === 'Success'){
					cmp.find('notifLib').showNotice({
						"variant" : "info",
						"header" : "Success",
						"message" : cmp.get('v.CPQSuccessMsgLabel'),
						closeCallback: function() {
							var navEvt = $A.get("e.force:navigateToSObject");
							navEvt.setParams({
								"recordId" : oppId
							});
							navEvt.fire();
							$A.get('e.force:refreshView').fire();
						}
					});
				}else{
					cmp.find('notifLib').showNotice({
						"variant": "error",
						"header": "Error",
						"message": cmp.get('v.successMsg')
					});
				}
			}
			else{
				var ProductFamilyError = $A.get("{!$Label.c.ErrorIncludingProductFamily}");//Added by Meher as part of SF-1879
                component.set("v.loadSpinner", false);
                component.find('notifLib').showNotice({
                    "variant": "error",
                    "header": "Error",
                    //"message": "Error occurred while including in Product Family"
                    "message": ProductFamilyError
                });
			}
		});
		$A.enqueueAction(act);
	
	},

	cancelEdit : function(cmp){
		var oppId = cmp.get('v.recordId');
		var cancelMsg = cmp.get("v.CPQCancelMsg");
		cmp.find('notifLib').showNotice({
			"variant" : "info",
			"header" : "Canceled",
			"message" : cancelMsg,
			closeCallback: function() {
				var navEvt = $A.get("e.force:navigateToSObject");
				navEvt.setParams({
					"recordId" : oppId
				});
				navEvt.fire();
			}
		});
	},

	processRowSelection : function(cmp){
		var qTree = cmp.find('quoteTree');
        var selectedRows = qTree.getSelectedRows();
        var qIdsOld = cmp.get('v.quoteList');
        var hostIds = cmp.get('v.hostIds');
        var gdata = cmp.get('v.gridData');
        var expandedRows = cmp.get('v.gridExpandedRows');
        console.log('hostIds: ' + JSON.stringify(hostIds));
        var qIds = [];
        for(var key in selectedRows){
            qIds.push(selectedRows[key].quoteId);
        }
        var newSelectedIds = qIds;
        console.log('expandedRows before: ' + JSON.stringify(expandedRows));
        console.log('newSelectedIds before: ' + JSON.stringify(newSelectedIds));
        //if a quote package host was selected select any children also 
        //first find what has changed
        var addFlag = false;
        console.log('qIdsOld: ' + qIdsOld);
        console.log('qIds: ' + qIds);
        for(var i in qIds){
            if(!qIdsOld.includes(qIds[i])){
                //QuoteId was added to the selection list
				var newq = qIds[i];
				//Make sure the selected quote is expanded 
                if(!expandedRows.includes(newq)){
                    expandedRows.push(newq);
                }
                addFlag = true;
                //Is this a host for the quote package? if yes select children also
                if(hostIds.includes(newq)){
                    for(var g in gdata){
						console.log('g: ' + JSON.stringify(gdata[g]));
                        if(gdata[g].quoteId == newq){
							var ch = gdata[g]._children;
							console.log('ch: ' + JSON.stringify(ch));
                            for(var c in ch){
								console.log('c: ' + JSON.stringify(ch[c]));
                                var cqId = ch[c].quoteId;
                                if(!expandedRows.includes(cqId)){
                                    expandedRows.push(cqId);
                                }
                                if(!newSelectedIds.includes(cqId)){
                                    newSelectedIds.push(cqId);
                                }
                            }
                            console.log('expandedRows Host: ' + JSON.stringify(expandedRows));
							console.log('newSelectedIds Host: ' + JSON.stringify(newSelectedIds));
							//parent record found. no need to continue
                            break;
                        }
                        
                    }
				}
				
            }
        }
        if(!addFlag){
			//If addFlag was not set to true we must be removing from the selection
			//If this is a host quote remove child quotes from the selection also
            var remIds = []
            for(var i in qIdsOld){
                if(!qIds.includes(qIdsOld[i])){
                    var removedId = qIdsOld[i];
                    remIds.push(removedId);
                    if(hostIds.includes(removedId)){
                        //this is a host remove children also
                        for(var g in gdata){
                            console.log('g: ' + JSON.stringify(gdata[g]));
                            if(gdata[g].quoteId == removedId){
                                var ch = gdata[g]._children;
                                for(var c in ch){
                                    //add to list of Ids to remove
                                    remIds.push(ch[c].quoteId);
                                }
                            }
                        }
					}
					//removed record found no need to continue
                    break;
                }
            }
            console.log('remIds: ' + JSON.stringify(remIds));
            //rebuild clean list of selected ids
            var tempIdList = [];
            for(var v in newSelectedIds){
                if(!remIds.includes(newSelectedIds[v])){
                    tempIdList.push(newSelectedIds[v]);
                }
            }
            newSelectedIds = tempIdList;
        }
        cmp.set('v.quoteList', newSelectedIds);
        if(qIds.length > 0){
            cmp.set('v.displayProductFamilyButtons', true);
			cmp.set('v.displayRemoveFamilyButton', false);
        }else{
            cmp.set('v.displayProductFamilyButtons', false);
			cmp.set('v.displayRemoveFamilyButton', cmp.get('v.currrentProductsIncluded'));
        }
        console.log('expandedRows: ' + JSON.stringify(expandedRows));
        console.log('newSelectedIds: ' + JSON.stringify(newSelectedIds));
        cmp.set('v.gridSelectedRows', newSelectedIds);
        cmp.set('v.gridExpandedRows', expandedRows);
	},
	  
	getSuccessMsg : function(component) {
        var action = component.get("c.fetchSuccessMsg");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
				var metaData = response.getReturnValue();
				console.log('metaData: ' + JSON.stringify(metaData));
                for (var i in metaData.length)
                {
                    if(metaData[i].DeveloperName=="CPQ_SuccessMsg")
                    {
                        component.set("v.CPQsuccessMsg", metaData[i].Long_Text_Area__c);
                        component.set("v.CPQsuccessMsgLabel", metaData[i].Values__c);
                    }  
                }
            }
        });
        $A.enqueueAction(action);
    }
	
});