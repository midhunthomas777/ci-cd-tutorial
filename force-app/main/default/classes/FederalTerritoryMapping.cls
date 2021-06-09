/*Test Class:GoogleDrivePermissionsTest,FederalTerritoryMapping_Test */
global class FederalTerritoryMapping {
    
    public static String getTerritoryDivision(String territory, String federalDiv) {
        if ((territory == 'DOD-East') || (territory ==  'DOD-West') || (territory ==  'DOS-EMEA') || (territory ==  'DOD-West') || (territory ==  'DOD')) {
            if (federalDiv == 'Department of State (DOS)')
                return 'DOS_Civil';
            else if (federalDiv != 'Department of State (DOS)')
                return federalDiv + '_DOD';
        } else if (territory == 'Civil') {
            if (federalDiv == 'US Postal Service (USPS)')
                return 'USPS_Civil';
            else if (federalDiv == 'Department of Energy (DOE)')
                return 'DOE_Civil';
            else if (federalDiv == 'Veterans Affairs Medical Center (VAMC)')
                return 'VAMC_Civil';
            else if (federalDiv == 'National Aeronautics and Space Administration (NASA)')
                return 'NASA_Civil';
            else if (federalDiv == 'Federal Protective Service (FPS)')
                return 'FPS_DHS';
            else if (federalDiv == 'Immigration and Customs Enforcement (ICE)')
                return 'ICE_DHS';
            else if (federalDiv == 'All Other Civil')
                return 'All Other Civil_Civil';
            else if (federalDiv == 'Federal Aviation Agency (FAA)')
                return 'FAA_Civil';
            else if (federalDiv == 'Federal Emergecy Management Agency (FEMA)')
                return 'FEMA_DHS';
            else if (federalDiv == 'Department of Interior (DOI)')
                return 'DOI_Civil';
        } else if (territory == 'Civil LEA') {
            if (federalDiv == 'US Coast Guards (USCG)')
                return 'USCG_DHS';
            else if (federalDiv == 'Customs and Border Protection (CBP)')
                return 'CBP_DHS';
            else if (federalDiv == 'Federal Bureau of Prisons (FBOP)')
                return 'FBOP_DOJ';
            else if (federalDiv == 'Federal Bureau of Investigation (FBI)')
                return 'FBI_DOJ';
            else if (federalDiv == 'Drug Enforcement Administration (DEA)')
                return 'DEA_DOJ';
            else if (federalDiv == 'All Other DHS')
                return 'All Other DHS_DHS';
            else if (federalDiv == 'All Other DOJ')
                return 'All Other DOJ_DOJ';
            else if (federalDiv == 'US Secret Service (USSS)')
                return 'USSS_DHS';
        }
        return '';
    }
    
    public class FoldersInfoWrapper {
        public String parentFolder;
        public String rootFolder;
        public String financialEmail;
        public String folderDesc;
        public String connectorName;
        public FoldersInfoWrapper(String parentFolder, String rootFolder, String financialEmail, String folderDesc, String connectorName) {
            this.parentFolder = parentFolder; this.rootFolder = rootFolder; this.financialEmail = financialEmail;
            this.folderDesc = folderDesc;this.connectorName = connectorName;
        }
    }
    
    public static FoldersInfoWrapper findFoldersInfo(Opportunity currentOppo) {        
        Set<String> channelTerritories = new Set<String>{'CT1','CT2','CT3','CT4','CT5','CT6','CT7','CT8','CT9','CT10','CT-Canada'};
            String oppRegion = currentOppo.Region__c;
        String projectStatus = currentOppo.Project_Status__c;
        String oppTerritory = currentOppo.Territory__c;
        String parentFolder = '';
        String rootFolder = 'Federal_NA Commerical and Federal_root';
        String financialEmail = 'FEDERALSOLUTIONSANDSERVICES@motorolasolutions.com';
        String oppState = currentOppo.State__c;
        String connectorName = '';
        String folderDesc = '';
        if (String.isBlank(projectStatus)) {
            projectStatus = 'Non SI Projects';
        }
        System.Debug('ENTERED HARISH METHOD-2');
        /* Logic to set the Parent Folder
* 2. Evaluate Territory to determine market.
a.  If “Territory” is one of the Federal values (“DOD-East”, “DOD-West”, “Civil”, “Civil LEA”, “DOS-EMEA”), open workspace under aligned Territory folder
b.  If “Territory” is “Comm Mkts”, open workspace under “Commercial Markets” folder.
c.  If “Territory” is one of the State and Local values (T1-T8, NYC), open workspace under the aligned “State/Province” value folder. Note that “New York City” is a separate workspace folder from “New York” state.

* 5.2.2.3  The value of the “Project Status” field shall govern the top level parent folder of the system created Google Drive Workspace, as described in 5.2.1.1.
•   When “Project Status” is “Non SI Project”, the Google Workspace shall be nested in the appropriate place as described in 5.2.3 beneath the “Non SI Project” folder.
•   When “Project Status” is “Presale SI Project”, the Google Workspace shall be nested in the appropriate place as described in 5.2.3 beneath the “Presale SI Projects” folder.
•   When “Project Status” is “Postsale SI Project”, the Google Workspace shall be nested in the appropriate place as described in 5.2.3 beneath the “Postsale SI Projects” folder.
•   When “Project Status” is “Closed SI Project”, the Google Workspace shall be nested in the appropriate place as described in 5.2.3 beneath the “Closed SI Projects” folder.
*/
        String uniqueFolder;
        String S1;
        Boolean federalFlag = false;
        Boolean commMktFlag = false;
        FolderStructure_GoogleDrive__c gDriveDBFolders = new FolderStructure_GoogleDrive__c(); // Modified by Harish
        Map<String, String> countryGrouping = new Map<String, String>();
        for(Country_Grouping__mdt eachGrouping: [Select MasterLabel,DeveloperName,FolderName__c from Country_Grouping__mdt]){
            countryGrouping.put(eachGrouping.MasterLabel,eachGrouping.FolderName__c);
        }        
        if(oppRegion == 'NA'){
            if (oppTerritory == 'DOD-East' || oppTerritory ==  'DOD-West' || oppTerritory == 'Civil' || oppTerritory == 'Civil LEA' || oppTerritory == 'DOS-EMEA') {
                if (currentOppo.Account.Territory__c == 'DOD-East' || currentOppo.Account.Territory__c == 'DOD-West') {
                    oppTerritory = 'DOD';                    
                }
                String  retVal = getTerritoryDivision(oppTerritory, currentOppo.Account.Federal_Division__c);
                System.debug('retVal==>'+retVal);
                System.debug('retVal oppTerritory==>'+oppTerritory);
                System.debug('retVal currentOppo.Account.Federal_Division__c==>'+currentOppo.Account.Federal_Division__c);
                //parentFolder = projectStatus + '_' + retVal + '_Federal_NA Commerical and Federal_root';
                uniqueFolder = projectStatus + '_' + retVal + '_Federal_NA Commerical and Federal_root';
                //rootFolder = retVal; retVal and ParentFolder__c names not matching
                federalFlag = true;
            } else if (oppTerritory == 'Comm Mkts') {               
                If(currentOppo.Country__c == 'United States' || currentOppo.Country__c == 'Canada') {
                    uniqueFolder = projectStatus + '_' + currentOppo.Country__c + '_Commercial_NA Commerical and Federal_root';
                    rootFolder = currentOppo.Country__c + '_Commercial_NA Commerical and Federal_root';
                } else {
                    uniqueFolder = projectStatus + '_International_Commercial_NA Commerical and Federal_root';
                    rootFolder = 'International_Commercial_NA Commerical and Federal_root';
                }
                //uniqueFolder = projectStatus + '_' + currentOppo.Country__c + '_Commercial_NA Commerical and Federal_root';
                //rootFolder = currentOppo.Country__c + '_Commercial_NA Commerical and Federal_root';
                financialEmail = 'CQ511@motorolasolutions.com';
                commMktFlag = true;
                System.debug('commMkt uniqueFolder==>'+uniqueFolder);
                System.debug('commMkt rootFolder==>'+rootFolder);
            }if(channelTerritories.contains(currentOppo.Territory__c)){ 
                System.debug('CT Territory');
                uniqueFolder=currentOppo.Opportunity_Status__c +'_' + oppState + '_' +oppTerritory+ '_NA Channel';
                rootFolder = oppState;               
                System.debug('CT Territory uniqueFolder==>'+ uniqueFolder);
            }else if(!channelTerritories.contains(currentOppo.Territory__c) && !federalFlag && !commMktFlag ){
                if (String.isBlank(oppState)) {
                    system.debug(' Should never be here no State information ');
                    // throw exception
                }
                uniqueFolder = projectStatus + '_' + oppState + '%'; // + '_' + oppTerritory + '%';
                rootFolder = (oppTerritory == 'NYC') ? 'New York City' : oppState;
                if (oppTerritory == 'NYC') {
                    uniqueFolder = projectStatus + '_New York City%'; // + '_' +oppTerritory + '%';
                }
                // this should not be a LIKE query - rather it should be a exact query.
            }
        }else{
            String oppCountry = currentOppo.Country__c;
            String oppOwnerFolderRollup = currentOppo.Owner.GoogleDriveFolderRollup__c;
            System.debug('currentOppo.IsClosed==>' + currentOppo.IsClosed);           
            System.debug('Before==>'+ currentOppo.Opportunity_Status__c +'_' + oppCountry + ' [' + SearchBeforeCreateCtrl.CountryISOCode(oppCountry) + '] ' + oppOwnerFolderRollup);
            if(oppRegion == 'AP' || oppRegion == 'EA' || oppRegion == 'ME'){
                //System.debug('countryGrouping==>' + countryGrouping);
                if(oppTerritory == 'United Nations'){
                    oppCountry ='United Nations';
                }else if(countryGrouping.containsKey(oppCountry)){
                    oppCountry = countryGrouping.get(oppCountry) + ' ' +  oppOwnerFolderRollup;
                }else{
                    oppCountry = oppCountry + ' [' + SearchBeforeCreateCtrl.CountryISOCode(oppCountry) + '] ' + oppOwnerFolderRollup;
                }
                uniqueFolder=currentOppo.Opportunity_Status__c +'_' + oppCountry;
            }else if(oppRegion == 'LA'){                
                if(countryGrouping.containsKey(oppCountry)){
                    oppCountry = countryGrouping.get(oppCountry);
                    uniqueFolder=currentOppo.Opportunity_Status__c +'_' + oppCountry;
                }else{
                    uniqueFolder=currentOppo.Opportunity_Status__c +'_' + oppCountry + ' [' + SearchBeforeCreateCtrl.CountryISOCode(oppCountry) + ']';                    
                }                
            }            
            System.debug('After uniqueFolder==>'+ uniqueFolder);
        }        
        List<FolderStructure_GoogleDrive__c> gDriveTemp;
        System.debug('uniqueFolder==>'+ uniqueFolder);
        if(oppRegion == 'NA'){
            if(federalFlag){
                 gDriveTemp = [SELECT Id, ConnectorName__c, UniqueFolderName__c from FolderStructure_GoogleDrive__c
                          where UniqueFolderName__c LIKE : uniqueFolder LIMIT 1];
            }else{
                 gDriveTemp = [SELECT Id, ConnectorName__c, UniqueFolderName__c from FolderStructure_GoogleDrive__c
                          where ParentFolder__c = : rootFolder AND UniqueFolderName__c LIKE : uniqueFolder LIMIT 1];                
            }
        }else{
            gDriveTemp = [SELECT Id, ConnectorName__c, UniqueFolderName__c from FolderStructure_GoogleDrive__c
                          where  UniqueFolderName__c LIKE : uniqueFolder LIMIT 1]; // Added by Harish    
        }
        if(gDriveTemp.size() == 0){
            uniqueFolder=currentOppo.Opportunity_Status__c +'_' + oppRegion + '_Miscellaneous';
            rootFolder = oppRegion;
            gDriveTemp = [SELECT Id, ConnectorName__c, UniqueFolderName__c from FolderStructure_GoogleDrive__c
                          where ParentFolder__c = : rootFolder AND UniqueFolderName__c LIKE : uniqueFolder LIMIT 1];
        }
        if(gDriveTemp.size()>0)
            gDriveDBFolders = gDriveTemp[0];
        
        System.Debug('####rootFolder####=>'+rootFolder);
        System.Debug('####uniqueFolder####=>'+uniqueFolder);
        System.Debug('#####gDriveDBFolders####'+gDriveDBFolders);
        System.Debug('##### gDriveDBFolders.UniqueFolderName__c####'+gDriveDBFolders.UniqueFolderName__c);
        
        if (gDriveDBFolders == null) {
            CreateErrorLog.createErrorRecord('No Connector Available for ' + oppState,'Opportunity'+currentOppo.Id, 'No Connector Available for ' + oppState,
                                             UserInfo.getName(), System.now(),'No Connector Available for ' + oppState);
            
            //globalFunctionsforGoogleDrive.SetLogValue(' No Connector Available for ' + oppState, 'Goolge Drive', currentOppo.Id);
            //throw exception;
            connectorName='';
            parentFolder='';
            rootFolder='';
        }else{
            if(!String.isBlank(gDriveDBFolders.ConnectorName__c)){
                /*if (gDriveDBFolders.ConnectorName__c.contains('T1')) {
rootFolder = oppState + '_NA T1_root';
} else if(gDriveDBFolders.ConnectorName__c.contains('T2')){
rootFolder = oppState + '_NA T2_root';
}else if(gDriveDBFolders.ConnectorName__c.contains('T6')){
rootFolder = '';                   
}*/
                parentFolder = gDriveDBFolders.UniqueFolderName__c; //PrStatus+'_'+State+'_NA T2_root';//+Country+'_State and Local Government_';
                connectorName = gDriveDBFolders.ConnectorName__c;
            }               
        }
        //Fill in Description for the folders now
        System.Debug('####Final ###=>'+parentFolder);        
        return new FoldersInfoWrapper(parentFolder, rootFolder, financialEmail, folderDesc, connectorName);
        
    }
}