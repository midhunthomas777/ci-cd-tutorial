/*  
* File Name : KeyWordSearch 
* Description:  
* author    : Infosys Technologies Limited
* Modification Log 
* ============================================================================= 
* Ver   Date        Author      Modification 
* ---   ---------   ----------- ----------------------------------------------- 
* 1.0   19-May-10   Infosys  Initial Code
* 1.1   27-May-10   Infosys  Modified to update the Keyword object instead of Account  
*/

global class KeyWordSearch1 implements Database.Batchable<sObject>
{

//System.debug('######Main query');
//Query to obtain all the component fields of keyword
global String query ='select Id,Name,Company_Description__c,Value_add__c,DBA_Trading_Name__c,Services_Provided__c,(select Id,Product_offering__c from Account.Product_offered__r where Publish_Flag__c=true),(select City__c,Postal_code__c,Country1__c,Id,State__c from Account.Partner_locations__r),(select Id,Industry_Type__c from Account.Industries__r where Publish_Flag__c=true),(select Partner_Level__c,Status__c from Partner_Types__r),(select solution__c from Validated_Solutions__r where Publish_Flag__c=true),(select Certificate_Name__c from Partner_Certifications__r where Publish_Flag__c=true)  from Account';

global database.querylocator start(Database.BatchableContext BC){
            return Database.getQueryLocator(query);}

global void execute(Database.BatchableContext BC, List<sObject> scope){
List<Account> accountsToBeUpdated = new List<Account>();
List<Keyword__c> keywordObjects = new List<Keyword__c>();
for(sObject s : scope)
{
    Account acc = (Account)s;
    String keyword=null;
    //Bind all the account fields to the keyword.
    keyword=acc.Name+',';
    
    if(acc.Company_Description__c!=null)
     keyword=keyword+acc.Company_Description__c+',';
    
    if(acc.DBA_Trading_Name__c!=null)
     keyword=keyword+acc.DBA_Trading_Name__c+','; 
    
    if(acc.Services_Provided__c!=null)
     keyword=keyword+acc.Services_Provided__c+',';

    if(acc.Value_Add__c!=null)
     keyword=keyword+acc.Value_Add__c+',';

 
    System.debug('######Keyword after account:'+keyword);
    
    //For Product offered
    String prdKey=null;
     for(Product_offered__c prd:acc.Product_Offered__r)
     {          
        if(prdKey==null)
        {
          if(prd.Product_Offering__c!=null)
           prdKey= prd.Product_Offering__c;
          
        } 
        else
        { 
          if(prd.Product_Offering__c!=null)
            prdKey=prdKey+','+prd.Product_Offering__c;
        } 
     }
     //Append all the products of this account with the keyword
     keyword = keyword+','+prdKey; 
     
    System.debug('######Keyword after prd:'+keyword);

        
     //For Locations
     String locKey=null;
     for(Partner_location__c loc:acc.Partner_Locations__r)  
     {
        if(locKey==null)
        {
           if(loc.City__c!=null)
             locKey= loc.City__c+',';
          if(loc.State__c!=null)
          {
            if(locKey==null)
             locKey=loc.State__c+',';
            else 
             locKey=locKey+loc.State__c+',';

          } 
          if(loc.Postal_Code__c!=null)
          {
            if(locKey==null)
             locKey=loc.Postal_Code__c+',';
            else 
             locKey=locKey+loc.Postal_Code__c+',';

          }
          if(loc.Country1__c!=null)
          {
            if(locKey==null)
             locKey=loc.Country1__c+',';
            else 
             locKey=locKey+loc.Country1__c+',';

          }
        } 
        else
        { 
          if(loc.City__c!=null)
             locKey= locKey+loc.City__c+',';
          if(loc.State__c!=null)
             locKey= locKey+loc.State__c+','; 
          if(loc.Postal_Code__c!=null)
             locKey= locKey+loc.Postal_Code__c+',';
          if(loc.Country1__c!=null)   
             locKey=locKey+loc.Country1__c+',';
        } 

     }
     //Append all the products of this account with the keyword
     keyword = keyword+','+locKey;
     
    System.debug('######Keyword after loc:'+keyword);

     
     //For Industries
     String indKey=null;
     for(Industry__c ind:acc.Industries__r) 
     {
        if(indKey==null)
        {
           if(ind.Industry_Type__c!=null)
            indKey= ind.Industry_Type__c;
        } 
        else 
        {
          if(ind.Industry_Type__c!=null)
            indKey=indKey+','+ind.Industry_Type__c;
        }
     }
     keyword = keyword+','+indKey;
     
    System.debug('######Keyword after ind:'+keyword);


     //For Validated solutions     
     /* Commented as part of SF-491-Delete unused objects
     String solKey=null;
     for(Validated_Solution__c sol:acc.Validated_Solutions__r)
     {
        if(solKey==null)
        {
          if(sol.Solution__c!=null)
           solKey= sol.Solution__c;
        }
        else 
        {
          if(sol.Solution__c!=null)
           solKey=solKey+','+sol.Solution__c;
         }

     }
     keyword = keyword+','+solKey;
     
    System.debug('######Keyword after sol:'+keyword);*/


     //For Partner type
     String partKey=null;
     for(Partner_Type__c part:acc.Partner_Types__r)
     {
      if(part.Status__c == 'Active')
      {
      if(partKey==null)
      {
         if(part.Partner_Level__c!=null)
          partKey= part.Partner_Level__c;
      }   
      else 
      {  
         if(part.Partner_Level__c!=null)
          partKey=partKey+','+part.Partner_Level__c;
       }
      }
     }
     keyword = keyword+','+partKey;
     
    System.debug('######Keyword after partner type:'+keyword);


     //For Certifications    
     String certKey=null;
     for(Partner_Certification__c cert:acc.Partner_Certifications__r)
     {
       if(certKey==null)
       {
         if(cert.Certificate_Name__c!=null)
          certKey= cert.Certificate_Name__c;
       } 
       else 
       {
          if(cert.Certificate_Name__c!=null)
           certKey=certKey+','+cert.Certificate_Name__c;
       }  
     }
     keyword = keyword+','+certKey;
     
    System.debug('######Keyword after cert:'+keyword);

     
   //Set the keyword field of the account object     
   //acc.Keyword_Search_Code__c = keyword;
   //accountMap.put(acc.Id,keyword);
   accountsToBeUpdated.add(acc);
   
   Keyword__c key=new Keyword__c();
   key.Keyword_Term__c=keyword;
   key.Account__c=acc.Id;
   key.ExternalId__c='KEY-'+acc.Id;
   keywordObjects.add(key);
   
}//End of for loop

System.debug('#######Accounts for updation:');

////COMMENTED TO REFER TO THE NEW OBJECT KEYWORD  update accountsToBeUpdated;

upsert keywordObjects ExternalId__c;
}


global void finish(Database.BatchableContext BC){
}

}//End of class