/*
 *    Creation Date: June 3, 2010
 *    Created By: Jude Voss/Raj
 *    Description: This class is used by the partner agreement email service to handle the 
 *    partner agreement email message to extract the agreement PDF document and attach it to
 *    application specified in the email custom header section.
 */

global class PartnerAgreementHandler implements Messaging.InboundEmailHandler {
    global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, 
                Messaging.InboundEnvelope envelope) {

        System.debug('Received a message: ' + email);
        
        Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
        String application_id = null;
        
        // Extract Application ID from email custom header
        Messaging.InboundEmail.Header[] headers = email.headers;
        
        if (headers.size() > 0)
        {
            System.debug('Found custom headers: ' + headers.size());
            
            // Loop through custom headers to get lead ID
            for (Integer i = 0; i < headers.size(); ++i) {
            
                System.debug(i + ': [' + headers[i].name + ']=[' + headers[i].value);
                
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
                
                Messaging.InboundEmail.BinaryAttachment[] attachments = email.binaryAttachments;
                if (attachments.size() > 0)
                {
                for (integer i = 0 ; i < attachments.size() ; i++) {
                    Blob pdfBlob = attachments[i].body;
                    System.debug('Number of attachments: ' + attachments.size());
                    
                    // Assuming the leade ID in the custom header is a valid lead ID    
                    Attachment a = new Attachment(ParentId = application_id, 
                                                  Name = attachments[i].filename,
                                                  ContentType = 'pdf',
                                                  Body = pdfBlob);

                    //insert the attachment 
                    try {
                        insert a;
                    } catch (System.DmlException e) {
                      ApexPages.addMessages(e);
                    }
                }} else {
                    System.debug('No attachments were found');
                }
            } // Application ID exists in the custom header
            
        } else {    // No email headers
            System.debug('Partner Agreement email service: No email headers were found');
        }
        
        result.success = true;
        return result;
    }
}