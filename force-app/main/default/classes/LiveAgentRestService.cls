@RestResource(urlMapping='/liveagentconfigurl')
 global class LiveAgentRestService {
  
    @HttpGet
    global static Locale_Region_Mapping_for_LiveAgent__mdt getLocaleConfigRecord() {
        Locale_Region_Mapping_for_LiveAgent__mdt configRec;
        try{
        String localename = RestContext.request.params.get('localename');
        configRec = [SELECT Id,DeveloperName,Default_Minimized_Text__c,Disabled_Minimized_Text__c,Check_Text__c,Display_Text__c,
                    Policy_URL__c,Privacy_Statement__c,Button_Id__c,Deployment_Id__c,Org_Id__c,First_Url__c,Second_Url_Channel__c,Live_Agent_Chat_Url__c,Embedded_Service_Deployment_Name__c,
                    baseLiveAgentContentURL__c,baseLiveAgentURL__c,eswLiveAgentDevName__c,isOfflineSupportEnabled__c,setAttribute_src__c ,isDebug__c,Is_Display_Chat_Button__c,Site_Language__c,Loading_Text__c,Email_Address_ChatT__c,First_Name_ChatT__c,Last_Name_ChatT__c,
                First_Name_Place_Holder__c,Last_Name_Place_Holder__c,Email_Place_Holder__c,Banner_Text__c,Is_Banner_Needed__c,Supported_Language_Banner__c,Url_Key_Set__c,Version__c FROM Locale_Region_Mapping_for_LiveAgent__mdt WHERE DeveloperName =:localename]; 
        }
        catch(Exception e){
            System.debug('Error from LiveAgentRestService Method' + e.getMessage());    
        }
        return configRec;
    }
}