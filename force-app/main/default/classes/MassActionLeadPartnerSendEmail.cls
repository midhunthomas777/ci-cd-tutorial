/**********************************************************************************************************************
* Description : Send Notifcation for Partner contacts with tags SFDC Partner Admin/Lead Admin 
* when leads get assigned to a partner account, without an assigned sales rep 
* Author : Anitha Mohankumar
* Date : 10th Oct 2019
**********************************************************************************************************************************/
public class MassActionLeadPartnerSendEmail{
    
    @InvocableMethod 
    public static void sendMailsToCon(List<Id> leadIds) { 
        system.debug('leadIds===>'+leadIds);
        Map<Id,Id> leadIdAccmap = new Map<Id,Id>();
        List<Lead> leadToBeUpdated = new  List<Lead>();
        OrgWideEmailAddress[] owea = [Select Id from OrgWideEmailAddress where Address = 'partners.na@motorolasolutions.com'];
        List<EmailTemplate> templateIds = [Select Id from EmailTemplate where DeveloperName='Lead_Partner_without_Contact_Assignment'];
        if(!templateIds.isEmpty()) {
            Id templateId = templateIds.get(0).Id;
            for(Lead leadObj : [SELECT Id,Partner_Account_NA__c,Partner_Assigned_Contact_NA__c,Partner_Email_Sent__c from Lead where Id=: leadIds]) {
                if(leadObj.Partner_Account_NA__c != NULL && leadObj.Partner_Assigned_Contact_NA__c == NULL) {
                    leadIdAccmap.put(leadObj.Partner_Account_NA__c, leadObj.Id);
                    leadObj.Partner_Email_Sent__c = 'Email Sent';
                    leadToBeUpdated.add(leadObj);
                }
            }
            System.debug('leadIdAccmap===>'+leadIdAccmap);
            Map<Id, List<Contact>> leadMap = new Map<Id, List<Contact>>();
            for(Contact sendEmailCon : [SELECT Email,AccountId FROM Contact WHERE AccountId IN : leadIdAccmap.keySet() 
                                        AND RecordType.DeveloperName = 'MPE_Partner_Contact' AND User__r.isActive = TRUE 
                                        AND (Tag__c includes ('Lead Admin') OR Tag__c includes ('SFDC Partner Admin'))]) 
            {
                Id leadId = leadIdAccmap.get(sendEmailCon.AccountId);
                system.debug('leadId===>'+leadId);
                if(leadMap.get(leadId) != NULL) {
                    system.debug('Inside if LeadMap===>'+leadId);
                    List<Contact> conList = leadMap.get(leadId);
                    conList.add(sendEmailCon);
                    leadMap.put(leadId, conList);
                } else {
                    system.debug('Inside else LeadMap===>'+leadId);
                    List<Contact> conList = new List<Contact>();
                    conList.add(sendEmailCon);
                    leadMap.put(leadId, conList);
                }
            }  
            List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
            for(Id leadId : leadMap.keySet()) {
                system.debug('Inside leadMap.keySet===>'+leadId);
                List<String> sendToaddr = new List<String>();
                Messaging.SingleEmailMessage singleMail = new Messaging.SingleEmailMessage();
                for(Contact con : leadMap.get(leadId)) {
                    sendToaddr.add(con.Email);
                }
                system.debug('sendToaddr===>'+sendToaddr);
                singleMail.setTemplateId(templateId);
                singleMail.setWhatId(leadId);
                singleMail.SaveAsActivity = false;
                singleMail.setTargetObjectId(UserInfo.getUserId());
                singleMail.setBccAddresses(sendToaddr);
                if ( owea.size() > 0 ) {
                    singleMail.setOrgWideEmailAddressId(owea.get(0).Id);
                }
                emailList.add(singleMail);
            }
            Messaging.SendEmailResult [] result = Messaging.sendEmail(emailList);
            system.debug('leadToBeUpdated===>'+leadToBeUpdated);
            if(!leadToBeUpdated.isEmpty()){
                update leadToBeUpdated;
            }
        }
    }
}