/*******************************************************************************
Copyright © 2014 Motorola Solutions.
Author: Ashish Jain
Email: XPD643@motorolasolutions.com 
Date:  April 2014
Description:  Controller class for See all contact functionality 
which is using for searching the contact on basis of some filter criteria.
********************************************************************************/
public class AllContactsVisibility{

       private String soql {get;set;}
       private String accountKey {get;set;}
       private String contactKey {get;set;}           
       public String contactJobRole { get; set; }
       public String getJobRole { get; set; }
       public String Theater { get; set; }
       public String PBG {get; set;}
       public String contactName { get; set; }
       public String accountName { get; set; }
       public boolean flag{get;set;}
       public boolean recordsIown {get; set;}
       public List<ContactWrapper> flagTrueList;
       public List<ContactWrapper> flagFalseList;
       public List<ContactWrapper> finalList {get;set;} 
       public List<ContactWrapper> ConWList {get;set;}
       public List<Contact> ConList {get;set;}
       public List<Contact> contactsList { get;set; }
       public integer counter{get; set;} 
       public List<String> contactIdsList { get;set; } 
       Set<id> accountSet = new Set<Id>();
       public Contact con {get; set;}
       ContactSharingClass cts = new ContactSharingClass();
                              public AllContactsVisibility(){
                                list_size = 100;
                                counter = 0;
                                total_pageNo = 1;
                                PageMinRecord = 1;
                                PageMaxRecord = 0;
                                page_num = getPageNumber();
                              }
           /**ADDED BY SHANTHI AS PART OF SEPARATION***///        
                     Public String curUserid = UserInfo.getUserId();                
                                  /*END***/                        

// For Pagination code..
            public integer list_size {get;set;} 
            public integer total_size{get;set;}
            public boolean start= false;
            public integer page_num { get;set;}
            public integer total_pageNo {get;set;}
            public integer PageMinRecord {get;set;}
            public integer PageMaxRecord {get;set;}
            public PageReference SearchContact() { 
              counter = 0;                   
            if (contactName.length() > 0 && contactName.length()< 2){             
               ApexPages.Message myMsg2 = new ApexPages.Message(ApexPages.Severity.Error,'Please enter more then 2 character in Contact Name');
               ApexPages.addMessage(myMsg2);
                return null;
            }       
            if(Theater == null){        
               ApexPages.Message myMsg1 = new ApexPages.Message(ApexPages.Severity.Error,'Please select the Theater.');
               ApexPages.addMessage(myMsg1);
                return null;
           }          
            if (accountName.length() > 0 && accountName.length()< 2){
               ApexPages.Message myMsg3 = new ApexPages.Message(ApexPages.Severity.Error,'Please enter more then 2 characters in Account Name');
               ApexPages.addMessage(myMsg3);
                return null;
            }          
            if (contactJobRole.length() > 0 &&  contactJobRole.length() < 2){
               ApexPages.Message myMsg4 = new ApexPages.Message(ApexPages.Severity.Error,'Please enter more then 2 character in Job Role');
               ApexPages.addMessage(myMsg4);
                return null;
            }
            if (accountName.length() > 29){
               ApexPages.Message myMsg3 = new ApexPages.Message(ApexPages.Severity.Error,'Please enter less then 30 characters in Account Name');
               ApexPages.addMessage(myMsg3);
                return null;
            }
            if (contactName.length() > 29){             
               ApexPages.Message myMsg2 = new ApexPages.Message(ApexPages.Severity.Error,'Please enter less then 30 character in Contact Name');
               ApexPages.addMessage(myMsg2);
                return null;
            }           
// Code for Dynamic query building..
                 String tempAccKey = String.escapeSingleQuotes(accountName);
                 accountKey = '%'+tempAccKey +'%';
                 String tempContactKey = String.escapeSingleQuotes(contactName);     
                 contactKey ='%'+tempContactKey +'%';
             String soql = 'select ID,name,owner.email,Account.Id,Account.Name,Account.NameLocal,Account.Partner_Account_Name__c,ldap_login__c,Contact_Job_Role__c,Email,DoNotCall,HasOptedOutOfEmail,Phone,department,Contact_Owner_theater__c, owner.Name from contact where (Contact_Owner_theater__c = \''+Theater+'\' AND Contact_Owner_theater__c <> null) ' ;
                      system.debug('#### Plain soql now #########'+soql);
                  if( !(contactName == NULL || contactName =='') ){
                       soql += ' AND (name like \''+contactKey+'\')';
                       system.debug('#### soql now after adding Contact name #########'+soql);
                     }
                  if(!(accountName == NULL || accountName =='')){
                       soql += ' AND (account.name like \''+accountName+'\' or Account.NameLocal like \''+accountKey+'\' or Account.Partner_Account_Name__c like \''+accountKey+'\')';
                       system.debug('#### soql now after adding Account name #########'+soql);
                     }
                  if( !(contactJobRole== NULL || contactJobRole=='') && contactJobRole != '---None---'){
                      soql += ' AND Contact_Job_Role__c INCLUDES(\''+contactJobRole+'\')';
                      system.debug('#### soql now after adding Job Role #########'+soql);
                     }
                    /***ADDED BY SHANTHI AS PART OF SEPARATION****/     
                     User usr1 = [Select Id, Primary_Business_Group__c from User where id =:curUserid limit 1];  
                      PBG = usr1.Primary_Business_Group__c;                          
                      if(PBG == 'Enterprise' || PBG == 'Government' ){                            
                         soql+= ' AND (Account.Owner.Primary_Business_Group__c = \''+PBG+'\' OR Account.Shared_Partner__c=TRUE) ';
                         }
                    /**** END***/     
              soql += 'order by LastModifiedDate desc LIMIT 1000';
              system.debug('final soql'+soql);
              if(recordsIown!=true){
                  contactsList = Database.query(soql);                  
              }
              else 
              {
                  contactsList  = cts.getListWithoutOffset(soql);
              }
              total_size = contactsList.size();
              system.debug('total_size ' +total_size );
              ConWList = getoffsetList();
              page_num = getPageNumber();
              total_pageNo = getTotalPages();
              PageMaxRecord = getPageMaxRecord();
              PageMinRecord = getPageMinRecord();
            flag=false;
            if(ConWList != null && ConWList.size() > 0){
                flag=false;
            }else{
                flag=true;
            }
                trackVisits(); 
            return null;       
        }
// Code for pagination..             
        public List<ContactWrapper> getoffsetList(){
                 String tempAccKey = String.escapeSingleQuotes(accountName);     
                 accountKey = '%'+tempAccKey +'%';
                 String tempContactKey = String.escapeSingleQuotes(contactName);     
                 contactKey ='%'+tempContactKey +'%';
         String soql = 'select ID,name,owner.email,Account.Id,Account.Name,Account.NameLocal,Account.Partner_Account_Name__c,ldap_login__c,Contact_Job_Role__c,Email,DoNotCall,HasOptedOutOfEmail,Phone,department,Contact_Owner_theater__c, Owner.Name from contact where (Contact_Owner_theater__c = \''+Theater+'\' AND Contact_Owner_theater__c <> null) ' ;
                 
                      system.debug('#### Plain soql now #########'+soql);
        
                  if( !(contactName == NULL || contactName =='') ){
                       soql += ' AND (name like \''+contactKey+'\')';
                       system.debug('#### soql now after adding Contact name #########'+soql);
                     }
                  if(!(accountName == NULL || accountName =='')){
                       soql += ' AND (account.name like \''+accountKey+'\' or Account.NameLocal like \''+accountKey+'\' or Account.Partner_Account_Name__c like \''+accountKey+'\')';
                       system.debug('#### soql now after adding Account name #########'+soql);
                     }
                  if( !(contactJobRole== NULL || contactJobRole=='') && contactJobRole != '---None---'){
                      soql += ' AND Contact_Job_Role__c INCLUDES(\''+contactJobRole+'\')';
                      system.debug('#### soql now after adding Job Role #########'+soql);
                     }
                    /***ADDED BY SHANTHI AS PART OF SEPARATION****/   
                      User usr1 = [Select Primary_Business_Group__c from User where id =:curUserid limit 1];    
                       PBG=usr1.Primary_Business_Group__c;          
                        if(PBG=='Enterprise' || PBG=='Government' ){              
                          soql+= ' AND (Account.Owner.Primary_Business_Group__c = \''+PBG+'\' OR Account.Shared_Partner__c=TRUE) ';
                      }                                                         
                       /**** END***/     
            soql += 'order by LastModifiedDate desc LIMIT '+list_size+' OFFSET '+counter;
            system.debug('==== final soql with OFFSET ===='+soql);
              ConList =  new List<Contact>();
            if(recordsIown!=true){
                ConList = Database.query(soql);
                contactIdsList = new List<String>();
                    for(Contact c:ConList){
                        contactIdsList.add(c.id);                    
            }  
            List<UserRecordAccess> userRecordAccessList=new List<UserRecordAccess>();
           userRecordAccessList=[SELECT RecordId FROM UserRecordAccess WHERE UserId=:UserInfo.getUserId() AND RecordId IN : contactIdsList AND HasReadAccess = true];
             For(UserRecordAccess ur : userRecordAccessList)
             accountSet.add(ur.RecordId);
             }
              else
                ConList  = cts.getListWithOffset(soql);
              
              finalList = new List<ContactWrapper>();
              flagTrueList = new List<ContactWrapper>();
              flagFalseList = new List<ContactWrapper>();           
              for(Contact c : ConList){
               ContactWrapper tempWrap = new ContactWrapper();
                       tempWrap.ID = c.id;
                       tempWrap.Name = c.name;
                       tempWrap.AccountId = c.Account.Id;
                       tempWrap.AccountName = c.Account.Name;
                       tempWrap.Department =  c.department;
                       tempWrap.DoNotCall = c.DoNotCall;
                       tempWrap.HasOptedOutOfEmail = c.HasOptedOutOfEmail;
                       tempWrap.Theater = c.Contact_Owner_theater__c;
                       tempWrap.ContactJobRole = c.Contact_Job_Role__c;
                       tempWrap.ownerEmail = c.owner.email;
                       tempWrap.ownerName = c.owner.Name;
                       tempWrap.LdapID = c.LDAP_Login__c;      
                  
                   if(accountSet.contains(c.id)||recordsIown==true){
                       system.debug('****this all have access****'+c.id);
                        tempWrap.Email=c.Email; 
                        tempWrap.Phone=c.Phone;
                        tempWrap.checkFlag = true;   
                        flagTrueList.add(tempWrap);
                      }else{
                        System.debug('==inside Not Access ==');
                       if(c.email != null)
                            tempWrap.Email='*********'; 
                       if(c.phone != null)
                            tempWrap.Phone='*********';
                            tempWrap.checkFlag = false;                    
                            flagFalseList.add(tempWrap);  
                    }                                   
                 }
                   if(recordsIown!=true){
                            finalList.addAll(flagTrueList);
                            finalList.addAll(flagFalseList); 
                    }
                    else{
                            finalList.addAll(flagTrueList);
                       } 
             for(ContactWrapper cw : finalList){
                     if(cw.DoNotCall == true)
                      cw.Phone='Do Not Call';
                    if(cw.HasOptedOutOfEmail == true)
                      cw.Email='Do Not Email';
             }                              
            return finalList;
       }
//Code for pagination
            public PageReference Previous() { 
            system.debug('called previous method');
            counter -= list_size;   
            page_num = getPageNumber();
            total_pageNo = getTotalPages();
            PageMaxRecord = getPageMaxRecord();
            PageMinRecord = getPageMinRecord();
            ConWList = getoffsetList();
            return null;
        }    
        public PageReference Next() {
        system.debug('called next button');
            counter += list_size; 
            page_num = getPageNumber();
            total_pageNo = getTotalPages();
            PageMaxRecord = getPageMaxRecord();
            PageMinRecord = getPageMinRecord();
            ConWList = getoffsetList();
            return null;
        }
        public PageReference First() {

        system.debug('called first button');
            counter = 0;   
            page_num = getPageNumber();
            total_pageNo = getTotalPages();
            PageMaxRecord = getPageMaxRecord();
            PageMinRecord = getPageMinRecord();
            ConWList = getoffsetList();
            return null;
        }
        public PageReference Last() {
        system.debug('called last button');
            counter = (getTotalPages() * list_size) - (list_size); 
            page_num = getPageNumber();
            total_pageNo = getTotalPages();
            PageMaxRecord = getPageMaxRecord();
            PageMinRecord = getPageMinRecord();
            ConWList = getoffsetList();
            return null;
        }
        public Boolean getDisablePrevious() {
        system.debug('called disable previous');
            if (counter > 0) return false;
            else return true;
        }
        public Boolean getDisableNext() {
        system.debug('called disable next');
            if (counter + list_size < total_size) return false;
            else return true;
        }
        public Boolean getDisableFirst() {
        system.debug('called disable first');
            if (counter == 0) return true;
            else return false;
        }
        public Boolean getDisableLast() { 
        system.debug('called disable last'+counter +' , '+total_size);
           if (getPageNumber() == getTotalPages()) 
           return true;
           else return false;
        }
        public Integer getTotal_size() {
            return total_size;
        }
        public Integer getPageNumber() {
            return counter / list_size + 1;
        }
        public Integer getTotalPages() {
            if (math.mod(total_size, list_size) > 0) {
                return total_size / list_size + 1;
            } else {
                return (total_size / list_size);
            }    
        }
        public Integer getPageMinRecord(){
                if(total_size<100)
                  PageMinRecord = 1;
                else
                  PageMinRecord = 100 *(page_num - 1) +1 ;  
            
           return PageMinRecord;
        }
        /* public Integer getPageMaxRecord(){
                if(total_size<100)
                    PageMaxRecord = total_size; 
                else
                   PageMaxRecord = 100*page_num; 
           return  PageMaxRecord;
        }*/
         public Integer getPageMaxRecord(){
                  if(total_size<100){
                        PageMaxRecord = total_size; 
                  }else{
                      if(100*page_num > total_size ){
                            PageMaxRecord = total_size; 
                      }else{
                            PageMaxRecord = 100*page_num; 
                  }
              }
              return PageMaxRecord;
            }
        public List<SelectOption> getJobRole() {
            List<SelectOption> options = new List<SelectOption>();
            Schema.DescribeFieldResult fieldResult = Contact.Contact_Job_Role__c.getDescribe();
            List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
            options.add(new SelectOption('---None---', '---None---'));
             for( Schema.PicklistEntry f : ple)
               {
                 options.add(new SelectOption(f.getLabel(), f.getValue()));
               }  
        return options;
        }
     public void trackVisits(){
                          String temp = '';
                         if(contactJobRole == '---None---')
                                temp ='';
                            else
                                temp = contactJobRole;
               Track_Contact_Search__c newTracking = new Track_Contact_Search__c(User__c=UserInfo.getUserId(),Search_Date__c=datetime.now(),Contact__c=contactName ,Account__c=accountName,Contact_Job_Role__c=temp ,Theater_Searched__c=Theater);
               insert newTracking;      }
    }