/*
*Description: This class is used to find the duplicate contacts matching with ADP contact email address.
- If there are more than one matching contact, consider user enabled contact for update.
- If more than one contact is user enabled, consider the contact which has active user for update.
- If there are more than one matching contact, but none of them is user enabled then consider the first contact for update.
*-------------------------------------------------------------------------------------------------------
*  Author                          Date                                Project         
*  SriDurgaDevi                    12/28/2016                          ADP 
*-------------------------------------------------------------------------------------------------------
*/
Public Class ADP_FindDuplicateContact
{
    
    
    public static Map<String,Contact> getDuplicateContact(Decimal gID, List<String> eMail){
        
        system.debug('Entering into helper class');
        ID PART_CON_RTId = Schema.SObjectType.Contact.RecordTypeInfosByName.get('Partner').RecordTypeId;
        ID PART_ACC_RTId = Schema.SObjectType.Account.RecordTypeInfosByName.get('Partner').RecordTypeId;
        Map<String,Contact> accContact = new Map<String,Contact>();
        Map<ID,Contact> contMap = new Map<ID,Contact>();
        Map<String,List<ID>> EmailContMap = new Map<String,List<ID>>();
        List<ID> contIdList = new List<ID>();
        
        List<Account> acct =[select id from Account where ADP_Global_Account_Name1__r.GitLab_Group_Id__c = :gID and RecordtypeId = :PART_ACC_RTId];

        for(Contact Ct : [Select Id, AccountId, Email,Tag__c,Primary_Contact_Type__c,Contact_Type__c,LastName,
                                    FirstName,MobilePhone,Title,Fax,MailingPostalCode,Preferred_Language__c,Salutation,
                                    MailingState From Contact Where Accountid in :acct and RecordtypeId = :PART_CON_RTId and Email in :eMail order by LastModifiedDate desc]){
            contMap.put(Ct.id,Ct);  
            contIdList.add(Ct.id); 
        }
        
        system.debug('List of matching contacts '+contIdList);  
        if(contIdList.size() > 0){
                List<User> usr = [select id,ContactId,Contact.Email,isActive,Email from User where ContactId in :contIdList order by isActive desc ];              
                
                // If contacts are enabled as users then pick the right one
                if(usr.size() > 0){
                    For(integer i=0; i<usr.size(); i++){
                        system.debug('Processing user ' +usr[i].Email);
                        if(usr[i].isActive == true && !accContact.containsKey(usr[i].Email.toLowerCase())){
                            system.debug('Entering into active loop');
                            accContact.put(usr[i].contact.Email.toLowerCase(),contMap.get(usr[i].ContactId));
                            
                        }
                        else if(usr[i].isActive == false && !accContact.containsKey(usr[i].Email.toLowerCase())){
                            system.debug('Entering into inactive loop');
                            accContact.put(usr[i].contact.Email.toLowerCase(),contMap.get(usr[i].ContactId));  
                        }
                    }
                    
                } 
                
                //Incase User is not enabled but duplicate contacts are exist
                //Loop through contacts & check if email is exist in final map. If not, add first contact into the list
                For(integer i=0; i<contIdList.size(); i++){
                       system.debug('Contact email address'+contMap.get(contIdList[i]).Email.toLowerCase());
                       if(!accContact.containsKey(contMap.get(contIdList[i]).Email.toLowerCase())){ 
                           accContact.put(contMap.get(contIdList[i]).Email.toLowerCase(),contMap.get(contIdlist[i]));
                       }
                }       
        } 
       
        system.debug('Final Account contact list' +accContact);             
        return accContact;
    }

}