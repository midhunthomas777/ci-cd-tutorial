public with sharing class FetchDuplicateContactsClass {    
    public FetchDuplicateContactsClass() {         
    }
    
    @AuraEnabled(cacheable=true)
    public static List<Contact> getContacts(Id chatid ){
        Id contactId;
        string email;        
        livechattranscript lct = [select contact.Email from livechattranscript where id=:chatid limit 1];
        email = lct.contact.email;    
        return [select id,AccountId,name,Account.Name,Record_Type_Name__c from contact where email=:email LIMIT 10];
    }
}