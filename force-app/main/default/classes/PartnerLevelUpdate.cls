/*  
* File Name : PartnerLevelUpdate
* Description:  
* author    : Infosys Technologies Limited
* Modification Log 
* ============================================================================= 
* Ver   Date        Author      Modification 
* ---   ---------   ----------- ----------------------------------------------- 
* 1.0   23-Sep-10   Infosys     Initial Code
* 2.0   10-Mar-11   Infosys     Modified Code for adding Product offered deletion logic
* 3.0   14-Jun-11   Infosys     Modified Code for updating Partner_status_field for Mobility on Account
* 4.0   20-Sep-13   Bharathi    Partner Track Status Optimization as per INC000008503654
*/

public class PartnerLevelUpdate 
{

/*public static void UpdateLevel(Account[] accnts,Account[] accntsOLD)
{
 
 List<Id> AccountIdList = new List<Id>();
 List<Partner_Type__c>PartnerFinalUpdationList = new List<Partner_Type__c>();
 List<Partner_Type__c>PartnerFinalCreationList = new List<Partner_Type__c>();
 List<String>ValueList = new List<String>();
  
 for(Account acc: accnts)
 {
     
       AccountIdList.add(acc.Id);
       if(acc.Level__c!=null)
         ValueList.add(acc.Level__c);
     
 } 

if(AccountIdList.size()>0)
{ 
 //Query the partner type object to get the partner level values
 List<Partner_Type__c> part = [select Id,Partner_Level__c,Account__c,Compliance_Status__c,Status__c from Partner_Type__c where Account__c in : AccountIdList and Program__c = 'Mobility'];
 
 Set<Id> PartnerSet = new Set<Id>();
 Map<Id,String> PartnerAccountLevelMap = new Map<Id,String>();
 Map<Id,Id> PartnerAccountIdLevelIdMap = new Map<Id,Id>();
 Map<String,String>configMap  = new Map<String,String>();
 Map<Id,String> partnerComplianceMap= new Map<Id,String>();
 Map<Id,String> partnerStatusMap= new Map<Id,String>();
  
 for(Partner_Type__c par: part)
 {
   PartnerSet.add(par.Account__c);
   PartnerAccountLevelMap.put(par.Account__c,par.Partner_Level__c); 
   PartnerAccountIdLevelIdMap.put(par.Account__c,par.Id);
   partnerComplianceMap.put(par.Account__c,par.Compliance_Status__c); 
   partnerStatusMap.put(par.Account__c,par.Status__c); 
 }


//Get the master picklist values corresponding to the label
List<Configuration_Variable__c> config = [select Name,Value__c from Configuration_Variable__c where Name in:ValueList];
if(config.size()>0)
{
 for(Configuration_Variable__c conf:config)
 {
   configMap.put(conf.Name,conf.Value__c);   
 }  
}
 
 for(Account acc1:accnts)
 {
   
    Integer flag =0;
   
   //Check if there is a Partner level for Mobility program 
   if(PartnerSet.contains(acc1.Id))
   {
     //Check if the partner level values are in sync
     String level = null;
     level = PartnerAccountLevelMap.get(acc1.Id);
     String acclvl = null;
     if(acc1.Level__c!=null)
       acclvl = configMap.get(acc1.Level__c);
     else
       acclvl = '';
        
    
      System.debug('#############Account level  Acclvl:'+acclvl);
      System.debug('#############Partners level:'+level);
     
      //If account's level is not = partner types level
      //Make the values in sync
      if((acclvl!=null) && (level!=null))
      {
       if(acclvl!=level)
       {
       String levelId = PartnerAccountIdLevelIdMap.get(acc1.Id);
       Partner_Type__c partUp = new Partner_Type__c(Id=levelId);      
       partUp.Partner_Level__c = acclvl; 
       partUp.Compliance_Status__c=acc1.Certificate_Status__c;
       partUp.Status__c=acc1.Status__c;    
       //Add it to a list for updation
       PartnerFinalUpdationList.add(partUp);
       flag = 1;
       }
     }
     if(((acclvl==null) && (level!=null))||((acclvl!=null) && (level==null)))
     {
       String levelId = PartnerAccountIdLevelIdMap.get(acc1.Id);
       Partner_Type__c partUp = new Partner_Type__c(Id=levelId);      
       partUp.Partner_Level__c = acclvl;
       partUp.Compliance_Status__c=acc1.Certificate_Status__c;
       partUp.Status__c=acc1.Status__c;       
       //Add it to a list for updation
       PartnerFinalUpdationList.add(partUp);  
       flag = 1;
     }
     
     if(flag==0)
     {
       //Check for the  status 
       if(acc1.Status__c!=null)
       {
         if(acc1.Status__c!= partnerStatusMap.get(acc1.Id))
         {
           String levelId = PartnerAccountIdLevelIdMap.get(acc1.Id);
           Partner_Type__c partUp = new Partner_Type__c(Id=levelId);      
           partUp.Status__c=acc1.Status__c;  
           PartnerFinalUpdationList.add(partUp);  
           flag = 1;        
         }
       }
       else
       {
         if(partnerStatusMap.get(acc1.Id)!=null)
         {
           String levelId = PartnerAccountIdLevelIdMap.get(acc1.Id);
           Partner_Type__c partUp = new Partner_Type__c(Id=levelId);      
           partUp.Status__c=acc1.Status__c;  
           PartnerFinalUpdationList.add(partUp);  
           flag = 1;        
         }
       }
     }//end of flag==0 
     if(flag==0)
     {
       //Check for the Compliance status 
       if(acc1.Certificate_Status__c!=null)
       {
         if(acc1.Certificate_Status__c!= partnerComplianceMap.get(acc1.Id))
         {
           String levelId = PartnerAccountIdLevelIdMap.get(acc1.Id);
           Partner_Type__c partUp = new Partner_Type__c(Id=levelId);      
           partUp.Compliance_Status__c=acc1.Certificate_Status__c;  
           PartnerFinalUpdationList.add(partUp);  
           flag = 1;        
         }
       }
       else
       {
         if(partnerComplianceMap.get(acc1.Id)!=null)
         {
           String levelId = PartnerAccountIdLevelIdMap.get(acc1.Id);
           Partner_Type__c partUp = new Partner_Type__c(Id=levelId);      
           partUp.Compliance_Status__c=acc1.Certificate_Status__c;  
           PartnerFinalUpdationList.add(partUp);  
           flag = 1;        
         }
       }
     }//end of flag==0 
   }
   
   //When Partner level records are not present for Mobility program,create the partner level records
   else
   {
     
     //If Partner level of Account is not null,then create the record
     String acclvls = null;
     if(acc1.Level__c!=null)
       acclvls = configMap.get(acc1.Level__c);
     if(acclvls!=null)
     {
     String acclvl = configMap.get(acc1.Level__c);
     Partner_Type__c partCr = new Partner_Type__c(Account__c = acc1.Id,Partner_Level__c=acclvls,Program__c='Mobility',Compliance_Status__c=acc1.Certificate_Status__c,Status__c=acc1.Status__c);    
     PartnerFinalCreationList.add(partCr);
     }
   }
 
}

//Create or update the records
if(PartnerFinalCreationList.size()>0)
{
 System.debug('###########Create List:'+PartnerFinalCreationList);
 insert PartnerFinalCreationList;
}
if(PartnerFinalUpdationList.size()>0)
{
 System.debug('###########Update List:'+PartnerFinalUpdationList);
 update PartnerFinalUpdationList;
}


}//End of IF
}//End of method


public static void UpdatePartnerLevel(Partner_Type__c[] pType)
{

    Map<Id,String> partnerIdMap = new Map<Id,String>();
    Map<Id,String> partnerComplianceMap= new Map<Id,String>();
    Map<Id,String> partnerStatusMap= new Map<Id,String>();
    
    Set<Id> partnerAccountId = new Set<Id>();
    List<Account> finalUpdate = new List<Account>();
    List<String>ValueList1 = new List<String>();
    Map<String,String>configMap1  = new Map<String,String>();
    
    for(Partner_Type__c partnerType : pType)
    {
        if(partnerType.Program__c!=null)
        {
        if(partnerType.Program__c.equals('Mobility'))
        {
            partnerAccountId.add(partnerType.Account__c);
            partnerIdMap.put(partnerType.Account__c,partnerType.Partner_Level__c);
            partnerComplianceMap.put(partnerType.Account__c,partnerType.Compliance_Status__c);
            partnerStatusMap.put(partnerType.Account__c,partnerType.Status__c);
            
            if(partnerType.Partner_Level__c!=null)
             ValueList1.add(partnerType.Partner_Level__c);
        }
        }
    }
    
    //Get the label corresponding to the master picklist value to be updated on to the Account record
    List<Configuration_Variable__c> config1 = [select Name,Value__c from Configuration_Variable__c where Value__c in:ValueList1];
    if(config1.size()>0)
    {
       for(Configuration_Variable__c conf:config1)
       {
         configMap1.put(conf.Value__c,conf.Name);   
       }  
    }
    
    if(partnerAccountId.size()>0)
    {
        List<Account> acc = [select Id,Level__c,Certificate_Status__c,Status__c from Account where Id in : partnerAccountId];
        for(Account acc1 : acc)
        {
            Integer flag =0;
            String lvl = null;
            lvl = partnerIdMap.get(acc1.Id);
                if((lvl!=null)&&(acc1.Level__c!=null))
                {
                 if(lvl!=acc1.Level__c)
                 {
                  Account a = new Account(Id=acc1.Id);
                  a.Level__c = configMap1.get(lvl);
                  a.Certificate_Status__c = partnerComplianceMap.get(acc1.Id);
                  a.Status__c=partnerStatusMap.get(acc1.Id);
                  finalUpdate.add(a);
                  flag=1;
                 }
                }
                if(((lvl==null)&&(acc1.Level__c!=null))||((lvl!=null)&&(acc1.Level__c==null))   )
                {
                Account a = new Account(Id=acc1.Id);
                a.Level__c = configMap1.get(lvl);
                a.Certificate_Status__c = partnerComplianceMap.get(acc1.Id);
                a.Status__c=partnerStatusMap.get(acc1.Id);
                finalUpdate.add(a);
                flag=1;
                }
                
                //Check for Status
                if(flag==0)    
                {
                  //Check for the  status 
                  if(acc1.Status__c!=null)
                  {
                    if(acc1.Status__c!= partnerStatusMap.get(acc1.Id))
                    {
                      Account a = new Account(Id=acc1.Id);
                      a.Status__c=partnerStatusMap.get(acc1.Id);   
                      finalUpdate.add(a);
                      flag = 1;        
                    }
                 }
                 else
                 {
                   if(partnerStatusMap.get(acc1.Id)!=null)
                   {
                      Account a = new Account(Id=acc1.Id);
                      a.Status__c=partnerStatusMap.get(acc1.Id);   
                      finalUpdate.add(a);
                      flag = 1;       
                   }
                 }
              }//end of flag==0 
                
              //Check for Compliance Status
                if(flag==0)    
                {
                  //Check for the  status 
                  if(acc1.Certificate_Status__c!=null)
                  {
                    if(acc1.Certificate_Status__c!= partnerComplianceMap.get(acc1.Id))
                    {
                      Account a = new Account(Id=acc1.Id);
                      a.Certificate_Status__c=partnerComplianceMap.get(acc1.Id);   
                      finalUpdate.add(a);
                      flag = 1;        
                    }
                 }
                 else
                 {
                   if(partnerComplianceMap.get(acc1.Id)!=null)
                   {
                      Account a = new Account(Id=acc1.Id);
                      a.Certificate_Status__c=partnerComplianceMap.get(acc1.Id);   
                      finalUpdate.add(a);
                      flag = 1;       
                   }
                 }
              }//end of flag==0   
                
                
        }
    }
 
    if(finalUpdate.size()>0)
    {
         
         update finalUpdate;
    }
    
}*/

//Method to update hidden fields
public static void UpdatePartnerLevel2(Partner_Type__c[] pType)
{

  List<Account> updateAccountListRADIO = new List<Account>();
  List<Account> updateAccountListWNS = new List<Account>();
  List<Account> updateAccountListSCADA = new List<Account>();
  List<Account> updateAccountListMobility = new List<Account>();
  Set<Id> AccId = new Set<Id>();
  Map<Id,Account> AccMap = new Map<Id,Account>();
  
  for(Partner_Type__c partType : pType){
     AccId.add(partType.account__c);
  }
  
  List<Account> accList = [Select id,PartnerStatus_RADIO__c,PartnerStatus_WNS__c,Partner_Status_Mobility__c,
                             PartnerStatus_SCADA__c from Account where id In: AccId];
  
  for(Account acct: accList){
     AccMap.put(acct.Id,acct);
  }
   
  for(Partner_Type__c partnerType : pType)
  {                
     Account acc = AccMap.get(partnerType.account__c);
     
     System.debug('Account hidden field Radio' +acc.PartnerStatus_RADIO__c);    
     System.debug('Program'+ partnerType.Program__c);
          
     if(partnerType.Program__c=='RADIO')
     {  
       System.debug('#RStatus'+partnerType.Status__c);
       if(partnerType.Status__c!=null)
       {
          if(acc.PartnerStatus_RADIO__c!=null && partnerType.Status__c != acc.PartnerStatus_RADIO__c)
          {            
              acc.PartnerStatus_RADIO__c = partnerType.Status__c;
              updateAccountListRADIO.add(acc);            
          }
          else
          {
            System.debug('#RStatus'+partnerType.Status__c);
            System.debug('accRadiostatus' + acc.PartnerStatus_RADIO__c);
            acc.PartnerStatus_RADIO__c = partnerType.Status__c;
            updateAccountListRADIO.add(acc);
          }
       }
     }      
     else if(partnerType.Program__c=='WNS')  
     {
        if(partnerType.Status__c!=null)
        {  
           System.debug('#WNSStatus'+partnerType.Status__c);
           if(acc.PartnerStatus_WNS__c!=null)
           {
              if(partnerType.Status__c != acc.PartnerStatus_WNS__c)
              { 
                   acc.PartnerStatus_WNS__c = partnerType.Status__c;
                   
                   //Added code to set WNS Partner flag on Account - Brahma 08/01/2011
                   if(partnerType.Status__c == 'Active'){
                        acc.WNS_Track__c = true;
                   }                   
                   if(partnerType.Status__c == 'Inactive'){
                        acc.WNS_Track__c = false;
                   }
                   //END of code
                   
                   updateAccountListWNS.add(acc);
               } 
           }
           else
           {
                  System.debug('#RStatus'+partnerType.Status__c);
                  System.debug('accWNSstatus' + acc.PartnerStatus_WNS__c);
                  acc.PartnerStatus_WNS__c = partnerType.Status__c;
                   
                   //Added code to set WNS Partner flag on Account - Brahma 07/26/2011
                   if(partnerType.Status__c == 'Active'){
                        acc.WNS_Track__c = true;
                   }                   
                   if(partnerType.Status__c == 'Inactive'){
                        acc.WNS_Track__c = false;
                   }
                   //END of code
                   
                   updateAccountListWNS.add(acc);
            }            
        }                  
     }    
     else if(partnerType.Program__c=='SCADA')  
     {
       if(partnerType.Status__c!=null)
       {  
          if(acc.PartnerStatus_SCADA__c!=null)
          {
             if(partnerType.Status__c != acc.PartnerStatus_SCADA__c)
             {
               acc.PartnerStatus_SCADA__c = partnerType.Status__c;
               updateAccountListSCADA.add(acc);
             }  
          }
          else
          {
              acc.PartnerStatus_SCADA__c = partnerType.Status__c;
              updateAccountListSCADA.add(acc);
          }  
       }   
     } 
     
     //Mobility
     else if(partnerType.Program__c=='Mobility')  
     {
       if(partnerType.Status__c!=null)
       {  
          System.debug('#MobilityStatus'+partnerType.Status__c);
          if(acc.Partner_Status_Mobility__c!=null)
          {
             if(partnerType.Status__c != acc.Partner_Status_Mobility__c)
             {
                   acc.Partner_Status_Mobility__c = partnerType.Status__c;
                   
                   //Added code to set Mobility Partner flag on Account - Brahma 08/01/2011
                   if(partnerType.Status__c == 'Active'){
                        acc.Mobility_Track__c = true;
                   }
                   
                   if(partnerType.Status__c == 'Inactive'){
                        acc.Mobility_Track__c = false;
                   }
                   //END of code 
                   
                   updateAccountListMobility.add(acc);
             }  
          }
          else
          {
                  System.debug('#MobilityStatus'+partnerType.Status__c);
                  System.debug('accMobilitystatus' + acc.Partner_Status_Mobility__c);
                  acc.Partner_Status_Mobility__c = partnerType.Status__c;
                   
                   //Added code to set Mobility Partner flag on Account - Brahma 08/01/2011
                   if(partnerType.Status__c == 'Active'){
                        acc.Mobility_Track__c = true;
                   }
                   
                   if(partnerType.Status__c == 'Inactive'){
                        acc.Mobility_Track__c = false;
                   }
                   //END of code
                   
                   updateAccountListMobility.add(acc);
           }            
       } 
     } 
      
  }
      
  if(updateAccountListRADIO.size()>0)
   update updateAccountListRADIO;
  
  if(updateAccountListWNS.size()>0)
   update updateAccountListWNS;
   
  if(updateAccountListSCADA.size()>0)
   update updateAccountListSCADA;  
  
  if(updateAccountListMobility.size()>0)
   update updateAccountListMobility;
     
}

//Method to delete product offering for support and advanced services
public static void UpdatePartnerLevel3(Partner_Type__c[] pTypes){

     List<Id> supportAccountid=new List<Id>();
     List<Id> advancedAccountid=new List<Id>();
     List<Product_Offered__c>productdeletionlist=new List<Product_Offered__c>();
     List<Product_Offered__c>productdeletionlist1=new List<Product_Offered__c>();
     
     for(Partner_Type__c partnerTypes : pTypes)
     {
        if(partnerTypes.Program__c=='Mobility'){
        
           if(partnerTypes.Support_Services__c==true)
           supportAccountid.add(partnerTypes.account__c);
           
           if(partnerTypes.Advanced_Services__c==true)
           advancedAccountid.add(partnerTypes.account__c);                   
        }     
     }
      
     List<Product_Offered__c> productSupport = new List<Product_Offered__c>();
     List<Product_Offered__c> productAdvanced = new List<Product_Offered__c>();
     
     if(supportAccountid.size()>0)
        productSupport= [Select id,Product_offering__c from  Product_Offered__c where Account__c in :supportAccountid];
     for(Product_Offered__c prodSupport:productSupport){
        if(prodSupport.Product_offering__c=='Support Services')
           productdeletionlist.add(prodSupport);
     }
     
     if(advancedAccountid.size()>0)
        productAdvanced= [Select id,Product_offering__c from  Product_Offered__c where Account__c in :advancedAccountid];     
     for(Product_Offered__c prodAdvanced:productAdvanced){
        if(prodAdvanced.Product_offering__c=='Advanced Services')
           productdeletionlist1.add(prodAdvanced);
     }
     
     if(productdeletionlist.size()>0){     
        delete productdeletionlist;
     }
     
     if(productdeletionlist1.size()>0){     
        delete productdeletionlist1;
     }          
}

}//End of Class