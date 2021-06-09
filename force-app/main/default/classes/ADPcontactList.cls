/*  
* File Name     : ADPcontactList
* Description   : This class is used for New case creation via ADP partner portal.
* Modification Log
* ===================================================================================================================================
*   Ver     Date         Author                      Modification
*------------------------------------------------------------------------------------------------------------------------------------
*   1.0     07-Dec-16    Hari Krishna              Initial Creation
    2.0     20-Feb-16    Madhavi Latha pannala     Adittion of case creation screen,Related list,Modification to existing code
*/
public class ADPcontactList{
        
        public Contact obj{get;set;}
        list<String> Acontact;
        public id accid;
        Public case cas{get;set;}//included by madhavi
        Public list<Account> PAccounts;
        public string accname{get;set;}
        public string ownname{get;set;}
        
        //@testVisible 
        private ApexPages.StandardController stdController;
        
        public ADPcontactList(ApexPages.StandardController controller) 
        {   
        User u = [select Id,username,contactid,accountid,account.name,name  from User where Id =:  userinfo.getuserid()];  
        accid= u.accountid;
       // accid='0018000000k5E5v';
        //included by madhavi
        cas=new case (RecordTypeId = [SELECT id from RecordType where Name ='ADP Partner Contact Request'].Id, Accountid=accid, status='new', Priority='Low');
        ownname=u.name;
        accname=u.account.name;
       // Account acclist=[select id,ADP_Global_Account_Name1__r.id from account where id =: accid];
        this.stdController = controller; 
        }
         
        public list<Contact> getContacts()
        {
           account acc11=[select id,ADP_Global_Account_Name1__r.id from account where id =: accid];
           list<id> accids = new list<id>();
          for(account a: [select id from account where ADP_Global_Account_Name1__r.id =: acc11.ADP_Global_Account_Name1__r.id and ADP_Global_Account_Name1__r.Name<>null])
          {
              accids.add(a.id);
          }
          if(accids.size()>0){
          //select id, name, contactid, accountid,IsActive from user where IsActive = true and contactid<>'' 
          list<contact> listcontact = [select name,tag__c,Email,Title from contact where tag__c includes ('ADP')  and accountid IN: accids];
          if(listcontact!=null && listcontact.size()>0){
              return listcontact;
          }
          else{
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.info,'No Contacts available'));
            return null;
            }
          }else
          {
          ApexPages.addmessage(new ApexPages.message(ApexPages.severity.info,'No accounts available for you'));
        return null;
          }
         
        }
        public PageReference redirect()
        {
          // pageReference  pageRef = new PageReference('/500/e?retURL=' + accid+ 'RecordType=0121b000000Ck7q&ent=Case&cas4_lkid=' + accid+ '&cas7=New');   
            //  Case case1 = new Case( RecordTypeId = '0121b000000Ck7q', Accountid=accid, status='new', Priority='Low') ;
                           
               pageReference  pageRef = new PageReference('/apex/DisplayNewCaseDetails');         
             
                pageRef.setRedirect(true);
                return pageref;
        }
       //included by Madhavi
       public list<Case> getCases()
        {
           account acc11=[select id,ADP_Global_Account_Name1__r.id from account where id =: accid];
           list<id> accids = new list<id>();
          for(account a: [select id from account where ADP_Global_Account_Name1__r.id =: acc11.ADP_Global_Account_Name1__r.id and ADP_Global_Account_Name1__r.Name<>null])
          {
              accids.add(a.id);
          }
          if(accids.size()>0){
          //select id, name, contactid, accountid,IsActive from user where IsActive = true and contactid<>'' 
          list<case> listcase = [select subject,priority,id,Due_Date__c,status,CaseNumber,createddate,recordtypeid,recordtype.name,createdby.name,Comments__c,reason from case where recordtype.name='ADP Partner Contact Request' and accountid IN: accids ];
          if(listcase!=null && listcase.size()>0){
              return listcase;
          }
          else{
           // ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Info,'No Cases available'));
            return null;
            }
          }else
          {
          ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Info,'No accounts available for you'));
        return null;
          }
         
        }
      
        
       // public static String cId{get;set;}
       // Written by hari
       // Commented by madhavi as this may be used in future
     /*   @future
        public static void removeADP() 
        {
        Contact Cnt=[select Id,tag__c,accountID from Contact where id =:cId];
        User usr= [select Id,username,UserRoleId,IsPortalEnabled,contactid,accountid,IsActive from User where contactId =: cId];
        //UserRole urole = [SELECT Id,DeveloperName FROM UserRole WHERE DeveloperName ='A1COMMSLTDPartnerExecutive'];
            List<User> usersToUpdate;
            System.debug('+++++++++++++63'+Cnt); 
            if(Cnt!=null && Cnt.Tag__c!=null && (Cnt.Tag__c.equalsIgnoreCase('ADP') || Cnt.Tag__c.equalsIgnoreCase('SFDC Partner Admin;ADP'))){
            if(usr.IsActive || usr.IsPortalEnabled ) {
                System.debug('+++++++++++++67'+usr); 
                //usr.ContactId=null;
                usr.IsActive = false;
                //usr.IsPortalEnabled = false;
                //usr.UserRoleId = urole.Id;
                update usr;
                //System.assert(false,usr);
                //usersToUpdate.add(usr);
            }
                System.debug('+++++++++++++65'+Cnt); 
            //User usr= [select Id,username,contactid,accountid,IsActive  from User where contactId =: Cnt.Id];
           usr.IsActive=false;
            usr.ContactId=null;
            //usr.IsPortalEnabled =false; 
            update usr; 
            delete cnt; 
            } 
            else if(Cnt!=null && Cnt.Tag__c!=null && Cnt.Tag__c.contains('ADP')){
            String Tag=Cnt.Tag__c;
            System.debug('+++++++++++++88'+Tag);
            String NTag= Tag.replace('ADP','');
            System.debug('+++++++++++++90'+NTag);
            Cnt.Tag__c=NTag;
            update Cnt;    
        } 
            
        
        System.debug('+++++++++++++96'+Cnt);
       // return null;    
        }*/
       
        
                
        //included by madhavi
         public PageReference Backtocontactslist()
        {
           pageReference  pageRef = new PageReference('/apex/ADP_Partner_Contacts?id='+accid);   
                
                pageRef.setRedirect(true);
                return pageRef;
        }
        public PageReference savecasedetails()
        {
           try
           {
           cas.reason='';
           insert cas;
           }
           catch(exception ex)
           {
           this.cas.addError(ex.getMessage());
                return null;            
           }
           pageReference  pageRef = new PageReference('/apex/ADP_Partner_Contacts?id='+accid);   
                
                pageRef.setRedirect(true);
                return pageRef;
        }
        }