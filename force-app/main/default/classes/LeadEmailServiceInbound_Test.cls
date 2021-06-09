/*
* Code Coverage For : LeadEmailServiceInbound
*
* Modification Log
* =====================================================================================================================================================
* Requirement/Jira Ticket       Date              Developer                 Description
* -----------------------       -----------       -------------------       -----------
* LUCXBW-675                    20-June-2020      Brijesh Shukla            Test class Created for the code coverage of Inbound Email Handler Class for lead emails.
*/

@isTest
public class LeadEmailServiceInbound_Test {
    @testSetup
    static void testSetUp() {
        TestDataSetUpUtils.insertCustomSettings();
    }

    static testMethod void TestLeadEmailServiceInbound() {
        // Create a new email and envelope object.
        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();
        list<String> lstAddresses = new List<String>();
        lstAddresses.add('lead_email_service@m-1jv9c8t418zy7j71rcfe6r1g3h00jzmw4kh1usjtxhlf8bv3rs.3c-1pcxuae.cs60.apex.sandbox.salesforce.com');

        // Create Test record.
        List<Lead> lstLead = testDataSetUpUtils.createLeadRecords(1);
        email.FromAddress = 'abc@org.com';
        email.toAddresses = lstAddresses;
        email.Subject = 'Test Lead Email';
        email.htmlBody = 'Test Lead Email Record Id:- '+ lstLead[0].Id;
        email.plainTextBody = 'Test Lead Email Record Id:- '+ lstLead[0].Id;
        email.inReplyTo = 'abc@org.com';
        
        system.debug('TEST Email :- '+email);
        envelope.fromAddress = 'test@test.com';
        LeadEmailServiceInbound objEmailServ = new LeadEmailServiceInbound();
        objEmailServ.handleInboundEmail(email, envelope);
    }
}