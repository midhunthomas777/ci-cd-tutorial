/*
*Description: This controller is associated with page 'Edit_CustomerAccountMR' which will create case for every edit action 
*of the customer account. 
*-------------------------------------------------------------------------------------------------------
*   Author                          Date                                Project         
*   SriDurgaDevi                    01/06/2015                          MR Relaunch 
*-------------------------------------------------------------------------------------------------------
*/

public class EditCustomerAccount {
    public String AccountId{get;set;}
    public String RequestedChanges {get; set;}
    public String CaseRequestor{get; set;}
    public String AssignedASM {get; set;}
    private User currUser;
    private ID CASE_OWNER_NAME;
      
        
    public EditCustomerAccount(ApexPages.StandardController controller) {
       Account Record = (Account)controller.getRecord();
       AccountId= Record.Id;
       AccountId = AccountId.Substring(0,15); 
    }
 
    public PageReference returnPage()
       {
          return Page.Edit_CustomerAccountMR;
       }
       
   Public PageReference createCase() {
     system.debug('casecreationstart');
      AccAndConData__c ad = AccAndConData__c.getValues('Current');
      CASE_OWNER_NAME = ad.CaseOwner__c; 
     Account acc = [select id,Name,ownerid, owner.managerid from Account where id=:AccountId];
     currUser = [select id from User where Id=:Userinfo.getUserId() limit 1];
      Id customerRecordTypeId = Schema.SObjectType.Case.RecordTypeInfosByName.get('MR Customer Account Update').RecordTypeId;
     CaseRequestor = currUser.id;
     AssignedASM = acc.Owner.managerid;     
     Case cusaccupdCase= new Case(Accountid = +AccountId,RecordTypeId=+customerRecordTypeId,Priority='High',Status='New',ASM_Approval_Status__c='In Approval',
                         Case_Requestor__c=+CaseRequestor,Assigned_ASM__c=AssignedASM, Description=+RequestedChanges, Ownerid=CASE_OWNER_NAME, Subject='Request for updating MRCustomerAccount');
     system.debug('case ower is ' +CASE_OWNER_NAME);                    
     Insert cusaccupdCase;
     PageReference page = new PageReference('/'+AccountId);        
     page.setRedirect(true);        
     return page;    
   }

}