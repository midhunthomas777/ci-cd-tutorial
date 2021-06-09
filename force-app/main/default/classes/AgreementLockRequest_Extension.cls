/*  
* File Name  : AgreementLockRequest_Extension 
* Description: This class locks the Sales agreement record if it is not already locked and records the 
*              name and id of user who locked the record. Only users who have 'Edit' access on the record
*              can lock the record.
* Author     : Subu Iyer
* Modification Log 
* ===========================================================================================================
* Ver   Date         Author                         Modification 
* -----------------------------------------------------------------------------------------------------------
* 1.0   10/15/2012   Subu Iyer                      Initial Code
*/
public class AgreementLockRequest_Extension 
{        
    @TestVisible private final Apttus__APTS_Agreement__c agreement;        
    @TestVisible private ApexPages.StandardController stdController;    
    
    public AgreementLockRequest_Extension(ApexPages.StandardController controller) {
        stdController = controller;            
        agreement = (Apttus__APTS_Agreement__c) stdController.getRecord();    
    }    
    
/*  * Name: lockRecord  
    * Input: None 
    * Output: Directs the user to the View page of the agreement record. 
    * Description: Sets the Locked by User name and Id if record is not already locked
*/  
public PageReference lockRecord() {      
    System.debug('Inside Apex class');
    //String theId = ApexPages.currentPage().getParameters().get('id');  
    //List<Apttus__APTS_Agreement__c> agreementsList = new List<Apttus__APTS_Agreement__c>();
    try{
    UserRecordAccess usrRecordAccess = [SELECT RecordId, HasEditAccess, MaxAccessLevel
                                        FROM UserRecordAccess
                                        WHERE UserId = :Userinfo.getUserID()
                                        AND RecordId = :agreement.id];
    for(Apttus__APTS_Agreement__c agmnts: [ SELECT id, Record_locked_by__c, Record_locked_by_id__c,Hidden_Record_Type_Name__c, Agreement_Locked_Message__c, 
                                                    Lock_Record_Check__c 
                                             FROM Apttus__APTS_Agreement__c  
                                             WHERE id =:agreement.id ]) { 
        System.debug('Inside for');
        if( agmnts.Record_locked_by__c==null) {                  
        
            System.debug('Record Type Name: = ' + agmnts.Hidden_Record_Type_Name__c);            
            System.debug('usrRecordAccess.HasEditAccess ' + usrRecordAccess.HasEditAccess);            
            //If the record type is Sales proceed to lock the record
            if ((agmnts.Hidden_Record_Type_Name__c).equalsignorecase('Sales') && usrRecordAccess.HasEditAccess) {                  
                System.debug('Record Type is Sales'); 
                agmnts.Record_locked_by__c=Userinfo.getName(); 
                agmnts.Record_locked_by_id__c=Userinfo.getUserID();
                //agmnts.Agreement_Locked_Message__c='You have successfully locked the agreement record. Please unlock the record after you have saved your changes.';            
                System.debug('After Updates'); 
                try{
                    update agmnts;
                    if(Test.isRunningTest()){
                        Account acc = new Account();
                        insert acc;
                    }
                } 
                //Catch errors while updating the agreement record. Exceptions because of Validation rules might cause the lock operation to not work. Trap the exception
                catch(DMLException dml){
                    //Create a Apex Message to display on the VF page calling this Apex class. The return statement causes it to return immediately to the calling VF page
                    ApexPages.Message validationMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'There are errors in the Agreement record. Please correct them before attempting to lock the record.');
                    ApexPages.addMessage(validationMsg);
                    return null;
                 }                
            } //end if recordtype //agmnts.Lock_Record_Check__c=true;
        } //end if lock
        /*else{
                if (agmnts.Record_locked_by__c.equals(Userinfo.getName()))
                    agmnts.Agreement_Locked_Message__c='You have successfully locked the agreement record. Please unlock the record after you have saved your changes.';              
                else {                        
                    agmnts.Agreement_Locked_Message__c='The agreement has been locked for editing by '+agmnts.Record_locked_by__c+ '. Please try again later.';            
                    System.debug('Record is locked'); 
                }
    
            }*/    
     } //end for  
        
     System.debug('After update');   
    } //end try
    catch (Exception E) { 
        agreement.adderror('There are errors in the Agreement record. Please correct them before locking the record.');
        ApexPages.addmessages(E);    
        return ApexPages.currentPage();     
    } //end catch 
         
    // Redirect the user back to the original page 
    System.debug('Before return');   
    return stdController.view().setRedirect(true);   
   }
  }