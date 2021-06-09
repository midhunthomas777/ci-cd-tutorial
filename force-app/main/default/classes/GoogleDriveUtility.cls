/*
* Name : GoogleDriveUtility
* Description: This is utility class which contains the methods for Google Drive Functionality
* Author : Adilraza Shaikh,Anitha Mohankumar
* Test class : GoogleDriveTest
* Date : 6/9/2020
*/
public class GoogleDriveUtility {  
    public static Boolean isGoogleDriveCreationDisabled(){
        return (TriggerSettings__c.getValues('GoogleDriveCreation').IsActive__c) ? true : false ;
    }
    @AuraEnabled
    public static void googleDriveFunctions(List<String> lstRecordIds,String action){
        List<Google_Drive_Integration__e> lstGoogleDriveEvent = new List<Google_Drive_Integration__e>(); 
        Boolean isGoogleDriveCreationDisabled = isGoogleDriveCreationDisabled();
        if(!lstRecordIds.isEmpty() && !isGoogleDriveCreationDisabled){
            for(String recordId : lstRecordIds){
                Google_Drive_Integration__e gd = new Google_Drive_Integration__e();
                gd.Action__c = action;
                gd.Record_Id__c = recordId;
                lstGoogleDriveEvent.add(gd); 
            }
        }
        
        if(!lstGoogleDriveEvent.isEmpty()){
            //System.debug('lstGoogleDriveEvent==>.'+lstGoogleDriveEvent);
			List<Database.SaveResult> results = EventBus.publish(lstGoogleDriveEvent);
            for (Database.SaveResult sr : results) {
                if (sr.isSuccess()) {
                    System.debug('Successfully published event.'+sr.Id);
                } else{
                    for(Database.Error err : sr.getErrors()) {
                        System.debug('Error returned: ' + err.getStatusCode() +' - ' +err.getMessage());
                    }
                }
            }
        }
    }
    @AuraEnabled
    public static String quickCheckForDrive(String recordId, Boolean deleteDrive) {
		String objectName = GlobalUtility.getSObjectNameById(recordId);
        Map<String, Alerts_And_Messages__mdt> alertMessageMap = GlobalUtility.metaMessagesMap(recordId, 'Google_Drive');
		List<Google_Drive_Folder__c> existingDrives = [ SELECT ID, ChildId__c FROM Google_Drive_Folder__c WHERE Name =: recordId AND Parent_Name__c = NULL];
		/*if(objectName == 'Opportunity'){
			Opportunity currentOpp = [SELECT Region__c,Owner.UserTheater__c FROM Opportunity WHERE Id =: recordId];
			String gDriveRegions = System.Label.GDrive_Regions;
			if(!gDriveRegions.contains(currentOpp.Owner.UserTheater__c)) {
				return alertMessageMap.get('Region_check').Message__c;
			}
		}*/
        //Commented for GD international
		if(!existingDrives.isEmpty()) {
            return !deleteDrive ? alertMessageMap.get('Already_Exists').Message__c : '';    
		} else{
            return deleteDrive ? alertMessageMap.get('Empty_Drive').Message__c : '';    
		}
    }
    public static List<Connector__c> getConnectorDetails(String connectorName){
        List<Connector__c> lstConnector = [SELECT  c.RefreshToken__c,c.Name,ConnectorType__r.ClientSecret__c, ConnectorType__r.ClientId__c,
                                           ConnectorType__r.CallbackURL__c,ConnectorType__r.TokenEndpoint__c FROM Connector__c c 
                                           WHERE c.Name =: connectorName];
        return lstConnector;
    }
    public static List<Google_Drive_Folder__c> getSobjectRootFolderDetails(String recorId){
        return [ SELECT Id, ConnectorName__c, ChildId__c FROM Google_Drive_Folder__c WHERE Name =: recorId AND Parent_Name__c = NULL];
    }
    public static OpportunityDetails getOppDetails(String opportunityId){
        List<Opportunity> lstOpp = [SELECT Id, Name,Project_Status__c,Territory__c,Region__c,State__c,Opportunity_ID_18__c,
                                    Project_Name__c,Country__c,SLC_Contract_Number__c,Owner.Email,Opportunity_Reference__c,AccountId,Account.Name,Account.Territory__c,
                                    Account.Federal_Division__c,Owner.UserType,Owner.GoogleDriveFolderRollup__c,IsClosed,IsWon,Revenue_Fully_Recognized__c,Opportunity_Status__c,SYM_Transaction_Number__c,(Select Id, Role__c from  Partners2__r), 
                                    (Select Id,PricebookEntryId,PricebookEntry.Product2Id FROM OpportunityLineItems)
                                    FROM Opportunity WHERE Id =: OpportunityId ];
        String partners = '';
        String product = '';
        String prStatus = lstOpp.get(0).Project_Status__c;
        String state = lstOpp.get(0).State__c;
        String territory = lstOpp.get(0).Territory__c;
        String country = lstOpp.get(0).Country__c;
        String projectID = lstOpp.get(0).Project_Name__c;
        String oppReference = lstOpp.get(0).Opportunity_Reference__c;
        String accName = lstOpp.get(0).Account.Name;
        String oppFolderGoogleDriveId;
        String productDescription = ''; 
        
        String SLC = lstOpp.get(0).SLC_Contract_Number__c;
        
        if(lstOpp.get(0).Partners2__r.size() > 0){
            for(Partners2__c partner : lstOpp.get(0).Partners2__r)
                partners = partners+' , '+partner.Role__c;
        }else{
            partners = 'No Partners available';
        }
        if(lstOpp.get(0).opportunityLineItems.size() > 0){
            Set<Id> productFamilyIds = new Set<Id>();
            for (OpportunityLineItem OLI : lstOpp.get(0).opportunityLineItems){
                productFamilyIds.add(OLI.PriceBookEntry.Product2Id);
            }
            // MODIFY THE LOGIC FOR PROD FAMILY CHANGES
            List<Product2> currentProdFamilyDetails = [SELECT Id,Name,SPSS_Shortcut__c, ECW_Shortcut__c, ILPS_Shortcut__c FROM Product2 
                                                       WHERE IsActive = TRUE AND Id IN: productFamilyIds];
            if(!currentProdFamilyDetails.isEmpty()){
                Integer countSPSS = 0;
                Integer countILPS = 0;
                Integer countECW = 0;
                Integer countNotSPSS = 0;
                for(Product2 prodFam : currentProdFamilyDetails){
                    if(prodFam.SPSS_Shortcut__c){
                        countSPSS++;
                    }
                    if(prodFam.ILPS_Shortcut__c){
                        countILPS++;
                    }   
                    if(prodFam.ECW_Shortcut__c){
                        countECW++; 
                    }
                    if(!prodFam.SPSS_Shortcut__c){
                        countNotSPSS++; 
                    }
                }
                if(countSPSS > 0){
                    productDescription = 'Shortcut: SPSS'+'\n';
                }
                if(countILPS > 0){
                    productDescription = productDescription+'Shortcut: ILPS'+'\n';
                }
                if(countECW > 0){
                    productDescription = productDescription+'Shortcut: ECW'+'\n';
                }
                if(countSPSS > 0 && countNotSPSS > 0){
                    productDescription = productDescription+'Shortcut: SPSS Combo'+'\n';    
                }
            }
        }
        //system.debug(' Description ## '+projectID + oppReference+'##'+partners+'###'+productDescription);      
        String descriptionFolder = '';
        descriptionFolder = descriptionFolder+'Shortcut: OpportunityId:'+opportunityId+' \n';
        if(String.isNotBlank(state)){
            String isNYK = (territory == 'NYC') ? 'New York City' : state;
            descriptionFolder = descriptionFolder+' Shortcut: State_'+isNYK+' \n';
        }
        if(String.isNotBlank(prStatus)){
            descriptionFolder = descriptionFolder+' Shortcut: Project Status: '+prStatus+'\n';
        }
        if(String.isNotBlank(SLC)){
            descriptionFolder = descriptionFolder+'Shortcut: SO###: '+SLC+'\n';
        }
        if(String.isNotBlank(accName)){
            descriptionFolder = descriptionFolder+' Shortcut:  Account Name: '+accName+'\n';
        }
        if(String.isNotBlank(oppReference)){
            descriptionFolder = descriptionFolder+' Shortcut: Opportunity Reference#: '+oppReference+'\n';
        }
        if(Partners.contains('Manufacturer Representative')){
            //system.debug(' Partners 2 : MR '+Partners); 
            descriptionFolder = descriptionFolder+' Shortcut: MR'+'\n';
        }
        if(String.isNotBlank(productDescription)){
            descriptionFolder = descriptionFolder+productDescription;
        }        
        if(lstOpp.get(0).Opportunity_Reference__c != NULL){
            //Modified the FolderName as per region for SF-2576 
            if(lstOpp.get(0).Region__c == 'NA'){
                return new OpportunityDetails(lstOpp.get(0),DescriptionFolder,
                                        lstOpp.get(0).Opportunity_Reference__c+'_'+lstOpp.get(0).Name,
                                        lstOpp.get(0).owner.email);
            }else{
                return new OpportunityDetails(lstOpp.get(0),DescriptionFolder,
                                        lstOpp.get(0).SYM_Transaction_Number__c +'_'+lstOpp.get(0).Name+'_'+lstOpp.get(0).Opportunity_Reference__c,
                                        lstOpp.get(0).owner.email);
            }
        }else{
            //Modified the FolderName as per region for SF-2576
            if(lstOpp.get(0).Region__c == 'NA'){
                return new OpportunityDetails(lstOpp.get(0),DescriptionFolder,
                                        lstOpp.get(0).Name,
                                        lstOpp.get(0).owner.email);
            }else{
                return new OpportunityDetails(lstOpp.get(0),DescriptionFolder,
                                        lstOpp.get(0).SYM_Transaction_Number__c +'_'+lstOpp.get(0).Name,
                                        lstOpp.get(0).owner.email);
            }
        }  
    }  
    public static List<OpportunityTeamMember> getOppTeamMembers(Id recordId){
        if(GlobalUtility.getSObjectNameById(recordId) == 'Opportunity'){
            return [SELECT id,User.email,OpportunityId,OpportunityAccessLevel FROM OpportunityTeamMember WHERE OpportunityId =:recordId AND User.UserType = 'Standard'];
        }else{
            return [SELECT id,User.email,OpportunityId, OpportunityAccessLevel FROM OpportunityTeamMember WHERE Id =:recordId AND User.UserType = 'Standard'];
        }
    }
    public static List<AccountTeamMember> getAccTeamMembers(Id recordId){
        if(GlobalUtility.getSObjectNameById(recordId) == 'Account'){
            return [SELECT id,User.email,AccountId, Quote_Access__c FROM AccountTeamMember WHERE AccountId = :recordId AND User.UserType = 'Standard' AND Quote_Access__c = 'Read/Write'];
        }else{
            return [SELECT id,User.email,AccountId, Quote_Access__c FROM AccountTeamMember WHERE Id = :recordId AND User.UserType = 'Standard' AND Quote_Access__c = 'Read/Write'];
        }
    }
    public static List<Attachment> getAttachments(Id recordId){
        return [SELECT Id,body,name,contenttype FROM Attachment WHERE ParentId =:recordId ];        
    }
    public static List<GoogleDriveFolderStructure.FileAttachments> getFileAttachments(String parentId,Map<String,FolderStructure_GoogleDrive__c> filesFolderInfo){ 
        List<Opportunity> lstOpp = [SELECT Id,Name,Opportunity_Reference__c from Opportunity WHERE Id =:parentId ]; 
        String folderName = lstOpp.get(0).Name;
        if(lstOpp.get(0).Opportunity_Reference__c != NULL){
            folderName = lstOpp.get(0).Opportunity_Reference__c+'_'+folderName;
        }
        //system.debug('filesFolderInfo.***************'+filesFolderInfo.keySet());
        List<GoogleDriveFolderStructure.FileAttachments> lstFileAttachments = new List<GoogleDriveFolderStructure.FileAttachments>();
        for(Attachment att : GoogleDriveUtility.getAttachments(system.label.File_Doc_Id)){
            if(filesFolderInfo.containsKey(att.Name)){
                String attachmentFolderName = filesFolderInfo.get(att.Name).FolderName__c ; 
                if(attachmentFolderName == 'root'){
                    attachmentFolderName = folderName;
                }
                lstFileAttachments.add(new GoogleDriveFolderStructure.FileAttachments(att.Id,'Attachment',NULL,attachmentFolderName,NULL));
            }
        }
        return lstFileAttachments;
    }
    
    public static List<ContentVersion> getContentVersions(Id recordId){
        List<ContentVersion> lstContentVersion = new List<ContentVersion>();
        Set<Id> setContentDocLinks = new Set<Id>();
        for(ContentDocumentLink cdl: getContentDocumentLink(recordId)){
            setContentDocLinks.add(cdl.ContentDocumentId);
        } 
        if(!setContentDocLinks.isEmpty()){
            return [SELECT Id,ContentDocumentId,SharingPrivacy FROM ContentVersion WHERE ContentDocumentId IN : setContentDocLinks ];  
        }
       return lstContentVersion;      
    }
    public static List<ContentDocumentLink> getContentDocumentLink(Id recordId){
        return  [SELECT Id,ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId =: recordId];
    }
    public static List<Sobject> getOwnerEmail(Id recordId){
        String theObject = GlobalUtility.getSObjectNameById(recordId);
        String theQuery = 'SELECT Owner.Email,Owner.UserType FROM ' + theObject + ' WHERE Id =: recordId';
        return Database.Query(theQuery);
    }
    public static List<BigMachines__Quote__c> getQuote(Id recordId){//BigMachines__Opportunity__r.Region__c for SF-2580
         return [SELECT Id,BigMachines__Status__c,Owner.Email,BigMachines__Opportunity__c,BigMachines__Opportunity__r.Owner.Email,BigMachines__Account__c,BigMachines__Account__r.Owner.Email,Owner_User_Type__c,BigMachines__Account__r.Owner.UserType,BigMachines__Opportunity__r.Region__c FROM BigMachines__Quote__c WHERE Id=: recordId];
    }
    public class OpportunityDetails{
       Public Opportunity opportunity; 
       public String folderDescription;
       public String oppFolderName; 
       public String oppFolderGoogleDriveId; 
       public String ownerEmail;
        public OpportunityDetails (Opportunity opportunity,String folderDescription, String oppFolderName,String ownerEmail){
            this.opportunity = opportunity;
            this.folderDescription = folderDescription;
            this.oppFolderName = oppFolderName;
            this.ownerEmail = ownerEmail;
        }
    }   
}