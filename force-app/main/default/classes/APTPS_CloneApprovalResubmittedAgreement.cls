public  class APTPS_CloneApprovalResubmittedAgreement {


public static final String PROP_SUMMARYOUTPUT_CONFIG = 'APTS_SummaryOutputConfig';

public void mainmethod(ID ParentId){
   
    list<Apttus__APTS_Agreement__c> originalAgreement = new list<Apttus__APTS_Agreement__c>();
    list<Apttus__APTS_Agreement__c> newAgreementList = new list<Apttus__APTS_Agreement__c>();
   
    list<Apttus__APTS_Related_Agreement__c> relatedagreementToInsert2 = new list<Apttus__APTS_Related_Agreement__c>(); 
    list<Apttus_Approval__Approval_Request__c> originalApprovalRequest= new list<Apttus_Approval__Approval_Request__c>();
    list<Apttus_Approval__Approval_Request__c> newRequest= new list<Apttus_Approval__Approval_Request__c>();  
   
 
        originalAgreement = getagreementList(ParentId);
    if(originalAgreement.size()>0){
        newAgreementList = cloneAgreement(originalAgreement);
        insert newAgreementList;
        system.debug('***********process start:Agreement Insert***************'+newAgreementList.size());

        }
     
        getApprovalRequest(originalAgreement,newAgreementList );
     
 
        Apttus__APTS_Related_Agreement__c newRelatedAgreement = new Apttus__APTS_Related_Agreement__c();
        newRelatedAgreement.Name='Snapshot Agreement';
        newRelatedAgreement.Apttus__APTS_Contract_From__c=originalAgreement[0].Id;
        newRelatedAgreement.Apttus__APTS_Contract_To__c= newAgreementList[0].Id;
        newRelatedAgreement.Apttus__Relationship_From_Type__c='Is Snapshot of';
        newRelatedAgreement.Apttus__Relationship_To_Type__c='Is Snapshot for';
        insert newRelatedAgreement;
       
        updateOldAgreement(originalAgreement);
        updateAgreement(newAgreementList);
        updateapprovals(newAgreementList[0].Id);
          

}

//Method to update old Agreement
public void updateOldAgreement(list<Apttus__APTS_Agreement__c> oldagreeementList){
    for(Apttus__APTS_Agreement__c agreement : oldagreeementList){
        agreement.Apttus__Status__c = 'Submitted Request';
        agreement.Apttus__Status_Category__c='Request';
        agreement.Apttus_Approval__Approval_Status__c='Not Submitted';
        agreement.Verified_By_Finance__c=false;
        agreement.Verified_By_Legal__c=false;   
        agreement.Finance_Verified_By__c='';
        agreement.Legal_Verified_By__c='';
        agreement.APTPS_Ready_For_Approval__c=false;      

    }
    update oldagreeementList;
}


public void updateAgreement(list<Apttus__APTS_Agreement__c> newAgreementList){
    for(Apttus__APTS_Agreement__c agreement : newAgreementList){
         agreement.Apttus__Status__c = 'Previously Approved';
         agreement.Apttus__Status_Category__c='Previously Approved';
         agreement.Hidden_Sales_Apex_Trigger_Update__c=Datetime.Now();

    }
        update newAgreementList;
    }


//Method to clone and insert Sobject 
public void getApprovalRequest(list<Apttus__APTS_Agreement__c> originalAgreement
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
                                    WHERE Name = :PROP_SUMMARYOUTPUT_CONFIG
                                    LIMIT 1];
    
//string stringlist=admins.Apttus__Code__c;
String str = admins.Apttus__Code__c;
List<String> strings=str.split(',');
 string objname;
 string fldname;
 
for(Integer i =0; i < strings.size(); i++){
    Integer sum = math.mod(i,2);
      if (sum == 0) {
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
                    newApprovalRequestList.add(TempSobj);
                 
                }
            }
       }
   }
   
  
   insert newApprovalRequestList;
 
    
    }

//Method to get the fields of Sobject dynamically
public String sobjetQuery( String SobjectApiName , String conditionalField ,String condition,String comparingFieldvalue,String additionalFields ){
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
             query = 'Select' + ' ' + query+' '+' from ' + SobjectApiName;
    system.debug('------------>'+query);
    if((conditionalField != null && conditionalField != '' ) && (condition != null && condition != '') && (comparingFieldvalue != null && comparingFieldvalue != null))
             query = query + ' ' + 'Where '+conditionalField+' '+condition+' '+comparingFieldvalue;
     
      system.debug('===query123 ====>'+query);        
     
    return query;
    }
  
 
    
public sObject createObject(String typeName) {
        Schema.SObjectType targetType = Schema.getGlobalDescribe().get(typeName);
        if (targetType == null) {
            return null;
    
        }
        
        return targetType.newSObject(); 
    }    
    

//Method to get agreementList for clone
public list<Apttus__APTS_Agreement__c> getagreementList(ID ParentId){
    list<Apttus__APTS_Agreement__c> agreementListtoproceed = new list<Apttus__APTS_Agreement__c>();

 
        String aIds = null;

        if(aIds == null)
            aIds = '\''+ParentId+'\'';
        else
            aIds += ',\''+ParentId+'\'';
    system.debug('==========This is parentId2=========='+sobjetQuery1('Apttus__APTS_Agreement__c','Id','=',aIds,''));
           // aIds ='('+aIds +')';
    agreementListtoproceed = Database.query(sobjetQuery1('Apttus__APTS_Agreement__c','Id','=',aIds,''));                        
          system.debug('==========This is parentId=========='+sobjetQuery1('Apttus__APTS_Agreement__c','Id','=',aIds,''));
    return agreementListtoproceed;
}

public String sobjetQuery1( String SobjectApiName , String conditionalField ,String condition,String comparingFieldvalue,String additionalFields ){
    String query = '';

    Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
   // List<String,Schema.SObjectType> gd = Schema.getGlobalDescribe(); 
    Map<String, Schema.SObjectField> fieldMap = schemaMap.get(SobjectApiName).getDescribe().fields.getMap();
    Schema.sObjectType T = schemaMap.get(SobjectApiName);
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
    
    if(additionalFields != null && additionalFields != '')
             query = 'Select' + ' ' + query +','+additionalFields+' '+' from ' + SobjectApiName;
    else
             query = 'Select' + ' ' + query+' '+' from ' + SobjectApiName;
    system.debug('------------>'+query);
    if((conditionalField != null && conditionalField != '' ) && (condition != null && condition != '') && (comparingFieldvalue != null && comparingFieldvalue != null))
             query = query + ' ' + 'Where '+conditionalField+' '+condition+' '+comparingFieldvalue ;
     SYSTEM.DEBUG('========HU='+query );
             
     
    return query;
    }


//Method to clone agreement 
public list<Apttus__APTS_Agreement__c> cloneAgreement(list<Apttus__APTS_Agreement__c> originalAgreement){
    list<Apttus__APTS_Agreement__c> newagreementList = new list<Apttus__APTS_Agreement__c>();
    Datetime dateTimetemp = System.now();
    Date dateTemp = Date.newInstance(dateTimetemp.year(),dateTimetemp.month(),dateTimetemp.day());
    String x=dateTemp.format();
    for(Apttus__APTS_Agreement__c newAgreement: originalAgreement){
        Apttus__APTS_Agreement__c agreement = new Apttus__APTS_Agreement__c();
        agreement=newagreement.clone(false,True);
        // Commented out by SD - Modified code to truncate new agreement name to 60 charcters
        // agreement.Name='SNPSHOT - '+ x + ' - '+ newagreement.Name;
        // New Code added by SD - 1/28/2013 - Truncates agreement name to 60 characters
        if (newagreement.Name.length()>= 60)
        {
            //agreement.Name='SNPSHOT - '+ x + ' - '+ newagreement.Name.left(50);
            agreement.Name='SNPSHOT-'+ x + '-' + newagreement.Name.left(60);
        }
        else
        {
            agreement.Name='SNPSHOT-'+ x + '-'+ newagreement.Name;           
        }
       agreement.Hidden_Sales_Snapshot__c='snapshot';
      //agreement.Apttus__Agreement_Number__c='';
      //agreement.Apttus__Version_Number__c=0;
        newagreementList.add(agreement);
        
    }
    system.debug('=========  newagreementList=='+newagreementList);
    return newagreementList;
     
}
//Method to update Approval request object(new approvals) to avoid Issue of Approval deletion
public void updateapprovals(Id ApprovalId)
 {
list<Apttus_Approval__Approval_Request__c> updateapprovalslist=[select Id,Apttus_Approval__Object_Id__c from  Apttus_Approval__Approval_Request__c where Apttus_Approval__Related_Agreement__c=:ApprovalId];
  List<Apttus_Approval__Approval_Request__c> Listtoupdateapprovals= new list<Apttus_Approval__Approval_Request__c>();
     for(Apttus_Approval__Approval_Request__c newreqtoupdate : updateapprovalslist){
           newreqtoupdate.Apttus_Approval__Object_Id__c =ApprovalId;
           Listtoupdateapprovals.add(newreqtoupdate);
           }
 update Listtoupdateapprovals;
 
   }
 
 }