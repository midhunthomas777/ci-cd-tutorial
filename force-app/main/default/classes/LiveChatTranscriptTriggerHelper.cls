/**
 * @author: WGVR43 
 * @date: 15.02.2021
 * @group: DTSFPART
 * @description: 
 */

public class LiveChatTranscriptTriggerHelper {
	/**
	 * @param newItems incoming transcripts
	 * @param oldItems old transcripts
	 * @description Workaround for Partner Hub not saving custom Transcript fields
	 */
	public static void populateFieldsForPartners(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
		Set<Id> contactIds = new Set<Id>();
		for (Id transcriptId: newItems.keySet()) {
			Id newContactId = ((LiveChatTranscript) newItems.get(transcriptId)).ContactId;
			Id oldContactId = ((LiveChatTranscript) oldItems.get(transcriptId)).ContactId;

			if(newContactId != oldContactId){
				contactIds.add(newContactId);
			}

			
			LogError.saveInfoPEvent('Chat', '' + ((LiveChatTranscript) newItems.get(transcriptId)).User__c, '' + newItems.get(transcriptId));
		}

		if(!contactIds.isEmpty()){
			Map<Id, Contact> contacts = new Map<Id, Contact>([
					SELECT Id, FirstName, LastName, Email, User__r.LanguageLocaleKey, RecordTypeId
					FROM Contact WHERE Id IN :contactIds
			]);

			if(!contacts.isEmpty()){
				for (LiveChatTranscript transcript : (List<LiveChatTranscript>) newItems.values()) {
					Id contactPartnerRT = GlobalUtility.getRecordTypeIdByDeveloperName('Contact', 'MPE_Partner_Contact');
					if (transcript.ContactId != null && contacts.get(transcript.ContactId).RecordTypeId == contactPartnerRT) {
						transcript.First_Name__c = contacts.get(transcript.ContactId).FirstName;
						transcript.Last_Name__c = contacts.get(transcript.ContactId).LastName;
						transcript.Email_Address__c = contacts.get(transcript.ContactId).Email;
					}
				}
			}
		}
	}
}