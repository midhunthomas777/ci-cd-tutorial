public class EinsteinBotConfiguration {
    
    public class TranscriptOutput {
        @InvocableVariable(required=true)
        public String sBotName;
        
        @InvocableVariable(required=true)
        public String sContactUsUrl; 
        
        @InvocableVariable(required=true)
        public String metaId; 
    }
    
    public class TranscriptInput {
        @InvocableVariable(required=true)
        public String conId;
        @InvocableVariable(required=true)
        public String botName;
    }
    
    @InvocableMethod(label='einsteinBotConfiguration' description='get the dynamic bot config')
    public static List<TranscriptOutput> getEinsteinConfig(List<TranscriptInput> input) {
        List<TranscriptOutput> outputList = new List<TranscriptOutput>();
        try{
            LiveChatTranscript lct = [SELECT Id,LiveChatButtonId FROM LiveChatTranscript WHERE Id =:input[0].conId limit 1];
            Locale_Region_Mapping_for_LiveAgent__mdt config = [SELECT Id,DeveloperName,Contact_Us_Form_Url__c,Einstein_Bot_Name__c FROM Locale_Region_Mapping_for_LiveAgent__mdt WHERE Button_Id__c =:lct.LiveChatButtonId AND Einstein_Bot_Name__c =:input[0].botName];
            TranscriptOutput output = new TranscriptOutput();
            output.sBotName = config.Einstein_Bot_Name__c;
            output.sContactUsUrl = config.Contact_Us_Form_Url__c;
            output.metaId = config.Id;
            outputList.add(output);
            return outputList;
        }
        catch(Exception e){
            System.debug('Error from getEinsteinConfig Method' + e.getMessage());    
        }
        return outputList;
    }
    
}