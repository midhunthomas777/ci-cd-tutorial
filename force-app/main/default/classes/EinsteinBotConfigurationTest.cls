@isTest(seeAllData=true)
public class EinsteinBotConfigurationTest {
    static testMethod void einsteinBotCheck(){
        
        EinsteinBotConfiguration.TranscriptOutput output = new EinsteinBotConfiguration.TranscriptOutput();        
        List<EinsteinBotConfiguration.TranscriptOutput> outputList = new List<EinsteinBotConfiguration.TranscriptOutput>();   
        LiveChatVisitor lcv = new LiveChatVisitor();
        insert lcv;
        System.debug('=========================LiveChatVisitor=========================================='+lcv.Id);
        LiveChatTranscript lct = new LiveChatTranscript();
        lct.LiveChatButtonId = [select id FROM LiveChatButton where DeveloperName = 'MSI_en_us'].id;
        lct.LiveChatVisitorid = lcv.id;
        insert lct;
        System.debug('=========================LiveChatTranscript=========================================='+lct.Id);
        Locale_Region_Mapping_for_LiveAgent__mdt metObj= new Locale_Region_Mapping_for_LiveAgent__mdt();
        metObj.Button_Id__c = lct.LiveChatButtonId;
        metObj.Einstein_Bot_Name__c = 'NA MSI.com';
        metObj.Contact_Us_Form_Url__c = 'https://www.motorolasolutions.com/en_us/about/privacy-policy.html#privacystatement';
        
        EinsteinBotConfiguration.TranscriptInput input = new EinsteinBotConfiguration.TranscriptInput();
        input.botName = metObj.Einstein_Bot_Name__c;
        input.conId   = lct.Id;
        System.debug('=========================input============='+input.conId+'========='+input.botName);
        List<EinsteinBotConfiguration.TranscriptInput> inputList = new List<EinsteinBotConfiguration.TranscriptInput>();
        inputList.add(input);
        outputList = EinsteinBotConfiguration.getEinsteinConfig(inputList);
        System.debug('=======outputList='+outputList);
        
    }
    
    
}