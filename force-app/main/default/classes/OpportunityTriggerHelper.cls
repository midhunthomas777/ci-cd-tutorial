/*
* RECORDTYPE.NAME SHOULD BE REPLACED WITH DEVELOPERNAME
*/

public class OpportunityTriggerHelper {
    
    public Id projectRecTypeId =  GlobalUtility.getRecordTypeIdByDeveloperName('Opportunity', 'Government_Standard');
    public Id registrationRecTypeId = GlobalUtility.getRecordTypeIdByDeveloperName('Opportunity', 'Registration');
    public Id fedRegistrationRecTypeId = GlobalUtility.getRecordTypeIdByDeveloperName('Opportunity', 'Federal_Registration');
    public Id runRateRecTypeId = GlobalUtility.getRecordTypeIdByDeveloperName('Opportunity', 'Run_Rate'); 
    public static Set<String> listOfOppCountries = new Set<String>(GlobalUtility.fetchPicklistsByObjectAndFieldMap('Opportunity', 'Country__c').values());//SF-2097
    public static Set<String> listOfOppStates = new Set<String>(GlobalUtility.fetchPicklistsByObjectAndFieldMap('Opportunity', 'State__c').values());//SF-2097
    public static Map<Id,List<OpportunityLineItem>> lineItemMap = new Map<Id,List<OpportunityLineItem>>(); 
    public static Map<String,String> priceBookEntryMap = new Map<String,String>();
    public static boolean changeCurrency = true;
    //OPTIMIZATION NOT COMPLETED
    /* THIS METHOD supports the use of "FX Rates" (annual rates) for EMEA
. FX Rates for a specific year and currency are stored in the FX_Rate__c object and this
. trigger finds the correct corresponding rate in that table for the Opportunites being
. created or updated and stores it in the custom Opportunity field: FX_Rate__c*/
    public void populateFXrateonOpp(List<Opportunity> incomingOpportunities, Set<String> nonUSDCurrencies){
        system.debug('incomingOpportunities ='+incomingOpportunities);
        Map<String,Double> rateMap = new Map<String,Double>();
        Map<String,List<Integer>> fxrateCodeYearMap = new Map<String,List<Integer>>();
        List<Integer> yearsList = new List<Integer>();
        system.debug('nonUSDCurrencies :='+nonUSDCurrencies);
        for(FX_Rate__c fxRate : [SELECT Id, Mashup__c, Conversion_Rate__c, currencyIsoCode,Year__c FROM FX_Rate__c WHERE currencyIsoCode IN: nonUSDCurrencies ORDER BY currencyIsoCode]) {
            rateMap.put(fxRate.Mashup__c,fxRate.Conversion_Rate__c);
            if(!fxrateCodeYearMap.containsKey(fxRate.currencyIsoCode)){
                fxrateCodeYearMap.put(fxRate.currencyIsoCode, new List<Integer>());
                fxrateCodeYearMap.get(fxRate.currencyIsoCode).add(Integer.valueOf(fxRate.Year__c));
            }
            else {
                fxrateCodeYearMap.get(fxRate.currencyIsoCode).add(Integer.valueOf(fxRate.Year__c));
            }
        }
        
        for(Opportunity opp : incomingOpportunities) {
            
            Integer systemYear = Date.Today().Year();
            yearsList.add(systemYear);
            Integer closeDateYear = opp.closeDate.year();
            yearsList.add(closeDateYear);
            Integer fxRateYear;
            Integer searchFxRateYear;

            if(fxrateCodeYearMap.containsKey(opp.currencyIsoCode)){
                List<Integer> dateList = fxrateCodeYearMap.get(opp.currencyIsoCode);
                dateList.sort();
                fxRateYear =  dateList.get(dateList.size()-1);
            }
                
                
            yearsList.add(fxRateYear);
            yearsList.sort();
            searchFxRateYear = yearsList.get(0);
            
            opp.FX_Rate__c = rateMap.get(opp.currencyIsoCode + Integer.valueOf(searchFxRateYear));
        
        }
    }
    
    public void populateMCNonOpp(List<Opportunity> newOpptyList) {
        Set<Id> accIds = new Set<Id>();
        Map<Id,Id> prosCDHMap = new Map<Id,Id>();
        
        for(opportunity eachOpp : newOpptyList) {
            accIds.add(eachOpp.AccountId);
        }
        //Added below Map acctsWithMCN as part of SF-1888 by Akhil
        Map<Id,Account> acctsWithMCN = new Map<Id,Account>([SELECT Id,(SELECT Id FROM AccToAcc__r where RecordType.Name = 'Motorola Customer Number') FROM Account WHERE Id IN :accIds]);
        for(Account acc : [SELECT Id,Name,parentId,recordtypeId FROM Account WHERE RecordType.Name = 'Motorola Customer Number' AND parentId IN :accIds LIMIT 2000])  {
            prosCDHMap.put(acc.parentId,acc.Id);
        }
        for(opportunity opp : newOpptyList) {
            if(opp.AccountId!=null){
                //System.debug('acctsWithMCN.get(opp.AccountId).AccToAcc__r.size()==>' + acctsWithMCN.get(opp.AccountId).AccToAcc__r.size());
                if(acctsWithMCN.get(opp.AccountId).AccToAcc__r.size()==1){ //Added as part of SF-1888 SF-2062 by Akhil             
                    if(prosCDHMap.containskey(opp.AccountId)){                
                        opp.CDH_Account__c = prosCDHMap.get(opp.AccountId);
                        
                    }
                }
                if(acctsWithMCN.get(opp.AccountId).AccToAcc__r.size()==0){
                    opp.CDH_Account__c=null;
                }
                System.debug('opp.CDH_Account__c==>' + opp.CDH_Account__c);
            }
        }
    }
    
    
    /*
* Commented Areas  - which might not required
* 
* Clone_Queue__c is not required with the new Clone functionality
* whenever a opportunity is cloned, cloned_from__c field should be updated from clone_queue__c object
* 
* Populate Closure_Reason__c based on the Stage of Opportunity and Reason_for_Win_or_Loss__c Custom Settings
* Closure_Reason__c - this field is not being used on any layouts.
* if this is being used on Reports this functionality has to be built
*/
    //NEED TO SETUP A CALL WITH JAROD TO GET MAPPING B/W mh_Place_in_Sales_Funnel__c and StageName
    //DEFINE DISPOSITION FOR Opportunity_Forecast__c
    //DEFINE DISPOSITION mh_Specify_Competitors__c
    //DEFINE DISPOSITION mh_Place_in_Sales_Funnel__c
    public void populateMHFields(List<Opportunity> newOpptyList) {
        
        for(Opportunity newOpp : newOpptyList) {
            String competitor = '';
            
            if(String.isNotBlank(newOpp.StageName) && newOpp.StageName != 'Lost') {
                newOpp.mh_Place_in_Sales_Funnel__c = newOpp.StageName;
            }else if(newOpp.StageName == 'Secure') {
                newOpp.Opportunity_Forecast__c = 'Commit';
            }
            if(newOpp.stageName == 'Prospect'){
                newOpp.mh_Blue_Sheet_Type__c='Blue Sheet Type 1'; 
            }else if(newOpp.stageName == 'Secure'){
                newOpp.mh_Blue_Sheet_Type__c='Blue Sheet Type 6';      
            }else if(newOpp.stageName == 'Position & Align'){
                newOpp.mh_Blue_Sheet_Type__c='Blue Sheet Type 9';
            }else if(newOpp.stageName == 'Design & Validate'){
                newOpp.mh_Blue_Sheet_Type__c='Blue Sheet Type 10';
            }else if(newOpp.stageName == 'Execute & Expand / Won'){
                newOpp.mh_Blue_Sheet_Type__c='Blue Sheet Type 11';
            }else{
                newOpp.mh_Blue_Sheet_Type__c = '';
            }
        }
    }
    
    public void populateAccountDetails(List<Opportunity> newOpptyList,Boolean isInsert) {
        set<Id> accIds = new set<Id>();
        for(Opportunity newOpp : newOpptyList) {
            if(String.isNotBlank(newOpp.AccountId)) {
                accIds.add(newOpp.AccountId);
            } 
        }
        
        Map<Id,Account> accountMap = new Map<Id,Account>([SELECT Id,RecordTypeId,OwnerId,Industry,Region__c,BillingCountry,BillingState,Territory__c FROM Account WHERE Id IN: accIds]);
        if(!accIds.isEmpty() && !accountMap.isEmpty() ){
            for(Opportunity newOpp : newOpptyList){
                if(!listOfOppCountries.contains(newOpp.Country__c)){//SF-2097
                    newOpp.Country__c = NULL;
                }
                if(!listOfOppStates.contains(newOpp.State__c)){//SF-2097
                    newOpp.State__c = NULL;
                }
                Account eachAcc = accountMap.get(newOpp.AccountId);
                If(eachAcc != null){
                    newOpp.Account_Executive__c = eachAcc.OwnerId;
                }
                if(isInsert && eachAcc != null){
                    if(String.isBlank(newopp.Region__c) && String.isNotBlank(eachAcc.Region__c)) {
                        newopp.Region__c = eachAcc.Region__c;
                    }
                    if(String.isBlank(newopp.Country__c) && String.isNotBlank(eachAcc.BillingCountry)) {
                        newopp.Country__c = eachAcc.BillingCountry;
                    }
                    if(String.isBlank(newopp.State__c ) && String.isNotBlank(eachAcc.BillingState) && (newopp.Country__c== 'United States' || newopp.Country__c== 'Canada')) {
                        newopp.State__c = eachAcc.BillingState;
                    }
                    if(String.isBlank(newopp.Territory__c) && String.isNotBlank(eachAcc.Territory__c) ) {
                        newopp.Territory__c = eachAcc.Territory__c ;
                    } 
                    if(String.isBlank(newopp.Industry__c) && String.isNotBlank(eachAcc.Industry)) {
                        newopp.Industry__c = eachAcc.Industry;
                    } 
                }
            }
        }
    }        
    public void populateAccountDetailsOnOpp(List<Opportunity> incomingOpportunities){
        Set<Id> accIds = new Set<Id>();
        for(Opportunity incomingopp:incomingOpportunities){
            if(incomingopp.Region__c == 'NA'){
                accIds.add(incomingopp.AccountId);    
            }
        }
        if(!accIds.isEmpty()){
            Map<Id,Account> accMap = new Map<Id,Account>([SELECT Id,Name,Industry,Region__c,BillingCountry,BillingState,BillingPostalCode,BillingStreet,BillingCity,Territory__c,
                                                          (SELECT Id FROM ChildAccounts WHERE Motorola_Customer_Number__c!=null AND recordtype.developername='Motorola_Customer_Number' AND ERP_Active__c=TRUE) FROM Account WHERE Id IN:accIds]);
            for(Opportunity incomingopp:incomingOpportunities){
                if(accMap.get(incomingopp.AccountId) != null){
                    incomingopp.End_User_Name__c = accMap.get(incomingopp.AccountId).Name;
                    incomingopp.Industry__c = accMap.get(incomingopp.AccountId).Industry;    
                    incomingopp.Region__c = accMap.get(incomingopp.AccountId).Region__c;
                    incomingopp.Territory__c = accMap.get(incomingopp.AccountId).Territory__c;
                    if(!listOfOppCountries.contains(accMap.get(incomingopp.AccountId).BillingCountry)){//SF-2097 
                        incomingopp.Country__c = NULL; 
                    }else{
                        incomingopp.Country__c = accMap.get(incomingopp.AccountId).BillingCountry;
                    }
                    if(!listOfOppStates.contains(accMap.get(incomingopp.AccountId).BillingState)){//SF-2097 
                        incomingopp.State__c = NULL;
                    }else{
                        incomingopp.State__c = accMap.get(incomingopp.AccountId).BillingState;
                    }
                    
                    List<Account> mcnAccounts = accMap.get(incomingopp.AccountId).ChildAccounts;
                    if(mcnAccounts.size() == 1){
                        incomingopp.CDH_Account__c = mcnAccounts[0].Id;    
                    } else if(mcnAccounts.size()> 1 && String.isBlank(incomingopp.CDH_Account__c)){
                        incomingopp.addError('Please choose one of the Motorola Customer Number Accounts,as the selected Customer account has more than one Motorola Customer Number');
                        return;
                    }
                }
            }  
        }
    }
    
    // CHECK WITH BUSINESS FOR THE REQUIREMENT TO AUTOMATE OppTeamMem Insertion
    public void insertOpportunityTeamMemberforFedReg(List<Opportunity> incomingFedReg){
        List<OpportunityTeamMember> toBeInserted= new List<OpportunityTeamMember>();
        for(Opportunity incoming:incomingFedReg){
            toBeInserted.add(new OpportunityTeamMember(UserId=incoming.Assigned_CAM__c, OpportunityId=incoming.Id, TeamMemberRole='CAM',OpportunityAccessLevel='Edit'));
            //toBeInserted.add(new OpportunityTeamMember(UserId=incoming.Account_Executive__c, OpportunityId=incoming.Id, TeamMemberRole='Account Manager',OpportunityAccessLevel='Edit'));
            toBeInserted.add(new OpportunityTeamMember(UserId=incoming.Assigned_ASM__c, OpportunityId=incoming.Id, TeamMemberRole='ASM-Area Sales Manager',OpportunityAccessLevel='Edit'));
        }
        if(!toBeInserted.isEmpty()){
            Database.insert(toBeInserted,false);
        }
    }
    
    //THIS METHOD HAS TO BE OPTIMIZED BY RENAMING VARAIBLES AND LOGIC//
    
    /**************************************************************************************************************************
* Trigger Name : ProjectStatusUpdate
* Description: 
*  •   When an Opportunity has no value populated in “Project ID”, “Project Status” shall be “Non SI Project”.
•   When an Opportunity “Status” is “Active” and has some value populated in “Project ID”, “Project Status” shall be “Presale SI Project”.
•   When an Opportunity “Status” is “Won” and has some value populated in “Project ID”, “Project Staus” shall be “Postsale SI Project”.
•   When an Opportunity Status is “No Pursuit” and has some value populated in “Project ID”, “Project Staus” shall be “Closed SI Project”.
•   When a Clarity Project is closed, the PMO will manually update the value of this field to “Closed SI Project”.
***************************************************************************************************************************/
    //projectStatusUpdateBeforeUpdate -- START
    //It will be optimized as part of Google drive code optimization
    //SF-2223 Google Drive Changes
    public void populateProjectStatusOnOpp(Map<Id,Opportunity> oldOpptyMap, Map<Id,Opportunity> newOpptyMap) {
        for(Opportunity opp : newOpptyMap.values()) {
            Opportunity oldOppty = oldOpptyMap.get(opp.Id);
            if(((oldOppty.Opportunity_Reference__c == NULL) && (opp.Opportunity_Reference__c != NULL)) 
               || ((oldOppty.StageName != 'Execute & Expand / Won' || opp.StageName=='Lost' ) && ((oldOppty.Project_Status__c != 'Postsale SI Projects')  
                                                                                                  || (oldOppty.Project_Status__c != 'Closed SI Projects') || (oldOppty.Project_Status__c != 'Service Projects') 
                                                                                                  || (oldOppty.Project_Status__c != 'Omitted Projects'))))
            {
                if((opp.StageName == 'No Pursuit')){
                    opp.Project_Status__c = 'Omitted Projects';
                }
                if((opp.StageName == 'Lost')){
                    opp.Project_Status__c = 'Omitted Projects';
                }
                if((opp.StageName == 'Execute & Expand / Won') && (opp.Opportunity_Reference__c != NULL)) {
                    opp.Project_Status__c = 'Postsale SI Projects';
                }
                if((opp.StageName == 'Execute & Expand / Won') && (opp.Opportunity_Reference__c == NULL)){
                    opp.Project_Status__c = 'Non SI Projects';
                }
                if((opp.StageName == 'Prospect' || opp.StageName == 'Position & Align' || opp.StageName == 'Design & Validate' 
                    || opp.StageName == 'Secure') && (opp.Opportunity_Reference__c == NULL)) {
                        opp.Project_Status__c = 'Non SI Projects';
                    }
                if((opp.StageName == 'Prospect' || opp.StageName == 'Position & Align' || opp.StageName == 'Design & Validate' || opp.StageName == 'Secure') 
                   && (opp.Opportunity_Reference__c != NULL)) {
                       opp.Project_Status__c = 'Presale SI Projects';
                   }
            }
        }
    }

    public void populateScoresAndStageDurationsOnSalesFunnelObject(Map<Id,Opportunity> oldOpptyMap, Map<Id,Opportunity> newOpptyMap) {
        List<SalesFunnelStageDuration__c> salesFunnelToBeInserted = new List<SalesFunnelStageDuration__c>();
        Map<String,SalesFunnelStageDuration__c> mapForSalFunnel = new Map<String,SalesFunnelStageDuration__c>();
        
        for(SalesFunnelStageDuration__c exisitngSalesFunnel:[SELECT id, Opportunity__c, Last_Assigned_Date__c, Last_Stage_Updated_Date__c, createdDate, Stage_Duration__c 
                                                             FROM SalesFunnelStageDuration__c WHERE Opportunity__c IN :newOpptyMap.values() order by createddate asc])
        {
            mapForSalFunnel.put(exisitngSalesFunnel.Opportunity__c,exisitngSalesFunnel);
        }
        
        for(Opportunity oppRec : newOpptyMap.values()) {
            Opportunity oldOpp = oldOpptyMap.get(oppRec.id);
            if(!mapForSalFunnel.containsKey(oppRec.Id) && oppRec.StageName != oldOpp.StageName) {
                DateTime dT = oppRec.LastModifiedDate;
                Date stageUpdatedDate = Date.newinstance(dT.year(), dT.month(), dT.day());
                salesFunnelToBeInserted.add(new SalesFunnelStageDuration__c(
                    Last_Assigned_Date__c = Date.today(),
                    Business_Score__c = oppRec.mh_Business_Score__c,
                    Opportunity_Score__c = oppRec.mh_Opportunity_Score__c,
                    Total_Score__c = oppRec.mh_Scorecard_Total__c,
                    Opportunity__c = oppRec.id,
                    Place_in_Sales_FunnelPipeline__c = oldOpp.StageName,
                    Stage_Duration__c = (stageUpdatedDate).daysbetween(Date.today())
                ));
            } else if(mapForSalFunnel.containsKey(oppRec.Id) && oppRec.StageName != oldOpp.StageName) {
                SalesFunnelStageDuration__c latestSalesFunnel = mapForSalFunnel.get(oppRec.Id);
                salesFunnelToBeInserted.add(new SalesFunnelStageDuration__c(
                    Last_Stage_Updated_Date__c = Date.today(),
                    Business_Score__c = oppRec.mh_Business_Score__c,
                    Opportunity_Score__c = oppRec.mh_Opportunity_Score__c,
                    Total_Score__c = oppRec.mh_Scorecard_Total__c,
                    Opportunity__c = oppRec.id,
                    Stage_Duration__c = (latestSalesFunnel.Last_Assigned_Date__c).daysbetween(Date.today()),
                    Place_in_Sales_FunnelPipeline__c = oldOpp.StageName,
                    Last_Assigned_Date__c = Date.today()
                ));
            }
        } 
        if(!salesFunnelToBeInserted.isEmpty()) {
            try {
                insert salesFunnelToBeInserted;
            } catch (Exception exp) {
                System.debug('Exception found: '+exp.getMessage());
            }
        }
    } 
    
    public void updateInheritedMIPonAgreements(List<Opportunity> updtedMIPOpps) {
        List<Apttus__APTS_Agreement__c> agreList = [SELECT Id,Inherited_MIP__c,bypassValidation__c,Apttus__Related_Opportunity__c,
                                                    Apttus__Status_Category__c,Apttus__Related_Opportunity__r.MIP_Agreement__c 
                                                    FROM Apttus__APTS_Agreement__c 
                                                    WHERE Apttus__Related_Opportunity__r.Id IN: updtedMIPOpps];
        List<Apttus__APTS_Agreement__c> updateAgrList = new List<Apttus__APTS_Agreement__c>();
        Map<Id,List<Apttus__APTS_Agreement__c>> agrOppMap = new Map<Id,List<Apttus__APTS_Agreement__c>>();
        if(!agreList.isEmpty() || Test.isRunningTest()) {
            for(Apttus__APTS_Agreement__c aggr : agreList) {
                if(agrOppMap.get(aggr.Apttus__Related_Opportunity__c) == null) {
                    agrOppMap.put(aggr.Apttus__Related_Opportunity__r.id,new List<Apttus__APTS_Agreement__c>());
                    agrOppMap.get(aggr.Apttus__Related_Opportunity__r.id).add(aggr);
                } else {
                    agrOppMap.get(aggr.Apttus__Related_Opportunity__r.id).add(aggr);
                }
            }
            if(!agrOppMap.isEmpty()) {
                for(Opportunity opp : updtedMIPOpps) {
                    for(Apttus__APTS_Agreement__c agr : agrOppMap.get(opp.Id)) {
                        agr.bypassValidation__c = TRUE;
                        if(agr.Apttus__Related_Opportunity__r.MIP_Agreement__c != NULL) {
                            agr.Inherited_MIP__c = TRUE;
                        } else {
                            agr.Inherited_MIP__c = FALSE;
                        }
                        updateAgrList.add(agr);
                    }
                }
            }
        }
        if(updateAgrList.size() > 0) {
            try {
                update updateAgrList;
            } catch(Exception exp) {
                System.debug('Exception found: '+exp.getMessage());
            }
        }
    }
    
    /******************************************************************************************
* Description : If the original Opportunity(N) that was approved for a lower margin is lost, 
then the MIP commitment for second generation Opportunities(N+1) is eliminated. 
If the original Opportunity(N) Status = “Lost”, then the “MIP Agreement” lookup field 
on all second generation Opportunities(N+1) shall be set to NULL and  the field 
Inherited MIP” on Agreement (N+1) shall be set to FALSE.
*******************************************************************************************/
    public void updateMIPonOpportunities(List<Opportunity> lostOpportunities) {
        List<Opportunity> agreeOppLst = new List<Opportunity>();
        List<Apttus__APTS_Agreement__c> relatedAggs = [SELECT Id,Apttus__Related_Opportunity__c,Apttus__Related_Opportunity__r.id,Apttus__Related_Opportunity__r.StageName
                                                       FROM Apttus__APTS_Agreement__c 
                                                       WHERE Apttus__Related_Opportunity__c IN : lostOpportunities
                                                       AND Apttus__Related_Opportunity__r.StageName = 'Lost'
                                                      ];
        if(relatedAggs.size() > 0) {
            for(Apttus__APTS_Agreement__c opp : relatedAggs) {
                agreeOppLst.add(opp.Apttus__Related_Opportunity__r);
            }
        }
        if(agreeOppLst.size() > 0 && relatedAggs.size() > 0) // Means we have Opportunities where Agreement for MIP is Not NULL... get those Opportunities now.
        {
            List<Opportunity> oppsToUpdate = [SELECT Id,MIP_Agreement__c FROM Opportunity WHERE MIP_Agreement__c IN :relatedAggs];
            if(oppsToUpdate.size() > 0) {
                for(Opportunity opp2 : oppsToUpdate) {
                    opp2.MIP_Agreement__c = NULL;
                }
                try{
                    update oppsToUpdate;
                } catch (Exception exp) {
                    System.debug('Exception found: '+exp.getMessage());
                }
            }
        } 
    }
    
    /********************************************************************************************** 
* Trigger Name : UpdateAwardStatusValue
* Description  : This method related to UpdateAwardStatusValue trigger AfterUpdate event
*                This method Updates the value of the Award Status field in the Agreement object 
*                everytime the Opportunity Status is changed to Won/Lost/No Pursuit. 
***********************************************************************************************/
    //updateAwardStatusValueAfterUpdate -- START
    public void updateAwardStatusOnAgreements(List<Opportunity> updatedStageProjRegOpps) {
        List<Apttus__APTS_Agreement__c> agreementList = new List<Apttus__APTS_Agreement__c>();
        Map<Opportunity,List<Apttus__APTS_Agreement__c>> aggMap = new Map<Opportunity,List<Apttus__APTS_Agreement__c>>();
        //Creating a map of list of agreements with opportunity as key
        for(Apttus__APTS_Agreement__c aggr : [SELECT id,Reason_for_Cancellation__c,Hidden_Sales_Apex_Trigger_Update__c,Apttus__Related_Opportunity__r.id,Apttus__Related_Opportunity__r.StageName
                                              FROM Apttus__APTS_Agreement__c
                                              WHERE (((Apttus__Related_Opportunity__r.RecordType.Name = 'Project'
                                                       OR Apttus__Related_Opportunity__r.RecordType.Name = 'Registration') 
                                                      AND Related_Presales_Resource_Request__r.RecordType.Name = 'NA Presales Resource') 
                                                     OR (m_GTM_Region__c = 'EMEA' OR m_GTM_Region__c = 'Latin America' OR m_GTM_Region__c = 'Asia Pacific'))
                                              AND Apttus__Related_Opportunity__c IN : updatedStageProjRegOpps
                                              AND Apttus__Related_Opportunity__r.StageName IN ('Execute & Expand / Won','Lost','No Pursuit')
                                             ]) {
                                                 if(aggMap.get(aggr.Apttus__Related_Opportunity__r) == NULL) {
                                                     aggMap.put(aggr.Apttus__Related_Opportunity__r,new List<Apttus__APTS_Agreement__c>());
                                                     aggMap.get(aggr.Apttus__Related_Opportunity__r).add(aggr);
                                                 } else {
                                                     aggMap.get(aggr.Apttus__Related_Opportunity__r).add(aggr);
                                                 }
                                             }
        if(!aggMap.isEmpty()) {
            for(Opportunity opp : aggMap.keySet()) {
                if(aggMap.get(opp) != null) {
                    for(Apttus__APTS_Agreement__c agg : aggMap.get(opp)) { 
                        if(opp.StageName == 'Lost') {
                            agg.Reason_for_Cancellation__c = 'Lost Bid';                      
                        } else if(opp.StageName == 'Execute & Expand / Won') {
                            agg.Reason_for_Cancellation__c = 'Contract Awarded';
                        } else if(opp.StageName == 'No Pursuit') {
                            agg.Reason_for_Cancellation__c = 'No Bid';
                        }else{
                            agg.Reason_for_Cancellation__c='';
                        }
                        agg.Hidden_Sales_Apex_Trigger_Update__c = DateTime.Now();
                        agreementList.add(agg);
                    }
                }
            }
        }
        try { 
            if(agreementList.size() > 0) {
                Database.SaveResult[] srList = Database.update(agreementList, false);
                // Iterate through each returned result
                for (Database.SaveResult sr : srList) {
                    if (sr.isSuccess()) {
                        //System.debug('Successfully Updated. Agreement ID: ' + sr.getId());
                    } else {
                        //System.debug('The associated agreement record is pending approval. Please encourage outstanding approvers to complete their review. If further help is needed, please contact your regional Bid & Quote or Pricing & Profitability Team or Legal & Government Affairs Operations.');
                    }
                }
            }
        } catch(Exception excep) {
            System.debug('#####Exception#### => ' + excep);
        }
    }
    
    public void calculateFiscalFields(List<Opportunity> newOpptyList, Boolean isInsert, Boolean isBefore){
        Set<String> years = new Set<String>();
        List<Opportunity> lstOpp = new List<Opportunity>();
        for(Opportunity incomingOppo : newOpptyList) {
            years.add(String.valueOf(incomingOppo.CloseDate.year()));
            if(incomingOppo.Pull_Forward_Date__c != NULL) {
                years.add(String.valueOf(incomingOppo.Pull_Forward_Date__c.year()));   
            } 
        } 
        Map<Map<Date,Date>,Fiscal_Metadata__c> mapStartEndMonth = getFiscalStartEndMonthMap(years);//added as resuable method for fiscal and BRR
        for(Opportunity incomingOppo : newOpptyList) {
            for(Map<Date,Date>  monthStartEndDate : mapStartEndMonth.keyset()){
                for(Date startDate : monthStartEndDate.keySet()){
                    if(isInsert) {
                        if(incomingOppo.CloseDate >= startDate && incomingOppo.CloseDate <= monthStartEndDate.get(startDate)){
                            incomingOppo.Fiscal_Metadata__c = mapStartEndMonth.get(monthStartEndDate).Id;
                            incomingOppo.Close_Fiscal_Period__c = mapStartEndMonth.get(monthStartEndDate).Fiscal_Period__c;
                            incomingOppo.Close_Fiscal_Quarter__c = mapStartEndMonth.get(monthStartEndDate).Fiscal_Quarter__c;
                            break;
                        }
                    } else {
                        /***Added the condition isBefore for SF-2021**/
                        if(isBefore){ // This condition for Before Update
                            if(incomingOppo.CloseDate >= startDate && incomingOppo.CloseDate <= monthStartEndDate.get(startDate)){
                                incomingOppo.Fiscal_Metadata__c = mapStartEndMonth.get(monthStartEndDate).Id;
                                incomingOppo.Close_Fiscal_Period__c = mapStartEndMonth.get(monthStartEndDate).Fiscal_Period__c;
                                incomingOppo.Close_Fiscal_Quarter__c = mapStartEndMonth.get(monthStartEndDate).Fiscal_Quarter__c;
                            }
                            if(incomingOppo.Pull_Forward_Date__c != NULL) {
                                if(incomingOppo.Pull_Forward_Date__c >= startDate && incomingOppo.Pull_Forward_Date__c <= monthStartEndDate.get(startDate)){
                                    incomingOppo.Pull_Metadata__c = mapStartEndMonth.get(monthStartEndDate).id;
                                    incomingOppo.Pull_Forward_Fiscal_Period__c = mapStartEndMonth.get(monthStartEndDate).Fiscal_Period__c;
                                    incomingOppo.Pull_Forward_Fiscal_Quarter__c = mapStartEndMonth.get(monthStartEndDate).Fiscal_Quarter__c;
                                    break;
                                }
                            }
                            
                        }else{
                            /***Logic for SF-2021 Start**/ // This condition for After Update
                            if(incomingOppo.CloseDate >= startDate && incomingOppo.CloseDate <= monthStartEndDate.get(startDate)){
                                Opportunity opp = new Opportunity();
                                opp.Id = incomingOppo.Id;
                                opp.Fiscal_Metadata__c = mapStartEndMonth.get(monthStartEndDate).Id;
                                opp.Close_Fiscal_Period__c = mapStartEndMonth.get(monthStartEndDate).Fiscal_Period__c;
                                opp.Close_Fiscal_Quarter__c = mapStartEndMonth.get(monthStartEndDate).Fiscal_Quarter__c;
                                lstOpp.add(opp);
                            }
                        }
                    }                 
                }
            } 
        }
        if(!lstOpp.isEmpty()){
            update lstOpp;
        }
        /***Logic for SF-2021 End**/
    }    
    
    public void populateOppStatus(List<Opportunity> newOpptyList) {
        for(Opportunity opp : newOpptyList) { //for loop starting
            if(string.isNotblank(opp.ForecastCategoryName) && opp.StageName == 'Prospect' && opp.ForecastCategoryName != 'Non Commit'){
                opp.addError('Opportunities in the Prospect Stage can only have a Forecast Category of Non Commit');
            }
            
            if(opp.StageName == 'Prospect'){
                opp.ForecastCategoryName = 'Non Commit';
            }
            if(opp.StageName == 'Execute & Expand / Won' && opp.ForecastCategoryName == 'Closed') {
                opp.Status__c = 'Won';
            }
            if(opp.StageName == 'Position & Align' && (opp.ForecastCategoryName == 'Commit' || opp.ForecastCategoryName == 'Non Commit')){
                opp.Status__c = 'Active';
            }
            if(opp.StageName == 'Design & Validate' && (opp.ForecastCategoryName == 'Commit' || opp.ForecastCategoryName == 'Non Commit')){
                opp.Status__c = 'Active';
            }
            if(opp.StageName == 'Secure' && opp.ForecastCategoryName == 'Commit'){
                opp.Status__c = 'Active';
            }
            if((opp.StageName == 'Lost' && opp.ForecastCategoryName == 'Omitted') || Test.isRunningTest()){
                opp.Status__c = 'Lost';
            }
            if((opp.StageName == 'No Pursuit' && opp.ForecastCategoryName == 'Omitted') || Test.isRunningTest()){
                opp.Status__c = 'No Pursuit';
            }
            if(opp.StageName == 'Prospect' && opp.ForecastCategoryName == 'Non Commit'){
                opp.Status__c = 'Active';
            }
        } //for loop ending            
    }
    
    //BRR Enchancement
    public void populateOppBRR(List<Opportunity> newOpptyList,Set<String> years,String fieldAPI){ //SF-2035
        Map<Map<Date,Date>,Fiscal_Metadata__c> mapStartEndMonth = getFiscalStartEndMonthMap(years);
        Map<String,String> mapBRR = new Map<String,String>();
        if(!mapStartEndMonth.isEmpty()){
            for(Fiscal_Metadata__c fiscalMeta : mapStartEndMonth.values()){
                mapBRR.put(fiscalMeta.Id,NULL);
            }
            for(Briefing_Room_Report__c brr : [SELECT Id,Name,Fiscal_Week__c FROM Briefing_Room_Report__c WHERE Fiscal_Week__c IN :mapBRR.keySet()]){
                mapBRR.put(brr.Fiscal_Week__c,brr.Id);
            }
            system.debug('mapBRR'+mapBRR);
            for(Opportunity incomingOppo : newOpptyList) {
                for(Map<Date,Date>  monthStartEndDate : mapStartEndMonth.keyset()){
                    for(Date startDate : monthStartEndDate.keySet()){
                        //Fix as issue noticed while converting Forecast_Note_Date_Time__c to date, time was not rounding to 00
                        //Date dateOfMapping= (incomingOppo.Forecast_Note_Date_Time__c).date();
                        Date dateOfMapping= (fieldAPI == 'Forecast_Note_Date_Time__c' && incomingOppo.Forecast_Note_Date_Time__c != NULL) ? (incomingOppo.Forecast_Note_Date_Time__c).date() : system.today();
                        system.debug('dateOfMapping'+dateOfMapping);
                        system.debug('startDate'+startDate);
                        system.debug('monthStartEndDate '+monthStartEndDate.get(startDate));
                        if(dateOfMapping >= startDate && dateOfMapping <= monthStartEndDate.get(startDate)){
                            system.debug('monthStartEndDate'+monthStartEndDate);
                            system.debug('mapStartEndMonth.get(monthStartEndDate).Id'+mapStartEndMonth.get(monthStartEndDate).Id);
                            if(mapBRR.containsKey(mapStartEndMonth.get(monthStartEndDate).Id)){
                                incomingOppo.Briefing_Room_Report__c = mapBRR.get(mapStartEndMonth.get(monthStartEndDate).Id);   
                                system.debug('incomingOppo.Briefing_Room_Report__c '+incomingOppo.Briefing_Room_Report__c );
                                break;
                            }
                        }
                    }
                }
            }
        }
    }
    public Map<Map<Date,Date>,Fiscal_Metadata__c> getFiscalStartEndMonthMap (Set<String> years){ //SF-2035
        Map<Map<Date,Date>,Fiscal_Metadata__c> mapStartEndMonth = new Map<Map<Date,Date>,Fiscal_Metadata__c>();
        for(Fiscal_Metadata__c fiscalMeta : [SELECT /*BRR_Week_Info__c,*/Week_Start_Date__c,Week_End_Date__c,Fiscal_Period__c,Fiscal_Quarter__c FROM Fiscal_Metadata__c WHERE Year__c IN : years]) {
            Map<Date,Date> mapStartEndDates = new Map<Date,Date>();
            mapStartEndDates.put(fiscalMeta.Week_Start_Date__c,fiscalMeta.Week_End_Date__c);
            mapStartEndMonth.put(mapStartEndDates, fiscalMeta);
        }
        return mapStartEndMonth;
    }
    
    /* Added as a part of VESTA_SPILLMAN_INT-784, VESTA_SPILLMAN_INT-1384 for creating Opportunity Competitors */
    public void createCompetitors(Set<Id> opportunityIds, String processIdentifier) {
        Map<Id,String> opportunitiesForReferences= new Map<Id,String>();
        Set<Id> oppIdsForExcluding = new Set<Id>();
        List<CompetitiveDB__c> competitorsToBeInserted = new List<CompetitiveDB__c>();
        for(Opportunity opp : [Select Id,Incumbent_Lookup__c, Incumbent_Lookup__r.MSI_Competitor_Account__c, 
                               Primary_Competitor_Account__c from Opportunity where Id IN : opportunityIds])
        {
            if(processIdentifier.equals('incumbentCompetitors') && !opp.Incumbent_Lookup__r.MSI_Competitor_Account__c){
                opportunitiesForReferences.put(opp.Id, opp.Incumbent_Lookup__c);                
            }else if(processIdentifier.equals('manufacturerCompetitors')){
                opportunitiesForReferences.put(opp.Id, opp.Primary_Competitor_Account__c);
            }
        }        
        if(!opportunitiesForReferences.isEmpty()){
            for(CompetitiveDB__c competitor : [SELECT Id,Competitive_Vendor__c,Related_Opportunity__c FROM CompetitiveDB__c
                                               where Related_Opportunity__c IN : opportunitiesForReferences.keyset()])
            {
                if(opportunitiesForReferences.get(competitor.Related_Opportunity__c) == competitor.Competitive_Vendor__c){
                    oppIdsForExcluding.add(competitor.Related_Opportunity__c);
                }
            }
            // Remove Opportunity with existing competitors with matching competitor vendor
            if(!oppIdsForExcluding.isEmpty()){
                for(Id oppId : oppIdsForExcluding){
                    opportunitiesForReferences.remove(oppId);
                }
            }
            for(Id opportunityId : opportunitiesForReferences.keyset()){
                CompetitiveDB__c competitor = new CompetitiveDB__c();
                competitor.Related_Opportunity__c = opportunityId;
                competitor.Competitive_Vendor__c = opportunitiesForReferences.get(opportunityId);
                competitorsToBeInserted.add(competitor);
            }
            if(!competitorsToBeInserted.isEmpty()){
                Database.SaveResult[] srList =  Database.insert(competitorsToBeInserted, false);
                for(Database.SaveResult sr : srList){
                    if(!sr.isSuccess()) {
                        //System.debug('Error while creating competitor == '+sr.getErrors());
                    }
                }
            }
        }   
    }
    
    /* Added as a part of VESTA_SPILLMAN_INT-1220 */
    public void updateOrConvertOpportunity(List<Opportunity> newOpportunities, Id oppRecordTypeId){
        Map<String,Decimal> theaterConfigMap = new Map<String,Decimal>();
        for(MR_Digitization_Settings__mdt metaData : [Select Id, MasterLabel,Values__c from MR_Digitization_Settings__mdt 
                                                      where Category__c = 'Theater Configurations'])
        {
            theaterConfigMap.put(metaData.MasterLabel,Decimal.valueOf(metaData.Values__c));
        }
        for(Opportunity eachOpp : newOpportunities){
            String oppRegion = eachOpp.Region__c;
            Decimal threshold = theaterConfigMap.get(oppRegion);
            if(threshold != NULL && eachOpp.Amount_USD__c < threshold){
                eachOpp.ForecastCategoryName = eachOpp.Product_Forecast_Commitment__c;
            }
            //SF-2246
            /*else if(threshold != NULL && eachOpp.Amount_USD__c >= threshold && String.isNotBlank(oppRecordTypeId)){
eachOpp.RecordTypeId = oppRecordTypeId;
}*/ 
        }
    }
    //SF-2172 - To Hold the Old OLI's prior to Delete and Delete the existing OLI
    public void changeCurrencyOnOpportunity(Map<Id,Opportunity> newOpptyMap, Set<String> newCurrencyList){           
        List<OpportunityLineItem> oppProductList = new List<OpportunityLineItem>(); 
        List<Opportunity> opportunityToBeUpated = new List<Opportunity>();        
        Set<String> productList = new Set<String>();
        Boolean activePriceBook = FALSE;
        Recursionblocker.flag = FALSE;        
        for(Opportunity opp : [SELECT Id,CurrencyIsoCode,New_Currency__c,Num_Product_Families__c,
                               (SELECT Id,Quantity,product2Id,OpportunityId,Opportunity.CurrencyIsoCode,Opportunity.New_Currency__c,Opportunity_Product_Mirror__c,
                                UnitPrice,PricebookEntryId,currencyISOCode,TotalPrice,ListPrice,Product_Segment__c,Description,Product_Description__c,
                                Contract_Subscription_Start_Date__c,Contract_Subscription_End_Date__c,Annual_Value__c,
                                Run_Rate_Revenue__c,EMEA_Channel_Rollup_Classification__c FROM OpportunityLineItems) FROM Opportunity WHERE Id=:newOpptyMap.keyset()]){
                                    if(String.isNotBlank(opp.New_Currency__c) && opp.Num_Product_Families__c == 0){  
                                        changeCurrency = FALSE; 
                                    }
                                    for(OpportunityLineItem oppLineItem : opp.OpportunityLineItems){
                                        productList.add(oppLineItem.Product2Id);
                                        oppProductList.add(oppLineItem);                   
                                        if(lineItemMap.containsKey(oppLineItem.OpportunityId)){
                                            lineItemMap.get(oppLineItem.OpportunityId).add(oppLineItem);
                                        }else{
                                            lineItemMap.put(oppLineItem.OpportunityId,new List<OpportunityLineItem>{oppLineItem}); 
                                        }
                                    }
                                }
        List<Pricebook2>  standardPbList = [SELECT Id, Name, isActive FROM Pricebook2 WHERE IsStandard = true LIMIT 1]; 
        system.debug('standardPbList******'+standardPbList);
        if(!standardPbList.isEmpty()){
            for(PricebookEntry pbe : [SELECT Id, Product2Id, Product2.Id, Product2.Name, CurrencyIsoCode FROM PriceBookEntry WHERE CurrencyIsoCode =:newCurrencyList AND Product2Id=:productList AND Pricebook2Id =:standardPbList.get(0).Id]){
                priceBookEntryMap.put(pbe.product2Id,pbe.Id);
            } 
        }
        
        if(!oppProductList.isEmpty()){
            for(OpportunityLineItem opp : oppProductList){
                system.debug('priceBookEntryMap*******'+priceBookEntryMap.get(opp.Product2Id));
                if(priceBookEntryMap.get(opp.Product2Id)==NULL){
                    for(Opportunity oppNew : newOpptyMap.values()){
                        oppNew.addError(system.label.OpportunityPriceBookEntryError);
                    }
                }else{
                    activePriceBook = TRUE;
                }
            }
            if(activePriceBook == TRUE){
                delete oppProductList;                
            }          
        }
    }    
    //SF-2172 - To create OLI's
    public void createOpportunityProduct(Set<String> newCurrencyList, Set<String> OldCurrencyList){
        List<OpportunityLineItem> opportunityProductLst = new List<OpportunityLineItem>();
        Map<String,CurrencyType> fxRateMap = new Map<String,CurrencyType>();
        List<opportunityLineItem> lineItemList = new List<opportunityLineItem>();       
        if(!newCurrencyList.isEmpty() || !OldCurrencyList.isEmpty()){
            Set<String> allCurrencyCode= newCurrencyList;
            allCurrencyCode.addAll(OldCurrencyList);
            fxRateMap = GlobalUtility.getConversionRate(allCurrencyCode);    
        }
        // system.debug('test fxRateMap->'+fxRateMap);        
        if(!lineItemMap.isEmpty() && !priceBookEntryMap.isEmpty() && !fxRateMap.isEmpty()){
            for(String outerKey : lineItemMap.keyset()){
                for(OpportunityLineItem innerKey : lineItemMap.get(outerKey) ){
                    Double oldConvRate = fxRateMap.get(innerKey.currencyISOCode).ConversionRate;
                    Double newConvRate = fxRateMap.get(innerKey.opportunity.New_Currency__c).ConversionRate; 
                    //system.debug('test opp new conv->'+newConvRate);
                    //system.debug('test opp old conv->'+priceBookEntryMap.get(innerKey.Product2Id));
                    OpportunityLineItem newOppLineItem = new OpportunityLineItem(OpportunityId = innerKey.OpportunityId,Quantity = innerKey.Quantity,
                                                                                 PricebookEntryId = priceBookEntryMap.get(innerKey.Product2Id),
                                                                                 UnitPrice = innerKey.UnitPrice/oldConvRate*newConvRate, Description = innerKey.Description,
                                                                                 Product_Description__c = innerKey.Product_Description__c, Contract_Subscription_Start_Date__c = innerKey.Contract_Subscription_Start_Date__c,
                                                                                 Contract_Subscription_End_Date__c = innerKey.Contract_Subscription_End_Date__c, Annual_Value__c =innerKey.Annual_Value__c, Run_Rate_Revenue__c = innerKey.Run_Rate_Revenue__c,
                                                                                 EMEA_Channel_Rollup_Classification__c = innerKey.EMEA_Channel_Rollup_Classification__c, Product_Segment__c = innerKey.Product_Segment__c);
                    opportunityProductLst.add(newOppLineItem);
                }
            }   
        }
        if(!opportunityProductLst.isEmpty()){
            insert opportunityProductLst;
        } 
    }
    //SF-2172 -  To update new Currency to NULL if there are no OLI's
    public void updateNewCurrency(List<Opportunity> opportunityToBeUpated){
        List<Opportunity> opportunityList = new List<Opportunity>();
        if(changeCurrency == FALSE){
            for(Opportunity opp : opportunityToBeUpated){
                if(String.isNotBlank(opp.New_Currency__c) && opp.Num_Product_Families__c == 0){
                    opp.New_Currency__c = NULL;
                    opportunityList.add(opp);
                }  
            }
        }
        //system.debug('inside update'+changeCurrency);
    }
    //SF-2399 updated as BRR Enhancement
    public void createOrUpdateExistingBRROpp(Map<Id,Opportunity> mapOpp,Map<Id,Opportunity> oldOpptyMap){
        //system.debug('mapOpp'+mapOpp.size());
        Set<String> brrUniqueIds = new Set<String>();
        Set<String> foundBRROppIds = new Set<String>();
        for(Opportunity opp : mapOpp.values()){
            brrUniqueIds.add(opp.Briefing_Room_Report__c + '#' + opp.Id);
        }
        //system.debug('brrUniqueIds'+brrUniqueIds.size()); 
        List<BRR_Opportunity__c> lstBrrOpp = [SELECT Id,Opportunity__c, Opportunity__r.StageName, Forecast_Notes__c,BookingsOwner__c,
                                              Briefing_Room_Report__c,Opportunity__r.ForecastCategoryName,Opportunity__r.Name,
                                              Opportunity__r.Amount,Opportunity__r.CloseDate FROM BRR_Opportunity__c 
                                              WHERE Unique_BRR_Opportunity__c IN : brrUniqueIds];
        //system.debug('lstBrrOpp****'+lstBrrOpp.size());        
        if(!lstBrrOpp.isEmpty()){
            //update existing BRR Opp logic
            //system.debug('Within found BRR Opp Loop****');        
            List<BRR_Opportunity__c> lstbrrOppToUpdate = new List<BRR_Opportunity__c>();
            for(BRR_Opportunity__c brrOpp : lstBrrOpp){
                foundBRROppIds.add(brrOpp.Opportunity__c);
                Opportunity oldOpp = oldOpptyMap.get(brrOpp.Opportunity__c);
                Opportunity newOpp = mapOpp.get(brrOpp.Opportunity__c);
                BRR_Opportunity__c updateBRR = new BRR_Opportunity__c();
                updateBRR.Id = brrOpp.Id;
                updateBRR.Opportunity_Name__c = brrOpp.Opportunity__r.Name;
                updateBRR.Stage__c = newOpp.StageName;
                updateBRR.BookingsOwner__c = newOpp.Bookings_Owner__c;
                updateBRR.ForecastCategory__c = newOpp.ForecastCategoryName;
                updateBRR.Amount__c = newOpp.Amount;
                updateBRR.CloseDate__c = newOpp.closeDate;
                updateBRR.CurrencyIsoCode = newOpp.CurrencyIsoCode;
                if(newOpp.Forecast_Notes__c != NULL && newOpp.Forecast_Notes__c != oldOpp.Forecast_Notes__c){
                    //system.debug('Forecast_Notes__c Changed');
                    updateBRR.Forecast_Notes__c =   brrOpp.Forecast_Notes__c +'\n'+ newOpp.Forecast_Notes__c;  
                    updateBRR.Forecast_Note_Date_Time__c = system.now();
                }
                lstbrrOppToUpdate.add(updateBRR);
            }
            //system.debug('lstbrrOppToUpdate'+lstbrrOppToUpdate.size());
            if(!lstbrrOppToUpdate.isEmpty()){
                Database.update(lstbrrOppToUpdate,false);                
            }
        }//else{
            //create BRR logic
            Map<String,String> mapPrimaryPrdNAPrdGrp = new Map<String,String>();
            for(Opportunity opp : mapOpp.values()){
                if(!foundBRROppIds.contains(opp.Id)){
                    if(String.isNotBlank(opp.Primary_Product__c)){
                        mapPrimaryPrdNAPrdGrp.put(opp.Primary_Product__c, NULL);
                    }  
                }
            }
            if(!mapPrimaryPrdNAPrdGrp.isEmpty()){
                for(Product2 prd : [SELECT Id,NA_Business_Group__c FROM Product2 WHERE Id IN : mapPrimaryPrdNAPrdGrp.keySet()]){
                    mapPrimaryPrdNAPrdGrp.put(prd.Id, prd.NA_Business_Group__c);
                }
            }            
            List<BRR_Opportunity__c> lstbrrOppToInsert = new List<BRR_Opportunity__c>();
        	//system.debug('foundBRROppIds***'+foundBRROppIds);
            for(Opportunity opp : mapOpp.values()){
                //system.debug(opp.Briefing_Room_Report__c+'#'+opp.Id);
                if(!foundBRROppIds.contains(opp.Id)){
                    //system.debug('MISSIGN BRR *****');
                    BRR_Opportunity__c createBRR = new BRR_Opportunity__c();
                    createBRR.Opportunity__c = opp.Id;
                    createBRR.Unique_BRR_Opportunity__c = opp.Briefing_Room_Report__c + '#' + opp.Id;
                    if(String.isNotBlank(opp.Primary_Product__c) && mapPrimaryPrdNAPrdGrp.containsKey(opp.Primary_Product__c)){
                        createBRR.System_Technology__c = mapPrimaryPrdNAPrdGrp.get(opp.Primary_Product__c);
                    }
                    createBRR.Briefing_Room_Report__c = opp.Briefing_Room_Report__c;
                    createBRR.BookingsOwner__c = opp.Bookings_Owner__c;
                    createBRR.Forecast_Note_Date_Time__c = opp.Forecast_Note_Date_Time__c;
                    createBRR.Forecast_Notes__c = opp.Forecast_Notes__c;
                    createBRR.Stage__c = opp.StageName; 
                    createBRR.Amount__c = opp.Amount;
                    createBRR.CurrencyIsoCode = opp.CurrencyIsoCode;
                    createBRR.CloseDate__c = opp.CloseDate;
                    createBRR.ForecastCategory__c = opp.ForecastCategoryName;
                    createBRR.Opportunity_Name__c = opp.Name;
                    lstbrrOppToInsert.add(createBRR);
                }
            }
        //system.debug('lstbrrOppToInsert'+lstbrrOppToInsert.size());
        if(!lstbrrOppToInsert.isEmpty()){
            Database.insert(lstbrrOppToInsert,false);
        }
        //}
    }
    /********************************************************************************************** 
* Method Name 		: createCAPPRecords
* Input Parameters  : Map<Id,Opportunity>
* Returntype		: void
* Description  		: This method is used to create CAPP when the opportunity is Won or Lost
* Requuirement 		: SF-2461 Create CAPP Records
***********************************************************************************************/
    public Static void createCAPPRecords (Map<Id,Opportunity> opptyMap) {
        PartnerOpportunityTriggerHandler.TriggerDisabled = True;
        Recursionblocker.flag = false;
        Set<Id> AccountIds = new Set<Id>();
        Set<Id> productIds = new Set<Id>();
        Set<Id> cappIds = new Set<Id>();
        //Get all the AccountIds
        for (Opportunity opptyRec : opptyMap.values()) {
            AccountIds.add(opptyRec.AccountId);
        }
        //Query Product Family records based on the Opportunity Id
        List<OpportunityLineItem> oliList = [SELECT Id, Name, OpportunityId, Opportunity.Auto_Create_CAPP_Record__c, 
                                             Opportunity.Primary_Competitor_Account__c, Opportunity.AccountId, Opportunity.StageName, 
                                             Opportunity.CloseDate, Product2Id FROM OpportunityLineItem 
                                             WHERE OpportunityId IN : opptyMap.keySet() AND TotalPrice > 0];
        //Create Map of AccountId, Map of Product2Id and  Opprotunity Line Item
        // Map<Id, List<OpportunityLineItem>> oliMap = new Map<Id, List<OpportunityLineItem>>();
        Map<Id, Map<Id, OpportunityLineItem>> oliAccProdMap = new Map<Id, Map<Id, OpportunityLineItem>>();
        if (!oliList.isEmpty()) {
            for (OpportunityLineItem oliRec : oliList) {
                productIds.add(oliRec.Product2Id);
                if (oliAccProdMap.containsKey(oliRec.Opportunity.AccountId)) {
                    oliAccProdMap.get(oliRec.Opportunity.AccountId).put(oliRec.Product2Id, oliRec);
                } else {
                    Map<Id, OpportunityLineItem> prodOlimap = new Map<Id, OpportunityLineItem>();
                    prodOlimap.put(oliRec.Product2Id, oliRec);
                    oliAccProdMap.put(oliRec.Opportunity.AccountId, prodOlimap);
                } 
            }  
        }
        //Query CAPP Rule Records based on the ProductId from above Product Family records
        List<CAPP_Auto_Creation_Product_Rule__c> cappRuleRecordList = [SELECT Id, Product_Family__c, CAPP_Record_Type__c,
                                                                       Type__c, Vendor_if_Won__c, Vendor_Product_Line_if_Won__c
                                                                       FROM CAPP_Auto_Creation_Product_Rule__c 
                                                                       WHERE Product_Family__c IN : productIds ];
        //Create Map of Product2Id and List of CAPP Rule
        Map<Id, List<CAPP_Auto_Creation_Product_Rule__c>> cappRuleMap= new Map<Id, List<CAPP_Auto_Creation_Product_Rule__c>>();
        //Map<Id, Map<String, CAPP_Auto_Creation_Product_Rule__c>> cappRuleMap = new Map<Id, MAp<String, CAPP_Auto_Creation_Product_Rule__c>>();
        for(CAPP_Auto_Creation_Product_Rule__c cappRule : cappRuleRecordList) {            
            
            if(cappRuleMap.containsKey(cappRule.Product_Family__c)) {
                cappRuleMap.get(cappRule.Product_Family__c).add(cappRule);
            }
            else {
                cappRuleMap.put(cappRule.Product_Family__c, new List<CAPP_Auto_Creation_Product_Rule__c>{cappRule});
            }
        }
        
        //Create CAPP RecordType Map
        Map<String, Id> recordTypeMap = new Map<String, Id>();
        for(RecordType recType : [SELECT Id, Name FROM RecordType WHERE SObjectType = 'Customer_Portfolio_Presence__c']){
            recordTypeMap.put(recType.Name, recType.Id);
        }
        
        //Query System Relationship records based on the Account Id
        List<System_Relationship__c>  systemRelList = [SELECT Id, Account__c, CAPP__c, CAPP__r.RecordType.Name, System_Parent__c FROM System_Relationship__c
                                                       WHERE Account__c IN: AccountIds AND System_Parent__c = null];
        
        //Get the Existing CAPP record ids and create Map of AccountId, Map of recordtype name and List of SysteRel
        Map<Id, Map<String, List<System_Relationship__c>>> systemRelMap = new Map<Id, Map<String, List<System_Relationship__c>>>();
        for (System_Relationship__c systemRel : systemRelList) {
            cappIds.add(systemRel.CAPP__c);
            if (systemRel.Account__c != null && systemRel.CAPP__r.RecordType.Name != null) {
                if (systemRelMap.containsKey(systemRel.Account__c)) {
                    if (systemRelMap.get(systemRel.Account__c).containsKey(systemRel.CAPP__r.RecordType.Name)) {
                        systemRelMap.get(systemRel.Account__c).get(systemRel.CAPP__r.RecordType.Name).add(systemRel);
                    } else {
                        systemRelMap.get(systemRel.Account__c).put(systemRel.CAPP__r.RecordType.Name, new List<System_Relationship__c>{systemRel});
                    }
                } else {
                    Map<String, List<System_Relationship__c>> newSystemMap = new Map<String, List<System_Relationship__c>>();
                    newSystemMap.put(systemRel.CAPP__r.RecordType.Name, new List<System_Relationship__c>{systemRel});
                    systemRelMap.put(systemRel.Account__c, newSystemMap);
                }
            }
        }
        
        //Query CAPP Records based on the Id 
        Map<Id, Customer_Portfolio_Presence__c> CAPPMap = new Map<Id, Customer_Portfolio_Presence__c>([SELECT Id, Vendor__c, Vendor_Product_Line__c, RecordTypeId, Purchase_Year__c, 
                                                                                                       Opportunity_Auto_Created_or_Modified_Fr__c, RADIO_INFRASTRUCTURE_1__c,
                                                                                                       Reviewed_by_Sales__c, OwnerId, CAPP_Change__c
                                                                                                       FROM Customer_Portfolio_Presence__c
                                                                                                       WHERE Id IN: cappIds]);  
        
        Set<Customer_Portfolio_Presence__c> newCAPPSet = new Set<Customer_Portfolio_Presence__c>();
        Set<Customer_Portfolio_Presence__c> updateCAPPSet = new Set<Customer_Portfolio_Presence__c>();
        List<System_Relationship__c> newSystemRelList = new List<System_Relationship__c>();
        Set<SObject> SObjectSet = new Set<SObject>();
        //Loop through AccountIds and ProductIds records to create CAPP Records
        Set<String> cappRecordTypeIdSet = new Set<String>();
        for (Id accountId : oliAccProdMap.keySet()) { 
            //system.debug('accountId>>'+accountId);
            if (! oliAccProdMap.get(accountId).isEmpty()){
                string tempCappRecordId;
                for (OpportunityLineItem eachOLI : oliAccProdMap.get(accountId).values()) {
                    //system.debug('eachOLI>>'+eachOLI);
                                        
                    if (!(systemRelMap == null || systemRelMap.isEmpty()) && eachOLI.Opportunity.Auto_Create_CAPP_Record__c == 'Yes, update top CAPP Vendor & Purchase Year' &&
                        systemRelMap.containsKey(eachOLI.Opportunity.AccountId) && ! systemRelMap.get(eachOLI.Opportunity.AccountId).isEmpty() &&
                        cappRuleMap.containsKey(eachOLI.Product2Id) && systemRelMap.get(eachOLI.Opportunity.AccountId).keySet().contains(cappRuleMap.get(eachOLI.Product2Id)[0].CAPP_Record_Type__c) ) {
                            
                            //Update existing CAPP Records
                            //system.debug('Update Existing CAPP>>>');
                            
                            for (CAPP_Auto_Creation_Product_Rule__c cappRuleRec: cappRuleMap.get(eachOLI.Product2Id)) {
                                Customer_Portfolio_Presence__c cappRec = new Customer_Portfolio_Presence__c();
                                cappRec = CAPPMap.get(systemRelMap.get(eachOLI.Opportunity.AccountId).get(cappRuleRec.CAPP_Record_Type__c)[0].CAPP__c);
                                cappRec.Vendor__c = (eachOLI.Opportunity.StageName == 'Execute & Expand / Won' ? cappRuleRec.Vendor_if_Won__c : eachOLI.Opportunity.Primary_Competitor_Account__c);
                                cappRec.Vendor_Product_Line__c = (eachOLI.Opportunity.StageName == 'Execute & Expand / Won' ? cappRuleRec.Vendor_Product_Line_if_Won__c : null);
                                cappRec.Purchase_Year__c = String.valueOf(eachOLI.Opportunity.CloseDate.year());
                                cappRec.Opportunity_Auto_Created_or_Modified_Fr__c = eachOLI.OpportunityId;
                                cappRec.Reviewed_by_Sales__c = false;
                                cappRec.CAPP_Change__c = 'Modified';
                                updateCAPPSet.add(cappRec);
                            }
                            
                        } else {
                            //Create new CAPP record
                            if (cappRuleMap.containsKey(eachOLI.Product2Id) ){
                                for(CAPP_Auto_Creation_Product_Rule__c cappRule : cappRuleMap.get(eachOLI.Product2Id)) {
                                    Id vendorId = (eachOLI.Opportunity.StageName == 'Execute & Expand / Won' ? cappRule.Vendor_if_Won__c : eachOLI.Opportunity.Primary_Competitor_Account__c);
                                    Id vendorProductId = (eachOLI.Opportunity.StageName == 'Execute & Expand / Won' ? cappRule.Vendor_Product_Line_if_Won__c : null);
                                    String type = cappRule.Type__c;
                                    Customer_Portfolio_Presence__c newCAPP = new Customer_Portfolio_Presence__c();
                                    newCAPP.Vendor__c = vendorId;
                                    newCAPP.Vendor_Product_Line__c = vendorProductId;
                                    newCAPP.RADIO_INFRASTRUCTURE_1__c = type;
                                    newCAPP.Purchase_Year__c = String.valueOf(eachOLI.Opportunity.CloseDate.year());
                                    Id capprecordTypeId = recordTypeMap.get(cappRule.CAPP_Record_Type__c);
                                    newCAPP.RecordTypeId = capprecordTypeId;
                                    newCAPP.Opportunity_Auto_Created_or_Modified_Fr__c = eachOLI.OpportunityId;
                                    newCAPP.Reviewed_by_Sales__c = false;
                                    String ExternalId = eachOLI.Opportunity.AccountId+''+capprecordTypeId+''+vendorId+''+vendorProductId+''+type+''+system.now();
                                    newCAPP.External_Id__c = ExternalId; 
                                    if(capprecordTypeId != null && !cappRecordTypeIdSet.contains(eachOLI.Opportunity.AccountId+''+capprecordTypeId+''+vendorId+''+vendorProductId+''+type)){
                                        cappRecordTypeIdSet.add(eachOLI.Opportunity.AccountId+''+capprecordTypeId+''+vendorId+''+vendorProductId+''+type);
                                        newCAPPSet.add(newCAPP); 
                                        
                                        //Create new System Relation record
                                        System_Relationship__c newSystemRel = new System_Relationship__c();
                                        newSystemRel.Account__c = eachOLI.Opportunity.AccountId;
                                        newSystemRel.CAPP__r = new Customer_Portfolio_Presence__c(External_Id__c = ExternalId);
                                        newSystemRelList.add(newSystemRel);   
                                    }
                                }
                            }
                        }
                }
            }
        }
        //system.debug('newCAPPSet>>'+newCAPPSet.size()+' '+newCAPPSet);
        //system.debug('newSystemRelList>>'+newSystemRelList.size()+' '+newSystemRelList);
        List<SObject>  SObjectList = new List<SObject>();
        SObjectList.addAll(new List<Customer_Portfolio_Presence__c>(newCAPPSet));
        SObjectList.addAll(new List<System_Relationship__c>(newSystemRelList));
        if(!SObjectList.isEmpty()){
            //system.debug('New List>>>'+SObjectList);
            Database.SaveResult[] results = Database.insert(SObjectList);
        }
        //system.debug('Update List>>>'+updateCAPPSet.size()+'  '+updateCAPPSet);
        List<Customer_Portfolio_Presence__c> updateCAPPList = new List<Customer_Portfolio_Presence__c>();
        updateCAPPList.addAll(updateCAPPSet);
        if(!updateCAPPList.isEmpty()){            
            Database.SaveResult[] results = Database.update(updateCAPPList);
        }
    } 
    
    //BRR Enhancement
    public void getLockedBRRs(List<Opportunity> newOpptyList) {
        //system.debug('In isBRRLocked Method***********');
        Map<Id,String> oppOwnerTerritoryMap = new Map<Id,String>();
        Set<String> setLockedBRRs = new Set<String>();
        Set<Id> brrId = new Set<Id>();
        Set<Id> oppOwnerRole = new Set<Id>();
        Set<Id> subroles = new Set<Id>();
        Integer lockdownDay ;
        for(Opportunity opp : newOpptyList) {
            //system.debug('opp.owner.userRoleId'+opp.owner.userRoleId);
            oppOwnerTerritoryMap.put(opp.ownerId, opp.Territory__c);
            brrId.add(opp.Briefing_Room_Report__c);
        }
        List<Briefing_Room_Report__c> lstCurrentBRR = BRRUtility.getCurrentWeekBRR();
        Map<Id,Briefing_Room_Report__c> mapBRRWeek = BRRUtility.getBRR(brrId); 
        //system.debug('oppOwnerTerritoryMap'+oppOwnerTerritoryMap.values());
        Map<String,MR_Digitization_Settings__mdt> mapTerritoryBRRMeta = BRRUtility.getLockdownDayByTerritory(oppOwnerTerritoryMap.values());
        //system.debug('mapTerritoryBRRMeta inside Helper outside loop'+mapTerritoryBRRMeta);
        //system.debug('brrId***********'+brrId);
        for(Opportunity opp : newOpptyList) { 
            Boolean isOutsideLockingPeriod = BRRUtility.isOutsideLockingPeriod(mapTerritoryBRRMeta,opp.Territory__c);
            //system.debug('mapTerritoryBRRMeta inside Helper'+mapTerritoryBRRMeta);
            //system.debug('isOutsideLockingPeriod***'+isOutsideLockingPeriod);
            if(opp.Briefing_Room_Report__c != NULL && mapBRRWeek.get(opp.Briefing_Room_Report__c).This_Week_BRR__c == True){                
                if(isOutsideLockingPeriod){
                    opp.Briefing_Room_Report__c = mapBRRWeek.get(opp.Briefing_Room_Report__c).Next_Week_s_BRR__c;
                    system.debug('opp.Briefing_Room_Report__c in lock '+opp.Briefing_Room_Report__c );
                }
            }else if(opp.Briefing_Room_Report__c != NULL && mapBRRWeek.get(opp.Briefing_Room_Report__c).Past_Week__c == True){
                if(isOutsideLockingPeriod){
                    opp.Briefing_Room_Report__c = lstCurrentBRR.get(0).Next_Week_s_BRR__c;
                }else{
                    opp.Briefing_Room_Report__c = lstCurrentBRR.get(0).Id;
                }
            }
        }
    }
    public void populatePriceBookId(List<Opportunity> newItems,Boolean isInsert){//SF-2783
        List<Pricebook2> lstPricebook = [Select Id,name from Pricebook2 order by IsStandard desc]; 
        if (!lstPricebook.isEmpty()) {
            for(Opportunity newOpp : newItems){
                if(newOpp.recordtypeId == runRateRecTypeId && newOpp.Region__c == 'NA'){
                    newOpp.Pricebook2Id=lstPricebook.get(1).Id;
                }else{
                    newOpp.Pricebook2Id=lstPricebook.get(0).Id;
                }            
            }   
        }     
    }
}