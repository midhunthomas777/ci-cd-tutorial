/*  
* File Name  : BlueSheetNotification
* Description: This Code is the controller class for the Visualforce page Blue Sheet 
               In this class, we perform the necessary check when a user click on the "request Manager review" button
* Author     : Vishal Rao Jujaray - Infosys Technologies Limited
* Modification Log 
* ============================================================================= 
* Ver   Date        Author                         Modification 
* -----------------------------------------------------------------------------------------------------------------------------------------
* 1.0   09-Nov-13   Vishal Rao Jujaray              Initial Code
* 1.1   05-May-16   Anusha Arra                     Mobile Accelerator changes       
* 
*/


public class BlueSheetNotification{    
    id currentPgId = ApexPages.currentPage().getParameters().get('id'); 
    id currentUserId = UserInfo.getUserId();
    String currentUserName = UserInfo.getUserName();
    boolean managerIsActive=false;
    public User currentUserDetails = [select id, Name, ManagerId  from User where id=: currentUserId limit 1];  
    
    
    public Opportunity Oppty = [select id,mh_Associated_Blue_Sheet__c,Blue_Sheet_Updated_SendEmailNotification__c, Name
                                     from Opportunity where id=:currentPgId limit 1];
                                     
    public BlueSheetNotification(ApexPages.StandardController controller) {
         Opportunity[] OpportunityDetails = [select Id,mh_Associated_Blue_Sheet__c,mh_Last_Updated_Blue_Sheet__c,mh_Managers_Notes_Exist__c,mh_Blue_Sheet_Last_Updated_By__c,mh_Managers_Review_Date__c,mh_Additional_Notes_Exist__c, Name,Blue_Sheet_Updated_SendEmailNotification__c from Opportunity where id =: Oppty.id limit 1];
       
       /* Added to Enabling the button only when all teh conditions are true*/    
                if(OpportunityDetails[0].mh_Associated_Blue_Sheet__c == true) {
                    EnableTheButton=true;
                }
        /* Added to Enabling the button only when all teh conditions are true*/  
        
        
                     
    } 
     
     public pagereference BlueSheetNotificationValidation(){
        
        list<User> ManagerDetails= new list<User>();
        list<User> ActiveManagerDetails= new list<User>();
        
        system.debug('Manager :' +currentUserDetails.ManagerId);
        if (currentUserDetails.ManagerId != null && String.valueOf(currentUserDetails.ManagerId) != ''){
            ActiveManagerDetails = [select Id, isActive from User where id =: currentUserDetails.ManagerId limit 1];
            managerIsActive=ActiveManagerDetails[0].isActive;          
        }
        
        
        if (currentUserDetails.ManagerId != null && String.valueOf(currentUserDetails.ManagerId) != '' && managerIsActive==true){
              ManagerDetails = [select Id, FirstName, Email from User where id =: currentUserDetails.ManagerId limit 1]; 
              if (Oppty.mh_Associated_Blue_Sheet__c !=true && ManagerDetails.size()!=0){
                   ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'This notification cannot be sent to your manager because :\n A Blue Sheet is not created on this Opportunity Record.');  
                   ApexPages.addMessage(myMsg);
                }
                else {
                    if(Oppty.Blue_Sheet_Updated_SendEmailNotification__c== null){
                        Oppty.Blue_Sheet_Updated_SendEmailNotification__c = 1;
                    }
                    else {
                        Oppty.Blue_Sheet_Updated_SendEmailNotification__c++;                  
                    }
                    Oppty.Owners_Manager_Email__c = ManagerDetails[0].Email;
                    Oppty.Users_Manager__c = ManagerDetails[0].FirstName;
                    
                    update Oppty;
           
                    list<Task> NewTaskRecords = new list<Task>(); 
                    Task taskrecords = new task ();
                    string SubjectOfTheActivity = null;
                    SubjectOfTheActivity = 'Please Review the Blue Sheet for the Opportunity : ';
                    SubjectOfTheActivity =  SubjectOfTheActivity +'"'+ Oppty.Name +'"';
                    SubjectOfTheActivity =  SubjectOfTheActivity +'. This request has been sent by :';
                    SubjectOfTheActivity =  SubjectOfTheActivity +'"' + currentUserDetails.Name + +'".';
                    taskrecords.Subject = SubjectOfTheActivity;
                    taskrecords.OwnerId = currentUserDetails.managerId;
                    taskrecords.WhatId = Oppty.id;
                    taskrecords.ActivityDate = Date.today() + 7; 
                    NewTaskRecords.add(taskrecords);
                    insert NewTaskRecords;

                   ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.INFO, 'An e-mail notification has been sent to your manager to request a Blue Sheet review. Refresh the page to find more information in the Open Activities associated to this Opportunity.');  
                   ApexPages.addMessage(myMsg);
                  }
            }
        else if (Oppty.mh_Associated_Blue_Sheet__c !=true && ManagerDetails.size()==0){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'This notification cannot be sent to your manager because : \n A Blue Sheet is not created on this Opportunity Record.  \n And \n Your Manager details are not identified on your user record. Please contact your salesforce.com administrator who can assist in correcting the issue.');  
            ApexPages.addMessage(myMsg);   
        }
        else {
           apexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'This request cannot be sent because your manager has not been assigned in your profile.  Please contact your regional salesforce.com administrator who can assign your manager for you.');  
            ApexPages.addMessage(myMsg);    
        }   
       return null; 
    }
    
   /* Added to Enabling the button only when all teh conditions are true*/  
   public boolean EnableTheButton{
        get{
            if(EnableTheButton == null){
                EnableTheButton= false;
            }
            return EnableTheButton;
        }
        set;
        }
  /* Added to Enabling the button only when all teh conditions are true*/
  // Added by Anusha for Mobile changes
  public Boolean isSF1 {
    get {                   
        if(String.isNotBlank(ApexPages.currentPage().getParameters().get('sfdcIFrameHost')) ||
            String.isNotBlank(ApexPages.currentPage().getParameters().get('sfdcIFrameOrigin')) ||
            ApexPages.currentPage().getParameters().get('isdtp') == 'p1' ||
            (ApexPages.currentPage().getParameters().get('retURL') != null && ApexPages.currentPage().getParameters().get('retURL').contains('projectone') )
        ) {
            return true;
        }else{
            return false;
        }
    }
}
}