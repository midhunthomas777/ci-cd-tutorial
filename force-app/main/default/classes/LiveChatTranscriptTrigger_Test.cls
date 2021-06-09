@isTest
public class LiveChatTranscriptTrigger_Test {
    @isTest(seeAllData=true)
    public static void testMethod1(){
        LiveChatVisitor lcv = new LiveChatVisitor();
        try{
            insert lcv;
        }
        catch(Exception e){
            system.debug('Error Inserting Chat Visitor Record');
        }
        // insert Live Chat Transcript
        LiveChatTranscript lct = new LiveChatTranscript();
        lct.LiveChatVisitorid = lcv.id;    
        lct.ChatKey = '53c20dfa-397e-489c-a175-24674ec434q9';
        try{
            insert lct;
            User u = [select Id,Name,lastname,firstname from user where id=:Userinfo.getUserId()];
            lct.ownerId=u.Id;
            lct.Status='Completed'; 
            update lct;
            delete lct;
            undelete lct;
        }
        catch(Exception e){
            system.debug('Error Inserting Chat Transcript Record');
        }
    }
    
    @isTest(seeAllData=true)
    public static void testMethod2(){
        LiveChatVisitor lcv = new LiveChatVisitor();
        try{
            insert lcv;
        }
        catch(Exception e){
            system.debug('Error Inserting Chat Visitor Record');
        }
        // insert Live Chat Transcript
        LiveChatTranscript lct = new LiveChatTranscript();
        lct.LiveChatVisitorid = lcv.id;    
        lct.ChatKey = '53c20dfa-397e-489c-a175-24674ec434q8';
        try{
            insert lct;
            User u = [select Id,Name,lastname,firstname from user where id=:Userinfo.getUserId()];
            lct.ownerId=u.Id;
            lct.Status='In Progress'; 
            update lct;
            delete lct;
            undelete lct;
            System.assertEquals(lct.Status, 'In Progress');
        }
        catch(Exception e){
            system.debug('Error Inserting Chat Transcript Record');
        }
    }

    @IsTest(SeeAllData=true)
    private static void testPartnerChat(){
        Id accPartnerRT = GlobalUtility.getRecordTypeIdByDeveloperName('Account', 'Partner');
        Account partnerAccount = TestDataSetUpUtils.createPartnerAccount(accPartnerRT);

        Id contPartnerRT = GlobalUtility.getRecordTypeIdByDeveloperName('Contact', 'MPE_Partner_Contact');
        List<Contact> partnerContact = TestDataSetUpUtils.createContacts(1, contPartnerRT, new List<Account>{partnerAccount});

        LiveChatVisitor visitor = new LiveChatVisitor();
        try{
            insert visitor;
        }
        catch(Exception e){
            System.debug('Error Inserting Chat Visitor Record');
        }

        LiveChatTranscript transcript = new LiveChatTranscript();
        transcript.LiveChatVisitorId = visitor.Id;
        insert transcript;

        System.assertNotEquals(null, transcript.Id);

        transcript.ContactId = partnerContact.get(0).Id;
        update transcript;

        LiveChatTranscript testTranscript = [SELECT First_Name__c, Last_Name__c, Email_Address__c
                                             FROM LiveChatTranscript WHERE Id = :transcript.Id LIMIT 1];
        System.assertEquals(partnerContact.get(0).FirstName.toLowerCase(), testTranscript.First_Name__c.toLowerCase());
        System.assertEquals(partnerContact.get(0).LastName.toLowerCase(), testTranscript.Last_Name__c.toLowerCase());
        System.assertEquals(partnerContact.get(0).Email.toLowerCase(), testTranscript.Email_Address__c.toLowerCase());
    }
    
}