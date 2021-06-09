/*  
* File Name  : AgreementUnlockRequest_Extension 
* Description: This class unlocks an already locked Sales agreement record. Only the user who originally locked the 
               agreement record or a System Administrator can unlock the record.          
* Author     : Subu Iyer
* Modification Log 
* ========================================================================================================================== 
* Ver   Date         Author                         Modification 
* --------------------------------------------------------------------------------------------------------------------------
* 1.0   10/15/2012   Subu Iyer                      Initial Code
*/
public class AgreementUnlockRequest_Extension 
{        
    private final Apttus__APTS_Agreement__c agreement;        
    private ApexPages.StandardController stdController;    
    
    public AgreementUnlockRequest_Extension(ApexPages.StandardController controller) {
        stdController = controller;            
        agreement = (Apttus__APTS_Agreement__c) stdController.getRecord();    
    }    
    
/*  * Name: unlockRecord  
    * Input: None 
    * Output: Directs the user to the View page of the agreement record. 
    * Description: Clears the lock if called by the same user who locked the record or System Administrator.
*/  
public PageReference unlockRecord() {  
    System.debug('Inside Apex class');
    //String theId = ApexPages.currentPage().getParameters().get('id');  
    //List<Apttus__APTS_Agreement__c> agreementsList = new List<Apttus__APTS_Agreement__c>();
    try{
    Profile userprofile=[Select p.id From Profile p where p.Name='System Administrator'];
        
    for(Apttus__APTS_Agreement__c agmnts: [ Select id, Record_locked_by__c, Record_locked_by_id__c, 
                                           Hidden_Record_Type_Name__c, Agreement_Locked_Message__c, 
                                           Lock_Record_Check__c from Apttus__APTS_Agreement__c  where id =:agreement.id ]) { 
        System.debug('Inside for');
        if( agmnts.Record_locked_by__c!=null && (agmnts.Record_locked_by_id__c==Userinfo.getUserID()||Userinfo.getProfileID()==userprofile.id)) {                  
        
            System.debug('Record Type Name: = ' + agmnts.Hidden_Record_Type_Name__c);     
            agmnts.Record_locked_by__c=''; 
            agmnts.Agreement_Locked_Message__c='';       
            agmnts.Record_locked_by_id__c = '';
            System.debug('After Updates'); 
            try{
            	update agmnts;
            } 
            //Catch errors while updating the agreement record. Exceptions because of Validation rules might cause the unlock operation to not work. Trap the exception
            catch(DMLException dml){
                //Create a Apex Message to display on the VF page calling this Apex class. The return statement causes it to return immediately to the calling VF page
                ApexPages.Message validationMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'There are errors in the Agreement record. Please correct them before unlocking the record.');
				ApexPages.addMessage(validationMsg);
                return null;
   			 }
        } //end if lock       
     } //end for  
        
     System.debug('After update');   
    } //end try
    catch (Exception E) {   
       //ApexPages.addmessages(E);    
       return ApexPages.currentPage();     
    } //end catch
    // Redirect the user back to the view page 
       System.debug('Before return');   
       return stdController.view().setRedirect(true);  
    //PageReference pageRef = new PageReference('/' + theId);       
    //pageRef.setRedirect(true);        
    //return pageRef;  
   }
  }