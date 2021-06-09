({
    doInit: function (cmp,event,helper) {
        let foldersNotCreated = $A.get("$Label.c.No_Folders_Created_Message");
        foldersNotCreated = foldersNotCreated+" "+"Opportunity";
        cmp.set("v.oldOppErrorMsg",foldersNotCreated);
        const empApi = cmp.find('empApi');
        helper.getRootFolder(cmp, event, helper);//Added for SF-2545
       	helper.subscribe(cmp, event, helper);
    },
    handleSelect: function (cmp, event, helper) {
       var myName = event.getParam('name');
       var win = window.open(myName , '_blank');
       win.focus();
    },
    handleRecordUpdated: function(component, event, helper) {
        var eventParams = event.getParams();
        if(eventParams.changeType === "LOADED") {
            component.set("v.loadSpinner",false);
            var recordId = component.get("v.recordId");
            var recordTypeName = component.get("v.recordInfo.RecordType.Name");
            var region = component.get("v.recordInfo.Region__c");
            var territory = component.get("v.recordInfo.Territory__c");
            var ownerGoogleDriveFolderRollup =component.get("v.recordInfo.Owner.GoogleDriveFolderRollup__c");
            var googleDriveRootFolderId = component.get("v.recordInfo.Google_Drive_Root_Folder_Id__c");//Added for SF-2545
            console.log('recordTypeName****'+recordTypeName);
            console.log('territory****'+territory);
            console.log('Label.c.Opportunity_Territory****'+$A.get("$Label.c.Opportunity_Territory"));
            if(recordId.startsWith("006")){
                component.set('v.recordIdType','Opportunity');
                //Commented for GD International if(recordTypeName === 'Project' && region === 'NA'){
                if(recordTypeName === 'Project'){
                    /*if((region === 'AP' || region === 'EA' || region === 'ME') && (territory !=  $A.get("$Label.c.Opportunity_Territory"))  && $A.util.isEmpty(ownerGoogleDriveFolderRollup)){
                        let ownerNoGoogleDriveRollup  = $A.get("$Label.c.Create_Google_Drive_UserGDRollup_Message");
                        component.set('v.folderExists',false);    
                        component.set('v.alertType','error');
                        component.set('v.displayMessage',ownerNoGoogleDriveRollup);                                                                  
                    }else{
                    }*/
                        var recordCreatedDate = component.get("v.recordInfo.CreatedDate");
                        var JSrecordCreatedDate = new Date(recordCreatedDate);
                        var today = new Date();
                        var timeDiff = today.getTime() - JSrecordCreatedDate.getTime(); 
                        var minutesDiff = Math.floor(timeDiff / 60000);
                        console.log('timeDiff is ************'+minutesDiff);
                        if(minutesDiff < 15 && $A.util.isEmpty(googleDriveRootFolderId)){//Added for SF-2545
                            let foldersCreatingMsg = $A.get("$Label.c.Folders_Creating_Message");
                            component.set('v.folderExists',false);
                            component.set('v.alertType','warning');
                            component.set('v.displayMessage',foldersCreatingMsg);
                        }else if(minutesDiff > 15){
                            component.set('v.oldOpportunity',true);                   
                        }
                        helper.getGoogleDrives(component, event, helper);
                    
                }else{
                    let foldersNotAvailable  = $A.get("$Label.c.Folders_Not_Available_for_Opportunity");
                    component.set('v.folderExists',false);
                    component.set('v.alertType','warning');
                    component.set('v.displayMessage',foldersNotAvailable);
                }
            }else if(recordId.startsWith("001")){
                component.set('v.recordIdType','Account');
                if((recordTypeName === 'Customer' || recordTypeName === 'Prospect') && region === 'NA'){
                    helper.getGoogleDrives(component, event, helper);
                }else{
                    let foldersNotAvailable  = $A.get("$Label.c.Folders_Not_Available_for_Account");
                    component.set('v.folderExists',false);
                    component.set('v.alertType','warning');
                    component.set('v.displayMessage',foldersNotAvailable);
                }
                
            }
            
            // record is loaded (render other component which needs record data value)
            console.log("Record is loaded successfully.");
        } else if(eventParams.changeType === "CHANGED") {
            // record is changed
        } else if(eventParams.changeType === "REMOVED") {
            // record is deleted
        } else if(eventParams.changeType === "ERROR") {
            // there’s an error while loading, saving, or deleting the record
        }
    },
    

});