global class EAAgreementController{

/*  
* File Name  : EAAgreementController 
* Description: Generates pdf for Opportunity Record for a set of allowed profiles
                Checks if there is an Agreement record for this Opportunity.Inserts if not found else shows an error message
                It also attaches this pdf in Notes and attachment section for inserted agreement record.    
* Author     : Anupama Ajith 
* Modification Log 
* ============================================================================= 
* Ver   Date                  Author                                                    Modification 

* -----------------------------------------------------------------------------------------------------------------------------------------
* 1.0   21-Aug-2013          Anupama                                                   Created                                                     
* 1.1  19-Feb-2018       Sravan                             SF-525- Removed hardcoded references of opportunity record types apart from "Registration"
*                                              & "Project".
*
*/

public Opportunity opportunity;
public List<Apttus__APTS_Agreement__c> aggr = new List<Apttus__APTS_Agreement__c>();
public Id oppId = ApexPages.currentPage().getParameters().get('id');
public id accid;
public id accid1;
public Apttus__APTS_Agreement__c  agreement = new Apttus__APTS_Agreement__c();
public static List<User> user = new List<User>();  
public static Set<String> profile = new Set<String>(); 
public boolean errMsg {get;set;}
public User currentuser{get;set;} //added by Haritha

public EAAgreementController() {


}

//Standard Controller
public EAAgreementController(ApexPages.StandardController controller) {

       // added by Haritha
     currentuser=[Select Id,Name,Primary_Business_Group__c from User where Id =:UserInfo.getUserID() limit 1];
     System.debug('User List '+currentuser);
       List<Account> AccName = [select id, name from Account where Type = 'Motorola Entity'];
        for(Account acc:AccName){
           if(acc.Name == 'Motorola Solutions Germany GmbH'){
             accid = acc.id;
             System.debug('***' +accid );
           }
           if(acc.Name == 'Motorola Solutions UK Limited'){
             accid1 = acc.id;
             System.debug('***' +accid1 );
           }


        } 

}

//Checks if the profile of the user is in the set of allowed profiles.called from the custom link.returns an integer
/*webservice static integer profileCheck(){
 
 user = [SELECT profile.Name FROM User WHERE id=:Userinfo.getUserid()]; 
 Map<String,EA_AgreementProfiles__c> mapForCustomSetting = EA_AgreementProfiles__c.getAll();
   for(EA_AgreementProfiles__c profileMap:mapForCustomSetting.values()){
       profile.add(profileMap.Profile_Names__c);
   }       
   //Check if its the allowed profiles 
   if(profile.contains(user[0].profile.Name)){
       return 1; 
   }
   else{
       return 0;
   }     
}*/

   
//inserting the Agreement   
public void insertAgreement(){



  system.debug('Entering insert agreement');
  aggr = [SELECT Name FROM Apttus__APTS_Agreement__c WHERE Apttus__Related_Opportunity__c=:oppId];     
  if(aggr.isEmpty()){
     opportunity = [SELECT id,Account.id,Owner.id,Owner.Area_Controller__c,Owner.Theater_Code__c,MSI_Business_Group__c,Name,Total_Order_Value_Inc_Service__c,
                 End_User_Country__c,Project_Awards__c,Mega_Indicator__c,RecordType.developerName,Project_Awards__r.Name,Status__c,RecordType.Name,CurrencyIsoCode,Account.BillingCountry  FROM Opportunity WHERE id =:oppId];
      
     errMsg = true;
     system.debug('opp is: '+opportunity.id); 
     
   /* Added by M Chanu : As a part of the Product Family to Technology mapping PSRR Phase 2*/
      
    map<Id, Schema.RecordTypeInfo> rt_map = Schema.getGlobalDescribe().get('Opportunity').getDescribe().getRecordTypeInfosById();
    
    List<String> prodName = new List<String>();
         String productfamily ;
         String pname;
         List<OpportunityLineItem> oppline = new List<OpportunityLineItem>([Select Id, product_name__c  from  OpportunityLineItem where OpportunityId =:opportunity.id]);                    
                                   
          For (OpportunityLineItem  opp :oppline ) {
           prodName.add(opp.product_name__c);
         }
   
          System.debug( '**********Product Family List *********'+prodName);
          productfamily = String.join(prodName, ',');
          System.debug( '**********Product Family List *********'+productfamily);
   
          if(productfamily != null || productfamily !='' ) {
          string pli = productfamily.trim();
          if(pli.contains('Services - Non-Traditional Systems Integration')){
           pli= pli.replaceAll('Services - Non-Traditional Systems Integration','ServicesNonTraditionalSystemsIntegration');
          }
        
            if(pli.contains(',')){
                List<String> values = pli.split(',');
                string assignValue = '';
                for(string s :values){
                    assignValue += s + ';';
                } 
                assignValue = assignValue.subString(0,assignValue .length()-1);
                pname = assignValue;
            }else{
                pname = pli;
            }            
          }
          else {
          // do nohing 
        }
 /* End of the  Product Family Logic  of Apttus */
     
     
     
     //Defaulting the values 
     Id RectypeId = [SELECT Name,Id FROM RecordType WHERE sObjectType =: 'Apttus__APTS_Agreement__c' AND Name = :'Sales'].id;
     agreement.RecordTypeId = RectypeId; 
     agreement.Apttus__Status__c = 'Request'; 
     agreement.Apttus__Status_Category__c= 'Request';
     agreement.m_GTM_Region__c = 'EA';
     agreement.Apttus_Approval__Approval_Status__c = 'Not Submitted';
     agreement.Email_Business_Contacts_upon_Activation__c = True;
     agreement.Apttus__Account__c = opportunity.Account.id;
     agreement.Apttus__Related_Opportunity__c = opportunity.id;
     agreement.Agreement_Title__c = opportunity.Name;
     agreement.Strategic_Project__c = opportunity.Mega_Indicator__c;
     agreement.Apttus__Total_Contract_Value__c = opportunity.Total_Order_Value_Inc_Service__c;
     agreement.New_Country_of_Deployment__c = opportunity.Account.BillingCountry;
     //agreement.Finance_Approver_c__c = opportunity.Owner.Area_Controller__c;
     //agreement.Proposal Due Date = opportunity.
     agreement.Business_Contact__c = opportunity.Owner.id;
     agreement.m_Motorola_Internal_Tracking_Number__c = opportunity.Project_Awards__r.Name;
     agreement.CurrencyIsoCode = opportunity.CurrencyIsoCode;
     agreement.m_Business_Unit__c = opportunity.MSI_Business_Group__c;
    if((opportunity.RecordType.developerName == 'Government_Standard')){
       agreement.m_Technology__c = pname;
    }
      
    
     
  
     if(opportunity.Owner.Theater_Code__c == 'EMEA' && opportunity.MSI_Business_Group__c== 'Enterprise'){
        agreement.Motorola_Entity_Account__c = accid;
        
     }
      else if(opportunity.Owner.Theater_Code__c == 'EMEA' && opportunity.MSI_Business_Group__c== 'Government'){
        agreement.Motorola_Entity_Account__c = accid1 ;
        
     }
  
     if(opportunity.Status__c == 'Lost'){
        agreement.Reason_for_Cancellation__c= 'Lost Bid';
     }
     else if(opportunity.Status__c == 'Won'){
        agreement.Reason_for_Cancellation__c= 'Contract Awarded';
     }
     else if(opportunity.Status__c == 'No Pursuit'){
        agreement.Reason_for_Cancellation__c= 'No Bid';
     }
  
     insert agreement;
  
  /*****Agreement as attachment in Notes and Attachment****/
     Id agrId = [SELECT id FROM Apttus__APTS_Agreement__c WHERE Apttus__Related_Opportunity__c=:oppId LIMIT 1].id;
     List<Attachment> attachList =[SELECT id FROM Attachment WHERE ParentId =: agrId];
     Attachment attach = new Attachment();
     if(attachList.isEmpty()){                
          PageReference pdf = Page.pdfDocEAAttachment;
          pdf.getParameters().put('id',oppId);
          Blob pdfBlob;                 
          try {         
            // returns the output of the page as a PDF
              pdfBlob= pdf.getContent(); 
              system.debug('body of pdf **'+pdfBlob);
          } catch (VisualforceException e) {
              pdfBlob= Blob.valueOf('Testing ');
          }
          attach.Body = pdfBlob;
          // add the name and extension
          attach.Name = 'OpportunityPDF'+'.pdf';
          attach.IsPrivate = false;
          // attach the pdf to the account
          attach.ParentId = agreement.id;         
          insert attach;       
      }
      system.debug('Agreement title is **'+opportunity.Name+' *** and **** '+agreement.Apttus__FF_Agreement_Number__c); 
  }
  else
  {
  system.debug('error');
  errMsg = false;
  ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,'An Agreement already exists for this Opportunity!'));
  }






}
}