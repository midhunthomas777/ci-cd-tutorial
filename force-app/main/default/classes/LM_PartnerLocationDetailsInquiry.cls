public class  LM_PartnerLocationDetailsInquiry {
 public String name {set;get;}
  public String partnerWebsite {set;get;}
  public String partnerPhone {set;get;}
  public String partnerCity {set;get;}
  public String partnerState {set;get;}
  public String partnerCountry {set;get;}
  public String partnerAddressLine1 {set;get;}
  public String zipCode{set;get;}
  public String partnerAssignedContactName{set;get;}
  public String leadName{set;get;}
  public String leadlanguage {set;get;}
  public Id leadSurveyId ;
  public Lead leadRecord {set;get;}
  public String leadId {set;get;}
  public String regId {set;get;}
  public List<Partner_Location__c> locationList=new List<Partner_Location__c>();

   
    public void getDetails(){
       getLeadSurveyId();
       Lead_Survey__c leadSur = [select Lead__c from Lead_Survey__c where id= :leadSurveyId limit 1];
       leadId = leadSur.Lead__c;
       leadRecord = [Select id,Registration_ID__c,Partner_Account_NA__r.id,Partner_Account_NA__r.name,country,state,Preferred_Language__c,Partner_Assigned_Contact_NA__c,Track__c,Technology_Segment__c,Industry, name from lead where id = :leadId limit 1];
       if(leadRecord.Partner_Account_NA__r.id != null){
           partnerAssignedContactName = leadRecord.Partner_Account_NA__r.name;
           leadName = leadRecord.name;
           leadlanguage = leadRecord.Preferred_Language__c;
           regId=leadRecord.Registration_ID__c;
           locationList= [select id, Account__c,Account_Name__c,City__c,Phone__c,Account_Website_URL__c,Country1__c,PartnerName__c,State_Code__c, State__c,Address_Type__c,Address_Line1__c,Postal_code__c from Partner_Location__c where Account__c =:leadRecord.Partner_Account_NA__r.id and Address_Type__c includes('Primary Location')];
            for(Partner_Location__c location:locationList) {
                name=location.Account_Name__c;
                partnerWebsite=location.Account_Website_URL__c;
                partnerPhone=location.Phone__c;
                partnerCity=location.City__c;
                partnerState=location.State__c;
                partnerCountry=location.Country1__c;
                partnerAddressLine1=location.Address_Line1__c;
                zipCode=location.Postal_code__c;                
           }
        }      
   }
   
   public ID getLeadSurveyId () { 
       return leadSurveyId; 
   }

   public void setLeadSurveyId (ID inputID){
       leadSurveyId = inputID;
       system.debug('hi sujata');
       if(leadSurveyId !=null)
           getDetails();
   }
   
}