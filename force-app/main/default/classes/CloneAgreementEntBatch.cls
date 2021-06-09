global class CloneAgreementEntBatch implements Database.Batchable<Sobject>
{ 
     global String query;
     global set<Id> agreementids=new set<Id>();
     global set<Id> newagreementids=new set<Id>();
     global set<String> inactiveapprovalrequest=new set<String>();    
     global Map<String,Apttus__APTS_Agreement__c> PLmap=new Map<String,Apttus__APTS_Agreement__c>();
     global Database.QueryLocator start(Database.BatchableContext BC)  
     {
         
      query ='SELECT id,TobeClonedEnterprise__c FROM Apttus__APTS_Agreement__c where TobeClonedEnterprise__c=true and tobeprocessed__c=false';
               
      return Database.getQueryLocator(query);
                    
     }
     global void execute(Database.BatchableContext BC, List<Apttus__APTS_Agreement__c> scope) 
     {
                    
            try
            {  
            
                            
               
              for(Apttus__APTS_Agreement__c apt:scope)
              {
               agreementids.add(apt.id);
              }
               list<Apttus__APTS_Agreement__c> originalAgreement = new list<Apttus__APTS_Agreement__c>();
    list<Apttus__APTS_Agreement__c> newAgreementList = new list<Apttus__APTS_Agreement__c>();  
    list<Apttus__APTS_Agreement__c> updAgreementList = new list<Apttus__APTS_Agreement__c>();  
    
    list<Apttus_Approval__Approval_Request__c> originalApprovalRequest= new list<Apttus_Approval__Approval_Request__c>();
    list<Apttus_Approval__Approval_Request__c> newRequest= new list<Apttus_Approval__Approval_Request__c>();         
    
    originalAgreement =Database.query(setquery(agreementids));
    
     system.debug('testmain'+originalAgreement.size());
     if(originalAgreement.size()>0){
        newAgreementList = cloneAgreement(originalAgreement);
        insert newAgreementList;
        system.debug('***********process start:Agreement Insert***************'+newAgreementList.size());

        }
     for(Apttus__APTS_Agreement__c newagreeset: newAgreementList)
     {
     newagreementids.add(newagreeset.id);
     }
     
     
     getApprovalRequest(originalAgreement,newAgreementList );
     getApprovalRequest2(originalAgreement,newAgreementList );  
     getApprovalRequest1(originalAgreement,newAgreementList );     
     updateapprovals(newagreementids);   
     
    for(Apttus__APTS_Agreement__c tech:originalAgreement)
       {
       PLmap.put(tech.Name,tech);  
       }
       if(originalAgreement.size()>0)
       {
       for(Apttus__APTS_Agreement__c uplist:newAgreementList)
       {
       if(PLmap.containsKey(uplist.name))
       {
        uplist.Reason_for_Cancellation__c=PLmap.get(uplist.name).Reason_for_Cancellation__c;
        uplist.Apttus__Status_Category__c=PLmap.get(uplist.name).Apttus__Status_Category__c;       
        uplist.Apttus__Status__c=PLmap.get(uplist.name).Apttus__Status__c;       
        uplist.Apttus_Approval__Approval_Status__c=PLmap.get(uplist.name).Apttus_Approval__Approval_Status__c; 
         
        uplist.Signed_Executed_Agreement__c=PLmap.get(uplist.name).Signed_Executed_Agreement__c;
        uplist.Ready_For_Submission__c=PLmap.get(uplist.name).Ready_For_Submission__c;
        uplist.TobeClonedEnterprise__c=false;
        uplist.Reason_for_Cancellation__c=PLmap.get(uplist.name).Reason_for_Cancellation__c;
        uplist.Ready_For_Submission__c=PLmap.get(uplist.name).Ready_For_Submission__c;
        updAgreementList.add(uplist);
       
       }
       
      
       }
       update updAgreementList;
        updateOldAgreement(originalAgreement);
       }
       
                    
       }
             catch(Exception ex)
             {
                  system.debug('exception'+ex.getmessage());
             }         
          
     }
   
   //Method to update old Agreement
global void updateOldAgreement(list<Apttus__APTS_Agreement__c> oldagreeementList){
    for(Apttus__APTS_Agreement__c agreement : oldagreeementList){
        agreement.Tobeprocessed__c=true;      

    }
    update oldagreeementList;
}

   
   
   
     
     //Method to clone and insert Sobject except approval request and agreement
global void getApprovalRequest(list<Apttus__APTS_Agreement__c> originalAgreement
                                    ,list<Apttus__APTS_Agreement__c> newAgreementList){

    List<String> objectnames = new List<String>();
    List<String> fieldnames = new List<String>();

    system.debug('***********startofgetapprovalmethod************');
    Map<String,list<Sobject>> approvalRequestListMaps = new Map<String,list<Sobject>>();
    list<Sobject> newApprovalRequestList = new list<Sobject>(); 
    list<id> agreementID = new list<id>();
    String aIds;
    for(Apttus__APTS_Agreement__c agreement: originalAgreement){
        agreementID.add(agreement.id);
        if(aIds == null)
            aIds = '\''+agreement.id+'\'';
        else
            aIds += ',\''+ agreement.id+'\'';
    }
    aIds = '('+aIds +')';
    
    Apttus__APTS_Admin__c admins = [SELECT Id,
                                    Name,
                                    Apttus__Value__c,
                                    Apttus__Code__c
                                    FROM Apttus__APTS_Admin__c
                                    WHERE Name = :Label.ApttusConfig
                                    LIMIT 1];
    
//string stringlist=admins.Apttus__Code__c;
String str = admins.Apttus__Code__c;
List<String> strings=str.split(',');
 string objname;
 string fldname;
 
for(Integer i =0; i < strings.size(); i++){
    Integer sum = math.mod(i,2);
      if (sum == 0 ) {
            objname= strings[i];
            objectnames.add(objname);
         } else {
             fldname= strings[i];
             fieldnames.add(fldname);
         }
         
     }
   
   
   for(Integer i =0; i < objectnames.size(); i++){
    list<Sobject> newApprovalRequestList1 = new list<Sobject>(); 
    system.debug('******objectnameeee*********'+objectnames[i]);
    
    newApprovalRequestList1= Database.query(sobjetQuery(objectnames[i],fieldnames[i],'in',aIds,''));
   system.debug('testquery'+newApprovalRequestList1);
        for(Apttus__APTS_Agreement__c agmtList : newAgreementList) {
            if(newApprovalRequestList1 != null && newApprovalRequestList1.size() > 0 ){
              system.debug('******newApprovalRequestList1 size*********'+newApprovalRequestList1.size());
              for(sObject sobj:newApprovalRequestList1) {   
                    system.debug('******fieldname*********'+fieldnames[i]);  
                    sObject TempSobj=sobj.clone(false,true);                    
                    TempSobj.put(fieldnames[i], agmtList.id);                    
                    newApprovalRequestList.add(TempSobj);
                 
                }
            }
       }
       
   }
   
   
    

     if(newApprovalRequestList.size()>0)
    {
   //  system.debug('testmad'+newApprovalRequestList);
     insert newApprovalRequestList;
    }
  
    
    }


global void getApprovalRequest1(list<Apttus__APTS_Agreement__c> originalAgreement
                                    ,list<Apttus__APTS_Agreement__c> newAgreementList){

    List<String> objectnames = new List<String>();
    List<String> fieldnames = new List<String>();

    system.debug('***********startofgetapprovalmethod************');
    Map<String,list<Sobject>> approvalRequestListMaps = new Map<String,list<Sobject>>();
    list<Sobject> newApprovalRequestList = new list<Sobject>(); 
    list<id> agreementID = new list<id>();
    String aIds;
    for(Apttus__APTS_Agreement__c agreement: originalAgreement){
        agreementID.add(agreement.id);
        if(aIds == null)
            aIds = '\''+agreement.id+'\'';
        else
            aIds += ',\''+ agreement.id+'\'';
    }
    aIds = '('+aIds +')';
    
    Apttus__APTS_Admin__c admins = [SELECT Id,
                                    Name,
                                    Apttus__Value__c,
                                    Apttus__Code__c
                                    FROM Apttus__APTS_Admin__c
                                    WHERE Name = 'APTS_SummaryOutputConfig2'
                                    LIMIT 1];
    
//string stringlist=admins.Apttus__Code__c;
String str = admins.Apttus__Code__c;
List<String> strings=str.split(',');
 string objname;
 string fldname;
 
for(Integer i =0; i < strings.size(); i++){
    Integer sum = math.mod(i,2);
      if (sum == 0 ) {
            objname= strings[i];
            objectnames.add(objname);
         } else {
             fldname= strings[i];
             fieldnames.add(fldname);
         }
         
     }
   
   
   for(Integer i =0; i < objectnames.size(); i++){
    list<Sobject> newApprovalRequestList1 = new list<Sobject>(); 
    system.debug('******objectnameeeeapproval*********'+objectnames[i]);
    
    newApprovalRequestList1= Database.query(sobjetQuery(objectnames[i],fieldnames[i],'in',aIds,''));
   
        for(Apttus__APTS_Agreement__c agmtList : newAgreementList) {
            if(newApprovalRequestList1 != null && newApprovalRequestList1.size() > 0 ){
              system.debug('******newApprovalRequestList1 size*********'+newApprovalRequestList1.size());
              for(sObject sobj:newApprovalRequestList1) {   
                    system.debug('******fieldname*********'+fieldnames[i]);  
                    sObject TempSobj=sobj.clone(false,true);
                    TempSobj.put(fieldnames[i], agmtList.id);
                   system.debug('testing1'+TempSobj.get('Apttus_Approval__Actual_Approver__c'));
                  String str1= String.valueOf(TempSobj.get('Apttus_Approval__Assigned_To_Id__c'));
                  list<user> u=[select IsActive from user where id =:str1 limit 1];
                  if(u.size()>0){
                  boolean qry=u[0].Isactive;
                  system.debug('madhavi'+qry);
                  if((TempSobj.get('ApproveActiveorinactive__c')==true && qry==true) || ((TempSobj.get('Apttus_Approval__Actual_Approver__c')=='' ||TempSobj.get('Apttus_Approval__Actual_Approver__c')==null) && qry==true))
                   newApprovalRequestList.add(TempSobj);
                   }
                   else 
                   {
                   system.debug('checking');
                   if((TempSobj.get('ApproveActiveorinactive__c')==true) || ((TempSobj.get('Apttus_Approval__Actual_Approver__c')=='' ||TempSobj.get('Apttus_Approval__Actual_Approver__c')==null)))
                   newApprovalRequestList.add(TempSobj);
                   }
                                    
                }
            }
       }
       
   }
   
   
    

     if(newApprovalRequestList.size()>0)
    {
    // system.debug('testmad1'+newApprovalRequestList.size());
     insert newApprovalRequestList;
    }
  
    
    }



global void getApprovalRequest2(list<Apttus__APTS_Agreement__c> originalAgreement
                                    ,list<Apttus__APTS_Agreement__c> newAgreementList){

    List<String> objectnames = new List<String>();
    List<String> fieldnames = new List<String>();

    system.debug('***********startofgetapprovalmethod************');
    Map<String,list<Sobject>> approvalRequestListMaps = new Map<String,list<Sobject>>();
    list<Sobject> newApprovalRequestList = new list<Sobject>(); 
    list<id> agreementID = new list<id>();
    String aIds;
    for(Apttus__APTS_Agreement__c agreement: originalAgreement){
        agreementID.add(agreement.id);
        if(aIds == null)
            aIds = '\''+agreement.id+'\'';
        else
            aIds += ',\''+ agreement.id+'\'';
    }
    aIds = '('+aIds +')';
    
    Apttus__APTS_Admin__c admins = [SELECT Id,
                                    Name,
                                    Apttus__Value__c,
                                    Apttus__Code__c
                                    FROM Apttus__APTS_Admin__c
                                    WHERE Name = 'APTS_SummaryOutputConfig3'
                                    LIMIT 1];
    
//string stringlist=admins.Apttus__Code__c;
String str = admins.Apttus__Code__c;
List<String> strings=str.split(',');
 string objname;
 string fldname;
 
for(Integer i =0; i < strings.size(); i++){
    Integer sum = math.mod(i,2);
      if (sum == 0 ) {
            objname= strings[i];
            objectnames.add(objname);
         } else {
             fldname= strings[i];
             fieldnames.add(fldname);
         }
         
     }
   
   
   for(Integer i =0; i < objectnames.size(); i++){
    list<Sobject> newApprovalRequestList1 = new list<Sobject>(); 
    system.debug('******objectnameeee*********'+objectnames[i]);
    
    newApprovalRequestList1= Database.query(sobjetQuery(objectnames[i],fieldnames[i],'in',aIds,''));
   
        for(Apttus__APTS_Agreement__c agmtList : newAgreementList) {
            if(newApprovalRequestList1 != null && newApprovalRequestList1.size() > 0 ){
              system.debug('******newApprovalRequestList1 size*********'+newApprovalRequestList1.size());
              for(sObject sobj:newApprovalRequestList1) {   
                    system.debug('******fieldname*********'+fieldnames[i]);  
                    sObject TempSobj=sobj.clone(false,true);                    
                    TempSobj.put(fieldnames[i], agmtList.id);
                    string val=String.valueOf(TempSobj.get('Ownerid'));
                    list<user> u=[select id,name,isactive from user where id =:val and isactive=false limit 1];
                    if(u.size()>0)
                    {
                    TempSobj.put('Ownerid','00580000003QSCJ');
                    newApprovalRequestList.add(TempSobj);
                    }
                    else
                    newApprovalRequestList.add(TempSobj);
                 
                }
            }
       }
       
   }
   
   
    

     if(newApprovalRequestList.size()>0)
    {
    // system.debug('testmad'+newApprovalRequestList);
     insert newApprovalRequestList;
    }
  
    
    }



global string setquery(set<id> agreementids )
{
 string query='';
   Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
   // List<String,Schema.SObjectType> gd = Schema.getGlobalDescribe(); 
    Map<String, Schema.SObjectField> fieldMap = schemaMap.get('Apttus__APTS_Agreement__c').getDescribe().fields.getMap();
    Schema.sObjectType T = schemaMap.get('Apttus__APTS_Agreement__c');
    Schema.DescribesObjectResult metadata = T.getDescribe();
    for (Schema.SObjectField field : metadata.fields.getMap().values()) {
        // use the fully qualified field name as the key
        Schema.DescribeFieldResult fldMetadata = field.getDescribe();
        
        if((query == null || query == '' ) && fldMetadata.iscalculated() == false) {
            query = field+'';
        }else if(fldMetadata.iscalculated() == false){
            query = query + ',' + field+'';
        }
   
    } 
String soql='Select '+query +',Agreementownerbusinessunit__c,Hidden_Record_Type_Name__c from Apttus__APTS_Agreement__c where id in : agreementids';
return soql;

}

//Method to get the fields of Sobject dynamically
global String sobjetQuery( String SobjectApiName , String conditionalField ,String condition,String comparingFieldvalue,String additionalFields ){
    String query = '';

    system.debug('*******SobjectApiName********' + SobjectApiName);
    Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
    system.debug('*******schemaMap********' +schemaMap);
    system.debug('*******schemaMap.get(SobjectApiName)********' +schemaMap.get(SobjectApiName));
    Map<String, Schema.SObjectField> fieldMap = schemaMap.get(SobjectApiName).getDescribe().fields.getMap();
     
    for(String fieldName : fieldMap.keyset()){
        if(query == null || query == ''){
            query = fieldName;
        }else{
            query = query + ',' + fieldName;
        }
     
    }
    if(additionalFields != null && additionalFields != '')
             query = 'Select' + ' ' + query +','+additionalFields+' '+' from ' + SobjectApiName;
    else
             query = 'Select' + ' ' + query+' '+'  from ' + SobjectApiName;
    system.debug('------------>'+query);
    if((conditionalField != null && conditionalField != '' ) && (condition != null && condition != '') && (comparingFieldvalue != null && comparingFieldvalue != null))
             query = query + ' ' + 'Where '+conditionalField+' '+condition+' '+comparingFieldvalue;
     
      system.debug('===query123 ====>'+query);        
     
    return query;
    }
  
 
    
global sObject createObject(String typeName) {
        Schema.SObjectType targetType = Schema.getGlobalDescribe().get(typeName);
        if (targetType == null) {
            return null;
    
        }
        
        return targetType.newSObject(); 
    }    
    



//Method to clone agreement 
global list<Apttus__APTS_Agreement__c> cloneAgreement(list<Apttus__APTS_Agreement__c> originalAgreement){
    list<Apttus__APTS_Agreement__c> newagreementList = new list<Apttus__APTS_Agreement__c>();
    Datetime dateTimetemp = System.now();
    Date dateTemp = Date.newInstance(dateTimetemp.year(),dateTimetemp.month(),dateTimetemp.day());
    String x=dateTemp.format();
    for(Apttus__APTS_Agreement__c newAgreement: originalAgreement){
        Apttus__APTS_Agreement__c agreement = new Apttus__APTS_Agreement__c();
        agreement=newagreement.clone(false,True);
       /* agreement.Signed_Executed_Agreement__c=null;
        agreement.Ready_For_Submission__c=null;
        agreement.Apttus_Approval__Approval_Status__c='';
        agreement.Reason_for_Cancellation__c='';
        agreement.Apttus__Status_Category__c='';
        agreement.Apttus__Status__c='';
        agreement.m_Business_Unit__c='';
        agreement.Apttus_Approval__Approval_Status__c='';
        agreement.Reason_for_Cancellation__c=newagreement.Reason_for_Cancellation__c;
        agreement.Apttus__Status_Category__c=newagreement.Apttus__Status_Category__c;       
        agreement.Apttus__Status__c=newagreement.Apttus__Status__c;       
        agreement.Apttus_Approval__Approval_Status__c=newagreement.Apttus_Approval__Approval_Status__c; 
         
        agreement.Signed_Executed_Agreement__c=newagreement.Signed_Executed_Agreement__c;
        agreement.Ready_For_Submission__c=newagreement.Ready_For_Submission__c;
       
        agreement.Reason_for_Cancellation__c=newagreement.Reason_for_Cancellation__c;
        agreement.Ready_For_Submission__c=newagreement.Ready_For_Submission__c;*/
        agreement.Hidden_Record_Type_Name_Original__c=newagreement.Hidden_Record_Type_Name__c;
        agreement.TobeClonedEnterprise__c=false;        
        agreement.m_Business_Unit__c='Enterprise';
      
        if(newagreement.Agreementownerbusinessunit__c!='Enterprise')   
        {
        agreement.OwnerId='00580000003QSCJ';
        }  
          
        newagreementList.add(agreement);
        
    }
    system.debug('=========  newagreementList=='+newagreementList);
    return newagreementList;
     
}
//Method to update Approval request object(new approvals) to avoid Issue of Approval deletion
global void updateapprovals(set<id> newagreementids)
 {
list<Apttus_Approval__Approval_Request__c> updateapprovalslist=[select Id,Apttus_Approval__Object_Id__c,ApproveActiveorinactive__c,Apttus_Approval__Related_Agreement__c from  Apttus_Approval__Approval_Request__c where Apttus_Approval__Related_Agreement__c in: newagreementids];
  List<Apttus_Approval__Approval_Request__c> Listtoupdateapprovals= new list<Apttus_Approval__Approval_Request__c>();
     for(Apttus_Approval__Approval_Request__c newreqtoupdate : updateapprovalslist){
           
           newreqtoupdate.Apttus_Approval__Object_Id__c =newreqtoupdate.Apttus_Approval__Related_Agreement__c;
           Listtoupdateapprovals.add(newreqtoupdate);
           
           }
 if(Listtoupdateapprovals.size()>0)
 update Listtoupdateapprovals;
 
   }
     global void finish(Database.BatchableContext BC)    
     {
   /*  Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
mail.setToAddresses(new String[] {'cdxp73@motorolasolutions.com'});
mail.setSubject('Inactive APproval Agreements');
//String messageBody = '<html><body>Hi, welcome to &nbsp;&nbsp;&nbsp;Our World <br/></body>  </html>';
system.debug('testing123'+inactiveapprovalrequest);
String messageBody='hello'+inactiveapprovalrequest;
system.debug('testmessage'+messageBody);
mail.setHtmlBody(messageBody); 
if(inactiveapprovalrequest.size()>0)
Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });*/
     }
      
}