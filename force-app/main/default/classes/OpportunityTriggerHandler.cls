/*************************************************************************************************************
* Class Name : OpportunityTriggerHandler
* Description : Handler class for OpportunityTrigger
* Date : 3rd Nov 2017
* Modification Log:
* ========================================================================================================== 
* Satish maddhi    9th April 2018      Added methods for Relative Revenue and Revenue Delta for EMEA(SF-289 & SF-290) 
* Saranya Sista    23 august 2018      Added Run Rate Opportunity logic as part of SF - 701         
* Saranya Sista    22 October 2018     Added EA and ME condition as part of SF - 1422
* Vineela N        21 May 2019         Removed the Fiscal fields logic from updateOppDetailsBeforeUpdate and created new method 
*************************************************************************************************************/
public class OpportunityTriggerHandler implements ITriggerHandler {
    public static Boolean TriggerDisabled = false;
    public Id projectRecTypeId =  GlobalUtility.getRecordTypeIdByDeveloperName('Opportunity', 'Government_Standard');
    public Id registrationRecTypeId = GlobalUtility.getRecordTypeIdByDeveloperName('Opportunity', 'Registration');
    public Id fedRegistrationRecTypeId = GlobalUtility.getRecordTypeIdByDeveloperName('Opportunity', 'Federal_Registration');
    public Id runRateRecTypeId = GlobalUtility.getRecordTypeIdByDeveloperName('Opportunity', 'Run_Rate'); 
    // public Id accMangRecTypeId = GlobalUtility.getRecordTypeIdByDeveloperName('Opportunity', 'Account_Management');
    // public Id channelPartRecTypeId = GlobalUtility.getRecordTypeIdByDeveloperName('Opportunity', 'Channel_Partner_Sales');
    // public Id newBussinessDevRecTypeId = GlobalUtility.getRecordTypeIdByDeveloperName('Opportunity', 'New_Business_Development');
    public static Map<String,List<String>> mapOppIdsTeamUserEmails= new  Map<String,List<String>>(); //SF-2223 Google Drive Changes
    private PartnerSharingHelper partnerSharingHelper = new PartnerSharingHelper();
    private OpportunityTriggerHelper opportunityHelper = new OpportunityTriggerHelper();
    public Boolean IsDisabled(){
        if (TriggerSettings__c.getValues('OpportunityTriggerDisabled').IsActive__c)
            return true;
        else
            return TriggerDisabled;
    }
    
    public void BeforeInsert(List<SObject> newItems) {
        List<Opportunity> newOpptyList = new List<Opportunity>();
        if(newItems != null) newOpptyList = (List<Opportunity>) newItems;
        List<Opportunity> projectOpportunities = new List<Opportunity>();
        List<Opportunity> registrationOpportunities = new List<Opportunity>();
        List<Opportunity> nonUSDOpportunities = new List<Opportunity>();
        Set<String> nonUSDCurrencies = new Set<String>();
        Map<Id,Opportunity> newChangeMapfiscal = new Map<Id,Opportunity>();
        // List<Opportunity> detailedProcessOpp = new List<Opportunity>(); // Added as part of VESTA_SPILLMAN_INT-1220
        List<Opportunity> updateOrConvertOpp = new List<Opportunity>();
        Set<String> listOfOppCountries = new Set<String>(GlobalUtility.fetchPicklistsByObjectAndFieldMap('Opportunity', 'Country__c').values());//SF-2097
        Set<String> listOfOppStates = new Set<String>(GlobalUtility.fetchPicklistsByObjectAndFieldMap('Opportunity', 'State__c').values());//SF-2097
        List<User> lstUser = [SELECT Id, UserTheater__c, Default_Territory__c FROM User WHERE Id = : UserInfo.getUserId() LIMIT 1];
        for(Opportunity eachOpp : newOpptyList) {
            
            if(!listOfOppCountries.contains(eachOpp.Country__c)){//SF-2097
                eachOpp.Country__c = NULL;
            }
            if(!listOfOppStates.contains(eachOpp.State__c)){//SF-2097
                eachOpp.State__c = NULL;
            }
            if(!lstUser.isEmpty()){
                if(String.isBlank(eachOpp.Region__c)){
                    eachOpp.Region__c = lstUser.get(0).UserTheater__c;
                }
                if(String.isBlank(eachOpp.Region__c)){
                    eachOpp.Territory__c = lstUser.get(0).Default_Territory__c;
                }
            }
            if(eachOpp.RecordTypeId == projectRecTypeId) {
                if(eachOpp.Pull_Forward_Date__c != NULL){
                    eachOpp.Pull_Forward_Date__c = NULL;
                }
                projectOpportunities.add(eachOpp);
            } else if(eachOpp.RecordTypeId == registrationRecTypeId){
                registrationOpportunities.add(eachOpp);
            } 
            if(eachOpp.CurrencyIsoCode != 'USD'){
                nonUSDOpportunities.add(eachOpp);
                nonUSDCurrencies.add(eachOpp.CurrencyIsoCode);
                system.debug('nonUSDOpportunities :='+nonUSDOpportunities);
                system.debug('nonUSDCurrencies :='+nonUSDCurrencies);
            }
            if(eachOpp.Pull_Forward_Date__c != NULL || eachOpp.CloseDate != NULL) {
                newChangeMapfiscal.put(eachOpp.Id,eachOpp);
            }
            if((eachOpp.StageName.equals('Position & Align') || eachOpp.StageName.equals('Design & Validate')) &&
               String.isNotBlank(eachopp.Product_Forecast_Commitment__c))
            {
                updateOrConvertOpp.add(eachOpp);
            }
        } //ENDING BeforeInsert FOR Loop Processing
        
        if(!nonUSDOpportunities.isEmpty() && !nonUSDCurrencies.isEmpty()){
            system.debug('nonUSDOpportunities ='+nonUSDOpportunities);
            system.debug('nonUSDCurrencies ='+nonUSDCurrencies);
            opportunityHelper.populateFXrateonOpp(nonUSDOpportunities, nonUSDCurrencies);
        }
        if(!projectOpportunities.isEmpty()) {
            opportunityHelper.populateMCNonOpp(projectOpportunities);
            opportunityHelper.populateMHFields(projectOpportunities);
            /***Added the parameter "isBefore" for SF-2021**/
            opportunityHelper.calculateFiscalFields(projectOpportunities, Trigger.isInsert, Trigger.isBefore);
        }
        opportunityHelper.populateAccountDetails(newOpptyList, Trigger.isInsert);
        if(!registrationOpportunities.isEmpty()){            
            opportunityHelper.populateAccountDetailsOnOpp(registrationOpportunities);
        }
        if(!newOpptyList.isEmpty()){
            opportunityHelper.populateOppStatus(newOpptyList);
        }
        if(!newChangeMapfiscal.isEmpty()) {
            /***Added the parameter "isBefore" for SF-2021**/
            opportunityHelper.calculateFiscalFields(newChangeMapfiscal.values(), Trigger.isInsert, Trigger.isBefore);
        }
        if(!updateOrConvertOpp.isEmpty()){
            opportunityHelper.updateOrConvertOpportunity(updateOrConvertOpp,projectRecTypeId);
        } 
		opportunityHelper.populatePriceBookId(newOpptyList, Trigger.isInsert);//SF-2783        
    }
    public void BeforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
        Map<Id,Opportunity> oldOpptyMap = new Map<Id,Opportunity>();
        Map<Id,Opportunity> newOpptyMap = new Map<Id,Opportunity>();
        if(oldItems != null) oldOpptyMap = (Map<Id,Opportunity>) oldItems;
        if(newItems != null) newOpptyMap = (Map<Id,Opportunity>) newItems;
        
        List<Opportunity> nonUSDOpportunities = new List<Opportunity>();
        Set<String> nonUSDCurrencies = new Set<String>();
        Map<Id,Opportunity> newProjMap = new Map<Id,Opportunity>();
        Map<Id,Opportunity> newRunRateMap = new Map<Id,Opportunity>();
        Map<Id,Opportunity> newFedRegMap = new Map<Id,Opportunity>();        
        List<Opportunity> allOppsWithUpdatedAccount = new List<Opportunity>();
        List<Opportunity> registrationOppsWithUpdatedStatus = new List<Opportunity>();
        Map<Id,Opportunity> newStageProjOppMap = new Map<Id,Opportunity>();
        List<Opportunity> accChangedRegOpps = new List<Opportunity>();
        Map<Id,Opportunity> oppsToValidateCAMandRCM = new Map<Id,Opportunity>();
        Map<Id,Opportunity> newChangeMapfiscal = new Map<Id,Opportunity>();
        List<Opportunity> lstfiscalForecastNoteBRR = new List<Opportunity>();
        Set<String> setForecastNoteYears = new Set<String>();
        List<Opportunity> lstfiscalWonLostBRR = new List<Opportunity>();
        Set<String> setWonLostYears =  new Set<String>();
        //List<Opportunity> detailedProcessOpp = new List<Opportunity>(); // Added as part of VESTA_SPILLMAN_INT-1220
        List<Opportunity> updateOrConvertOpp = new List<Opportunity>();
        List<Opportunity> opportunityToBeUpdated = new List<Opportunity>(); //SF-2172
        Set<Id> setOwnerChanged = new Set<Id>();
        List<Opportunity> oppsWithMCNnull = new List<Opportunity>();
        List<Opportunity> lstchangedBRR = new List<Opportunity>(); // BRR Enhancement
        
        validationsOnOpportunityUpdate(newOpptyMap.values(),oldOpptyMap);
        for(Opportunity eachOpp :(List<Opportunity>) newOpptyMap.values()) {
            system.debug('eachOpp.CurrencyIsoCode ='+eachOpp.CurrencyIsoCode);
            Opportunity oldOpp = (Opportunity)oldItems.get(eachOpp.Id);
            //SF-2172 -  To update new Currency to NULL if there are no OLI's
            if(String.isNotBlank(eachOpp.New_Currency__c) && eachOpp.CurrencyIsoCode != oldOpp.CurrencyIsoCode){
                opportunityToBeUpdated.add(eachOpp); 
            }
            //SF-2216 - populateFXrateonOpp on ClostDate Change
            //if(eachOpp.CurrencyIsoCode != 'USD' && eachOpp.CurrencyIsoCode != oldOpp.CurrencyIsoCode){
            if((eachOpp.CurrencyIsoCode != 'USD' && eachOpp.CurrencyIsoCode != oldOpp.CurrencyIsoCode) || (eachOpp.CloseDate != oldOpp.CloseDate)){
                
                nonUSDOpportunities.add(eachOpp);
                nonUSDCurrencies.add(eachOpp.CurrencyIsoCode);
            }
            if(eachOpp.Pull_Forward_Date__c != oldOpp.Pull_Forward_Date__c || eachOpp.CloseDate != oldOpp.CloseDate) {
                newChangeMapfiscal.put(eachOpp.Id,eachOpp);
            }            
            if(eachOpp.RecordTypeId == projectRecTypeId) {
                newProjMap.put(eachOpp.Id,eachOpp);
                //SF-2035
                //BRR Enhancement
                if(eachOpp.stageName !=oldOpp.StageName &&  (eachOpp.stageName == 'Execute & Expand / Won' || eachOpp.stageName == 'Lost' || eachOpp.stageName == 'No Pursuit') ){
                    lstfiscalWonLostBRR.add(eachOpp);
                    setWonLostYears.add(String.valueOf(System.now().year()));   
                    lstchangedBRR.add(eachOpp);
                }
                if(eachOpp.Forecast_Notes__c != NULL && eachOpp.Forecast_Notes__c != oldOpp.Forecast_Notes__c){
                    eachOpp.Forecast_Note_Date_Time__c = system.now();
                    lstfiscalForecastNoteBRR.add(eachOpp);
                    setForecastNoteYears.add(String.valueOf(eachOpp.Forecast_Note_Date_Time__c.year()));   
                    lstchangedBRR.add(eachOpp);
                }
                if(eachOpp.StageName != oldOpp.StageName || eachOpp.mh_Place_in_Sales_Funnel__c != oldOpp.mh_Place_in_Sales_Funnel__c){
                    newStageProjOppMap.put(eachOpp.Id,eachOpp);
                }
                //SF-2223 Google Drive Changes
                //if(eachOpp.ownerId != oldOpp.ownerId && eachOpp.Region__c == 'NA' ){
                if(eachOpp.ownerId != oldOpp.ownerId ){//GD International
                    setOwnerChanged.add(eachOpp.Id);
                }
            } else if(eachOpp.RecordTypeId == fedRegistrationRecTypeId){
                newFedRegMap.put(eachOpp.Id,eachOpp);
            } else if(eachOpp.RecordTypeId == registrationRecTypeId){
                if(eachOpp.Approval_Status__c != oldOpp.Approval_Status__c){
                    registrationOppsWithUpdatedStatus.add(eachOpp);
                }
                if(eachOpp.AccountId != oldOpp.AccountId || eachOpp.CDH_Account__c != oldOpp.CDH_Account__c){
                    accChangedRegOpps.add(eachOpp);    
                }
                if(eachOpp.Extend_Expiry_Date__c != oldOpp.Extend_Expiry_Date__c && (eachOpp.Region__c == 'EA' || eachOpp.Region__c == 'ME') 
                   && oldOpp.Extend_Expiry_Date__c == true && eachOpp.Extend_Expiry_Date__c == false) {
                       eachOpp.addError('This Deal Registration has already been extended and cannot be extended second time. Please submit a new Deal Registration application.');
                       return;
                   }
                if(eachOpp.Extend_Expiry_Date__c != oldOpp.Extend_Expiry_Date__c 
                   && (eachOpp.Region__c == 'EA' || eachOpp.Region__c == 'ME') && oldOpp.Extend_Expiry_Date__c == false
                   && eachOpp.Extend_Expiry_Date__c == true && eachOpp.Approval_Status__c != 'Approved') {
                       eachOpp.addError('Deal Registration should be validated before an extension request is approved.');
                       return;
                   }               
            } else if(eachOpp.RecordTypeId == runRateRecTypeId){
                newRunRateMap.put(eachOpp.Id,eachOpp);
            }
            //System.debug('Before eachOpp.CDH_Account__c==>' +eachOpp.CDH_Account__c);
            if(eachOpp.AccountId != ((Opportunity)oldItems.get(eachOpp.Id)).AccountId){
                eachOpp.CDH_Account__c = NULL;
                allOppsWithUpdatedAccount.add(eachOpp);
            }
            //System.debug('After eachOpp.CDH_Account__c==>' +eachOpp.CDH_Account__c);
            if(eachOpp.Approval_Status__c != oldOpp.Approval_Status__c){
                if(eachOpp.Approval_Status__c == 'Approved' && eachOpp.RecordTypeId == fedRegistrationRecTypeId){
                    eachOpp.OwnerId = eachOpp.Account_Executive__c;
                }
            }
            if(eachOpp.Approval_Status__c != oldOpp.Approval_Status__c && (eachOpp.Region__c == 'EA' || eachOpp.Region__c == 'ME')) {
                if(oldOpp.Approval_Status__c == 'Waiting Approval' && eachOpp.RecordTypeId == RegistrationRecTypeId){
                    oppsToValidateCAMandRCM.put(eachOpp.id,eachOpp);
                }   
            }
            if((eachOpp.StageName.equals('Position & Align') || eachOpp.StageName.equals('Design & Validate')) &&
               String.isNotBlank(eachopp.Product_Forecast_Commitment__c))
            {
                updateOrConvertOpp.add(eachOpp);
            }
            //SF-2704
            System.debug('1 Before Update eachOpp.CDH_Account__c==>'+eachOpp.CDH_Account__c);
            if(String.isBlank(eachOpp.CDH_Account__c)){
                System.debug('2 Before Update eachOpp.CDH_Account__c==>'+eachOpp.CDH_Account__c);
                oppsWithMCNnull.add(eachOpp);            
            }
   		/* Added as part of VESTA_SPILLMAN_INT-1220 */
        }//ENDING Before Update FOR Loop Processing
        //SF-2704--Start        
        if(!oppsWithMCNnull.isEmpty()){
            System.debug('3 Before Update oppsWithMCNnull==>'+oppsWithMCNnull);
            opportunityHelper.populateMCNonOpp(oppsWithMCNnull);
        }        
        if(!opportunityToBeUpdated.isEmpty()){
            opportunityHelper.updateNewCurrency(opportunityToBeUpdated);
        }
        if(!nonUSDOpportunities.isEmpty() && !nonUSDCurrencies.isEmpty()){
            system.debug('nonUSDOpportunities ='+nonUSDOpportunities);
            system.debug('nonUSDCurrencies ='+nonUSDCurrencies);
            opportunityHelper.populateFXrateonOpp(nonUSDOpportunities, nonUSDCurrencies);
        }
        if(!allOppsWithUpdatedAccount.isEmpty()){
            opportunityHelper.populateMCNonOpp(allOppsWithUpdatedAccount); 
            opportunityHelper.populateAccountDetails(allOppsWithUpdatedAccount,Trigger.isInsert);
            opportunityHelper.insertOpportunityTeamMemberforFedReg(allOppsWithUpdatedAccount); 
        }       
        if(!newProjMap.isEmpty()){
            opportunityHelper.populateProjectStatusOnOpp(oldOpptyMap, newProjMap);
            opportunityHelper.populateMHFields(newProjMap.values());
            updateOpptyAgingType(newProjMap);
        }
        if(!newRunRateMap.isEmpty()){
            updateOpptyAgingType(newRunRateMap);
        }
        if(!newStageProjOppMap.isEmpty()){
            opportunityHelper.populateMHFields(newStageProjOppMap.values());
            opportunityHelper.populateOppStatus(newStageProjOppMap.values());
        }
        if(!registrationOppsWithUpdatedStatus.isEmpty()){
            validationsOnOpportunitySubmission(registrationOppsWithUpdatedStatus,oldOpptyMap);
        }
        cmtsOnApprvlRejectionBfrUpdate(oldOpptyMap,newOpptyMap);
        if(!accChangedRegOpps.isEmpty()){
            opportunityHelper.populateAccountDetailsOnOpp(accChangedRegOpps);
        }
        if(!newFedRegMap.isEmpty()){
            fedRegApprovalValidations(oldOpptyMap,newFedRegMap);
        }
        if(!oppsToValidateCAMandRCM.isEmpty()) {
            populateCAMandRCMForEA(oppsToValidateCAMandRCM);
        }
        if(!newChangeMapfiscal.isEmpty()) {
            /***Added the parameter "true" for SF-2021**/
            opportunityHelper.calculateFiscalFields(newChangeMapfiscal.values(), false , true);
        }
        if(!lstfiscalForecastNoteBRR.isEmpty() && !setForecastNoteYears.isEmpty()) {
            //SF-2035
            opportunityHelper.populateOppBRR(lstfiscalForecastNoteBRR, setForecastNoteYears,'Forecast_Note_Date_Time__c');
        }
        if(!lstfiscalWonLostBRR.isEmpty() && !setWonLostYears.isEmpty()) {
            //SF-2035
            opportunityHelper.populateOppBRR(lstfiscalWonLostBRR, setWonLostYears,'today');
        }
        if(!updateOrConvertOpp.isEmpty()){
            opportunityHelper.updateOrConvertOpportunity(updateOrConvertOpp,projectRecTypeId);
        }
        //SF-2223 Google Drive Changes - To hold all OppTeamMember details before Opp Owner is changed
        if(!setOwnerChanged.isEmpty()){
            for(OpportunityTeamMember otm : getOppTeamMembers(setOwnerChanged)){
                if(mapOppIdsTeamUserEmails.containsKey(otm.OpportunityId)){
                    mapOppIdsTeamUserEmails.get(otm.OpportunityId).add(otm.User.Email);
                }else{
                    mapOppIdsTeamUserEmails.put(otm.OpportunityId,new List<String>{otm.User.Email}); 
                }
            }
        }
        //BRR Enhancement
        if(!lstchangedBRR.isEmpty()){
            //system.debug('getLockedBRRs calling');
            opportunityHelper.getLockedBRRs(lstchangedBRR);
        }
    }
    public void BeforeDelete(Map<Id, SObject> oldItems) {
    }
    public void AfterInsert(Map<Id, SObject> newItems) {
        Map<Id,Opportunity> newOpptyMap = new Map<Id,Opportunity>();
        if(newItems != null) newOpptyMap = (Map<Id,Opportunity>) newItems;
        Map<Id,Opportunity> projectOppMap = new Map<Id,Opportunity>();
        Map<Id,Id> fedOrRegopportunityPartnerAccountMap = new Map<Id,Id>();
        Set<Id> incumbentOpportunityIds = new Set<Id>(); // Added as a part of VESTA_SPILLMAN_INT-784
        Set<Id> manufacturerOpportunityIds = new Set<Id>(); // Added as a part of VESTA_SPILLMAN_INT-1384
        Set<String> createGoogleDriveSet = new Set<String>();
        for(Opportunity eachOpp : newOpptyMap.values()) {
            //SF-2246
            //if(eachOpp.RecordTypeId == projectRecTypeId && eachOpp.Region__c == 'NA'){
            if(eachOpp.RecordTypeId == projectRecTypeId){//GD International  
                //SF-2223 Google Drive Changes
                System.debug('After Insert Project==>' + eachOpp.Id);                
                createGoogleDriveSet.add(eachOpp.Id);  
                //projectOppMap.put(eachOpp.Id,eachOpp);              
            } else if(eachOpp.RecordTypeId == fedRegistrationRecTypeId || eachOpp.RecordTypeId == registrationRecTypeId){
                fedOrRegopportunityPartnerAccountMap.put(eachOpp.Id, eachOpp.PartnerAccountId);
            }
            /* Added as a part of VESTA_SPILLMAN_INT-784 for creating Opportunity Competitors */
            if(String.isNotBlank(eachOpp.Incumbent_Lookup__c)){
                incumbentOpportunityIds.add(eachOpp.Id);
            }
            /* Added as a part of VESTA_SPILLMAN_INT-1384 for creating Opportunity Competitors */
            if(String.isNotBlank(eachOpp.Primary_Competitor_Account__c)){
                manufacturerOpportunityIds.add(eachOpp.Id);
            }
        }
        if(!fedOrRegopportunityPartnerAccountMap.isEmpty()) {
            partnerSharingHelper.shareToExecutiveRoles(fedOrRegopportunityPartnerAccountMap);
        }
        /* Added part of VESTA_SPILLMAN_INT-784 for creating Opportunity Competitors */
        if(!incumbentOpportunityIds.isEmpty()){
            opportunityHelper.createCompetitors(incumbentOpportunityIds,'incumbentCompetitors');
        }
        /* Added part of VESTA_SPILLMAN_INT-1384 for creating Opportunity Competitors */
        if(!manufacturerOpportunityIds.isEmpty()){
            opportunityHelper.createCompetitors(manufacturerOpportunityIds,'manufacturerCompetitors');
        }
        //SF-2223 Google Drive Changes
        if(!createGoogleDriveSet.isEmpty()) {
            //System.debug('createGoogleDriveSet==>' + createGoogleDriveSet);
            insertGoogleDriveAfterInsert(createGoogleDriveSet);
        }       
    }
    public void AfterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
        Map<Id,Opportunity> oldOpptyMap = new Map<Id,Opportunity>();
        Map<Id,Opportunity> newOpptyMap = new Map<Id,Opportunity>();
        if(oldItems != null) oldOpptyMap = (Map<Id,Opportunity>) oldItems;
        if(newItems != null) newOpptyMap = (Map<Id,Opportunity>) newItems;
        
        List<Opportunity> updtedMIPProjectOpps = new List<Opportunity>();
        List<Opportunity> lostProjectOpps = new List<Opportunity>();
        List<Opportunity> updatedStageProjRegOpps = new List<Opportunity>();
        Map<Id,Opportunity> newProjectOpptyMap = new Map<Id,Opportunity>();
        List<Opportunity> approvedFedOpps = new List<Opportunity>();
        Set<Id> oppCreators = new Set<Id>();
        Map<Id,Id> createdbyAccMap = new Map<Id,Id>();
        List<Opportunity> registrationOpps = new List<Opportunity>();
        Map<Id,Opportunity> newStageProjOppMap = new Map<Id,Opportunity>();
        Map<Id,Opportunity> oldStageProjOppMap = new Map<Id,Opportunity>();
        Map<Id,Decimal> mapRelativeOpp = new  Map<Id,Decimal>();
        Map<Id,Opportunity> rejectedProjectOppMap = new Map<Id,Opportunity>();
        Set<Id> incumbentOpportunityIds = new Set<Id>(); // Added as a part of VESTA_SPILLMAN_INT-784
        Set<Id> manufacturerOpportunityIds = new Set<Id>(); // Added as a part of VESTA_SPILLMAN_INT-1384
        /***Map of Opportunity for SF-2021**/
        Map<Id,Opportunity> newChangeMapfiscal = new Map<Id,Opportunity>();
        Map<Id,Id> mapUpdateForecastNote = new Map<Id,Id>(); //SF-2035
        Map<Id,Opportunity> newChangeCurrencyMap = new Map<Id,Opportunity>();
        Set<String> currencyList = new Set<String>();
        Set<String> newCurrencyList = new Set<String>();
        Set<String> oldCurrencyList = new Set<String>();
        //SF-2223 Google Drive Changes
        Set<String> googleDriveUpdateEvtSet = new Set<String>();
        Set<String> setOwnerChanged = new Set<String>();
        Set<String> createGoogleDriveSet = new Set<String>();
        Map<Id,Opportunity> mapCreateUpdateExistingBRR = new Map<Id,Opportunity>();//SF-2399
        Map<Id,Opportunity> mapCreateCAPPRecords = new Map<Id,Opportunity>(); //SF-2461 Create CAPP Records
        for(Opportunity eachOpp : newOpptyMap.values()) {
            Opportunity oldOpp = oldOpptyMap.get(eachOpp.Id);
            /**Logic for SF-2172 Start**/    
            if(eachOpp.CurrencyIsoCode != eachOpp.New_Currency__c && String.isNotBlank(eachOpp.New_Currency__c)){
                //To delete OLI's   
                currencyList.add(eachOpp.New_Currency__c);             
                newChangeCurrencyMap.put(eachOpp.Id,eachOpp);  
            }            
            if(eachOpp.CurrencyIsoCode!=oldOpp.CurrencyIsoCode && String.isNotBlank(eachOpp.New_Currency__c)){
                // To  Insert OLI's
                newCurrencyList.add(eachOpp.CurrencyIsoCode);
                oldCurrencyList.add(oldOpp.CurrencyIsoCode); 
            }
            /**Logic for SF-2172 End**/
            /***Logic for SF-2021 Start**/
            if(eachOpp.Is_Created_From_Conversion__c && eachOpp.Fiscal_Metadata__c == NULL && oldOpp.Fiscal_Metadata__c == NULL){
                newChangeMapfiscal.put(eachOpp.Id, eachOpp);
            } 
            /***Logic for SF-2021 End**/
            if (eachOpp.RecordTypeId == projectRecTypeId) {
                //newProjectOpptyMap.put(eachOpp.Id,eachOpp);//Commented for GD International
                system.debug('eachOpp.Briefing_Room_Report__c'+eachOpp.Briefing_Room_Report__c);
                if(eachOpp.Forecast_Notes__c != NULL && eachOpp.Forecast_Notes__c != oldOpp.Forecast_Notes__c && eachOpp.Briefing_Room_Report__c !=  NULL/* && eachOpp.Briefing_Room_Report__c == oldOpp.Briefing_Room_Report__c*/){
                    mapUpdateForecastNote.put(eachOpp.Id,eachOpp.Briefing_Room_Report__c);
                    mapCreateUpdateExistingBRR.put(eachOpp.Id,eachOpp);
                }
                if(eachOpp.StageName != oldOpp.StageName || eachOpp.mh_Place_in_Sales_Funnel__c != oldOpp.mh_Place_in_Sales_Funnel__c){
                    newStageProjOppMap.put(eachOpp.Id,eachOpp);
                    oldStageProjOppMap.put(oldOpp.Id,oldOpp);
                }
                //SF-2399
                system.debug('eachOpp.Briefing_Room_Report__c '+eachOpp.Briefing_Room_Report__c );
                system.debug('oldOpp.Briefing_Room_Report__c '+oldOpp.Briefing_Room_Report__c );
                if(eachOpp.Briefing_Room_Report__c != oldOpp.Briefing_Room_Report__c){
                    mapCreateUpdateExistingBRR.put(eachOpp.Id,eachOpp);
                }
                if(eachOpp.MIP_Agreement__c != oldOpp.MIP_Agreement__c){
                    updtedMIPProjectOpps.add(eachOpp);
                }
                if(eachOpp.StageName != oldOpp.StageName){
                    updatedStageProjRegOpps.add(eachOpp);
                    if(eachOpp.StageName == 'Lost'){
                        lostProjectOpps.add(eachOpp);
                    }
                    //BRR Enhancement
                    if(eachOpp.Briefing_Room_Report__c != NULL &&  (eachOpp.stageName == 'Execute & Expand / Won' || eachOpp.stageName == 'Lost' || eachOpp.stageName == 'No Pursuit')){
                        mapCreateUpdateExistingBRR.put(eachOpp.Id,eachOpp);
                    }
                }
                if(eachOpp.Aging_Type__c == 'Relative' && eachOpp.CloseDate != oldOpp.CloseDate ){
                    mapRelativeOpp.put(eachOpp.Id,eachOpp.Sequential_Month_Number__c);
                }
                //SF-2223 Google Drive Changes
                //if(eachOpp.Region__c == 'NA'){ // Commented for GD International
                if(oldOpp.RecordTypeId !=eachOpp.RecordTypeId && eachOpp.RecordTypeId == projectRecTypeId ){
                    createGoogleDriveSet.add(eachOpp.Id);
                }                    
                /*if(eachOpp.Name != oldOpp.Name || eachOpp.State__c != oldOpp.State__c || (oldOpp.Project_Status__c != NULL && eachOpp.Project_Status__c != oldOpp.Project_Status__c) 
|| eachOpp.SLC_Contract_Number__c != oldOpp.SLC_Contract_Number__c || eachOpp.AccountId != oldOpp.AccountId 
|| eachOpp.Opportunity_Reference__c != oldOpp.Opportunity_Reference__c || eachOpp.Territory__c != oldOpp.Territory__c 
|| eachOpp.Amount !=oldOpp.Amount)*/    
                if((eachOpp.Name != oldOpp.Name || eachOpp.State__c != oldOpp.State__c || ((oldOpp.Project_Status__c != NULL && eachOpp.Project_Status__c != oldOpp.Project_Status__c) && eachOpp.Region__c == 'NA') 
                       || eachOpp.SLC_Contract_Number__c != oldOpp.SLC_Contract_Number__c || eachOpp.AccountId != oldOpp.AccountId 
                       || eachOpp.Opportunity_Reference__c != oldOpp.Opportunity_Reference__c || eachOpp.Territory__c != oldOpp.Territory__c || (eachOpp.Country__c != oldOpp.Country__c && eachOpp.Region__c != 'NA')  
                   	   || (eachOpp.Region__c != oldOpp.Region__c && eachOpp.Region__c != 'NA') 
                       || eachOpp.Amount !=oldOpp.Amount || ((oldOpp.Opportunity_Status__c!= NULL && eachOpp.Opportunity_Status__c != oldOpp.Opportunity_Status__c) && (eachOpp.Region__c != 'NA' || eachOpp.Territory__c.startsWith('CT')))
                   	   || eachOpp.Partner_Count__c !=oldOpp.Partner_Count__c) && Recursionblocker.flag){
                           Recursionblocker.flag= False;
                           System.debug('googleDriveUpdateEvtSet==>'+eachOpp.Id);
                           googleDriveUpdateEvtSet.add(eachOpp.Id);  
                           Recursionblocker.flag = True;
                       }
                if(eachOpp.OwnerId != oldOpp.OwnerId){
                    newProjectOpptyMap.put(eachOpp.Id,eachOpp);
                }
                //}//Commneted for GD International
            } else if(eachOpp.RecordTypeId == registrationRecTypeId){
                if(eachOpp.StageName != oldOpp.StageName){
                    updatedStageProjRegOpps.add(eachOpp);
                }
            }
            if(oldOpp.Approval_Status__c != eachOpp.Approval_Status__c && eachOpp.Approval_Status__c == 'Approved'){
                if(oldOpp.RecordTypeId == fedRegistrationRecTypeId){
                    approvedFedOpps.add(eachOpp);    
                }
            }
            if(oldOpp.OwnerId != eachOpp.OwnerId){
                oppCreators.add(eachOpp.CreatedById);
            }
            if(eachOpp.RecordTypeId == registrationRecTypeId && (eachOpp.Region__c == 'EA' || eachOpp.Region__c == 'ME')
               && (oldOpp.Assigned_CAM__c != eachOpp.Assigned_CAM__c || oldOpp.RCAM_ASL__c != eachOpp.RCAM_ASL__c) ) {
                   registrationOpps.add(eachOpp);
               }
            if(((eachOpp.Approval_Status__c == 'Rejected' && oldOpptyMap.get(eachOpp.id).Approval_Status__c != 'Rejected') || 
                (eachOpp.RecordTypeId == projectRecTypeId && oldOpptyMap.get(eachOpp.id).RecordTypeId != projectRecTypeId)) && eachOpp.Region__c == 'NA')
            {
                rejectedProjectOppMap.put(eachOpp.id,eachOpp);
            }
            /* Added as a part of VESTA_SPILLMAN_INT-784 for creating Opportunity Competitors */
            if(String.isNotBlank(eachOpp.Incumbent_Lookup__c) && oldOpp.Incumbent_Lookup__c != eachOpp.Incumbent_Lookup__c){
                incumbentOpportunityIds.add(eachOpp.Id);
            }
            /* Added as a part of VESTA_SPILLMAN_INT-1384 for creating Opportunity Competitors */
            if(String.isNotBlank(eachOpp.Primary_Competitor_Account__c) && oldOpp.Primary_Competitor_Account__c != eachOpp.Primary_Competitor_Account__c){
                manufacturerOpportunityIds.add(eachOpp.Id);
            }
            //SF-2461 Create CAPP Records- Start
            if(eachOpp.RecordTypeId == projectRecTypeId && eachOpp.StageName != oldOpp.StageName && eachOpp.Amount > 0 &&
              (eachOpp.StageName == 'Execute & Expand / Won' || eachOpp.StageName == 'Lost') &&
              (eachOpp.Auto_Create_CAPP_Record__c == 'Yes, update top CAPP Vendor & Purchase Year' || 
               eachOpp.Auto_Create_CAPP_Record__c == 'Yes, add additional CAPP Vendor & Purchase Year')){
                    mapCreateCAPPRecords.put(eachOpp.Id, eachOpp);
                }
            //SF-2461 Create CAPP Records- End
            
        }
        if(!mapRelativeOpp.isEmpty()){
            List<Revenue__c> lstrevenue = new List<Revenue__c>();
            for(Revenue__c rev : [SELECT Id,Revenue_Month__c,Opportunity_Product_Mirror__r.Opportunity__c,Mid_Month_Revenue_Date__c FROM Revenue__c 
                                  WHERE Opportunity_Product_Mirror__r.Opportunity__c IN : mapRelativeOpp.keySet()])
            {
                Opportunity oldOpp = oldOpptyMap.get(rev.Opportunity_Product_Mirror__r.Opportunity__c);  
                Integer monthDiff =  Integer.valueOf(mapRelativeOpp.get(rev.Opportunity_Product_Mirror__r.Opportunity__c) - oldOpp.Sequential_Month_Number__c);
                Datetime temp = rev.Mid_Month_Revenue_Date__c.addMonths(monthDiff);
                rev.Revenue_Year__c =  String.ValueOf(temp.year());
                rev.Revenue_Month__c = temp.format('MMMMM');  
                lstrevenue.add(rev);
            }
            if(!lstrevenue.isEmpty()){
                update lstrevenue;
            }
        }
        //SF-2172
        if(!newChangeCurrencyMap.isEmpty() || !currencyList.isEmpty()){
            if(Recursionblocker.flag){
                opportunityHelper.changeCurrencyOnOpportunity(newChangeCurrencyMap,currencyList);    
            }          
        }
        //SF-2172
        if(!newCurrencyList.isEmpty() || !OldCurrencyList.isEmpty()){
            opportunityHelper.createOpportunityProduct(newCurrencyList,OldCurrencyList);  
        }
        if(!updtedMIPProjectOpps.isEmpty()){
            opportunityHelper.updateInheritedMIPonAgreements(updtedMIPProjectOpps);
        }
        if(!lostProjectOpps.isEmpty()){
            opportunityHelper.updateMIPonOpportunities(lostProjectOpps);
        }
        if(!updatedStageProjRegOpps.isEmpty()){
            opportunityHelper.updateAwardStatusOnAgreements(updatedStageProjRegOpps);
        }
        if(!rejectedProjectOppMap.isEmpty()){
            updatePresalesResourceStatus(rejectedProjectOppMap,rejectedProjectOppMap);//Added by Saranya as part of SF-527
        }
        if(!approvedFedOpps.isEmpty()){
            insertPartnerAsOpportunityTeamMember(approvedFedOpps);
        }
        if(!oppCreators.isEmpty()) {
            createdbyAccMap = partnerSharingHelper.getAccountIdFromUser(oppCreators);
            Map<Id,Id> oppPartnerAccMap = new Map<Id,Id>();
            for(Opportunity eachOpp : newOpptyMap.values()) {
                Opportunity oldOpp = oldOpptyMap.get(eachOpp.Id);
                if(eachOpp.OwnerId != oldOpp.OwnerId){
                    oppPartnerAccMap.put(eachOpp.Id,createdbyAccMap.get(eachOpp.CreatedById));
                }
            } 
            if(!oppPartnerAccMap.isEmpty()){
                partnerSharingHelper.shareToExecutiveRoles(oppPartnerAccMap);
            }
        }
        if(!registrationOpps.isEmpty()) {
            insertOpptyTeamMembersForEA(registrationOpps);
        }
        if(!oldStageProjOppMap.isEmpty() && !newStageProjOppMap.isEmpty()){
            opportunityHelper.populateScoresAndStageDurationsOnSalesFunnelObject(oldStageProjOppMap,newStageProjOppMap);
        }
        /***Logic for SF-2021 Start**/
        if(!newChangeMapfiscal.isEmpty()){
            opportunityHelper.calculateFiscalFields(newChangeMapfiscal.values(), false, false);
        }
        /* Added part of VESTA_SPILLMAN_INT-784 for creating Opportunity Competitors */
        if(!incumbentOpportunityIds.isEmpty()){
            opportunityHelper.createCompetitors(incumbentOpportunityIds,'incumbentCompetitors');
        }
        /* Added part of VESTA_SPILLMAN_INT-1384 for creating Opportunity Competitors */
        if(!manufacturerOpportunityIds.isEmpty()){
            opportunityHelper.createCompetitors(manufacturerOpportunityIds,'manufacturerCompetitors');
        }        
        //SF-2223 Google Drive Changes
        if(!newProjectOpptyMap.isEmpty()){
            folderPermissionOnOwnerChange(oldOpptyMap,newProjectOpptyMap);
        }
        //SF-2223 Google Drive Changes
        if(!googleDriveUpdateEvtSet.isEmpty() && Recursionblocker.flag){ 
            Recursionblocker.flag = False; 
            Set<String> existingGDriveOppIds = new Set<String>();
            system.debug('update opp Event***');
            for(Google_Drive_Folder__c gdrive  : [SELECT Id,Name FROM Google_Drive_Folder__c WHERE Name IN: googleDriveUpdateEvtSet AND Parent_Name__c = NULL]){
                existingGDriveOppIds.add(gdrive.Name);
            }
            if(!existingGDriveOppIds.isEmpty()){                
                GoogleDriveUtility.googleDriveFunctions(new List<String>(existingGDriveOppIds),'Update');      
            }
            Recursionblocker.flag = true;
        }
        //SF-2223 Google Drive Changes
        if(!createGoogleDriveSet.isEmpty() && Recursionblocker.flag) {
            //System.debug('createGoogleDriveSet==>' + createGoogleDriveSet);
            Recursionblocker.flag = False;
            insertGoogleDriveAfterInsert(createGoogleDriveSet);
        }
        //SF-2399
        if(!mapCreateUpdateExistingBRR.isEmpty() ){
            opportunityHelper.createOrUpdateExistingBRROpp(mapCreateUpdateExistingBRR,oldOpptyMap);
        }
        //SF-2461 Create CAPP Records 
        if(!mapCreateCAPPRecords.isEmpty() && Recursionblocker.flag){
            system.debug('CreateCAPP>>'+mapCreateCAPPRecords);
            OpportunityTriggerHelper.createCAPPRecords(mapCreateCAPPRecords);
        }
    }
    public void AfterDelete(Map<Id, SObject> oldItems) {
        //SF-2223 Google Drive Changes
        Map<Id,Opportunity> oldOpptyMap = new Map<Id,Opportunity>();
        if(oldItems != null) oldOpptyMap = (Map<Id,Opportunity>) oldItems;
        Map<Id,Opportunity> projectOppMap = new Map<Id,Opportunity>();
        List<String> existingGDriveOppIds = new List<String>();
        for(Opportunity eachOpp : oldOpptyMap.values()) {
            if (eachOpp.RecordTypeId == projectRecTypeId && eachOpp.Region__c == 'NA') {
                projectOppMap.put(eachOpp.Id,eachOpp);
            }
        }
        if(!projectOppMap.isEmpty()) {
            for(Google_Drive_Folder__c gdrive  : [SELECT Id,Name FROM Google_Drive_Folder__c WHERE Name IN: projectOppMap.keySet() AND Parent_Name__c = NULL]){
                existingGDriveOppIds.add(gdrive.Name);
            }
        }
        if(!existingGDriveOppIds.isEmpty()){
            GoogleDriveUtility.googleDriveFunctions(existingGDriveOppIds,'Delete');    
        }
    }
    public void AfterUndelete(Map<Id, SObject> oldItems) {}
    public void cmtsOnApprvlRejectionBfrUpdate(Map<Id,Opportunity> oldOpptyMap, Map<Id,Opportunity> newOpptyMap) {
        //System.debug('Entered Reject Statements Method###=>'+newOpptyMap);
        Map<Id,Opportunity> rejectedStatements = new Map<Id,Opportunity>();
        for(Opportunity opp : newOpptyMap.values()) {
            if(opp.recordtypeId == registrationRecTypeId || opp.recordtypeId == fedRegistrationRecTypeId) { 
                Opportunity oldOpp = oldOpptyMap.get(opp.Id);
                if(oldOpp.Approval_Status__c != 'Rejected' && opp.Approval_Status__c == 'Rejected') { 
                    rejectedStatements.put(opp.Id, opp);  
                }
            }
        }
        if(!rejectedStatements.isEmpty()) {
            List<Id> processInstanceIds = new List<Id>();
            for (Opportunity opps : [SELECT (SELECT ID FROM ProcessInstances ORDER BY CreatedDate DESC LIMIT 1) FROM Opportunity WHERE ID IN :rejectedStatements.keySet()]) {
                if(opps.ProcessInstances.size() > 0) {
                    processInstanceIds.add(opps.ProcessInstances[0].Id);
                }
            }
            for(ProcessInstance pi : [SELECT TargetObjectId,(SELECT Id, StepStatus, Comments FROM Steps ORDER BY CreatedDate DESC LIMIT 1) FROM ProcessInstance 
                                      WHERE Id IN :processInstanceIds ORDER BY CreatedDate DESC]) 
            {
                if(String.isBlank(pi.Steps[0].Comments)) {
                    String fullRecordURL = URL.getSalesforceBaseUrl().toExternalForm() + '/' + newOpptyMap.values()[0].Id;
                    rejectedStatements.get(pi.TargetObjectId).addError('<b>Operation Cancelled: Please provide a rejection reason! Please enter Rejection reason in the previous screen</b> </br>'+'<a href=\''+fullRecordURL+'\'>Click Here</a> to access the Opportunity',false);
                }
            }
        }
    }
    public void updatePresalesResourceStatus(Map<Id,Opportunity> oldOpptyMap, Map<Id,Opportunity> newOpptyMap){
        List<PreSales__c> psrrList = [Select id,Presale_Resource_Request_Status__c,Opportunity__c FROM PreSales__c WHERE Opportunity__c IN :newOpptyMap.values()];
        List<PreSales__c> updatelist = new List<PreSales__c>();
        Map<Id,PreSales__c> preSalesMap = new Map<Id,PreSales__c>();
        for(Opportunity opp : newOpptyMap.values()) {
            if(!psrrList.isEmpty()) {
                for(PreSales__c eachpsrr : psrrList){   
                    if(opp.Approval_Status__c == 'Approved') {          
                        eachpsrr.Presale_Resource_Request_Status__c = 'Active';  
                    }
                    else if(opp.Approval_Status__c == 'Rejected') {        
                        eachpsrr.Presale_Resource_Request_Status__c = 'Cancelled';  
                    }  
                    updatelist.add(eachpsrr);
                }
            }
        }
        preSalesMap.putAll(updatelist);
        if(!preSalesMap.isEmpty()){
            update preSalesMap.values();
        } 
    }
    public void updateOpptyAgingType(Map<Id,Opportunity> newOppMap) {
        if(!newOppMap.isEmpty()) {
            for(Opportunity eachOpp : newOppMap.values()) {
                if(eachOpp.StageName == 'Execute & Expand / Won' || eachOpp.StageName == 'Lost' || eachOpp.StageName == 'No Pursuit') {
                    eachOpp.Aging_Type__c = 'Fixed';
                }
            }
        } 
    }
    public void validationsOnOpportunitySubmission(List<Opportunity> incomingOpps,Map<Id,Opportunity> oldOppMap){
        Map<Id,Integer> oppMRCalc = new Map<Id,Integer>();
        for(Opportunity incomingopp:incomingOpps){
            Integer intCount = 0;
            for(AggregateResult mrCalcCount :[SELECT COUNT(Id) intVal FROM MR_Commission_Calculator__c WHERE Opportunity__c =:incomingopp.Id]) {
                intCount+=(Integer)mrCalcCount.get('intVal');
            }
            oppMRCalc.put(incomingopp.id,intCount);
        }
        for(Opportunity incomingopp:incomingOpps){
            Opportunity oldOpp = oldOppMap.get(incomingopp.Id);
            if(incomingopp.Region__c=='NA' && incomingopp.RecordTypeId == registrationRecTypeId && incomingopp.Approval_Status__c!=oldOpp.Approval_Status__c 
               && incomingopp.Approval_Status__c == 'Waiting Approval'){
                   if(oppMRCalc.get(incomingopp.Id) == 0 || incomingopp.Num_Product_Families__c == 0 ){
                       incomingopp.addError('Please populate a Product Family 1st then include a MR Commission Calculator before submitting for approval!');  
                       return;
                   }else if(oppMRCalc.get(incomingopp.Id) > 1){
                       incomingopp.addError('Please have only one MR Commission Calculator for submitting for approval!');  
                       return;
                   }
               }
            //Added by Satish for EA Communities (SF-1400)
            if((incomingopp.Region__c == 'EA' || incomingopp.Region__c == 'ME') && incomingopp.RecordTypeId == registrationRecTypeId 
               && incomingopp.Approval_Status__c!=oldOpp.Approval_Status__c && incomingopp.Approval_Status__c == 'Waiting Approval')
            {
                if(incomingopp.Num_Product_Families__c == 0){
                    incomingopp.addError('Please populate a Product Family before submitting for approval!');  
                    return;
                }
                if(incomingopp.Amount < 50000){
                    incomingopp.addError('The minimum opportunity value for a Deal Registration is 50,000.');  
                    return;
                }
            }
            if((incomingopp.Region__c == 'AP' || incomingopp.Region__c == 'LA' ) && incomingopp.RecordTypeId == registrationRecTypeId && incomingopp.Approval_Status__c!=oldOpp.Approval_Status__c && 
               (incomingopp.Approval_Status__c == 'PENDING' || incomingopp.Approval_Status__c == 'Waiting Approval' ) )
            {
                if(incomingopp.Num_Product_Families__c == 0){
                    //System.debug('####Inside AP loop####');
                    incomingopp.addError(System.Label.Validation_Error_Product_Family);  
                    return;
                }
            }
        }
    }
    public void validationsOnOpportunityUpdate(List<Opportunity> incomingOpps,Map<Id,Opportunity> oldOppMap){
        for(Opportunity incomingopp:incomingOpps){
            Opportunity oldOpp = oldOppMap.get(incomingOpp.Id);
            if(UserInfo.getUserType() != 'Standard' && (incomingOpp.Region__c == 'NA' || incomingOpp.Region__c == 'EA' || incomingOpp.Region__c == 'ME')){
                if(incomingOpp.StageName != oldOpp.StageName && ((incomingOpp.StageName == 'Prospect' && (oldOpp.StageName == 'Position & Align' || oldOpp.StageName == 'Design & Validate')) ||
                                                                 (incomingOpp.StageName == 'Position & Align' && oldOpp.StageName == 'Design & Validate'))){
                                                                     incomingOpp.addError('Previous Stage cannot be selected');
                                                                     return;
                                                                 }
                if(incomingOpp.CloseDate != oldOpp.CloseDate && incomingOpp.CloseDate < oldOpp.CloseDate){
                    incomingOpp.addError('Close Date cannot be moved backward for an approved opportunity');
                    return;
                }
            }
            if(String.isNotBlank(oldOppMap.get(incomingOpp.Id).Order_Type__c) && incomingOpp.Order_Type__c != oldOppMap.get(incomingOpp.Id).Order_Type__c && incomingopp.Region__c=='NA'){
                incomingOpp.adderror('Order Type Cannot be changed once Opportunity is registered');
                return;
            }
            if(incomingopp.Order_Type__c == 'System' && incomingopp.Region__c == 'NA' && UserInfo.getUserType() != 'Standard'){
                if(String.isBlank(incomingopp.Funding_Vehicle_Type__c) 
                   || String.isBlank(incomingopp.System_Type__c) || String.isBlank(incomingopp.System_Mode__c) 
                   || String.isBlank(incomingopp.Coverage_Analysis_Required__c) || String.isBlank(incomingopp.Network_Management_Proposed__c) 
                   || String.isBlank(incomingopp.Civil_Required__c) || incomingopp.Number_of_Channels__c == NULL 
                   || incomingopp.Number_Of_Dispatch_Locations__c == NULL || incomingopp.Number_Of_Dispatch_Positions__c == null 
                   || incomingopp.Number_Of_Sites__c == null){
                       incomingopp.addError('Please update \'PROPOSED SYSTEM\' section when Order Type is \'System\'');   
                       return;
                   }
            } 
        }
    }
    public void fedRegApprovalValidations(Map<Id,Opportunity> oldOpptyMap, Map<Id,Opportunity> newOpptyMap) {
        Map<Id,Opportunity> fedOppsWithoutDiscounPercentage = new Map<Id,Opportunity>();
        for(Opportunity opp : newOpptyMap.values()) {
            if(opp.recordtypeId == fedRegistrationRecTypeId) {  
                Opportunity oldOpp = oldOpptyMap.get(opp.Id);
                if(opp.Discount_Percentage__c==null && opp.Approval_Status__c != oldOpp.Approval_Status__c && oldOpp.Approval_Status__c == 'APPROVAL IN PROCESS- ADMIN APPROVED' && opp.Approval_Status__c == 'CAM Approved'){ 
                    fedOppsWithoutDiscounPercentage.put(opp.Id, opp);  
                }
            }
        }
        if(!fedOppsWithoutDiscounPercentage.isEmpty()) { 
            List<Id> processInstanceIds = new List<Id>{};
                for (Opportunity opps : [SELECT (SELECT ID FROM ProcessInstances ORDER BY CreatedDate DESC LIMIT 1) FROM Opportunity WHERE ID IN :fedOppsWithoutDiscounPercentage.keySet()])
            {
                if(opps.ProcessInstances.size() > 0) {
                    processInstanceIds.add(opps.ProcessInstances[0].Id);
                }
            }
            // Now that we have the most recent process instances, we can check the most recent process steps for comments.
            if(!processInstanceIds.isEmpty()){
                for(ProcessInstance pi : [SELECT TargetObjectId,(SELECT Id, StepStatus, Comments FROM Steps ORDER BY CreatedDate DESC LIMIT 1)
                                          FROM ProcessInstance WHERE Id IN :processInstanceIds ORDER BY CreatedDate DESC])
                {
                    if(String.isBlank(pi.Steps[0].Comments)) {
                        String fullRecordURL = URL.getSalesforceBaseUrl().toExternalForm() + '/' + newOpptyMap.values()[0].Id;
                        fedOppsWithoutDiscounPercentage.get(pi.TargetObjectId).addError('<b>Operation Cancelled: Please provide Discount Percentage before the approval.</b> </br>'+'<a href=\''+fullRecordURL+'\'>Click Here</a> to access the Opportunity',false);
                    }
                }
            }           
        }
    }
    public void insertPartnerAsOpportunityTeamMember(List<Opportunity> incomingFedReg){
        List<OpportunityTeamMember> toBeInserted= new List<OpportunityTeamMember>();
        for(Opportunity incoming:incomingFedReg){
            toBeInserted.add(new OpportunityTeamMember(UserId=incoming.createdbyId, OpportunityId=incoming.Id, TeamMemberRole='Partner',OpportunityAccessLevel='Edit'));
        }
        if(!toBeInserted.isEmpty()){
            Database.insert(toBeInserted,false);
        }
    }
    public void insertOpptyTeamMembersForEA(List<Opportunity> incomingOpps) {
        List<OpportunityTeamMember> toBeInserted= new List<OpportunityTeamMember>();
        for(Opportunity incoming : incomingOpps) {
            toBeInserted.add(new OpportunityTeamMember(UserId=incoming.Assigned_CAM__c, OpportunityId=incoming.Id, TeamMemberRole='CAM',OpportunityAccessLevel='Edit'));
            toBeInserted.add(new OpportunityTeamMember(UserId=incoming.RCAM_ASL__c, OpportunityId=incoming.Id, TeamMemberRole='RCAM',OpportunityAccessLevel='Edit'));
            if(incoming.Amount >= 250000)
                toBeInserted.add(new OpportunityTeamMember(UserId='00534000008cwFq', OpportunityId=incoming.Id, TeamMemberRole='CVP-Channel Vice President',OpportunityAccessLevel='Edit'));
        }
        if(!toBeInserted.isEmpty()){
            Database.insert(toBeInserted,false);
        }
    }
    public void populateCAMandRCMForEA(Map<Id,Opportunity> incomingOpps) {
        if(!incomingOpps.isEmpty()) {
            List<Id> processInstanceIds = new List<Id>{};
                for (Opportunity opps : [SELECT (SELECT ID FROM ProcessInstances ORDER BY CreatedDate DESC LIMIT 1) FROM Opportunity WHERE ID IN :incomingOpps.keySet()]) {
                    if(opps.ProcessInstances.size() > 0) {
                        processInstanceIds.add(opps.ProcessInstances[0].Id);
                    }
                }
            for(ProcessInstance pi : [SELECT TargetObjectId,(SELECT Id, StepStatus, Comments FROM Steps ORDER BY CreatedDate DESC LIMIT 1) FROM ProcessInstance 
                                      WHERE Id IN :processInstanceIds ORDER BY CreatedDate DESC])
            {
                if(String.isBlank(incomingOpps.get(pi.TargetObjectId).Assigned_CAM__c) || String.isBlank(incomingOpps.get(pi.TargetObjectId).RCAM_ASL__c)) {
                    String fullRecordURL = URL.getSalesforceBaseUrl().toExternalForm() + '/' + incomingOpps.values()[0].Id;
                    incomingOpps.get(pi.TargetObjectId).addError('<b>Operation Cancelled: Please populate CAM and RCAM users in the previous screen</b> </br>'+'<a href=\''+fullRecordURL+'\'>Click Here</a> to access the Opportunity',false);
                }
            }
        }
    }
    //SF-2223 Google Drive Changes
    public void insertGoogleDriveAfterInsert(Set<String> createGoogleDriveSet) {
        //SF-2223 Google Drive Changes
        //System.debug('insertGoogleDriveAfterInsert Method==>' + createGoogleDriveSet);
        GoogleDriveUtility.googleDriveFunctions(new List<String>(createGoogleDriveSet),'Create');
    } 
    //SF-2223 Google Drive Changes
    public void folderPermissionOnOwnerChange(Map<Id,Opportunity> oldOpptyMap, Map<Id,Opportunity> newOpptyMap) {
        List<String> revokeProvisionSet = new List<String>();
        List<String> provideProvisionSet = new List<String>();
        Set<String> existingGDriveOppIds = new Set<String>();
        Map<String,List<OpportunityTeamMember>> mapOppAndTeamMember= new  Map<String,List<OpportunityTeamMember>>();
        //system.debug('mapOppIdsTeamUserEmails***'+mapOppIdsTeamUserEmails);
        for(Google_Drive_Folder__c gdrive  : [SELECT Id,Name FROM Google_Drive_Folder__c WHERE Name IN: newOpptyMap.keySet() AND Parent_Name__c = NULL]){
            existingGDriveOppIds.add(gdrive.Name);
        }
        for(OpportunityTeamMember otm : [SELECT Id,UserId,OpportunityId,User.Email FROM OpportunityTeamMember WHERE opportunityID IN : newOpptyMap.keySet()]){
            if(mapOppAndTeamMember.containsKey(otm.OpportunityId)){
                mapOppAndTeamMember.get(otm.OpportunityId).add(otm);
            }else{
                mapOppAndTeamMember.put(otm.OpportunityId,new List<OpportunityTeamMember>{otm}); 
            }
        }
        for(Opportunity opp : [SELECT Id,Owner_Email__c,Owner.UserType FROM Opportunity WHERE Id IN : existingGDriveOppIds]) {
            //system.debug('oldOpptyMap Owner Email'+oldOpptyMap.get(opp.Id).Owner_Email__c);
            //system.debug('New Owner Email'+opp.Owner_Email__c);
            If(opp.Owner.UserType == 'Standard'){
                provideProvisionSet.add(opp.Id);
            }
            //revokeProvisionSet.add(oldOpptyMap.get(opp.Id).Owner_Email__c);
            revokeProvisionSet.add(opp.Id+';'+oldOpptyMap.get(opp.Id).Owner_Email__c);
            if(mapOppIdsTeamUserEmails.containsKey(opp.Id)){
                List<OpportunityTeamMember> lstOTM = new  List<OpportunityTeamMember>();
                if(!mapOppAndTeamMember.isEmpty() && mapOppAndTeamMember.containsKey(opp.Id) && mapOppAndTeamMember.get(opp.Id) != NULL){
                    lstOTM.addALL(mapOppAndTeamMember.get(opp.Id));
                    for(OpportunityTeamMember otm : lstOTM){
                        //system.debug('out if'+opp.Id+';'+otm.User.Email);
                        if(!revokeProvisionSet.isEmpty() && revokeProvisionSet.contains(opp.Id+';'+otm.User.Email)){
                            Set<String> revokeProvisionSetTemp = new Set<String>(revokeProvisionSet);
                            revokeProvisionSetTemp.remove(opp.Id+';'+otm.User.Email);
                            revokeProvisionSet = new List<String>(revokeProvisionSetTemp);
                        }
                    }
                }
                if(lstOTM.isEmpty()){
                    for(String otmEmail : mapOppIdsTeamUserEmails.get(opp.Id)){
                        revokeProvisionSet.add(opp.Id+';'+otmEmail);
                    }
                }
            }
        }
        //system.debug('revokeProvisionSet***'+revokeProvisionSet);
        //system.debug('provideProvisionSet***'+provideProvisionSet);
        if(!revokeProvisionSet.isEmpty()){
            GoogleDriveUtility.googleDriveFunctions(revokeProvisionSet,'RevokePermission');
        }
        if(!provideProvisionSet.isEmpty()){
            GoogleDriveUtility.googleDriveFunctions(provideProvisionSet,'Provision');
        }
    }
    //SF-2223 Google Drive Changes
    public List<OpportunityTeamMember> getOppTeamMembers(Set<Id> oppIds){
        return [SELECT Id,OpportunityId, User.Email FROM OpportunityTeamMember WHERE OpportunityId IN: oppIds];
    }   
    
}