/*  
 * Class Name  :LM_LeadEmailHandler
 * Description:  This class is used to attach email send to Notes and Attachments               
 * Modification Log 
 * ============================================================================= 
 * Ver   Date      Author        Modification 
 * -----------------------------------------------------------------------------------------------------------------------------------------
 * 1.0  11/12/2014 Kushal        Initial Code
.
 */
global class LM_LeadEmailHandler implements Messaging.InboundEmailHandler 
{
    
       global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, 
                                                           Messaging.InboundEnvelope envelope) {
        
        
        Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
        
        String LeadId = null;
        Messaging.InboundEmail.Header[] headers = email.headers;

       if (headers.size() > 0)
      {
            // Loop through custom headers to get Lead_Id
         for (Integer i = 0; i < headers.size(); ++i) 
         {
               System.debug('testing:'+i + ': [' + headers[i].name + ']=[' + headers[i].value);
               if (headers[i].name == 'X-SFDC-X-Lead-Id') {
                    LeadId = headers[i].value;
                    break;
                }
         }
                                        
         String htmlValue = email.htmlBody;
         String strPId=null;

         if (LeadId == null) 
         {
             String getId=htmlValue.substringBetween('value=','visible'); 
             system.debug('test:'+htmlValue);        
             strPId=getId.trim();
             List<String> parts = htmlValue .split('</label>');
             if(parts.size() > 1)
             email.htmlBody=parts [1];
         } 
         else 
         {
             strPId= LeadId;
         }                
        Lead leadRecord = [select OwnerId from lead where id= :LeadId]; 
        System.debug('lead owner id-->'+leadRecord.OwnerId) ;   
        if (htmlValue != null && strPId!= null) 
        {
            // attach a note to the agreement
            // create the note
            Id parentId= strPId; 
            system.debug('Testp:'+parentId);            
            Note noteSO = new Note(parentId = parentId);
            noteSO.IsPrivate = true;
            noteSO.OwnerId = leadRecord.OwnerId;
            System.debug('owner id-->'+noteSO.OwnerId);
            noteSO.Body = email.htmlBody;
            if(email.subject.length() > 80){
                         noteSO.Title = (email.subject).substring(0,79);
                    } else {
                         noteSO.Title  = email.subject;
                    }

            insert noteSO;        
        }                  
        else 
        {    // No email headers
            System.debug('No email headers were found');
        }        
        result.success = true;
      }        
      return result;
}}