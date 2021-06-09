/*
* Class   : LeadEmailServiceInbound
* Purpose : This Email Service Class is written to attach the inbound email response to the Lead Record which were generated from Send Email activity At leasd level.
*
* Modification Log
* =====================================================================================================================================================
* Requirement/Jira Ticket       Date              Developer                 Description
* -----------------------       -----------       -------------------       -----------
* LUCXBW-675                    18-June-2020      Jitender Bhatia           Created the class to attach the inbound emails to Lead record based on the sender email.
* LUCXBW-675                    10-June-2020      Brijesh Shukla            Updated the Email template body to have reference id for the records and updated the logic to read the record id and fetch the parent Lead based on that.
*/

global class LeadEmailServiceInbound implements Messaging.InboundEmailHandler {
    global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) {
        Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();
        system.debug('Email Body'+ email.plainTextBody);

        String strBody = email.plainTextBody;
        Integer iCounter = strBody.indexof('Record Id:- ');
        Id strLinkId;

        if(String.isNotBlank(strBody) && iCounter != -1) {
            strLinkId = strBody.substring(iCounter+12, iCounter+27).trim();
        }

        try {
            if((strLinkId.getsobjecttype().getDescribe().getName()=='Lead' || strLinkId.getsobjecttype().getDescribe().getName()=='Contact') && email.inReplyTo != null) {
                system.debug('Entered If:-');
                EmailMessage objLeadEmailMessage = new EmailMessage();
                    objLeadEmailMessage.Status = '2';
                    objLeadEmailMessage.Incoming= True;
                    objLeadEmailMessage.Subject = email.Subject;
                    objLeadEmailMessage.HtmlBody = email.HtmlBody;
                    objLeadEmailMessage.TextBody = email.plainTextBody;
                    objLeadEmailMessage.FromName = email.FromAddress;
                    objLeadEmailMessage.FromAddress =  email.FromAddress;
                    objLeadEmailMessage.ToAddress =  String.join(email.toAddresses, ',');
                    if(strLinkId.getsobjecttype().getDescribe().getName()=='Lead') {
                        objLeadEmailMessage.Lead__c = strLinkId;
                    }
                    else if(strLinkId.getsobjecttype().getDescribe().getName()=='Contact') {
                        objLeadEmailMessage.Contact__c = strLinkId;
                    }
                insert objLeadEmailMessage;

                // Add Email Message Relation for id of the sender
                EmailMessageRelation objEMR = new EmailMessageRelation();
                    objEMR.EmailMessageId = objLeadEmailMessage.id;
                    objEMR.RelationId = strLinkId; 
                    objEMR.RelationAddress = email.FromAddress;
                    objEMR.RelationType = 'FromAddress';
                insert objEMR; 
            }
        }
        catch(Exception e) {
            system.debug('An Issue Occured while Creating Inbound Email Record :- ' + e);
        }
        return result;
    }
}