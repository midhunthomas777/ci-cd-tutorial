/*  
* File Name  : FieldOfPlayWorksheetController
* Description: This Code is the controller class for the Visualforce page "FieldOfPlayWorkSheet". 
               In this class, the scores are calculated and published. 
* Author     : Vishal Rao Jujaray - Infosys Technologies Limited
* Modification Log 
* ============================================================================= 
* Ver   Date        Author                         Modification 
* -----------------------------------------------------------------------------------------------------------------------------------------
* 1.0   17-Dec-12   Vishal Rao Jujaray              Initial Code
* 
*/

public with sharing class FieldOfPlayWorksheetController{
//  public class FieldOfPlayWorksheetController{
    
    id currentPgId = ApexPages.currentPage().getParameters().get('FOPid');
    
    public Field_of_Play__c FOPs = [SELECT Id, Name, Account__r.Name, Total_Score_FOPs_View_on_Us__c, Total_Score_Our_View_of_FOP__c, Total_Score_FOPs_View_Our_Competitor__c  FROM Field_of_Play__c WHERE id=:currentPgId limit 1];
    
    public string FOPName = FOPs.Name; 
    public string AcctName = FOPs.Account__r.Name; 
    
    public Field_of_Play_Worksheet__c FieldOfPlayWorkSheet;
    public Boolean RecordAlreadyExistsFlag = false;
    public decimal ourViewFOP =0;
    public decimal fopView =0;
    public decimal fopCompView = 0;
    public boolean insertFOPRecordSuccessCheck = true;
    public boolean updateFOPRecordSuccessCheck = true;
    public Id FieldOfPlayRecordId;
    
    public id getFieldOfPlayId(){
    return currentPgId; 
    }
    
    public string getFOPName() {
    return FOPName;
    }
    
    public string getAcctName() {
    return AcctName;
    }
   
    public FieldOfPlayWorksheetController(ApexPages.StandardController controller) {
        Field_of_Play_Worksheet__c[] FieldOfPlayRecordWorksheetScore = [Select Id, Competition__c, Contact_at_FOP__c, Contact_Roles_at_FOP__c, Contact_At_Field_Of_Play__c, Total_Score_FOPs_View_Our_Competitor__c , Total_Score_FOPs_View_on_Us__c, Total_Score_Our_View_of_FOP__c, FOP_View_1__c,FOP_View_2__c,FOP_View_3__c,FOP_View_4__c, FOP_View_5__c, FOP_View_6__c, FOP_View_7__c,OurView__c,OurView_FOP_2__c,OurView_FOP_3__c, OurView_FOP_4__c, OurView_FOP_5__c, OurView_FOP_6__c,OurView_FOP_7__c, FOP_View_On_Our_COmpetitor_1__c, FOP_View_On_Our_COmpetitor_2__c, FOP_View_On_Our_COmpetitor_3__c, FOP_View_On_Our_COmpetitor_4__c, FOP_View_On_Our_COmpetitor_5__c, FOP_View_On_Our_COmpetitor_6__c, FOP_View_On_Our_COmpetitor_7__c
        FROM Field_of_Play_Worksheet__c WHERE Field_of_Play__c =:FOPs.id];
    FieldOfPlayWorkSheet = (Field_of_Play_Worksheet__c)controller.getRecord();
    if(FieldOfPlayRecordWorksheetScore.isEmpty()){
    RecordAlreadyExistsFlag = false;
    }
    else{
    RecordAlreadyExistsFlag = true;
    FieldOfPlayRecordId = FieldOfPlayRecordWorksheetScore[0].Id; 
    
    FieldOfPlayWorkSheet.Competition__c = FieldOfPlayRecordWorksheetScore[0].Competition__c; 
    FieldOfPlayWorkSheet.Contact_At_Field_Of_Play__c = FieldOfPlayRecordWorksheetScore[0].Contact_At_Field_Of_Play__c;
    FieldOfPlayWorkSheet.Contact_at_FOP__c = FieldOfPlayRecordWorksheetScore[0].Contact_at_FOP__c;
    FieldOfPlayWorkSheet.Contact_Roles_at_FOP__c = FieldOfPlayRecordWorksheetScore[0].Contact_Roles_at_FOP__c;
    
    FieldOfPlayWorkSheet.FOP_View_1__c = FieldOfPlayRecordWorksheetScore[0].FOP_View_1__c;
    FieldOfPlayWorkSheet.FOP_View_2__c = FieldOfPlayRecordWorksheetScore[0].FOP_View_2__c;
    FieldOfPlayWorkSheet.FOP_View_3__c = FieldOfPlayRecordWorksheetScore[0].FOP_View_3__c;
    FieldOfPlayWorkSheet.FOP_View_4__c = FieldOfPlayRecordWorksheetScore[0].FOP_View_4__c;
    FieldOfPlayWorkSheet.FOP_View_5__c = FieldOfPlayRecordWorksheetScore[0].FOP_View_5__c;
    FieldOfPlayWorkSheet.FOP_View_6__c = FieldOfPlayRecordWorksheetScore[0].FOP_View_6__c;
    FieldOfPlayWorkSheet.FOP_View_7__c = FieldOfPlayRecordWorksheetScore[0].FOP_View_7__c;
    
    FieldOfPlayWorkSheet.FOP_View_On_Our_COmpetitor_1__c = FieldOfPlayRecordWorksheetScore[0].FOP_View_On_Our_COmpetitor_1__c;
    FieldOfPlayWorkSheet.FOP_View_On_Our_COmpetitor_2__c = FieldOfPlayRecordWorksheetScore[0].FOP_View_On_Our_COmpetitor_2__c;
    FieldOfPlayWorkSheet.FOP_View_On_Our_COmpetitor_3__c = FieldOfPlayRecordWorksheetScore[0].FOP_View_On_Our_COmpetitor_3__c;
    FieldOfPlayWorkSheet.FOP_View_On_Our_COmpetitor_4__c = FieldOfPlayRecordWorksheetScore[0].FOP_View_On_Our_COmpetitor_4__c;
    FieldOfPlayWorkSheet.FOP_View_On_Our_COmpetitor_5__c = FieldOfPlayRecordWorksheetScore[0].FOP_View_On_Our_COmpetitor_5__c;
    FieldOfPlayWorkSheet.FOP_View_On_Our_COmpetitor_6__c = FieldOfPlayRecordWorksheetScore[0].FOP_View_On_Our_COmpetitor_6__c;
    FieldOfPlayWorkSheet.FOP_View_On_Our_COmpetitor_7__c = FieldOfPlayRecordWorksheetScore[0].FOP_View_On_Our_COmpetitor_7__c;
    
    FieldOfPlayWorkSheet.OurView__c = FieldOfPlayRecordWorksheetScore[0].OurView__c;
    FieldOfPlayWorkSheet.OurView_FOP_2__c = FieldOfPlayRecordWorksheetScore[0].OurView_FOP_2__c;
    FieldOfPlayWorkSheet.OurView_FOP_3__c = FieldOfPlayRecordWorksheetScore[0].OurView_FOP_3__c;
    FieldOfPlayWorkSheet.OurView_FOP_4__c = FieldOfPlayRecordWorksheetScore[0].OurView_FOP_4__c;
    FieldOfPlayWorkSheet.OurView_FOP_5__c = FieldOfPlayRecordWorksheetScore[0].OurView_FOP_5__c;
    FieldOfPlayWorkSheet.OurView_FOP_6__c = FieldOfPlayRecordWorksheetScore[0].OurView_FOP_6__c;
    FieldOfPlayWorkSheet.OurView_FOP_7__c = FieldOfPlayRecordWorksheetScore[0].OurView_FOP_7__c;
    
    FieldOfPlayWorkSheet.Total_Score_Our_View_of_FOP__c = FieldOfPlayRecordWorksheetScore[0].Total_Score_Our_View_of_FOP__c; 
    FieldOfPlayWorkSheet.Total_Score_FOPs_View_on_Us__c =  FieldOfPlayRecordWorksheetScore[0].Total_Score_FOPs_View_on_Us__c; 
    FieldOfPlayWorkSheet.Total_Score_FOPs_View_Our_Competitor__c =  FieldOfPlayRecordWorksheetScore[0].Total_Score_FOPs_View_Our_Competitor__c; 
    
    }
    }
    public PageReference CalculateScore(){
    ourViewFOP =0;
    fopView =0;
    fopCompView=0;
        if(FieldOfPlayWorkSheet.FOP_View_1__c != null )
            fopView = fopView + Integer.valueof(FieldOfPlayWorkSheet.FOP_View_1__c);
        if(FieldOfPlayWorkSheet.FOP_View_2__c != null )
            fopView = fopView + Integer.valueof(FieldOfPlayWorkSheet.FOP_View_2__c);
        if(FieldOfPlayWorkSheet.FOP_View_3__c != null )
            fopView = fopView + Integer.valueof(FieldOfPlayWorkSheet.FOP_View_3__c);
        if(FieldOfPlayWorkSheet.FOP_View_4__c != null )
            fopView = fopView + Integer.valueof(FieldOfPlayWorkSheet.FOP_View_4__c);
        if(FieldOfPlayWorkSheet.FOP_View_5__c != null )
            fopView = fopView + Integer.valueof(FieldOfPlayWorkSheet.FOP_View_5__c);
        if(FieldOfPlayWorkSheet.FOP_View_6__c != null )
            fopView = fopView + Integer.valueof(FieldOfPlayWorkSheet.FOP_View_6__c);
        if(FieldOfPlayWorkSheet.FOP_View_7__c != null )
            fopView = fopView + Integer.valueof(FieldOfPlayWorkSheet.FOP_View_7__c);  

        if(FieldOfPlayWorkSheet.FOP_View_On_Our_COmpetitor_1__c != null )
            fopCompView = fopCompView + Integer.valueof(FieldOfPlayWorkSheet.FOP_View_On_Our_COmpetitor_1__c);
        if(FieldOfPlayWorkSheet.FOP_View_On_Our_COmpetitor_2__c != null )
            fopCompView = fopCompView + Integer.valueof(FieldOfPlayWorkSheet.FOP_View_On_Our_COmpetitor_2__c);
        if(FieldOfPlayWorkSheet.FOP_View_On_Our_COmpetitor_3__c != null )
            fopCompView = fopCompView + Integer.valueof(FieldOfPlayWorkSheet.FOP_View_On_Our_COmpetitor_3__c);
        if(FieldOfPlayWorkSheet.FOP_View_On_Our_COmpetitor_4__c != null )
            fopCompView = fopCompView + Integer.valueof(FieldOfPlayWorkSheet.FOP_View_On_Our_COmpetitor_4__c);
        if(FieldOfPlayWorkSheet.FOP_View_On_Our_COmpetitor_5__c != null )
            fopCompView = fopCompView + Integer.valueof(FieldOfPlayWorkSheet.FOP_View_On_Our_COmpetitor_5__c);
        if(FieldOfPlayWorkSheet.FOP_View_On_Our_COmpetitor_6__c != null )
            fopCompView = fopCompView + Integer.valueof(FieldOfPlayWorkSheet.FOP_View_On_Our_COmpetitor_6__c);
        if(FieldOfPlayWorkSheet.FOP_View_On_Our_COmpetitor_7__c != null )
            fopCompView = fopCompView + Integer.valueof(FieldOfPlayWorkSheet.FOP_View_On_Our_COmpetitor_7__c);      
        
        if(FieldOfPlayWorkSheet.OurView__c != null )
            ourViewFOP = ourViewFOP + Integer.valueof(FieldOfPlayWorkSheet.OurView__c );
        if(FieldOfPlayWorkSheet.OurView_FOP_2__c!= null )
            ourViewFOP = ourViewFOP + Integer.valueof(FieldOfPlayWorkSheet.OurView_FOP_2__c);
        if(FieldOfPlayWorkSheet.OurView_FOP_3__c!= null )
            ourViewFOP = ourViewFOP + Integer.valueof(FieldOfPlayWorkSheet.OurView_FOP_3__c);
        if(FieldOfPlayWorkSheet.OurView_FOP_4__c!= null )
            ourViewFOP = ourViewFOP + Integer.valueof(FieldOfPlayWorkSheet.OurView_FOP_4__c);
        if(FieldOfPlayWorkSheet.OurView_FOP_5__c!= null )
            ourViewFOP = ourViewFOP + Integer.valueof(FieldOfPlayWorkSheet.OurView_FOP_5__c);
        if(FieldOfPlayWorkSheet.OurView_FOP_6__c!= null )
            ourViewFOP = ourViewFOP + Integer.valueof(FieldOfPlayWorkSheet.OurView_FOP_6__c);
        if(FieldOfPlayWorkSheet.OurView_FOP_7__c!= null )
            ourViewFOP = ourViewFOP + Integer.valueof(FieldOfPlayWorkSheet.OurView_FOP_7__c);   
            
               
        FieldOfPlayWorkSheet.Total_Score_Our_View_of_FOP__c = ourViewFOP; 
        FieldOfPlayWorkSheet.Total_Score_FOPs_View_on_Us__c = fopView;
        FieldOfPlayWorkSheet.Total_Score_FOPs_View_Our_Competitor__c = fopCompView;
        
        
                  
    return null;
    }
     public PageReference Cancel(){
        String OpenPageUrl = '/'+ FOPs.id;
        PageReference newPage = new PageReference(OpenPageUrl);
        newPage.setRedirect(true);
        return newPage; 
    } 
    public PageReference saveScoreandReturnToFOP(){
    
        /*saveScoreCardAndContinue();
        String OpenPageUrl = '/'+ FOPs.id;
        PageReference newPage = new PageReference(OpenPageUrl);
        newPage.setRedirect(true);
        return newPage;  */
        
        try {
        saveScoreCardAndContinue();
        if(updateFOPRecordSuccessCheck == false || insertFOPRecordSuccessCheck == false) {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'INSUFFICIENT PRIVILEGES - You do not have the level of access necessary to perform the operation you requested. Please contact the owner of the record or your administrator if access is necessary.');  
            ApexPages.addMessage(myMsg);
            return null;
        }
        else{
            String OpenPageUrl = '/'+ FOPs.id;
            PageReference newPage = new PageReference(OpenPageUrl);
            newPage.setRedirect(true);
            return newPage;
        }         
      }
        catch(System.DMLException e){
        ApexPages.Message myMsg = new ApexPages.Message(ApexPages.severity.ERROR,'Error While saving the Record : ' + e.getMessage());
        ApexPages.addMessage(myMsg);
        System.debug('Error is======'+e.getMessage());
        return null;
        }
    
        
    
    }
    public PageReference saveScoreCardAndContinue(){
        try{
        CalculateScore();
        if(RecordAlreadyExistsFlag == false){
            FieldOfPlayWorkSheet.Total_Score_Our_View_of_FOP__c = ourViewFOP; 
            FieldOfPlayWorkSheet.Total_Score_FOPs_View_on_Us__c = fopView;
            FieldOfPlayWorkSheet.Total_Score_FOPs_View_Our_Competitor__c = fopCompView;
            FieldOfPlayWorkSheet.Field_of_Play__c = FOPs.Id;
            /*insert FieldOfPlayWorkSheet;
            RecordAlreadyExistsFlag = true;
            FieldOfPlayRecordId = FieldOfPlayWorkSheet.Id; */
            
            database.Saveresult FOPRecordInsertResult = database.insert(FieldOfPlayWorkSheet, false);
            
            if(FOPRecordInsertResult.isSuccess() == true){
            insertFOPRecordSuccessCheck = true;          
            RecordAlreadyExistsFlag = true;
            FieldOfPlayRecordId = FieldOfPlayWorkSheet.Id;
            }
            else 
            {
            insertFOPRecordSuccessCheck = false;    
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'INSUFFICIENT PRIVILEGES - You do not have the level of access necessary to perform the operation you requested. Please contact the owner of the record or your administrator if access is necessary.');
            
           
            ApexPages.addMessage(myMsg);  
            return null;
            }
            }
        else{
        Field_of_Play_Worksheet__c[] FieldOfPlayRecordWorksheetScoreUpdate = [Select Id, Competition__c, Contact_At_Field_Of_Play__c, Total_Score_FOPs_View_Our_Competitor__c , Total_Score_FOPs_View_on_Us__c, Total_Score_Our_View_of_FOP__c, FOP_View_1__c,FOP_View_2__c,FOP_View_3__c,FOP_View_4__c, FOP_View_5__c, FOP_View_6__c, FOP_View_7__c,OurView__c,OurView_FOP_2__c,OurView_FOP_3__c, OurView_FOP_4__c, OurView_FOP_5__c, OurView_FOP_6__c,OurView_FOP_7__c, FOP_View_On_Our_COmpetitor_1__c, FOP_View_On_Our_COmpetitor_2__c, FOP_View_On_Our_COmpetitor_3__c, FOP_View_On_Our_COmpetitor_4__c, FOP_View_On_Our_COmpetitor_5__c, FOP_View_On_Our_COmpetitor_6__c, FOP_View_On_Our_COmpetitor_7__c FROM Field_of_Play_Worksheet__c WHERE Field_of_Play__c =: FOPs.id];
        
        FieldOfPlayRecordWorksheetScoreUpdate[0].Competition__c = FieldOfPlayWorkSheet.Competition__c; 
        FieldOfPlayRecordWorksheetScoreUpdate[0].Contact_At_Field_Of_Play__c = FieldOfPlayWorkSheet.Contact_At_Field_Of_Play__c;
        FieldOfPlayRecordWorksheetScoreUpdate[0].Contact_at_FOP__c = FieldOfPlayWorkSheet.Contact_at_FOP__c;
        FieldOfPlayRecordWorksheetScoreUpdate[0].Contact_Roles_at_FOP__c = FieldOfPlayWorkSheet.Contact_Roles_at_FOP__c;
    
        
        FieldOfPlayRecordWorksheetScoreUpdate[0].FOP_View_1__c = FieldOfPlayWorkSheet.FOP_View_1__c;
        FieldOfPlayRecordWorksheetScoreUpdate[0].FOP_View_2__c = FieldOfPlayWorkSheet.FOP_View_2__c;
        FieldOfPlayRecordWorksheetScoreUpdate[0].FOP_View_3__c = FieldOfPlayWorkSheet.FOP_View_3__c;
        FieldOfPlayRecordWorksheetScoreUpdate[0].FOP_View_4__c = FieldOfPlayWorkSheet.FOP_View_4__c;
        FieldOfPlayRecordWorksheetScoreUpdate[0].FOP_View_5__c = FieldOfPlayWorkSheet.FOP_View_5__c;
        FieldOfPlayRecordWorksheetScoreUpdate[0].FOP_View_6__c = FieldOfPlayWorkSheet.FOP_View_6__c;
        FieldOfPlayRecordWorksheetScoreUpdate[0].FOP_View_7__c = FieldOfPlayWorkSheet.FOP_View_7__c;
        
        FieldOfPlayRecordWorksheetScoreUpdate[0].FOP_View_On_Our_COmpetitor_1__c = FieldOfPlayWorkSheet.FOP_View_On_Our_COmpetitor_1__c;
        FieldOfPlayRecordWorksheetScoreUpdate[0].FOP_View_On_Our_COmpetitor_2__c = FieldOfPlayWorkSheet.FOP_View_On_Our_COmpetitor_2__c;
        FieldOfPlayRecordWorksheetScoreUpdate[0].FOP_View_On_Our_COmpetitor_3__c = FieldOfPlayWorkSheet.FOP_View_On_Our_COmpetitor_3__c;
        FieldOfPlayRecordWorksheetScoreUpdate[0].FOP_View_On_Our_COmpetitor_4__c = FieldOfPlayWorkSheet.FOP_View_On_Our_COmpetitor_4__c;
        FieldOfPlayRecordWorksheetScoreUpdate[0].FOP_View_On_Our_COmpetitor_5__c = FieldOfPlayWorkSheet.FOP_View_On_Our_COmpetitor_5__c;
        FieldOfPlayRecordWorksheetScoreUpdate[0].FOP_View_On_Our_COmpetitor_6__c = FieldOfPlayWorkSheet.FOP_View_On_Our_COmpetitor_6__c;
        FieldOfPlayRecordWorksheetScoreUpdate[0].FOP_View_On_Our_COmpetitor_7__c = FieldOfPlayWorkSheet.FOP_View_On_Our_COmpetitor_7__c;
    
        FieldOfPlayRecordWorksheetScoreUpdate[0].OurView__c = FieldOfPlayWorkSheet.OurView__c;
        FieldOfPlayRecordWorksheetScoreUpdate[0].OurView_FOP_2__c = FieldOfPlayWorkSheet.OurView_FOP_2__c;
        FieldOfPlayRecordWorksheetScoreUpdate[0].OurView_FOP_3__c = FieldOfPlayWorkSheet.OurView_FOP_3__c;
        FieldOfPlayRecordWorksheetScoreUpdate[0].OurView_FOP_4__c = FieldOfPlayWorkSheet.OurView_FOP_4__c;
        FieldOfPlayRecordWorksheetScoreUpdate[0].OurView_FOP_5__c = FieldOfPlayWorkSheet.OurView_FOP_5__c;
        FieldOfPlayRecordWorksheetScoreUpdate[0].OurView_FOP_6__c = FieldOfPlayWorkSheet.OurView_FOP_6__c;
        FieldOfPlayRecordWorksheetScoreUpdate[0].OurView_FOP_7__c = FieldOfPlayWorkSheet.OurView_FOP_7__c;
    
        FieldOfPlayRecordWorksheetScoreUpdate[0].Total_Score_FOPs_View_on_Us__c = FieldOfPlayWorkSheet.Total_Score_FOPs_View_on_Us__c; 
        FieldOfPlayRecordWorksheetScoreUpdate[0].Total_Score_FOPs_View_Our_Competitor__c = FieldOfPlayWorkSheet.Total_Score_FOPs_View_Our_Competitor__c; 
        FieldOfPlayRecordWorksheetScoreUpdate[0].Total_Score_Our_View_of_FOP__c =  FieldOfPlayWorkSheet.Total_Score_Our_View_of_FOP__c;  
        
        //update FieldOfPlayRecordWorksheetScoreUpdate;
        database.Saveresult[] FOPRecordUpdateResult = database.update(FieldOfPlayRecordWorksheetScoreUpdate, false);
            
            if(FOPRecordUpdateResult[0].isSuccess() == false){
                updateFOPRecordSuccessCheck = false;
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'INSUFFICIENT PRIVILEGES - You do not have the level of access necessary to perform the operation you requested. Please contact the owner of the record or your administrator if access is necessary.');  
                ApexPages.addMessage(myMsg);  
                return null;
            }
        }
        FOPs.Total_Score_Our_View_of_FOP__c = ourViewFOP;
        FOPs.Total_Score_FOPs_View_on_Us__c = fopView;
        FOPs.Total_Score_FOPs_View_Our_Competitor__c = fopCompView;
        
        update FOPs;
        return null;
        }
        catch(System.DMLException e){
        
        ApexPages.Message myMsg = new ApexPages.Message(ApexPages.severity.ERROR,'Error While saving the Record : ' + e.getMessage());
        ApexPages.addMessage(myMsg);
        System.debug('Error is======'+e.getMessage());
        return null;
    }
    }
}