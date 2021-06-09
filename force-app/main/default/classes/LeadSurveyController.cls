public with sharing class LeadSurveyController {

/*  
* File Name     : LeadSurveyController  
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
//system.debug('*********************** Current Page Id*****'+ApexPages.currentPage().getParameters().get('id');
    String Id = ApexPages.currentPage().getParameters().get('id');
        string sInTouch = '';
        string sInteraction = null;
        string sFollowUp = null;
        string sComments = '';
        

        string sAccountName = '';
        
        public Lead_Survey__c rCurrentLeadSurvey = new Lead_Survey__c(); 

    /*   list<Lead_Survey__c> lstleadsurvey = new List <Lead_Survey__c>();
       list<Lead> lstlead = new list<Lead>();
       
       public void LeadSurveyController()
       {
           Id = ApexPages.currentPage().getParameters().get('id');
           
       }
 */
   
    //Constructor
    public Lead_Survey__c getrCurrentLeadSurvey(){
                //To avoid errors when SQL Command is executed for the case where the ID doesn't exist
                //We will previously fill a list with possible records to check size
               /*
                
                Id = 'a1qS00000004lh1';
                if(Id != null && Id != '')                              
                lstleadsurvey = [select Id, Lead__c from Lead_Survey__c Where Id =: Id limit 1];
                system.debug('Partner---::::'+ lstleadsurvey  );
                if(!lstleadsurvey.isEmpty()){
               
                lstlead = [select Partner_Account_NA__c from Lead Where Id =: lstleadsurvey[0].Lead__c limit 1];
                partnerAcc = lstlead[0].Partner_Account_NA__c;}
                
                system.debug('Partner Account**************************'+partnerAcc);
                
              
               */  
               System.debug('ID:'+Id);
                Lead_Survey__c[] possibleLeadSurveys = [Select Id, Name, Partner_Name__c, Account__r.Name, Assigned_On__c, Contact__r.ID, Created_On__c, 
                                                        Customer_Email__c, Lead__r.ID, Question_1__c, 
                                                        Question_2__c, Question_3__c, Question_4__c, 
                                                        Status__c, Submitted_On__c, LACR_Preferable_Language__c from Lead_Survey__c where ID =:Id limit 1];
                system.debug('possibleLeadSurveys:'+possibleLeadSurveys);   
                if (possibleLeadSurveys.size() > 0){
                        rCurrentLeadSurvey = possibleLeadSurveys[0];
                        
                      //  sAccountName = rCurrentLeadSurvey.Name; 
                    //   sAccountName = rCurrentLeadSurvey.Account__r.Name;
                       sAccountName = rCurrentLeadSurvey.Partner_Name__c;
                }//end if

        return rCurrentLeadSurvey;
    }// end constructor
    
        public string getAccountName(){
                return sAccountName;
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
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'Question 1. Partner in touch. A valid value is required.'));
                }//end if

                if (sInteraction != null){
                        rCurrentLeadSurvey.Question_2__c = sInteraction;
                      //  System.debug('SInteraction:'+ sInteraction);
                }else{
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'Question 2. Interaction with representative from Motorola. A valid value is required.'));
                }//end if

                if (sFollowUp != null){
                        rCurrentLeadSurvey.Question_3__c = sFollowUp;
                      //  System.debug('SFollowup:'+ sFollowUp);
                }else{
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'Question 3. Quality of follow up. A valid value is required.'));
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

                    returnPage = new PageReference ('/apex/LeadSurveyThankYou');
                }
                
                return returnPage;              
        }
}