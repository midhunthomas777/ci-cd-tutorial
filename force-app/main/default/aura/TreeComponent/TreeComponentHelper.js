({
    getGoogleDrives : function(cmp,event,helper) {
        //console.log('Entered JS Controller');
        var oldOpportunity = cmp.get("v.oldOpportunity");
        var action = cmp.get("c.getRelatedGoogleDrives");
        var recordId = cmp.get("v.recordId");
        var folderExists = cmp.get("v.folderExists");
        var region = cmp.get("v.recordInfo.Region__c");
        var territory = cmp.get("v.recordInfo.Territory__c");
        var ownerGoogleDriveFolderRollup =cmp.get("v.recordInfo.Owner.GoogleDriveFolderRollup__c");
        action.setParams({ recordId : recordId});
        action.setCallback(this, function(response) {
            if (response.getState() === "SUCCESS" && cmp.isValid()) {
                if(response.getReturnValue().length >= 1 ){
                    cmp.set('v.displayMessage',null);
                    cmp.set('v.items', response.getReturnValue());
                    cmp.set('v.folderExists',true);
					helper.checkFolderMisc(cmp,event,helper);
                    if((region === 'AP' || region === 'EA' || region === 'ME') && (territory !=  $A.get("$Label.c.Opportunity_Territory"))  && $A.util.isEmpty(ownerGoogleDriveFolderRollup)){
                        let ownerNoGoogleDriveRollup  = $A.get("$Label.c.Create_Google_Drive_UserGDRollup_Message");
                        cmp.set('v.alertType','error');
                        cmp.set('v.displayMessage',ownerNoGoogleDriveRollup);  
                    }
                }else{
                    cmp.set('v.folderExists',false);
                    if(recordId.startsWith("001")){
                        let noCPQFolderMsg = $A.get("$Label.c.No_CPQ_Folders_Message");
                        cmp.set('v.alertType','warning');
                        cmp.set('v.displayMessage',noCPQFolderMsg);
                    }else{
                        console.log('oldOpportunity==>' + oldOpportunity);
                        if(oldOpportunity){
                            console.log('Error==>');
                            cmp.set('v.alertType','error');
                            cmp.set('v.displayMessage',cmp.get('v.oldOppErrorMsg'));
                        }else{
                            let foldersCreatingMsg = $A.get("$Label.c.Folders_Creating_Message");
                            console.log('warning==>');
                            cmp.set('v.alertType','warning');
                            cmp.set('v.displayMessage',foldersCreatingMsg);
                        }
                        //Added below for SF-2545
                        
                        var rootFolderId = cmp.get("v.rootFolderId");
                        console.log('Before If region==>'+region);
                        console.log('Before If rootFolderId==>'+rootFolderId);
                        console.log('IsEmpty==>' + $A.util.isEmpty(rootFolderId));
                        //if((region === 'AP' || region === 'EA' || region === 'ME') && $A.util.isEmpty(rootFolderId)){
                        if($A.util.isEmpty(rootFolderId) && oldOpportunity){
                            console.log('If region==>'+region);
                            console.log('If rootFolderId==>'+rootFolderId);                           
                            cmp.set('v.displayMessage',null);
                            cmp.set('v.alertType','error');
                            cmp.set('v.displayMessage',cmp.get('v.oldOppErrorMsg'));
                        }else{
                            console.log('In refreshCmp==>');
                            helper.refreshCmp(cmp,event,helper);                            
                        }                    
                    }
                }            
            } else {
                console.log('Error in Retreiving the Tree Structure');
            }
        });        
        $A.enqueueAction(action);
    },
    
    refreshCmp : function(cmp, event, helper) {
        var action = cmp.get("c.getRelatedGoogleDrives");
        var recordId = cmp.get("v.recordId");
        var oldOpportunity = cmp.get("v.oldOpportunity");        
        var refreshAttempt = 0;
        var refreshTime = 0;
        action.setParams({ recordId : recordId});
        cmp._interval = setInterval($A.getCallback(function () {
            var folderExists = cmp.get("v.folderExists");
            //console.log('refreshAttempt before condition'+refreshAttempt);
            if(!folderExists && refreshAttempt < 8){
                //alert(folderExists);
                console.log('folderExists in interval*****'+folderExists);
                action.setCallback(this, function(response){
                    var state = response.getState();
                    var cmpState = cmp.isValid();
                    if(state === 'SUCCESS' && cmp.isValid()){
                        cmp.set('v.displayMessage',null);
                        console.log('valid comp');
                        var resp = response.getReturnValue();
                        console.log('resp******'+JSON.stringify(resp));
                        if(response.getReturnValue().length >= 1){
                            cmp.set('v.items', resp);    
                            cmp.set('v.folderExists',true);
                        }else{
                            cmp.set('v.folderExists',false);
                            refreshAttempt = refreshAttempt + 1;
                            console.log('refreshAttempt'+refreshAttempt);
                            //Mule Retry limit is 8mins; Saleforce Refresh Component 1min interval 8attempts
                            if(refreshAttempt < 7){
                                if(oldOpportunity){
                                    //cmp.set('v.alertType','error');
                                    cmp.set('v.displayMessage',cmp.get('v.oldOppErrorMsg'));
                                }else{
                                    let foldersCreatingMsg = $A.get("$Label.c.Folders_Creating_Message");
                                    cmp.set('v.alertType','warning');
                                    cmp.set('v.displayMessage',foldersCreatingMsg);
                                }
                                
                            }else{
                                let recordIdType = cmp.get('v.recordIdType');
                                let foldersNotCreated = $A.get("$Label.c.No_Folders_Created_Message");
                                foldersNotCreated = foldersNotCreated+" "+recordIdType;
                                cmp.set('v.alertType','error');
                                cmp.set('v.displayMessage',foldersNotCreated);
                            }
                        }
                    }
                });
                $A.enqueueAction(action);
            }
        }), 60000);
    },
    onReceiveNotification: function (component,event,helper, message) {
        console.log('message in handler'+message);
        var recordId = component.get("v.recordId");
        var eventRecId = message.data.payload.Record_Id__c;
        var eventAction = message.data.payload.Action__c;
        console.log('eventRecId********'+eventRecId);
        console.log('eventAction********'+eventAction);
        if(recordId === eventRecId && eventAction === 'Create'){
            let foldersCreatingMsg = $A.get("$Label.c.Folders_Creating_Message");
            console.log('winthin if');
            component.set('v.displayMessage',null);
            component.set('v.alertType','warning');
            component.set('v.displayMessage',foldersCreatingMsg);
            component.set('v.oldOppErrorMsg',foldersCreatingMsg);
            //this.refreshCmp(component,event,helper);
        }
        if(recordId === eventRecId && eventAction === 'Delete'){
            let folderDeletedMsg = $A.get("$Label.c.Folders_Deleted_Message");
            console.log('winthin if');
            component.set('v.items', null); 
            component.set('v.folderExists',false);
            component.set('v.alertType','error');
            component.set('v.displayMessage',folderDeletedMsg);            
            component.set('v.oldOppErrorMsg',folderDeletedMsg);
        }
    },
    subscribe: function (component, event, helper) {
        //alert('Event Subscribe');
        // Get the empApi component.
        const empApi = component.find('empApi');
        // Get the channel from the attribute.
        const channel = component.get('v.channel');
        // Subscription option to get only new events.
        const replayId = -1;
        // Callback function to be passed in the subscribe call.
        // After an event is received, this callback prints the event
        // payload to the console. A helper method displays the message
        // in the console app.
        const callback = function (message) {
            console.log('Event Received : ' + JSON.stringify(message));
            helper.onReceiveNotification(component,event,helper, message);
        };
        // Subscribe to the channel and save the returned subscription object.
        empApi.subscribe(channel, replayId, $A.getCallback(callback)).then($A.getCallback(function (newSubscription) {
            console.log('Subscribed to channel ' + channel);
            console.log('Subscribed to newSubscription ' + newSubscription);
            //component.set('v.subscription', newSubscription);
        }));
    },
    getRootFolder : function(cmp,event,helper) {        
        var action = cmp.get("c.getRelatedRootFolderID");
        var recordId = cmp.get("v.recordId");        
        action.setParams({ recordId : recordId});
        action.setCallback(this, function(response) {
            if (response.getState() === "SUCCESS" && cmp.isValid()) {               
                cmp.set('v.rootFolderId',response.getReturnValue());   
            }else{
                cmp.set('v.rootFolderId',null);  
            }
            console.log('cmp.get("v.rootFolderId")====>'+cmp.get("v.rootFolderId")); 
        });        
        $A.enqueueAction(action);
    }, 
    checkFolderMisc : function(cmp, event, helper) {
        var action = cmp.get("c.checkFolderMiscellaneous");
        var recordId = cmp.get("v.recordId");
        var oldOpportunity = cmp.get("v.oldOpportunity");      
        action.setParams({ recordId : recordId});
        action.setCallback(this, function(response) {
            if (response.getState() === "SUCCESS" && cmp.isValid()) {
                console.log('response.getReturnValue()==>'+response.getReturnValue());               
                if(response.getReturnValue()){
                    let ownerNoGoogleDriveRollup  = $A.get("$Label.c.Create_Google_Drive_UserGDRollup_Message");
                    cmp.set('v.alertType','error');
                    cmp.set('v.displayMessage',ownerNoGoogleDriveRollup); 
                }                
            }
        });        
        $A.enqueueAction(action);
    },
})