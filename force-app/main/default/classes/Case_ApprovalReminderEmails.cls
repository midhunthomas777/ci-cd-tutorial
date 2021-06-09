/*
*Description: This controller is used to send reminder emails to the Approvers of cases which are still in Pending Approval Process every 48 hours  
*This is Batch Class created newly that is scheduled to run every day.
*-------------------------------------------------------------------------------------------------------
*            Author                                    Date                                       Project         
* NagaPattabhi Gollapudi              21/10/2015                          MR Relaunch Point Release-6 

*-------------------------------------------------------------------------------------------------------
*/
global class Case_ApprovalReminderEmails implements Database.Batchable<sObject>,Database.Stateful,Schedulable
{
    static final String newCustomerAccReqTemplate = 'CaseApproversEmailReminder';  
     public Id customerRecordTypeId = Schema.SObjectType.Account.RecordTypeInfosByName.get('Customer').RecordTypeId;
     
     AccAndConData__c ad = AccAndConData__c.getValues('Current');
     Id mrAccountCreationCaseRecType = ad.MR_Account_Creation_Case_Rec_Type__c;
     Id mrAccountUpdateReCasecType = ad.MR_Customer_Account_Update_Case_Rec_Type__c;
     Id mrAccountAssignmentCaseRecType = ad.MR_Account_Assignment_Case_Rec_Type__c;
     Id mrCommisssionInquiryCaseRecType = ad.MR_Commission_Inquiry_Case_Rec_Type__c;
     
     //variables start
     List<Case> caseList = new List<Case>();
     List<Case> caseList1 = new List<Case>();
     Id recordTypeMRCustCreatetion = '01280000000M3Mc';
     List<Case> finalCaseList = new List<Case>();
     List<ProcessInstance> PIList = new List<ProcessInstance>();
    
     //end variables
     
    global Database.QueryLocator start(Database.BatchableContext bc)
    {
        
        Set<Id> idSet = new Set<Id>();
        date currentDate = Date.today();
        
       caseList = [select Id,CaseNumber,RecordType.Name,ASM_Approval_Status__c,CreatedDate from Case where (RecordTypeId=:mrAccountCreationCaseRecType OR RecordTypeId=:mrAccountUpdateReCasecType OR RecordTypeId=:mrAccountAssignmentCaseRecType OR RecordTypeId=:mrCommisssionInquiryCaseRecType) AND SystemModStamp >= 2015-11-02T00:00:00.000Z AND ASM_Approval_Status__c='In Approval'];
        
        DateTime dT = System.now();
        Date myDate = date.newinstance(dT.year(), dT.month(), dT.day());
        
        for(Case c : caseList){
        
        DateTime dT1 = c.CreatedDate;
        Date CaseDate = date.newinstance(dT1.year(), dT1.month(), dT1.day());
        
            if(math.mod(CaseDate.daysBetween(myDate),2)  == 0 && CaseDate.daysBetween(myDate)!=0 && CaseDate.daysBetween(myDate)!=1)
            {
                system.debug('Entered'+CaseDate.daysBetween(myDate));
                finalCaseList.add(c);
            } 
              system.debug('Number'+CaseDate.daysBetween(myDate)); 
           
        }
       
        system.debug('FINAL CASE LIST SIZE'+finalCaseList.size()+'FINAL CASE LIST'+finalCaseList);
        for(Case c : finalCaseList){
                system.debug('Entered ID SET');
            idSet.add(c.Id);
            }
            system.debug('IDSET SIZE'+idSet.size()+'IDSET'+idSet);
        
        
        String Query = 'SELECT Id, TargetObject.Name, TargetObjectID, TargetObject.Type, (SELECT Id, Actor.email, Actor.Name,Actor.Type FROM WorkItems) FROM ProcessInstance WHERE TargetObject.Type =\'Case\' AND Status = \'Pending\' AND IsDeleted = False AND SystemModStamp<=Today AND TargetObjectId IN : idSet';
        system.debug('MR ACC CREATION CASE LIST SIZE'+caseList.size()+'MR ACC CREATION LIST'+caseList);
        system.debug('MY QUERY'+Query);
        
       if (test.IsRunningTest() == true)
           {
             query = 'SELECT Id, TargetObject.Name, TargetObjectID, TargetObject.Type, (SELECT Id, Actor.email, Actor.Name,Actor.Type FROM WorkItems) FROM ProcessInstance WHERE Status = \'Pending\' AND IsDeleted = False';   
           }
           
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope)
    {
         system.debug('Customer Record Type'+customerRecordTypeId);
        for(SObject s : scope)
        {
            ProcessInstance PI = (ProcessInstance)s;
            PIList.add(PI);
            for(ProcessInstanceWorkItem WI : PI.WorkItems)
            { 
                Case_ApprovalReminderEmails.SendReminderEmail(PI.TargetObject.ID, PI.TargetObject.Type, WI.Actor.Id, WI.Actor.Email, WI.Actor.Name, PI.TargetObject.Name,WI.Actor.Type);
            }
            system.debug('PI LIST SIZE'+PIList.size()+'PI LIST'+PIList);
        }   
    } 
    
    global void finish(Database.BatchableContext info)
    {
    
    }
    
    public static void SendReminderEmail(Id TargetID, String TargetObjectType, Id ActorID, string ActorEmailAddress, string ActorName, string TargetDesc, String ActorType)
    {
        AccAndConData__c ad = AccAndConData__c.getValues('Current');
        Id fromEmailId = ad.From_Address_for_Case_Approvers__c;
       
        id EmailTemplateID;
        system.debug('TargetObjectType = ' + TargetObjectType);
        if (TargetObjectType == 'Case')
        {
             EmailTemplateID = FindEmailTemplateIDByDeveloperName(newCustomerAccReqTemplate);
        }
        Messaging.reserveSingleEmailCapacity(1);
 
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();     
 
        String[] toAddresses;
        
        if (test.IsRunningTest() == true)
        {
             toAddresses = new String[] {'no-reply@salesforce.com'};
        } 
        else
         {
             toAddresses = new String[] {ActorEmailAddress};  
         }
        
        system.debug('TO ADDRESSES'+toAddresses);
        system.debug('GOT EMAIL TEMP HERE IS'+EmailTemplateID);
        if (EmailTemplateID != null)
        {
            system.debug('Entered NOT NULL EMAIL TMP');    
             // use our template
             email.setTemplateId(EmailTemplateID);
             email.saveAsActivity = false;
            email.setOrgWideEmailAddressId(fromEmailId);  
             // populate the template w/ object data
             
           if(ActorType=='Queue' || Test.isRunningTest())
             {
                   Case c = [select Id,CaseNumber,RecordTypeId,RecordType.Name from Case where Id=:TargetId];
                 system.debug('Entered QUEUE');
                 Messaging.SingleEmailMessage[] mailsToSend = new Messaging.SingleEmailMessage[]{};
                 system.debug('Entered QUEUE COND');
                 
                 List<Id> queUserList = new List<Id>();
                 
                 List<GroupMember> queList = [Select Id, UserOrGroupId,GroupId,Group.type From GroupMember Where GroupId=:ActorId];
                 List<Id> groupUserList = new List<Id>();
                 for(GroupMember gm : queList)
                 {
                  String s = (String) gm.UserOrGroupId;
                     if(s.subString(0,3)=='005')
                     {
                     queUserList.add(gm.UserOrGroupId);
                     }
                     else if(s.subString(0,3)=='00G')
                     {
                         for(GroupMember gm1:[Select Id, UserOrGroupId,GroupId,Group.type From GroupMember Where GroupId=:gm.UserOrGroupId])
                         {
                         groupUserList.add(gm1.UserOrGroupId);
                         }
                     }
                 }
                 
              List<User> userList = [select Id,Name,Email from User where (Id IN : queUserList) OR (Id IN : groupUserList)];
            
              
              List<String> sendTo = new List<String>();
              for(User u : userList)
              {
                  
                  sendTo.add(u.Email);
              }    
                  Messaging.SingleEmailMessage email1 = new Messaging.SingleEmailMessage(); 
              email1.setToAddresses(sendTo);
              email1.setSubject('Items: pending for your approval');
             
              string domain = URL.getSalesforceBaseUrl().toExternalForm();
              string TargetLink = domain + '/' + string.valueof(TargetID);
              String body ='Dear ' + 'Approver' + ', ' + '<br/>' +'<br/>'+
                       'The following ' + TargetObjectType + ' is still pending your approval:' +'<br/>'+'<br/>'+
                       'Case Number : '+ TargetDesc +'<br/>' +'<br/>'+
                       'Case Record Type :'+c.RecordType.Name + '<br/>'+'<br/>'+
                       ' Click below link to view the full record: ' + '<br/>'+'<br/>'+
                       '<a href=\'' + TargetLink + '\'>' + TargetLink + '</a>' +'<br/>' +'<br/>'+
                       'Please DO NOT reply to this email.' ;
              email1.setHTMLBody(body);
              email1.setOrgWideEmailAddressId(fromEmailId);  
             mailsToSend.add(email1);
             
           	if(!Test.isRunningTest())
           	Messaging.sendEmail(mailsToSend);
           } 
            else if(ActorType!='Queue')
             {
                 email.setTargetObjectId(ActorID);
                 email.setWhatId(TargetID); 
             }
          
             //ends mass email coding toAddress
             
              
      system.debug('ACTOR ID'+ActorId);
        }
        
        else {
      
      system.debug('Entered since NULL EMAIL TEMP ID');
     // use a generic HTML email when no template is setup / found
 
     // get the current salesforce instance to build the link with
     string domain = URL.getSalesforceBaseUrl().toExternalForm();
     string TargetLink = domain + '/' + string.valueof(TargetID);
           
     email.setToAddresses(toAddresses);
       
     // set the subject on the email
     email.setSubject('Reminder: Item pending approval and a it is gentle reminder');
      
     // set the body of the email
     email.setHTMLBody('Dear ' + 'Approver' + ', ' +
                       'The following ' + TargetObjectType + ' is still pending your approval:' + 
                       TargetDesc + '' +
                       ' Click this link to view the full record: ' + 
                       '<a href=\'' + TargetLink + '\'>' + TargetLink + '</a>' +
                       'Please DO NOT reply to this email.'                     
     );
      
    }
        if(ActorType!='Queue'){
            Messaging.SingleEmailMessage[] EmailsToSend = new Messaging.SingleEmailMessage[] { email };
            try{
                if(!test.IsRunningTest())
                Messaging.sendEmail(EmailsToSend);
               }
               catch(Exception e)
               {
                   system.debug('Error in sending email:' +e.getmessage());
                   
               } 
            system.debug('SIZE OF EMAILS TO SEND LIST'+EmailsToSend.size()+'EMAILS TO SEND LIST'+EmailsToSend);
        }
    }
   
    public static ID FindEmailTemplateIDByDeveloperName(string DeveloperName)
    {
        id EmailTemplateID;
        system.debug('DEVELOPER NAME'+DeveloperName);
        List<EmailTemplate> EmailTemplateResults = new List<EmailTemplate>();
        if (DeveloperName != null)
        {
           EmailTemplateResults = [SELECT Id, Name, DeveloperName, IsActive FROM EmailTemplate WHERE DeveloperName = :DeveloperName];
           if (EmailTemplateResults.size() > 0)
           {
                if (EmailTemplateResults[0].IsActive == true)
                {
                     EmailTemplateID = EmailTemplateResults[0].id;
                } // check for active email template
           } // check for null search results  
       } // check for blank name
 
  system.debug('EMAIL TEMP RESULTS LIST SIZE'+EmailTemplateResults.size()+'EMAIL TEMP RESULTS LIST'+EmailTemplateResults);
  system.debug('Returning EmailTemplateID in FIND EMAIL TEMP METHOD'+EmailTemplateID);
  return EmailTemplateID;
  }
   
 
    
   global void execute(SchedulableContext scMain)
   {
       Case_ApprovalReminderEmails CARE = new Case_ApprovalReminderEmails();
       ID myBatch = Database.executeBatch(CARE,1);
   } 
    
}