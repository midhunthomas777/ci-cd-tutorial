public class  LM_PartnerLocationDetails {
 public String name {set;get;}
  public String partnerWebsite {set;get;}
  public String partnerPhone {set;get;}
  public String partnerCity {set;get;}
  public String partnerState {set;get;}
  public String partnerCountry {set;get;}
  public String partnerAddressLine1 {set;get;}
  public String zipCode{set;get;}
  public Id leadId ;
  public Lead leadRecord {set;get;}
  public List<Partner_Location__c> locationList=new List<Partner_Location__c>();

   
    public void getDetails(){
        String addressLine1;
       
        //partnerAddress='';
       getLeadId();
       leadRecord = [Select id,Partner_Account_NA__c,country,state,Partner_Assigned_Contact_NA__c,Track__c,Technology_Segment__c,Industry, name from lead where id = :leadId  ];
       locationList= [select id, Account__c,Account_Name__c,City__c,Phone__c,Account_Website_URL__c,Country1__c,PartnerName__c,State_Code__c, State__c,Address_Type__c,Address_Line1__c,Postal_code__c from Partner_Location__c where Account__c =:leadRecord.Partner_Account_NA__c and Address_Type__c includes('Primary Location')];
        for(Partner_Location__c location:locationList) {
            name=location.Account_Name__c;
            partnerWebsite=location.Account_Website_URL__c;
            partnerPhone=location.Phone__c;
            //addressLine1=location.Address_Line1__c;
            partnerAddressLine1=location.Address_Line1__c;
            zipCode=location.Postal_code__c;
            partnerCity=location.City__c;
            partnerState=location.State__c;
            partnerCountry=location.Country1__c;          
       } 
      /* if(addressLine1!=null)
            partnerAddressLine1=partnerAddressLine1+addressLine1+'\n';
       if(partnerState!=null)
            partnerAddressLine1=partnerAddressLine1+partnerState+',';
       if(zipCode!=null)
            partnerAddressLine1=partnerAddressLine1+zipCode+'\n';
       if(partnerCountry!=null)
            partnerAddressLine1=partnerAddressLine1+partnerCountry;
    */
   }
   
   public ID getLeadId () { 
       return leadId; 
   }

   public void setLeadId (ID inputID){
       leadId = inputID;
       system.debug('hi sujata');
       if(leadId!=null)
           getDetails();
   }
   
}