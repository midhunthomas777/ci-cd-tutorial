/*
* Class Name- CaseInboundRestController
* Description - Inbound Integration Remedy/MSI/MyView to Salesforce
* Modification log
* ======================================================
* Ver   Date          Author        Modification 
* ----------------------------------------------------------
* 
*/


@RestResource(urlMapping = '/CaseRESTService/v1/*')
global with sharing class CaseInboundRestController {
    
    @HttpPost
    global static void createCase() {
        RestRequest req= RestContext.request;
        RestResponse res = RestContext.response;
        
        CaseResponseWrapper caseResObj = new CaseResponseWrapper();
        CaseResponseWrapper.CaseResponseHandler result = new CaseResponseWrapper.CaseResponseHandler();
        
        
        
        try{
            System.debug('RequestBody::'+req.requestBody);
            CaseRequestWrapper caseReqObj = (CaseRequestWrapper) JSON.deserializeStrict(req.requestBody.toString(), CaseRequestWrapper.class);
            System.debug('caseReqObj-->' + caseReqObj);
            Case newCase = new Case();
            
            /*Logic for Technical site Id assignment*/
            String techsite = caseReqObj.techSiteId;
            String thsite;
            Boolean createFeeditem = false;
            /*If Technical site id is passed*/
            if(techsite!=null){
                System.debug('techsite@@@'+techsite);
                List<Technical_Site__c> thList = [Select Id,Site_ID__c from Technical_Site__c where Site_ID__c=:techsite];
                if(thList.size()>0){
                    System.debug('Techsite###');
                    thsite = thList[0].id;
                }
                /*If Technical site id has different value  passed*/
                else {
                    createFeeditem=true;
                    result.warningMessage = 'Site Id not found: '+techsite;
                    
                }
            }
            
            
            /* Contact filtering solution */
            Id conSfId=caseReqObj.contactId;
            Id accountSfId;
         
            //if all parameters are null for MSI
            if(conSfId==null && String.isEmpty(caseReqObj.firstName) && String.isEmpty(caseReqObj.lastName) && String.isEmpty(caseReqObj.email) && String.isEmpty(caseReqObj.phone)){
                System.debug('Entering MSI logic@@');
                conSfId = null;
                accountSfId = null;
            }
            //Contact filtering solution for Remedy/MyView
            else if(conSfId!=null){
                System.debug('Contact not null::');
                Contact con = [Select AccountId from Contact where Id=:conSfId];
                accountSfId = con.AccountId;
            }
            else{
                System.debug('Contact Id null');
                /* Checking if FirstName and phone number in input is not null*/
                if(caseReqObj.firstName!=null && caseReqObj.phone!=null){
                    System.debug('Firstname and phone not null');
                    List<Contact> queryList1 = [Select Id,FirstName,LastName,Phone,Email,AccountId,LDAP_Login__c from Contact where LDAP_Login__c!=null
                                                AND FirstName=:caseReqObj.firstName AND LastName=:caseReqObj.lastName AND Phone=:caseReqObj.phone];
                    if(queryList1.size()==1){
                        System.debug('Check@@@'+queryList1.size());
                        conSfId = queryList1.get(0).Id;
                        accountSfId = queryList1.get(0).AccountId;
                    }
                    /* if no record returned from queryList1*/
                    else if(queryList1.size()==0){
                        System.debug('Check2@@@'+queryList1.size());
                        List<Contact> queryList2 = [Select Id,LastName,Email,LDAP_Login__c,AccountId from Contact where LastName=:caseReqObj.lastName and Email=:caseReqObj.Email]; //Remove WebUserId null check
                        if(queryList2.size()==1){
                            System.debug('Inside If');
                            conSfId = queryList2.get(0).Id;
                            accountSfId = queryList2.get(0).AccountId;
                        }
                        //Keep the record that has Ldap Login and assign the 1st record
                        else if(queryList2.size()>1){
                            System.debug('queryList2.size::'+queryList2.size());
                            for(Contact query2item:queryList2){  
                                if(query2item.LDAP_Login__c!=null){
                                    System.debug('query2Item with LdapLogin::');
                                    conSfId = query2item.Id;
                                    accountSfId = query2item.AccountId;
                                    // break;
                                }
                            }
                        }
                        /*Assignment of null contact Id and Account Id if queryList2.size = 0*/
                        /*Logic changed from default to null as per 17th February discussion*/
                        else {
                            System.debug('Assign null contact@@');
                            conSfId = null;
                            accountSfId = null;
                        }
                    }
                    /*If queryList1 returns more than 1 records*/
                    else{
                        System.debug('Inside 2nd Else');
                        List<Contact> queryList2 = [Select Id,LastName,Email,LDAP_Login__c,FirstName,Phone from Contact where LastName=:caseReqObj.lastName and Email=:caseReqObj.Email and FirstName=:caseReqObj.firstName
                                                    and Phone=:caseReqObj.Phone]; //Remove null check WebUser id
                        if(queryList2.size()==1){
                            System.debug('queryList2 size 1'+queryList2.size());
                            conSfId = queryList1.get(0).Id;
                            accountSfId = queryList1.get(0).AccountId;
                        }
                        
                      
                        //Keep the record that has Ldap Login and assign the 1st record
                        else if(queryList2.size()>1){
                            System.debug('queryList2.size::'+queryList2.size());
                            for(Contact query2item:queryList2){  
                                if(query2item.LDAP_Login__c!=null){
                                    System.debug('query2Item with LdapLogin');
                                    conSfId = query2item.Id;
                                    accountSfId = query2item.AccountId;
                                    // break;
                                }
                            }
                        }
                        /*Assignment of null contact Id and Account Id if queryList2.size = 0*/
                        /*Logic changed from default to null as per 17th February discussion*/
                        
                        else {
                            System.debug('Assigns null contact');
                            conSfId = null;
                            accountSfId = null;
                        }
                        
                    }
                }
                /* else block for NULL check for firstname and phone*/
                else {
                    System.debug('Entering last Else@@@');
                    //query for lastname and email
                    List<Contact> queryList1 = [Select LastName,Email,AccountId,LDAP_Login__c FROM Contact WHERE LastName=:caseReqObj.lastName AND Email=:caseReqObj.email]; //Remove Web_User_ID__c != null
                    if(queryList1.size() == 1) {
                        System.debug('OK@@');
                        conSfId = queryList1.get(0).Id;
                        accountSfId = queryList1.get(0).AccountId;
                    }
                    //more than 1 record for Lastname and Email
                    else if(queryList1.size()>1){
                        System.debug('queryList1.size in final else::'+queryList1.size());
                        for(Contact queryitem3:queryList1){  
                            if(queryitem3.LDAP_Login__c!=null){
                                System.debug('queryItem3 with LdapLogin');
                                conSfId = queryitem3.Id;
                                accountSfId = queryitem3.AccountId;
                                // break;
                            }
                        }
                    }
                    /*Assignment of null contact and Account if no records returned for lastname and email*/
                    /*Logic changed from default to null as per 17th February discussion*/
                    
                    else {
                        System.debug('Check5@@@');
                        conSfId = null;
                        accountSfId = null;
                    }
                }
            }
            System.debug('ContactId@@@'+conSfId);
            System.debug('AccountId@@@'+accountSfId);
            
            
            
            newCase.Origin = caseReqObj.caseOrigin;
            // newCase.Source_System__c = caseReqObj.dataSource;
            newCase.Priority = caseReqObj.priority;
            newCase.Impact__c = caseReqObj.impact;
            newCase.AccountId = accountSfId;
            newCase.Remedy_Incident_ID__c = caseReqObj.remedyId;
            newCase.Technical_Site__c = thsite;
            newCase.Subject = caseReqObj.title;
            newCase.Case_Type_1__c = caseReqObj.caseType1;
            newCase.Case_Type_2__c = caseReqObj.caseType2;
            newCase.Case_Type_3__c = caseReqObj.caseType3;
            //newCase.Case_Type_4__c = caseReqObj.caseType4;
            newCase.Description = caseReqObj.description;
            newCase.Additional_Info_1__c='RestAPI';
            //Addtional parameter used by MyView/MSI
            newCase.Route_Class_1__c = caseReqObj.region;
            newCase.CC_List__c = caseReqObj.ccList;
            
            /*Checks for passed queue name in parameter and queries existing records with
				* matching developername.If no match is found the running user is assigned as owner*/
            if(!String.ISEMPTY(caseReqObj.queueName))
            {
                List<Group> grp = [select Id from Group where Type = 'Queue' AND DeveloperNAME =: caseReqObj.queueName limit 1];
                
                if(!grp.isEmpty())
                {
                    Id ownerid = grp[0].Id; 
                    System.debug('Owner changed@@'+ownerid);
                    newcase.OwnerId = ownerid;
                   
                }
                else
                {
                    if(result.warningMessage!=null)
                        result.warningMessage = result.warningMessage + ' Queue not found: '+caseReqObj.queueName;
                    else
                        result.warningMessage = 'Queue not found: '+caseReqObj.queueName;
                    newcase.OwnerId = userInfo.getUserId();
                  
                }
            }
            else
            {
                newcase.OwnerId = userInfo.getUserId();
              
            }		
            newCase.ContactId = conSfId;
            
            
            /*Checks for passed recordtype name in parameter and queries existing records with
* matching developername.If no match is found the master recordtype is assigned*/
            if(!String.ISEMPTY(caseReqObj.recordtype))
            {
                List<RecordType> rt = [select id, Name from RecordType where SobjectType='case' and DeveloperName=: caseReqObj.recordtype Limit 1];
                if(!rt.isEmpty())
                {
                    Id recordtypeid = rt[0].Id; 
                    newcase.recordtypeid = recordtypeid;
                }
                else
                {
                    if(result.warningMessage!=null)
                        result.warningMessage = result.warningMessage + ' RecordType not found: '+caseReqObj.recordtype;
                    else
                        result.warningMessage = 'RecordType not found: '+caseReqObj.recordtype;
                }
            }
            
            //Logic for MCN
            if(!String.isEmpty(caseReqObj.mcn)){
                if(conSfId!=null && accountSfId!=null){
                    System.debug('conSfId/accountSfdId is::'+conSfId+' '+accountSfId);
                    System.debug('Contact present');
                    String csmcn = caseReqObj.mcn;
                    if(csmcn.length()>10){
                        csmcn = csmcn.substring(0,10);
                        
                    }
                    System.debug('csmcn new value::'+csmcn+''+csmcn.length());
                    if(!String.isEmpty(csmcn) && csmcn.length()==10){
                        System.debug('csmcn passed::'+csmcn+''+csmcn.length());
                        List<Account> accList = [Select Id,name,Motorola_Customer_Number__c,Customer_or_Prospect_Account__c from Account where Motorola_Customer_Number__c=:csmcn];
                        if(accList.size()==1){
                            System.debug('Selecting account'+accList);
                            newcase.Customer_Account__c = accList.get(0).Id;
                            newcase.customer_number__c = csmcn; 
                            
                           
                        }
                        else{
                            if(result.warningMessage!=null)
                                result.warningMessage = result.warningMessage + ' No matching MCN account found:'+caseReqObj.mcn;
                            else
                                result.warningMessage = 'No matching MCN account found:'+caseReqObj.mcn;
                            newcase.Customer_Number__c = csmcn;
                        }
                    }
                }
                else{
                    System.debug('null contact present');
                    String csmcn = caseReqObj.mcn;
                    if(csmcn.length()>10){
                        csmcn = csmcn.substring(0,10);
                        
                    }
                    System.debug('csmcn new value::'+csmcn+''+csmcn.length());
                    if(!String.isEmpty(csmcn) && csmcn.length()==10){
                         System.debug('csmcn passed==>'+csmcn+''+csmcn.length());
                        List<Account> accList = [Select Id,name,Motorola_Customer_Number__c,Customer_or_Prospect_Account__c from Account where Motorola_Customer_Number__c=:csmcn];
                        if(accList.size()==1){
                            System.debug('Selecting account in else::'+accList);
                            newcase.customer_number__c = csmcn; 
                        }
                        else{
                            System.debug('MCN not found');
                            if(result.warningMessage!=null)
                                result.warningMessage = result.warningMessage + ' No matching MCN account found:'+caseReqObj.mcn;
                            else
                                result.warningMessage = 'No matching MCN account found:'+caseReqObj.mcn;
                            
                              newcase.Customer_Number__c = csmcn;
                            
                        }
                    }
                    
                }
                
            }
            
            System.debug('Customer Account and Cust Acc number::'+ newcase.Customer_Account__c+' '+ newcase.Customer_number__c);
            insert newCase;
            System.debug('Case created::'+newCase);
            
            
            //Query for relating cs to parameters from CaseResponseWrapper
            Case cs =[Select Id,caseNumber,Status,isClosed from Case where Id=: newCase.Id];
            System.debug('Details@@@'+cs.Id+cs.CaseNumber+cs.Status+cs.isClosed);
            
            System.debug('createFeedItem::'+createFeedItem);
            /*If technical site is a different value create FeedItem*/
            if(createFeedItem==True){
                try{
                    FeedItem fi = new FeedItem();
                    fi.parentId = newCase.id;
                    fi.Body = 'Technical Site ID: ' + techsite;
                    fi.Type = 'TextPost';
                    insert fi;
                    System.debug('Chatter feed created:'+fi.id);
                }
                
                catch(exception ex){
                    System.debug('Check@@ line'+ex.getLineNumber()+ex.getMessage());
                }
            }
            
            
            //create chatter post if contact details don't match
            if(conSfId == null){
               System.debug('chatter post for contact::');
                
                FeedItem fi = new FeedItem();
                fi.parentId = newCase.id;
                fi.Body = 'Contact details:FirstName:' + caseReqObj.firstname + ' Lastname:' + caseReqObj.lastname+',Email:'+ caseReqObj.email + ',Phone:' + caseReqObj.phone;
                fi.Type = 'TextPost';
                insert fi;
                System.debug('Chatter feed created for contact:'+fi.id);
                
                  
                if(result.warningMessage !=null)
                 	 result.warningMessage = result.warningMessage +' Contact details not found:Firstname:' + caseReqObj.firstname + ' LastName:' + caseReqObj.lastname + ' Email:'+caseReqObj.email+' Phone:'+caseReqObj.phone;
                else
                     result.warningMessage = 'Contact details not found:Firstname:' + caseReqObj.firstname + ' LastName:' + caseReqObj.lastname + ' Email:'+caseReqObj.email+' Phone:'+caseReqObj.phone;
       
            }
            
            
            /*Mapping to CaseResponseWrapper parameters */
            result.isClosed = cs.IsClosed;
            result.caseStatus = cs.Status;
            result.casenumber = cs.caseNumber;
            result.caseId = newCase.Id;
            
            caseResObj.result = result;
            
            res.addHeader('Content-Type','application/json');
            res.StatusCode = 201;
            res.responseBody = Blob.valueOf(JSON.serialize(caseResObj,true));
        }
        
        
        catch(Exception e){
            result.message = e.getMessage();
            caseResObj.result = result;
            res.addHeader('Content-Type','application/json');
            res.responseBody = Blob.valueOf(JSON.serialize(caseResObj,true));
            System.debug('Exception at@@'+e.getMessage()+e.getLineNumber());
        }
        
    }
    
    
}