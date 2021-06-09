/**
 * @author      Sagar Sindhi
 * @created     2020-08-27
 * @updated     2020-10-27
 * @description Class for sending email notifications.
 */
public class EmailMessagingClass {

    /** @description Send Number of Emails as per the parameters defined in this method.
     *  @param Target objectIDs of the contact, lead, or user to which the email will be sent.
     *  @param Email TemplateID used for Email Notification Information.
     *  @param Object Records which will be use for Mergering Template Fields.
     *  @param Boolean Identifier which will be use to identify Email details needs to be save as activity or not.
     *  @param list of email addresses or object IDs of the contacts, leads, and users you’re sending the email.
     *  @param Record Ids Map you're using in the case when you need to retrieve targetObjIds on the basis of @param3 object Record specific field values.
     *  @param field name of @param3 object which you're using for retrieve targetObjectIds from @param6.
     *  @param Boolean Identifier use for identifing targetObject as email recipient or not.
     *  @param Record ID with list of Email Addresses Map which you're using for retrieve Email Addresses from Obj Record.
     */
    public static void sendEmailMessage(List<Id> TargetObjIds, Id templateId, List<sObject> objRecords, Boolean saveAsActivity,
                                        List<String> toAddresses, Map<Id, List<Id>> objsMapping, String mapKeyName,
                                        Boolean targetObjAsRecipient, Map<Id, List<String>> objWithAddress) {

        List<Messaging.SingleEmailMessage> allmessages = new List<Messaging.SingleEmailMessage> ();

        if (objRecords != null && !objRecords.isEmpty() && objsMapping != null && !objsMapping.isEmpty()) {
            for (sObject eachRecord: objRecords) {
                String eachRecId = String.valueOf(eachRecord.get('Id'));
                String mapKey = String.valueOf(eachRecord.get(mapKeyName));
                List<Id> targetObjectIds = objsMapping.get(mapKey);
                if (!targetObjectIds.isEmpty()) {
                    for (Id eachTargetId: targetObjectIds) {
                        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                        mail.setTargetObjectId(eachTargetId);
                        mail.setTreatTargetObjectAsRecipient(targetObjAsRecipient);
                        mail.setTemplateId(templateId);
                        if (toAddresses != null && !toAddresses.isEmpty()) {
                            mail.setToAddresses(toAddresses);
                        }
                        mail.setWhatId(eachRecId);
                        mail.setSaveAsActivity(saveAsActivity);
                        allmessages.add(mail);
                    }
                }
            }
        } else if (TargetObjIds != null && !TargetObjIds.isEmpty()) {
            if (objRecords != null && !objRecords.isEmpty() && objWithAddress != null && !objWithAddress.isEmpty()) {
                for (Id eachTargetId: TargetObjIds) {
                    for (sObject eachRecord: objRecords) {
                        String eachRecId = String.valueOf(eachRecord.get('Id'));
                        List<String> addresses = objWithAddress.get(eachRecId);
                        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                        mail.setTargetObjectId(eachTargetId);
                        mail.setTreatTargetObjectAsRecipient(targetObjAsRecipient);
                        mail.setTemplateId(templateId);
                        if (addresses != null && !addresses.isEmpty()) {
                            mail.setToAddresses(addresses);
                        }
                        mail.setWhatId(eachRecId);
                        mail.setSaveAsActivity(saveAsActivity);
                        allmessages.add(mail);
                    }
                }
            } else {
                for (Id eachTargetId: TargetObjIds) {
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    mail.setTargetObjectId(eachTargetId);
                    mail.setTreatTargetObjectAsRecipient(targetObjAsRecipient);
                    mail.setTemplateId(templateId);
                    if (toAddresses != null && !toAddresses.isEmpty()) {
                        mail.setToAddresses(toAddresses);
                    }
                    mail.setSaveAsActivity(saveAsActivity);
                    allmessages.add(mail);
                }
            }
        }
        emailMessageSend(allmessages);
    }

    private static void emailMessageSend(List<Messaging.SingleEmailMessage> allmessages) {
        try {
            if (!allmessages.isEmpty()) {
                Messaging.sendEmail(allmessages);
            }
        } catch (Exception e) {
            LogError.saveExceptionPEvent('EmailMessagingClass.emailMessageSend', '', '', e);
            throw e;
        }
    }
}