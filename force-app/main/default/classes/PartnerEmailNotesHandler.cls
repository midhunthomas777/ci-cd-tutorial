/*  
* File Name     : PartnerEmailNotesHandler
* Description   : This class is used by the partner agreement email service to handle the 
*                 partner agreement email message to extract the agreement PDF document and attach it to
*                 application specified in the email custom header section.
*                 
* @author       : Jude Voss
*
* Modification Log
* =============================================================================
*   Ver     Date         Author          Modification
*------------------------------------------------------------------------------
*   1.0     25-Jan-12    Jude Voss       Initial Creation
*/
global class PartnerEmailNotesHandler implements Messaging.InboundEmailHandler {
    global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, 
                Messaging.InboundEnvelope envelope) {
        
        Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
        String application_id = null;
        
        // Extract Application ID from email custom header
        Messaging.InboundEmail.Header[] headers = email.headers;
        
        if (headers.size() > 0 || headers.size() <= 0)
        {            
            // Loop through custom headers to get lead ID
            for (Integer i = 0; i < headers.size(); ++i) {                            
                if (headers[i].name == 'X-SFDC-X-application_id') {
                    application_id = headers[i].value;
                    break;
                }
            }
            
            // If application id is not found in the custom headers then don't do anything
            if (application_id == null) {
                System.debug('There was no application_id in the custom headers: ' + headers);
            } else {
                System.debug('Found application id in the custom header: ' + application_id);
                
                //Messaging.InboundEmail.BinaryAttachment[] attachments = email.binaryAttachments;
                if (email.binaryAttachments != null && email.binaryAttachments.size() > 0)
                {
                for (integer i = 0 ; i < email.binaryAttachments.size() ; i++) {
                    Blob pdfBlob = email.binaryAttachments[i].body;
                    
                    // Assuming the leade ID in the custom header is a valid lead ID    
                    Attachment a = new Attachment(ParentId = application_id, 
                                                  Name = email.binaryAttachments[i].filename,
                                                  ContentType = 'pdf',
                                                  Body = pdfBlob);
                                                  
                     try {
                        insert a;
                    } catch (System.DmlException e) {
                      ApexPages.addMessages(e);
                    }                             
                    }
                    } 
                    else {
                    System.debug('No attachments were found');
                    } 
                                                
                    Note note = new Note();
                    note.ParentId = application_id;
                    
                    if(email.subject.length() > 80){
                        note.Title = (email.subject).substring(0,79);
                    } else {
                        note.Title = email.subject;
                    }
                         
                    note.Body = email.htmlBody;
                    //note.Body = email.plainTextBody;
                    //insert the attachment 
                    try {
                        
                        insert note; 
                    } catch (System.DmlException e) {
                      ApexPages.addMessages(e);
                    }
                
                 
            } // Application ID exists in the custom header
            
        } else {    // No email headers
            System.debug('Partner Agreement email service: No email headers were found');
        }
        
        result.success = true;
        return result;
    }
}