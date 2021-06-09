public class LiveChatTranscriptTriggerHandler implements ITriggerHandler {    
    
    public static Boolean TriggerDisabled = false;
    
    public Boolean isDisabled(){
        if (TriggerSettings__c.getValues('LiveChatTranscriptTriggerDisabled').IsActive__c)
            return True;
        else
            return TriggerDisabled;
    }
    
    public void BeforeInsert(List<SObject> newItems){}

    public void BeforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {}
    
    public void BeforeDelete(Map<Id, SObject> oldItems){}
    
    public void AfterInsert(Map<Id, SObject> newItems){
                
        SurveyInvitation[] surveyInvites = new List<SurveyInvitation>();
        string SurveysId = [Select Id from Survey where DeveloperName = 'chat_survey'].Id;
        for (LiveChatTranscript lct : (List<LiveChatTranscript>)newItems.values()) {
            SurveyInvitation surveyInvite =  new SurveyInvitation(
                Name = lct.Name,
                SurveyId = SurveysId, //'0Kd2H000000GmaiSAC',
                ChatKey__c = lct.ChatKey, 
                Chat_Transcript__c = lct.Id,
                Chat_Visitor__c = lct.LiveChatVisitorId,
                CommunityId = '0DB2H00000005Gr',
                OptionsAllowGuestUserResponse = TRUE,
                OptionsAllowParticipantAccessTheirResponse = FALSE,
                OptionsCollectAnonymousResponse = TRUE
            );
            surveyInvites.add(surveyInvite);
             System.debug('##surveyInvite###'+surveyInvite);
        }
        if (!surveyInvites.isEmpty()){
            insert surveyInvites;
        }
    }
    
    public void AfterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems){}
    
    public void AfterDelete(Map<Id, SObject> oldItems){}
    
    public void AfterUndelete(Map<Id, SObject> oldItems){}
    
    
}