public class LeadSurveyControllerNA {

/*  
* File Name     : LeadSurveyControllerNA  
* Description   : This class is written to Insert the Lead Survey Response into Salesforce.com Lead_survey object.
*                 This Functionality is built as part of the NA Radio Lead Management Program.
*                 
* Modification Log
* =============================================================================
*   Ver     Date         Author               Modification
*------------------------------------------------------------------------------
*   1.0    7-Oct-2011  Ashutosh Dwivedi       Created
*   2.0    20-Oct-11   Sirish Soma            Udpated as per the SIT and UAT comments.
*/


 // public String Id = '';  
 public String partnerAcc{get;set;}
  public Lead theLead {get;set;}
  public Contact theContact {get;set;}
   public String partnerWebsite {set;get;}
   public String surveyStatus {get;set;}
  public String partnerPhone {set;get;}
   public String company{get;set;}
   public String contactName{get;set;}
   public String leadPhone{get;set;}
   public String leadState{get;set;}
   public String leadCountry{get;set;}
   public String leadAddress{get;set;}
    public String partnerCity {set;get;}
   public String partnerState {set;get;}
   public String partnerCountry {set;get;}
   public String partnerAddressLine1 {set;get;}
   public String zipCode{set;get;}
   public String name {set;get;}
   public List<Partner_Location__c> locationList=new List<Partner_Location__c>();
//system.debug('*********************** Current Page Id*****'+ApexPages.currentPage().getParameters().get('id');
    String Id = ApexPages.currentPage().getParameters().get('id');
        string sInTouch = '';
        string sInteraction = null;
        string sFollowUp = null;
        string sComments = '';
        

        public string sAccountName{get; set;}
        string email = '';
        public Lead_Survey__c rCurrentLeadSurvey = new Lead_Survey__c(); 

    /*   list<Lead_Survey__c> lstleadsurvey = new List <Lead_Survey__c>();
       list<Lead> lstlead = new list<Lead>();
       
       public void LeadSurveyControllerNA()
       {
           Id = ApexPages.currentPage().getParameters().get('id');
           
       }
 */
   
    //Constructor
    
    public LeadSurveyControllerNA(){
        String leadSurveyID = ApexPages.currentPage().getParameters().get('id');
        
        if(leadSurveyID !=null ){
              Lead_Survey__c leadSurveyRecord = [Select Id, Name, Partner_Name__c, Account__r.Name, Assigned_On__c, Contact__r.ID, Created_On__c, 
                                                        Customer_Email__c, Lead__r.ID, Question_1__c, 
                                                        Question_2__c, Question_3__c, Question_4__c, 
                                                        Status__c, Submitted_On__c, LACR_Preferable_Language__c from Lead_Survey__c where ID =:leadSurveyID  limit 1];
                                                        
             if(leadSurveyRecord !=null ){
                 surveyStatus = leadSurveyRecord.Status__c ;
              }
            system.debug('surveyStatus --> ' +surveyStatus);
            system.debug('leadSurveyRecord --> ' +leadSurveyRecord);
        }
        
           
    } 
    
    
    public Lead_Survey__c getrCurrentLeadSurvey(){
               
               System.debug('ID:'+Id);
                Lead_Survey__c possibleLeadSurveys = [Select Id, Name, Partner_Name__c, Account__r.Name, Assigned_On__c, Contact__r.ID, Created_On__c, 
                                                        Customer_Email__c, Lead__r.ID, Question_1__c, 
                                                        Question_2__c, Question_3__c, Question_4__c, 
                                                        Status__c, Submitted_On__c, LACR_Preferable_Language__c from Lead_Survey__c where ID =:Id limit 1];
                system.debug('possibleLeadSurveys:'+possibleLeadSurveys); 
                
                    
                  
                    rCurrentLeadSurvey = possibleLeadSurveys;
                    if(rCurrentLeadSurvey !=null ){
                        String tempId= rCurrentLeadSurvey.Lead__c; 
                        system.debug('tempId ' +tempId);
                        theLead = [select name, company, email, state, phone, country,Partner_Account_NA__r.Website_URL__c, Partner_Account_NA__c,Partner_Assigned_Contact_NA__c from Lead where id= :tempId limit 1 ]; 
                        sAccountName = rCurrentLeadSurvey.Partner_Name__c;
                        email = rCurrentLeadSurvey.Customer_Email__c;
                        company = theLead.Company;
                            
                       // contactName= theLead.Partner_Assigned_Contact_NA__c ;

                        if(theLead.Partner_Assigned_Contact_NA__c !=null && theLead.Partner_Assigned_Contact_NA__c !=null ){
                            theContact= [select name from Contact where id=:theLead.Partner_Assigned_Contact_NA__c LIMIT 1 ];
                            if(theContact!=null)
                              contactName= theContact.Name ;
                        }
                        leadPhone = theLead.Phone;
                        leadState = theLead.State;
                        leadCountry = theLead.country;
                         locationList= [select id, Account__c,Account_Name__c,City__c,Phone__c,Account_Website_URL__c,Country1__c,PartnerName__c,State_Code__c, State__c,Address_Type__c,Address_Line1__c,Postal_code__c from Partner_Location__c where Account__c =:theLead.Partner_Account_NA__c and Address_Type__c includes('Primary Location')];
                        partnerWebsite=theLead.Partner_Account_NA__r.Website_URL__c;
                        
                        if(locationList!=null && locationList.size()>0){
                            for(Partner_Location__c location:locationList) {
                                name=location.Account_Name__c;
                                
                                partnerPhone=location.Phone__c;
                                //addressLine1=location.Address_Line1__c;
                                partnerAddressLine1=location.Address_Line1__c;
                                zipCode=location.Postal_code__c;
                                partnerCity=location.City__c;
                                partnerState=location.State__c;
                                partnerCountry=location.Country1__c;   
                            }
           
                       } 
              }

        return rCurrentLeadSurvey;
    }// end constructor
    
        public string getAccountName(){
                return sAccountName;
        }
        public string getEmail(){
                return email;
        }
        
        public string getQuestionInTouch(){
                return sInTouch;
        }
        
        public void setQuestionInTouch(string QuestionInTouch){
                sInTouch = QuestionInTouch;
        }
        
        public string getQuestionInteraction(){
                return sInteraction;
        }
        
        public void setQuestionInteraction(string QuestionInteraction){
                sInteraction = QuestionInteraction;
        }

        public string getQuestionFollowUp(){
                return sFollowUp;
        }
        
        public void setQuestionFollowUp(string QuestionFollowUp){
                sFollowUp = QuestionFollowUp;           
        }

        public string getQuestionComments(){
                return sComments; 
        }

        public void setQuestionComments(string QuestionComments){
                sComments = QuestionComments;
        }

        public PageReference save(){
                PageReference returnPage = null;
                
                //Validate that all questions have a valid option
              //  System.debug('Entered Save');
                if (sInTouch != null){
                        if(sInTouch == 'Yes')
                            rCurrentLeadSurvey.Question_1__c = True;
                        else
                            rCurrentLeadSurvey.Question_1__c = False;    
                     //   System.debug('SIntouch:'+ sInTouch);
                }else
                {
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, Label.Customer_Survey_Site_Error));
                }//end if

                if (sInteraction != null){
                        rCurrentLeadSurvey.Question_2__c = sInteraction;
                      //  System.debug('SInteraction:'+ sInteraction);
                }else{
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, Label.Customer_Survey_Site_Error));
                }//end if

                if (sFollowUp != null){
                        rCurrentLeadSurvey.Question_3__c = sFollowUp;
                      //  System.debug('SFollowup:'+ sFollowUp);
                }else{
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, Label.Customer_Survey_Site_Error));
                }//end if

                rCurrentLeadSurvey.Question_4__c = sComments;

                // If there's not any validation error, we could try to update the record.
                if (!ApexPages.hasMessages()){
                      //  System.debug('Entered final');
                        rCurrentLeadSurvey.Status__c = 'Answering - Submitted'; 
                        rCurrentLeadSurvey.Submitted_On__c = datetime.now();
                      //  System.debug('rcurrent:'+rCurrentLeadSurvey);
                try {
                        update rCurrentLeadSurvey;
                        
                } catch (System.DmlException e) {
                        ApexPages.addMessages(e);

                        return null;
                }

                    returnPage = new PageReference ('/apex/LeadSurveyGovtThankYou');
                }
                
                return returnPage;              
        }
}