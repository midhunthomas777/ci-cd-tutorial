/*  
* File Name  : Funnel_Score_Card_Ctrl1_CalculateScore
* Description: This Code is the controller class for the Visualforce page "Funnel score Card 1". 
In this class, the scores are calculated and published. 
* Author     : Vishal Rao Jujaray - Infosys Technologies Limited
* Modification Log 
* ============================================================================= 
* Ver   Date        Author                         Modification 
* -----------------------------------------------------------------------------------------------------------------------------------------
* 1.0   08-Feb-12   Vishal Rao Jujaray              Initial Code
* 
*/


public class Funnel_Score_Card_Ctrl1_CalculateScore{    
    id currentPgId = ApexPages.currentPage().getParameters().get('oppid');  
    
    //SF-1804 - -Miller Heiman legacy Fields Replacement
    public Opportunity Oppty = [select id,Amount,AccountId, name,mh_Business_Score__c,mh_Opportunity_Score__c,
                                //Commented for Salesstage changes//
                                //FSC_Total_Score__c, StageName,Project_Name__c,OwnerId,
                                //Removed Status__c field from below SOQL query by Satish as part of SF-1235
                                mh_Scorecard_Total__c, StageName,Project_Name__c,OwnerId,
                                CloseDate,mh_Place_in_Sales_Funnel__c
                                from Opportunity where id=:currentPgId limit 1];
    public Integer BusinessScore=0 ;
    public Integer OpportunityScore=0 ;
    public Integer TotalScore=0 ;
    public Funnel_ScoreCard__c FSCRecord;   
    public Boolean RecordAlreadyExistsFlag;
    
    public Id FSCId=null;
    public boolean ShowMeInEditMode{
        get{
            if(ShowMeInEditMode == null){
                ShowMeInEditMode= True;
            }
            return ShowMeInEditMode;
        }
        set;
    }
    
    public string value;
    //public Opportunity Opportunity {get;set;}
    //private final Funnel_ScoreCard__c fscRecord;
    
    public Funnel_Score_Card_Ctrl1_CalculateScore(ApexPages.StandardController controller) {
        
        Funnel_ScoreCard__c[] FSCardRecord = [select Id,F1_BQ1__c,F1_BQ2__c,F1_BQ3__c,F1_BQ4__c,F1_BQ5__c,F1_BQ6__c,F1_BQ7__c,F1_BQ8__c,F1_BQ9__c,F1_BQ10__c,
                                              F1_OQ1__c,F1_OQ2__c,F1_OQ3__c,F1_OQ4__c,F1_OQ5__c,F1_OQ6__c,F1_OQ7__c,F1_OQ8__c,F1_OQ9__c,F1_OQ10__c,
                                              F1_Business_Score__c,F1_Opportunity_Score__c, F1_Total_Score__c,
                                              opportunity__r.stagename
                                              from Funnel_ScoreCard__c where Opportunity__c =: Oppty.id ];            
        
        system.debug('***opp values **');                                        
        fscRecord = (Funnel_ScoreCard__c)controller.getRecord();
        
        if(FSCardRecord.isEmpty()){
            RecordAlreadyExistsFlag = false;
            system.debug('###'+RecordAlreadyExistsFlag);
        }       
        
        else {
            RecordAlreadyExistsFlag=true;
            system.debug('$$$'+RecordAlreadyExistsFlag);
            
            FSCId = FSCardRecord[0].Id;
            system.debug('***opp values **'+oppty); 
            fscRecord.opportunity__r = oppty;
            fscRecord.F1_BQ1__c = FSCardRecord[0].F1_BQ1__c;
            fscRecord.F1_BQ2__c = FSCardRecord[0].F1_BQ2__c;
            fscRecord.F1_BQ3__c = FSCardRecord[0].F1_BQ3__c;
            fscRecord.F1_BQ4__c = FSCardRecord[0].F1_BQ4__c;
            fscRecord.F1_BQ5__c = FSCardRecord[0].F1_BQ5__c;
            fscRecord.F1_BQ6__c = FSCardRecord[0].F1_BQ6__c;
            fscRecord.F1_BQ7__c = FSCardRecord[0].F1_BQ7__c;
            fscRecord.F1_BQ8__c = FSCardRecord[0].F1_BQ8__c;
            fscRecord.F1_BQ9__c = FSCardRecord[0].F1_BQ9__c;
            fscRecord.F1_BQ10__c = FSCardRecord[0].F1_BQ10__c;
            fscRecord.F1_Business_Score__c = FSCardRecord[0].F1_Business_Score__c;
            BusinessScore = (integer) FSCardRecord[0].F1_Business_Score__c;
            
            
            fscRecord.F1_OQ1__c = FSCardRecord[0].F1_OQ1__c;
            fscRecord.F1_OQ2__c = FSCardRecord[0].F1_OQ2__c;
            fscRecord.F1_OQ3__c = FSCardRecord[0].F1_OQ3__c;
            fscRecord.F1_OQ4__c = FSCardRecord[0].F1_OQ4__c;
            fscRecord.F1_OQ5__c = FSCardRecord[0].F1_OQ5__c;
            fscRecord.F1_OQ6__c = FSCardRecord[0].F1_OQ6__c;
            fscRecord.F1_OQ7__c = FSCardRecord[0].F1_OQ7__c;
            fscRecord.F1_OQ8__c = FSCardRecord[0].F1_OQ8__c;
            fscRecord.F1_OQ9__c = FSCardRecord[0].F1_OQ9__c;
            fscRecord.F1_OQ10__c = FSCardRecord[0].F1_OQ10__c;
            fscRecord.F1_Opportunity_Score__c = FSCardRecord[0].F1_Opportunity_Score__c;
            fscRecord.F1_Total_Score__c = FSCardRecord[0].F1_Total_Score__c;
            
            OpportunityScore = (integer) FSCardRecord[0].F1_Opportunity_Score__c;
            TotalScore = (integer)FSCardRecord[0].F1_Total_Score__c;
            
            //Sales Stage alignment change start   --Abhilash Govinda 16-May-13              
            // if(Oppty.StageName =='Closed Won' ||Oppty.StageName =='Closed Lost'  || Oppty.StageName =='Closed Other' ||Oppty.StageName =='Secure' ){                
            if(Oppty.StageName<>'Active' ){  //Changed from status__c to StageName
                ShowMeInEditMode=false;           
            }     
        }               
        // if(Oppty.StageName =='Closed Won' ||Oppty.StageName =='Closed Lost'  || Oppty.StageName =='Closed Other' ||Oppty.StageName =='Secure' ){            
        if(Oppty.StageName<>'Active' ){        
            ShowMeInEditMode=false;              
            //Sales Stage alignment change end         
        }
    }
    
    
    //public pagereference CalculateScore(){
    public void CalculateScore(){
        BusinessScore=0;
        OpportunityScore=0;
        TotalScore=0;
        
        if(fscRecord.F1_BQ1__c == 'Yes'){
            BusinessScore = BusinessScore+8;
        }
        if(fscRecord.F1_BQ2__c == 'Yes'){
            BusinessScore = BusinessScore+7;
        }
        if(fscRecord.F1_BQ3__c == 'Yes'){
            BusinessScore = BusinessScore+7;
        }
        if(fscRecord.F1_BQ4__c == 'Yes'){
            BusinessScore = BusinessScore+6;
        }
        if(fscRecord.F1_BQ5__c == 'Yes'){
            BusinessScore = BusinessScore+5;
        }
        if(fscRecord.F1_BQ6__c == 'Yes'){
            BusinessScore = BusinessScore+4;
        }
        if(fscRecord.F1_BQ7__c == 'Yes'){
            BusinessScore = BusinessScore+4;
        }
        if(fscRecord.F1_BQ8__c == 'Yes'){
            BusinessScore = BusinessScore+5;
        }
        if(fscRecord.F1_BQ9__c == 'Yes'){
            BusinessScore = BusinessScore+2;
        }
        if(fscRecord.F1_BQ10__c == 'Yes'){
            BusinessScore = BusinessScore+2;
        }
        
        if(fscRecord.F1_OQ1__c == 'Yes'){
            OpportunityScore = OpportunityScore+7;
        }
        if(fscRecord.F1_OQ2__c == 'Yes'){
            OpportunityScore = OpportunityScore+7;
        }
        if(fscRecord.F1_OQ3__c == 'Yes'){
            OpportunityScore = OpportunityScore+3;
        }
        if(fscRecord.F1_OQ4__c == 'Yes'){
            OpportunityScore = OpportunityScore+7;
        }
        if(fscRecord.F1_OQ5__c == 'Yes'){
            OpportunityScore = OpportunityScore+5;
        }
        if(fscRecord.F1_OQ6__c == 'Yes'){
            OpportunityScore = OpportunityScore+5;
        }
        if(fscRecord.F1_OQ7__c == 'Yes'){
            OpportunityScore = OpportunityScore+5;
        }
        if(fscRecord.F1_OQ8__c == 'Yes'){
            OpportunityScore = OpportunityScore+5;
        }
        if(fscRecord.F1_OQ9__c == 'Yes'){
            OpportunityScore = OpportunityScore+3;
        }
        if(fscRecord.F1_OQ10__c == 'Yes'){
            OpportunityScore = OpportunityScore+3;
        }
        
        
        system.debug('Check Point BusinessScore :'+BusinessScore);
        system.debug('Check Point OpportunityScore :'+OpportunityScore);
        system.debug('Check Point TotalScore :'+TotalScore);            
        TotalScore=BusinessScore + OpportunityScore;
        
        //fscRecord.F1_Business_Score__c = BusinessScore;
        //fscRecord.F1_Opportunity_Score__c = OpportunityScore;
        //fscRecord.F1_Total_Score__c = TotalScore;
        
        //return null;
    }  
    
    public PageReference saveAndContinue(){
        
        Funnel_ScoreCard__c[] FSCardRecord = [select Id,F1_BQ1__c,F1_BQ2__c,F1_BQ3__c,F1_BQ4__c,F1_BQ5__c,F1_BQ6__c,F1_BQ7__c,F1_BQ8__c,F1_BQ9__c,F1_BQ10__c,
                                              F1_OQ1__c,F1_OQ2__c,F1_OQ3__c,F1_OQ4__c,F1_OQ5__c,F1_OQ6__c,F1_OQ7__c,F1_OQ8__c,F1_OQ9__c,F1_OQ10__c,
                                              F1_Business_Score__c,F1_Opportunity_Score__c, F1_Total_Score__c                                         
                                              from Funnel_ScoreCard__c where Opportunity__c =: Oppty.id ];            
        
        if(FSCardRecord.isEmpty()){
            RecordAlreadyExistsFlag = false;
            system.debug('###'+RecordAlreadyExistsFlag);
        }       
        
        else {
            RecordAlreadyExistsFlag=true;
            system.debug('$$$'+RecordAlreadyExistsFlag);
            FSCId = FSCardRecord[0].Id;
        }
        
        system.debug('****'+RecordAlreadyExistsFlag);     
        CalculateScore();
        
        if(RecordAlreadyExistsFlag==false){
            fscRecord.F1_Business_Score__c=BusinessScore;
            fscRecord.F1_Opportunity_Score__c=OpportunityScore;
            fscRecord.F1_Total_Score__c=TotalScore;
            fscRecord.Opportunity__c= Oppty.id;
            insert fscRecord; 
            
        }
        
        else{
            
            Funnel_ScoreCard__c[] FSCardRecordForUpdate = [select Id,F1_BQ1__c,F1_BQ2__c,F1_BQ3__c,F1_BQ4__c,F1_BQ5__c,F1_BQ6__c,F1_BQ7__c,F1_BQ8__c,F1_BQ9__c,F1_BQ10__c,
                                                           F1_OQ1__c,F1_OQ2__c,F1_OQ3__c,F1_OQ4__c,F1_OQ5__c,F1_OQ6__c,F1_OQ7__c,F1_OQ8__c,F1_OQ9__c,F1_OQ10__c,
                                                           F1_Business_Score__c,F1_Opportunity_Score__c, F1_Total_Score__c from Funnel_ScoreCard__c where Id =: FSCId ];            
            
            FSCardRecordForUpdate[0].F1_BQ1__c=fscRecord.F1_BQ1__c;
            FSCardRecordForUpdate[0].F1_BQ2__c=fscRecord.F1_BQ2__c;
            FSCardRecordForUpdate[0].F1_BQ3__c=fscRecord.F1_BQ3__c;
            FSCardRecordForUpdate[0].F1_BQ4__c=fscRecord.F1_BQ4__c;
            FSCardRecordForUpdate[0].F1_BQ5__c=fscRecord.F1_BQ5__c;
            FSCardRecordForUpdate[0].F1_BQ6__c=fscRecord.F1_BQ6__c;
            FSCardRecordForUpdate[0].F1_BQ7__c=fscRecord.F1_BQ7__c;
            FSCardRecordForUpdate[0].F1_BQ8__c=fscRecord.F1_BQ8__c;
            FSCardRecordForUpdate[0].F1_BQ9__c=fscRecord.F1_BQ9__c;
            FSCardRecordForUpdate[0].F1_BQ10__c=fscRecord.F1_BQ10__c;
            
            FSCardRecordForUpdate[0].F1_OQ1__c=fscRecord.F1_OQ1__c;
            FSCardRecordForUpdate[0].F1_OQ2__c=fscRecord.F1_OQ2__c;
            FSCardRecordForUpdate[0].F1_OQ3__c=fscRecord.F1_OQ3__c;
            FSCardRecordForUpdate[0].F1_OQ4__c=fscRecord.F1_OQ4__c;
            FSCardRecordForUpdate[0].F1_OQ5__c=fscRecord.F1_OQ5__c;
            FSCardRecordForUpdate[0].F1_OQ6__c=fscRecord.F1_OQ6__c;
            FSCardRecordForUpdate[0].F1_OQ7__c=fscRecord.F1_OQ7__c;
            FSCardRecordForUpdate[0].F1_OQ8__c=fscRecord.F1_OQ8__c;
            FSCardRecordForUpdate[0].F1_OQ9__c=fscRecord.F1_OQ9__c;
            FSCardRecordForUpdate[0].F1_OQ10__c=fscRecord.F1_OQ10__c;
            
            FSCardRecordForUpdate[0].F1_Business_Score__c=BusinessScore;
            FSCardRecordForUpdate[0].F1_Opportunity_Score__c=OpportunityScore;
            FSCardRecordForUpdate[0].F1_Total_Score__c=TotalScore;
            
            update FSCardRecordForUpdate;
        }
        //SF-1804 - -Miller Heiman legacy Fields Replacement    
        Oppty.mh_Business_Score__c = BusinessScore;
        Oppty.mh_Opportunity_Score__c = OpportunityScore;
        Oppty.mh_Scorecard_Total__c = TotalScore;
        
        update Oppty; 
        
        return null;
        
    }  
    
    public PageReference saveScoresAndReturnToOppty(){
        saveAndContinue();
        String OpenPageUrl = '/'+ Oppty.id;
        PageReference newPage = new PageReference(OpenPageUrl);
        newPage.setRedirect(true);
        return newPage;  
    }
    
    public PageReference dontSaveAndReturnToOppty(){
        String OpenPageUrl = '/'+ Oppty.id;
        PageReference newPage = new PageReference(OpenPageUrl);
        newPage.setRedirect(true);
        return newPage; 
    }
    public PageReference redirectToPrint(){
        String OpenPageUrl = '/apex/Funnel_score_card_1_CalculateScore?oppid='+ Oppty.id;
        // PageReference newPage = new PageReference(OpenPageUrl);
        // newPage.setRedirect(true);
        // return newPage; 
        return null;
    }
    
    public PageReference returnToOpptyPage(){
        String OpenPageUrl = '/'+ Oppty.id;
        PageReference newPage = new PageReference(OpenPageUrl);
        newPage.setRedirect(true);
        ShowMeInEditMode=null;
        return newPage; 
    }
    
    
    public Integer getcallBusinessScore() {
        return BusinessScore;
    }
    public Integer getcallOpportunityScore() {
        return OpportunityScore;
    }
    public Integer getcallTotalScore() {
        return TotalScore;
    }
    
    public id getOpportunityId(){
        return currentPgId;
    }
    
}