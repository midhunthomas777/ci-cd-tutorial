/*  
* File Name     : ADPUpdAccOnLicCreation
* Description   : This class is used in Trigger 'ADP_Create_License' to validate the associated Account values
* Modification Log
* =============================================================================
*   Ver     Date         Author                      Modification
*------------------------------------------------------------------------------
*   1.0     18-Jan-17    Poongodi V                  Initial Creation

*/

Public Class ADPUpdAccOnLicCreation{

    public static void updAccount(Id adpRecId){
       
        try{
        
        ADP_Registration__c adpRec=[Select Id,Partner_Account__c,Region_Requested__c,ADP_Global_Account_Name1__c,Street_Address_1__c,Address_Line_2__c,City_Town__c,Applicant_State_Province__c,Country__c,zipcode__c,Technology_Segment_Interest__c from ADP_Registration__c where Id=:adpRecId limit 1];
           
       Account UpdAcc=[Select Id,Name,ADP_Global_Account_Name1__c,ADP_Technology_Segment__c,Hierarchy_Placement__c,Partner_Region__c,BillingStreet, BillingCity, BillingState, BillingPostalCode,BillingCountry,ADP_Partner__c,MPE_Program_Status_New__c from Account where Id=:adpRec.Partner_Account__c limit 1];      
       String AccRegion='';
       //Mapping for the Region field in Account
        if(adpRec.Region_Requested__c.equals(Label.ADP_NAMR))
        AccRegion='NAMR';
        else if(adpRec.Region_Requested__c.equals(Label.ADP_LACR))
        AccRegion='LACR';
        else if(adpRec.Region_Requested__c.equals(Label.ADP_EMEA))
        AccRegion='EMEA';
        else if(adpRec.Region_Requested__c.equals(Label.ADP_APAC))
        AccRegion='APAC';
    //Update the null values of the field in Account with the required values
        if(String.isBlank(UpdAcc.ADP_Global_Account_Name1__c)==true)
        UpdAcc.ADP_Global_Account_Name1__c=adpRec.ADP_Global_Account_Name1__c; 
    
    
        if((UpdAcc.BillingStreet=='' || UpdAcc.BillingStreet==null) && (UpdAcc.BillingCity=='' || UpdAcc.BillingCity==null) && (UpdAcc.BillingCountry =='' || UpdAcc.BillingCountry ==null) && (UpdAcc.BillingState=='' || UpdAcc.BillingState==null) && (UpdAcc.BillingPostalCode=='' || UpdAcc.BillingPostalCode==null)){
            if(string.isblank(adpRec.Address_Line_2__c) ==true){
                UpdAcc.BillingStreet=adpRec.Street_Address_1__c;
            }else{
                String str = adpRec.Street_Address_1__c;
                str = str.removeEnd(',');
                UpdAcc.BillingStreet=str+','+adpRec.Address_Line_2__c;
            }     
            UpdAcc.BillingCity=adpRec.City_Town__c;
            UpdAcc.BillingState=adpRec.Applicant_State_Province__c;
            UpdAcc.BillingCountry =adpRec.Country__c;                
            UpdAcc.BillingPostalCode=String.Valueof(adpRec.zipcode__c);
        }
        
        if(UpdAcc.Hierarchy_Placement__c=='' || UpdAcc.Hierarchy_Placement__c==null)
        UpdAcc.Hierarchy_Placement__c='Regional Account';

        if(UpdAcc.Partner_Region__c=='' || UpdAcc.Partner_Region__c==null)
        UpdAcc.Partner_Region__c=AccRegion; 
        
        System.debug('#####UpdAcc after:'+UpdAcc);    
        Update UpdAcc;
    
        }catch(Exception e){
        System.debug('Error in updating the Partner Account for the ADP Record:' + e); 
        }    

    }

}