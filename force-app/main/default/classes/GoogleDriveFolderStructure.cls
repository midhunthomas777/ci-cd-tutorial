/*
* Name : GoogleDriveFolderStructure
* Test Class : GoogleDriveTest
* Description: This API class is consumed by Mulesoft to acheive Google Drive functionality
* Author : Adilraza Shaikh, Anitha Mohankumar

* Date : 6/9/2020
*/
@RestResource(urlMapping='/getGoogleFolderStructure/*')
global class GoogleDriveFolderStructure {
    @httpGet
    global static GoogleStructureWrapper getGoogleStructureDataModel(){
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        String idInfos = RestContext.request.params.get('id');
        system.debug('idInfos'+idInfos);
        Id recordId = idInfos.split(';').get(0);
        String action = RestContext.request.params.get('action');
        String objectName = GlobalUtility.getSObjectNameById(recordId);
        //GoogleStructureWrapper googleStructureWrap1; = new GoogleStructureWrapper();
        system.debug('recordId'+recordId);
        try{
            if(objectName == 'Opportunity'){
                if(action == 'Create'){
                    GoogleDriveUtility.OpportunityDetails oppDetails = GoogleDriveUtility.getOppDetails(recordId);
                    List<Permissions> lstPermissions = new List<Permissions>();
                    //System.debug('oppDetails.Opportunity.ownerID==>'+oppDetails.Opportunity.ownerId);
                    //System.debug('oppDetails.Opportunity.owner.UserType==>'+oppDetails.Opportunity.owner.UserType);
                    if(oppDetails.Opportunity.owner.UserType == 'Standard'){
                        lstPermissions.add(new Permissions(oppDetails.ownerEmail,'writer'));
                    }
                    lstPermissions.addALL(provideAccessToTeamMembers(recordId));
                    //System.debug('lstPermissions==>'+lstPermissions);
                    GoogleStructureWrapper googleStructureWrap = createOppFolderStructure(oppDetails.opportunity);
                    googleStructureWrap.recordId =oppDetails.opportunity.Id;
                    googleStructureWrap.folderName = oppDetails.oppFolderName;
                    googleStructureWrap.action = 'CreateFolder';//SF-2441;SF-2423
                    googleStructureWrap.folderDescription = 'Created from Opportunity '+oppDetails.folderDescription;
                    googleStructureWrap.permissions = lstPermissions;
                    //SF-2441;SF-2423 - Commented below lines
                    //googleStructureWrap.fileAttachments = GoogleDriveUtility.getFileAttachments(recordId,googleStructureWrap.fileFolderStrucMap);
                   	//googleStructureWrap.fileFolderStrucMap = NULL;
                   	//googleStructureWrap.action = 'CreateAndMove';
                    return googleStructureWrap; 
                }
                else if (action == 'Update'){
                    GoogleDriveUtility.OpportunityDetails oppDetails = GoogleDriveUtility.getOppDetails(recordId);
                    List<Google_Drive_Folder__c> lstRootFolderDetails = GoogleDriveUtility.getSobjectRootFolderDetails(recordId);
                    
                    FederalTerritoryMapping.FoldersInfoWrapper foldersInfoWrapper = FederalTerritoryMapping.findFoldersInfo(oppDetails.opportunity); 
                    List<FolderStructure_GoogleDrive__c> parentFolderLst = [SELECT Id, ActualFoldderID__c, FolderName__c FROM FolderStructure_GoogleDrive__c WHERE UniqueFolderName__c =:foldersInfoWrapper.parentFolder LIMIT 1];
                    
                    //system.debug('lstRootFolderDetails'+lstRootFolderDetails);
                    if(!lstRootFolderDetails.isEmpty()){
                        List<Connector__c> lstConnector = GoogleDriveUtility.getConnectorDetails(lstRootFolderDetails.get(0).ConnectorName__c);
                        GoogleStructureWrapper googleStructureWrap = new GoogleStructureWrapper();
                        googleStructureWrap.recordId =oppDetails.opportunity.Id;
                        googleStructureWrap.folderName = oppDetails.oppFolderName;
                        googleStructureWrap.folderDescription  = 'Created from Opportunity '+oppDetails.folderDescription;
                        googleStructureWrap.folderGoogleDriveId = lstRootFolderDetails.get(0).ChildId__c;
                        googleStructureWrap.connectorDetails = lstConnector;
                        googleStructureWrap.rootFolderId = parentFolderLst.get(0).ActualFoldderID__c;
                        googleStructureWrap.action = 'UpdateFolder';
                        //system.debug('Opp update googleStructureWrap'+googleStructureWrap);
                        return googleStructureWrap;
                    }else{
                        res.statusCode = 204;
                        return NULL;
                    }
                }
                else if (action == 'RevokePermission'){
                    List<Google_Drive_Folder__c> lstRootFolderDetails = GoogleDriveUtility.getSobjectRootFolderDetails(recordId);
                    List<Permissions> lstPermissions = new List<Permissions>();
                    lstPermissions.add(new Permissions(idInfos.split(';').get(1),'revoke'));
                    //system.debug('lstRootFolderDetails'+lstRootFolderDetails);
                    if(!lstRootFolderDetails.isEmpty()){
                        List<Connector__c> lstConnector = GoogleDriveUtility.getConnectorDetails(lstRootFolderDetails.get(0).ConnectorName__c);
                        GoogleStructureWrapper googleStructureWrap = new GoogleStructureWrapper();
                        googleStructureWrap.folderGoogleDriveId = lstRootFolderDetails.get(0).ChildId__c;
                        googleStructureWrap.recordId = recordId;
                        googleStructureWrap.permissions = lstPermissions;
                        googleStructureWrap.connectorDetails = lstConnector;
                        googleStructureWrap.action = 'RevokePermission';
                        //system.debug('RevokePermission googleStructureWrap'+googleStructureWrap);
                        return googleStructureWrap;
                    }else{
                        res.statusCode = 204;
                        return NULL;
                    }
                }
                else if (action == 'Provision'){
                    List<Google_Drive_Folder__c> lstRootFolderDetails = GoogleDriveUtility.getSobjectRootFolderDetails(recordId);
                    List<Opportunity> lstOpp = GoogleDriveUtility.getOwnerEmail(recordId);
                    List<Permissions> lstPermissions = new List<Permissions>();
                    if(!lstRootFolderDetails.isEmpty() && !lstOpp.isEmpty()){
                        List<Connector__c> lstConnector = GoogleDriveUtility.getConnectorDetails(lstRootFolderDetails.get(0).ConnectorName__c);
                        if(lstOpp.get(0).Owner.UserType == 'Standard'){
                            lstPermissions.add(new Permissions(lstOpp.get(0).Owner.Email,'writer'));
                        }
                        //lstPermissions.addALL(provideAccessToTeamMembers(recordId));
                        GoogleStructureWrapper googleStructureWrap = new GoogleStructureWrapper();
                        googleStructureWrap.folderGoogleDriveId = lstRootFolderDetails.get(0).ChildId__c;
                        googleStructureWrap.connectorDetails = lstConnector;
                        googleStructureWrap.recordId = recordId;
                        googleStructureWrap.permissions = lstPermissions;
                        googleStructureWrap.action = 'Provision';
                        return googleStructureWrap;
                    }else{
                        res.statusCode = 204;
                        return NULL;
                    }
                }
                else if (action == 'Delete'){
                    List<Google_Drive_Folder__c> lstRootFolderDetails = GoogleDriveUtility.getSobjectRootFolderDetails(recordId);
                    if(!lstRootFolderDetails.isEmpty()){
                        List<Connector__c> lstConnector = GoogleDriveUtility.getConnectorDetails(lstRootFolderDetails.get(0).ConnectorName__c);
                        GoogleStructureWrapper googleStructureWrap = new GoogleStructureWrapper();
                        googleStructureWrap.folderGoogleDriveId = lstRootFolderDetails.get(0).ChildId__c;
                        googleStructureWrap.connectorDetails = lstConnector;
                        googleStructureWrap.recordId = recordId;
                        googleStructureWrap.action = 'DeleteFolder';
                        //system.debug('RevokePermission googleStructureWrap'+googleStructureWrap);
                        return googleStructureWrap;
                    } else{
                        res.statusCode = 204;
                        return NULL;
                    }
                }
                return NULL;
            }
            else if(objectName == 'OpportunityTeamMember'){
                if(action == 'Create' || action == 'Update'){
                    //List<OpportunityTeamMember> lstOTM = GoogleDriveUtility.getOppTeamMembers(recordId);
                    Id opportunityId = idInfos.split(';').get(1);
                    List<Google_Drive_Folder__c> lstRootFolderDetails = GoogleDriveUtility.getSobjectRootFolderDetails(opportunityId);
                    List<Permissions> lstPermissions = new List<Permissions>();
                    if(!lstRootFolderDetails.isEmpty()){
                        List<Connector__c> lstConnector = GoogleDriveUtility.getConnectorDetails(lstRootFolderDetails.get(0).ConnectorName__c);
                        lstPermissions.addALL(provideAccessToTeamMembers(recordId));
                        GoogleStructureWrapper googleStructureWrap = new GoogleStructureWrapper();
                        googleStructureWrap.folderGoogleDriveId = lstRootFolderDetails.get(0).ChildId__c;
                        googleStructureWrap.connectorDetails = lstConnector;
                        googleStructureWrap.permissions = lstPermissions;
                        googleStructureWrap.action = 'Provision';
                        googleStructureWrap.recordId = recordId;
                        return googleStructureWrap;
                    } else{
                        res.statusCode = 204;
                        return NULL;
                    }
                }
            }
            else if(objectName == 'AccountTeamMember'){
                if(action == 'Create' || action == 'Update'){
                    //List<AccountTeamMember> lstATM = GoogleDriveUtility.getAccTeamMembers(recordId);
                    Id accountId = idInfos.split(';').get(1);
                    List<Google_Drive_Folder__c> lstRootFolderDetails = GoogleDriveUtility.getSobjectRootFolderDetails(accountId);
                    List<Permissions> lstPermissions = new List<Permissions>();
                    if(!lstRootFolderDetails.isEmpty()){
                        List<Connector__c> lstConnector = GoogleDriveUtility.getConnectorDetails(lstRootFolderDetails.get(0).ConnectorName__c);
                        lstPermissions.addALL(provideAccessToTeamMembers(recordId));
                        GoogleStructureWrapper googleStructureWrap = new GoogleStructureWrapper();
                        googleStructureWrap.folderGoogleDriveId = lstRootFolderDetails.get(0).ChildId__c;
                        googleStructureWrap.connectorDetails = lstConnector;
                        googleStructureWrap.permissions = lstPermissions;
                        googleStructureWrap.action = 'Provision';
                        googleStructureWrap.recordId = accountId;
                        return googleStructureWrap;
                    }else{
                        res.statusCode = 204;
                        return NULL;
                    }
                }
            }
            else if (objectName == 'BigMachines__Quote__c'){
                List<BigMachines__Quote__c> lstQuote = GoogleDriveUtility.getQuote(recordId);
                if(action == 'QuoteFiles'){
                    if(!lstQuote.isEmpty() && lstQuote.get(0).BigMachines__Opportunity__c != NULL ){  
                        GoogleStructureWrapper googleStructureWrap = new GoogleStructureWrapper();
                        GoogleDriveUtility.OpportunityDetails oppDetails = GoogleDriveUtility.getOppDetails(lstQuote.get(0).BigMachines__Opportunity__c);  
                        List<Google_Drive_Folder__c> lstRootFolderDetails = GoogleDriveUtility.getSobjectRootFolderDetails(lstQuote.get(0).BigMachines__Opportunity__c);
                        List<Google_Drive_Folder__c> lstMoveFileParent = new List<Google_Drive_Folder__c>();
                        List<FileAttachments> filestoMove= new List<FileAttachments>();
                        List<Permissions> lstPermissions = new List<Permissions>();      
                        String folderName;
                        /*if(lstQuote.get(0).Owner_User_Type__c == 'Standard'){
                            lstPermissions.add(new Permissions(lstQuote.get(0).owner.Email,'writer')); 
                        }*/
                        if(oppDetails.Opportunity.owner.UserType == 'Standard'){
                            lstPermissions.add(new Permissions(oppDetails.ownerEmail,'writer'));
                        }                                         
                        lstPermissions.addALL(provideAccessToTeamMembers(lstQuote.get(0).BigMachines__Opportunity__c));
                        
                        if(lstRootFolderDetails.isEmpty()){
                            googleStructureWrap = createOppFolderStructure(oppDetails.opportunity);
                            googleStructureWrap.folderName = oppDetails.oppFolderName;
                            googleStructureWrap.action = 'CreateAndMove';
                        }else{
                            List<Connector__c> lstConnector = GoogleDriveUtility.getConnectorDetails(lstRootFolderDetails.get(0).ConnectorName__c);
                            googleStructureWrap.connectorDetails = lstConnector;                            
                            if(lstQuote.get(0).BigMachines__Status__c=='Order Review'){
                                //SF-2580 - Added the below condition for Region check
                                if(oppDetails.opportunity.Region__c =='NA'){
                                    lstMoveFileParent= [SELECT ChildId__c,Child_Name__c FROM Google_Drive_Folder__c WHERE Name = :lstQuote.get(0).BigMachines__Opportunity__c AND Child_Name__c= '00_Financial/Contract Documents'];
                                    folderName = '00_Financial/Contract Documents'; 
                                }else{
                                    lstMoveFileParent= [SELECT ChildId__c,Child_Name__c FROM Google_Drive_Folder__c WHERE Name = :lstQuote.get(0).BigMachines__Opportunity__c AND Child_Name__c='CPQ Quote Archive'];  
                                    folderName = 'CPQ Quote Archive';
                                }                                
                            }else{
                                lstMoveFileParent= [SELECT ChildId__c,Child_Name__c FROM Google_Drive_Folder__c WHERE Name = :lstQuote.get(0).BigMachines__Opportunity__c AND Child_Name__c='CPQ Quote Archive'];  
                                folderName = 'CPQ Quote Archive';
                            } 
                            if(!lstMoveFileParent.isEmpty()){                        
                                googleStructureWrap.action = 'MoveOnly';
                            }else{
                                googleStructureWrap.parentName = 'root';
                                googleStructureWrap.rootFolderId = lstRootFolderDetails.get(0).ChildId__c;  
                                googleStructureWrap.folderName =folderName;
                                googleStructureWrap.action = 'CreateAndMove';
                            }
                        }                                    
                        googleStructureWrap.recordId =oppDetails.opportunity.Id;                    
                        googleStructureWrap.folderDescription = 'Created from Opportunity '+oppDetails.folderDescription;
                        filestoMove = getFileAttachments(lstQuote); 
                        system.debug('googleStructureWrap.action****'+googleStructureWrap.action);
                        if(googleStructureWrap.action == 'CreateAndMove'){
                            googleStructureWrap.permissions = lstPermissions;
                            //SF-2441;SF-2423 - Commented below lines
                            //filestoMove.addAll(GoogleDriveUtility.getFileAttachments(googleStructureWrap.recordId,googleStructureWrap.fileFolderStrucMap));
                        }
                        googleStructureWrap.fileAttachments = filestoMove; 
                        //googleStructureWrap.fileFolderStrucMap = NULL;//SF-2441;SF-2423 - Commented
                        return googleStructureWrap;
                    }else{
                        String accId = lstQuote.get(0).BigMachines__Account__c;
                        //1.AddPermission to AccountOwner & AccountTeamMembers & QuoteOwner  
                        List<Permissions> lstPermissions = new List<Permissions>();                               
                        /*if(lstQuote.get(0).Owner_User_Type__c == 'Standard'){
                            lstPermissions.add(new Permissions(lstQuote.get(0).owner.Email,'writer'));
                        }*/
                        if(lstQuote.get(0).BigMachines__Account__r.Owner.UserType == 'Standard' ){
                            //system.debug('Account Owner Email '+lstQuote.get(0).BigMachines__Account__r.Owner.Email);
                            lstPermissions.add(new Permissions(lstQuote.get(0).BigMachines__Account__r.Owner.Email,'writer')); 
                        }                            
                        lstPermissions.addALL(provideAccessToTeamMembers(accId));
                        //2.CreateAccountFolders
                        GoogleStructureWrapper googleStructureWrap = createAccFolders(accId); 
                        if(googleStructureWrap.action == 'CreateAndMove'){
                            googleStructureWrap.permissions = lstPermissions;
                        }                        
                        googleStructureWrap.fileAttachments = getFileAttachments(lstQuote);  
                        googleStructureWrap.recordId = accId;
                        return googleStructureWrap;
                    }                
                }                     
            }
            else if (objectName == 'Account'){
                //1.CreateAccountFolders with AddPermission to AccountOwner & AccountTeamMembers
                //GoogleStructureWrapper googleStructureWrap = createAccFolders(recordId); 
                List<Google_Drive_Folder__c> lstRootFolderDetails = GoogleDriveUtility.getSobjectRootFolderDetails(recordId);
                if(!lstRootFolderDetails.isEmpty()){
                    List<Account> lstAccount = [SELECT Id, Name, Owner_Email__c FROM Account WHERE Id =: recordId];
                    GoogleStructureWrapper googleStructureWrap =new GoogleStructureWrapper();
                    googleStructureWrap.folderGoogleDriveId = lstRootFolderDetails.get(0).ChildId__c;
                    googleStructureWrap.connectorDetails = GoogleDriveUtility.getConnectorDetails(Label.GoogleConnectorAccountName);
                    if(action == 'Update'){
                        //googleStructureWrap.folderName = lstAccount.get(0).Id+'_'+lstAccount.get(0).Name;
                        googleStructureWrap.folderName = lstAccount.get(0).Name;
                        googleStructureWrap.action = 'UpdateFolder';
                        googleStructureWrap.recordId = recordId;
                        return googleStructureWrap;
                    }
                    else if(action == 'Provision'){
                        List<Permissions> lstPermissions = new List<Permissions>();
                        lstPermissions.add(new Permissions(lstAccount.get(0).Owner_Email__c,'writer'));
                        googleStructureWrap.permissions = lstPermissions;
                        googleStructureWrap.action = 'Provision';
                        googleStructureWrap.recordId = recordId;
                        return googleStructureWrap;
                    } 
                    else if(action == 'RevokePermission'){
                        List<Permissions> lstPermissions = new List<Permissions>();
                        lstPermissions.add(new Permissions(idInfos.split(';').get(1),'revoke'));
                        googleStructureWrap.action = 'RevokePermission';
                        googleStructureWrap.permissions = lstPermissions;
                        googleStructureWrap.recordId = recordId;
                        return googleStructureWrap;
                    }
                    else if(action == 'Delete'){
                        googleStructureWrap.action = 'DeleteFolder';
                        googleStructureWrap.recordId = recordId;
                        return googleStructureWrap;
                    }
                }
                else{
                    res.statusCode = 204;
                    return NULL;
                }            
            }
            res.statusCode = 204;
            return NULL;
        }catch(Exception ex){
            return NULL;
        }
    }    
    public static GoogleStructureWrapper createOppFolderStructure(Opportunity opp){
        GoogleStructureWrapper googleStructureWrap = new GoogleStructureWrapper();
        Map<String,String> childFolderParentFolderMap = new Map<String,String>();
        Map<String,FolderStructure_GoogleDrive__c> fileFolderStrucMap = new Map<String,FolderStructure_GoogleDrive__c>();
        
        Map<String, List<FolderStructure_GoogleDrive__c>> parentChildMap = new Map<String, List<FolderStructure_GoogleDrive__c>>();
        
        FederalTerritoryMapping.FoldersInfoWrapper foldersInfoWrapper = FederalTerritoryMapping.findFoldersInfo(opp);
        List<Connector__c> lstConnector = GoogleDriveUtility.getConnectorDetails(foldersInfoWrapper.connectorName);
        system.debug('foldersInfoWrapper.parentFolder'+foldersInfoWrapper);
        List<FolderStructure_GoogleDrive__c> parentFolderLst = [SELECT Id, ActualFoldderID__c, FolderName__c FROM FolderStructure_GoogleDrive__c WHERE UniqueFolderName__c =:foldersInfoWrapper.parentFolder LIMIT 1];
        system.debug('parentFolderLst**************'+parentFolderLst);
        system.debug('parentFolderLst.get(0).ActualFoldderID__c**************'+parentFolderLst.get(0).ActualFoldderID__c);
        
        Map<String,String> mapGoogleDriveDocs = new Map<String,String>();
        for(Document doc : [SELECT Id,Name,ContentType from Document where Folder.name = 'GoogleDriveFolders']){
            mapGoogleDriveDocs.put(doc.Name, doc.Id);
        }
        for (FolderStructure_GoogleDrive__c gDriveFolder : [SELECT Id, FolderName__c, ParentFolder__c, DocumentNameField__c, ContentType__c FROM FolderStructure_GoogleDrive__c WHERE Region__c =: opp.Region__c AND FolderRoot__c = 'Project Specific']) {
            if(gDriveFolder.FolderName__c != 'root'){
                childFolderParentFolderMap.put(gDriveFolder.FolderName__c,gDriveFolder.ParentFolder__c);
                if (!parentChildMap.keyset().contains(gDriveFolder.ParentFolder__c)) {
                    parentchildmap.put(gDriveFolder.ParentFolder__c, new List<FolderStructure_GoogleDrive__c>());
                }
                parentChildMap.get(gDriveFolder.ParentFolder__c).add(gDriveFolder);
            }            
            if(String.isNotBlank(gDriveFolder.DocumentNameField__c)){
                List<String> tempNames = gDriveFolder.DocumentNameField__c.Split(',');
                //system.debug('tempNames***********'+tempNames);
                if(!tempNames.isEmpty()){
                    for(String fileName : tempNames){
                        List<String> tempFileName = fileName.Split(':');
                        if(!tempFileName.isEmpty()){
                            String fileNameKey = tempFileName[0].trim();
                            FolderStructure_GoogleDrive__c tempFolderStruc = new FolderStructure_GoogleDrive__c();
                            tempFolderStruc.FolderName__c = gDriveFolder.FolderName__c;
                            tempFolderStruc.ParentFolder__c = gDriveFolder.ParentFolder__c;
                            tempFolderStruc.DocumentNameField__c = gDriveFolder.DocumentNameField__c;
                            tempFolderStruc.ContentType__c = gDriveFolder.ContentType__c;
                            tempFolderStruc.DocumentURL__c = NULL;
                            if(mapGoogleDriveDocs.containsKey(fileNameKey) ){
                                //system.debug('mapGoogleDriveDocs.get(fileNameKey)'+mapGoogleDriveDocs.get(fileNameKey));
                                tempFolderStruc.DocumentURL__c ='/services/data/v48.0/sobjects/Document/'+mapGoogleDriveDocs.get(fileNameKey)+'/Body';
                            }
                            fileFolderStrucMap.put(fileNameKey, tempFolderStruc); 
                        }  
                    }  
						system.debug('fileFolderStrucMap***********'+fileFolderStrucMap);
                }
            }
        }        
        googleStructureWrap.childFolderParentFolderMap = childFolderParentFolderMap;        
        googleStructureWrap.fileFolderStrucMap = fileFolderStrucMap;
        googleStructureWrap.rootFolderId = parentFolderLst.get(0).ActualFoldderID__c;
        googleStructureWrap.connectorDetails = lstConnector;
        return googleStructureWrap;        
    }
    public static GoogleStructureWrapper createAccFolders(String accId){
        Map<String,String> childFolderParentFolderMap = new Map<String,String>();
        List<Google_Drive_Folder__c> accFolder = new List<Google_Drive_Folder__c>(); 
        List<Google_Drive_Folder__c> cpqFolder = new List<Google_Drive_Folder__c>(); 
        List<Google_Drive_Folder__c> currentYearFolder = new List<Google_Drive_Folder__c>();
        GoogleStructureWrapper googleStructureWrap = new GoogleStructureWrapper();
        List<Permissions> lstPermissions = new List<Permissions>(); 
        
        String currentYear = String.valueof(System.Today().year());         
        List<Account> lstAccount = [SELECT Id, Name,Owner.Email FROM Account WHERE Id =: accId];
        
        accFolder = [SELECT ChildId__c from Google_Drive_Folder__c WHERE Name =: accId AND Parent_Name__c = NULL];             
        cpqFolder = [SELECT ChildId__c from Google_Drive_Folder__c WHERE Name =: accId AND Child_Name__c= 'CPQ Quote Archive'];           
        currentYearFolder = [SELECT ChildId__c from Google_Drive_Folder__c WHERE Name =: accId AND Child_Name__c =: currentYear];  
        
        if(!currentYearFolder.isEmpty()){//CPQ & CurrentYear Folder exists
            googleStructureWrap.rootFolderId =accFolder[0].ChildId__c ;
            googleStructureWrap.action = 'MoveOnly';
        }else if(!cpqFolder.isEmpty()){ //CPQ exists and CurrentYear not exists            
            googleStructureWrap.action = 'CreateAndMove';    
            if(String.isBlank(cpqFolder[0].ChildId__c)){//CPQfolder ID is blank
                googleStructureWrap.rootFolderId =accFolder[0].ChildId__c ;
                //googleStructureWrap.parentName = lstAccount.get(0).Id+'_'+lstAccount.get(0).Name; 
                googleStructureWrap.parentName = lstAccount.get(0).Name; 
                googleStructureWrap.folderName = currentYear;
            }else{
                googleStructureWrap.rootFolderId =cpqFolder[0].ChildId__c;
                googleStructureWrap.parentName = 'CPQ Quote Archive';
                googleStructureWrap.folderName = currentYear;                
            }            
        }else if(!accFolder.isEmpty()){ //CPQ & Currentyear folder           
            googleStructureWrap.action = 'CreateAndMove'; 
            googleStructureWrap.rootFolderId =accFolder[0].ChildId__c ;
            googleStructureWrap.parentName = 'root'; 
            googleStructureWrap.folderName = 'CPQ Quote Archive';                      
            childFolderParentFolderMap.put(currentYear,'root');
        }else{
            googleStructureWrap.action = 'CreateAndMove';            
            googleStructureWrap.folderName = lstAccount.get(0).Id+'_'+lstAccount.get(0).Name;   
            childFolderParentFolderMap.put('CPQ Quote Archive','root');
            childFolderParentFolderMap.put(currentYear,'CPQ Quote Archive');
        }
        
        String ConnectorName = Label.GoogleConnectorAccountName;                                       
        List<Connector__c> lstConnector = GoogleDriveUtility.getConnectorDetails(ConnectorName);
        googleStructureWrap.childFolderParentFolderMap = childFolderParentFolderMap;
        googleStructureWrap.recordId = lstAccount.get(0).Id;
        
        googleStructureWrap.connectorDetails = lstConnector;
        googleStructureWrap.folderDescription = 'Created from Account '+lstAccount.get(0).Id; 
        googleStructureWrap.permissions = lstPermissions;            
        return googleStructureWrap;
    }
    public static List<FileAttachments> getFileAttachments(List<BigMachines__Quote__c> lstQuote){
        List<FileAttachments> lstFileAttachments = new List<FileAttachments>();
        List<Google_Drive_Folder__c> lstParentFolder = new List<Google_Drive_Folder__c>();
        String currentYear = String.valueof(System.Today().year());
        String parentFolderName;
        List<BigMachines__Quote__c> incomingQuote = lstQuote;
        if (incomingQuote[0].BigMachines__Opportunity__c == NULL) {//Account              
            parentFolderName = currentYear;
            lstParentFolder = [SELECT ChildId__c FROM Google_Drive_Folder__c WHERE Name = :incomingQuote[0].BigMachines__Account__c AND Child_Name__c=: currentYear];
        }else{
            if(incomingQuote[0].BigMachines__Status__c == 'Order Review'){
                //SF-2580 - Added the below condition for Region check
                if(incomingQuote[0].BigMachines__Opportunity__r.Region__c == 'NA'){
                    parentFolderName = '00_Financial/Contract Documents';
                }else{
                    parentFolderName = 'CPQ Quote Archive';  
                }                                      
            }else{	
                parentFolderName = 'CPQ Quote Archive';                     	
            }
            lstParentFolder = [SELECT ChildId__c FROM Google_Drive_Folder__c WHERE Name = :incomingQuote[0].BigMachines__Opportunity__c AND Child_Name__c=: parentFolderName ];                        
        }                     
        for(Attachment quoteAtt : GoogleDriveUtility.getAttachments(incomingQuote[0].Id)){
            if(!lstParentFolder.isEmpty()){
                lstFileAttachments.add(new FileAttachments(quoteAtt.Id,'Attachment',lstParentFolder[0].ChildId__c,parentFolderName,quoteAtt.Id));
            }else{
                lstFileAttachments.add(new FileAttachments(quoteAtt.Id,'Attachment',NULL,parentFolderName,quoteAtt.Id));
            }
        }  
        Map<String,String> mapContentDocumentLink = new Map<String,String>();
        for(ContentDocumentLink cdl : GoogleDriveUtility.getContentDocumentLink(incomingQuote[0].Id)){
            mapContentDocumentLink.put(cdl.ContentDocumentId, cdl.Id);
        }
        for(ContentVersion conVer : GoogleDriveUtility.getContentVersions(incomingQuote[0].Id)){
            if(!lstParentFolder.isEmpty()){
                lstFileAttachments.add(new FileAttachments(conVer.Id,'ContentVersion',lstParentFolder[0].ChildId__c,parentFolderName,mapContentDocumentLink.get(conVer.ContentDocumentId)));
            }else{
                lstFileAttachments.add(new FileAttachments(conVer.Id,'ContentVersion',NULL,parentFolderName,mapContentDocumentLink.get(conVer.ContentDocumentId)));
            }
        }
        return lstFileAttachments;
    }  
    public static List<Permissions> provideAccessToTeamMembers(Id recordId){
        List<Sobject> lstTeamMemebrs = new List<Sobject>();
        List<Permissions> lstPermissions = new List<Permissions>(); 
        String objectName = GlobalUtility.getSObjectNameById(recordId);
        if(objectName == 'Account' || objectName == 'AccountTeamMember'){
            for(AccountTeamMember atm : GoogleDriveUtility.getAccTeamMembers(recordId)){
                    lstPermissions.add(new Permissions(atm.User.email,'writer'));
            }
        }else{
            for(OpportunityTeamMember otm : GoogleDriveUtility.getOppTeamMembers(recordId)){
                if(otm.OpportunityAccessLevel == 'Read'){
                    lstPermissions.add(new Permissions(otm.User.email,'reader'));
                }else{
                    lstPermissions.add(new Permissions(otm.User.email,'writer'));
                }
            }
        }
        return lstPermissions;
    }
    global class GoogleStructureWrapper{
        public Map<String,FolderStructure_GoogleDrive__c> fileFolderStrucMap ;
        public Map<String,String> childFolderParentFolderMap;
        public String recordId {get;set;}
        public String folderName {get;set;}
        public String parentName {get;set;}
        public String rootFolderId {get;set;}
        public String folderGoogleDriveId {get;set;}
        public List<Connector__c> connectorDetails {get;set;}
        public String folderDescription {get;set;}
        public String action {get;set;}
        public List<Permissions> permissions {get;set;}
        public List<FileAttachments> fileAttachments {get;set;}
    }
    public class Permissions{
        public String email {get;set;}
        public String accessLevel {get;set;}
        Permissions(String email, String accessLevel){
            this.email = email;
            this.accessLevel = accessLevel;
        }
    }
    public class FileAttachments{
        public Id attachmentId {get;set;}
        public String fileType {get;set;}
        public String parentFolderId {get;set;}
        public String parentFolderName {get;set;}
        public Id attachmentDeletionId {get;set;}
       	public FileAttachments(Id attachmentId, String fileType, String parentFolderId, String parentFolderName, Id attachmentDeletionId ){
            this.attachmentId = attachmentId;
            this.fileType = fileType;
            this.parentFolderId = parentFolderId;
            this.parentFolderName = parentFolderName;
            this.attachmentDeletionId = attachmentDeletionId;
        }
    }
}