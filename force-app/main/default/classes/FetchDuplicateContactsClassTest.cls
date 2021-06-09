@isTest
public class FetchDuplicateContactsClassTest {
    @isTest
    public static void fetchContacts(){
        TestDataSetUpUtils.insertCustomSettings();
        Id standardCon = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Standard').getRecordTypeId();
        Id custRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        List<Account> cusAcc = TestDataSetUpUtils.createAccounts(3,custRecTypeId);
        List<Contact> conLst = TestDataSetUpUtils.createContacts(1,standardCon,cusAcc);
         /*
            insert Live Chat Visitor
        */
        LiveChatVisitor lcv = new LiveChatVisitor();
        try{
            insert lcv;
        }
        catch(Exception e){
            
        }
        /*
            insert Live Chat Transcript
        */
        LiveChatTranscript lct = new LiveChatTranscript();
        lct.LiveChatVisitorid = lcv.id;
        lct.ContactId = conLst[0].id;
        try{
            insert lct;
        }
        catch(Exception e){
            
        }
        FetchDuplicateContactsClass fDupCon = new FetchDuplicateContactsClass();
        FetchDuplicateContactsClass.getContacts(lct.id);       
    }
}