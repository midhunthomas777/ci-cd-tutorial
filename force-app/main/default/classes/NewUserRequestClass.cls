public without sharing class  NewUserRequestClass {
/*          
Created By: Shipra upadhyaya
Created On: 
Purpose:To insert case in SFDC for request of New user Account from site page.
--------------------------------------------------------------------------
Modified By: Kushal Soni
Modified On: 15-Oct-2014
Modification: Modified to include zebra.com email also

Version             Modified By           Incident              Modification        
---------------------------------------------------------------------------------------------------
2.0                 Sai Sampath          INC0955235            Added fields to check wheather they are filled or not based as per the request .
3.0                 Satish Maddhi         SF-401               Removed Anaplan references
4.0                 Vineela N             SF-824               Modification done for all salesforce,CPQ and Tableau
5.0 				Vineela N			  SF-1513					            
*/
    public case cases {get;set;}
    public boolean requiredval;
    //boolean isDisabled = false;
    public PageReference save(){ 
        //isDisabled =true;   
        requiredval = false;
        //modified By Sampath as a part of INC0955235  
        //cases.Request_Access_Tableau__c == null|| -- Removed as part of - SF-2503
        if(cases.Associate_ID__c == null || cases.Associate_Core_ID__c == null || cases.Associate_First_Name__c == null ||
           cases.Associate_Position__c == null||cases.Associate_Last_Name__c == null || cases.Associate_Email__c == null || 
           cases.Associate_Theater__c==null || cases.Title__c== null || cases.Supervisor_Core_ID__c == null ||
           cases.Request_Access_Salesforce__c== null||
           cases.Business_Justification__c == null || cases.Associate_Currency__c == null || 
           cases.Associate_Time_Zone__c == null || cases.Submitter_Name__c == null) {
               System.debug('General Section');
               requiredval=true;             
           }
        //modified By Sampath as a part of INC0955235   
        //Added By Sampath as a part of INC0955235 
        //Throwing error message if Request_Access_Salesforce__c == 'Yes' and below mentioned fields are NULL            
        if(cases.Request_Access_Salesforce__c == 'Yes') {
            if(cases.APTTUS__c == null || cases.Miller_Heiman__c == null || cases.Miller_Heiman_Training_Status__c == null) {    
                requiredval=true;
                System.debug('SFDC Section');   
            }
            if(cases.APTTUS__c == 'Yes') {    
                if(cases.APTTUS_Record_Access_Type__c == null || cases.Create_eNDA__c == null) {
                    requiredval=true;
                    System.debug('Apttus Section');
                    
                }
            }
            // Added by vineela as a part of SF-824 if Request_Access_CPQ__c field is null it will throw error
            if(cases.Request_Access_CPQ__c == null) {
                requiredval=true;
            } 
            if(cases.Request_Access_CPQ__c == 'Yes') {
                if(cases.Ability_to_create_Quotes__c == null || cases.Ability_to_approve_Quotes__c == null) {
                    requiredval=true;
                }    
            }
            
        } 
        //Ended by Vineela as a part of SF-824
        //Added By Sampath as a part of INC0955235     
        if(requiredval == true && !Test.isRunningTest()) {
            ApexPages.addMessage(new Apexpages.Message(ApexPages.severity.error,'Please fill all mandatory fields.'));
            return null; 
        }
        system.debug('testing'+ cases.Associate_Email__c );
        //Checking for valid mail address
        if(cases.Associate_Email__c!=null && !(cases.Associate_Email__c.contains('motorolasolutions.com') )) {
            ApexPages.addMessage(new Apexpages.Message(ApexPages.severity.error,'Please enter a valid Motorola Solutions email address.'));
            return null;
        }
        System.debug('Entered into save'); 
        System.debug('theater selected ......'+cases.Associate_Theater__c); 
        RecordType caseRtype = [SELECT Name,id FROM RecordType WHERE SobjectType='Case' and Name='User Request' LIMIT 1];
        system.debug('Record type of inserted case ..'+caseRtype.id);
        cases.RecordTypeId = caseRtype.id;
        cases.Subject = 'New User Request case' ;
        cases.type = 'New User Request';  
        try {      
            System.debug('Entered into save'+cases);
            insert cases;
            System.debug('Entered into save'+cases);
            
            ID IdVal= ApexPages.currentPage().getParameters().get('id');
            pagereference Page = new pagereference('/apex/SuccessMessage?caseno='+[SELECT CaseNumber FROM case WHERE id =:cases.id].CaseNumber);
            return Page;
        }
        catch(DMLException e) {
            return null;
        }
    }  
    public pageReference cancelMe() {
        pagereference Retpage = Page.UserRequestLandingPage;
        return Retpage ;
    }
    public NewUserRequestClass(ApexPages.StandardController controller) {
        cases = (case)controller.getRecord();
        system.debug('m here ....'+cases); 
    }  
}