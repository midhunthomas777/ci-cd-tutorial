@RestResource(urlMapping='/einsteinconfigurl')
global class EinsteinLiveAgentRestService{
    @HttpGet
    global static Locale_Region_Mapping_for_LiveAgent__mdt  getLocaleConfigRecord() {
        Locale_Region_Mapping_for_LiveAgent__mdt configRec;
        String siteurl = RestContext.request.params.get('siteurl');
        String recordKey = '';
        if(siteurl.contains('partner-central') && siteurl.contains('en_us')){
            recordKey = 'NAPC';
        }
        else if(siteurl.contains('en_us')){
           recordKey = 'NAMSI';
        }
        else if(siteurl.contains('eloqua')){
            recordKey = 'NAMSI';
        }
        else if(siteurl.contains('blog')){
            recordKey = 'NAMSI';
        }
        
        if(String.isNotBlank(siteurl)){
            try{
                configRec = [SELECT Id,DeveloperName,Default_Minimized_Text__c,Disabled_Minimized_Text__c,Check_Text__c,Display_Text__c,Policy_URL__c,Privacy_Statement__c,
                             Button_Id__c,Deployment_Id__c,Org_Id__c,First_Url__c,Second_Url_Channel__c,Live_Agent_Chat_Url__c,Embedded_Service_Deployment_Name__c,
                             baseLiveAgentContentURL__c,baseLiveAgentURL__c,eswLiveAgentDevName__c,isOfflineSupportEnabled__c,setAttribute_src__c ,isDebug__c,
                             Is_Display_Chat_Button__c,Einstein_Bot_Name__c,Site_Url__c,Site_Language__c,Is_Banner_Needed__c,Loading_Text__c,Email_Address_ChatT__c,First_Name_ChatT__c,Last_Name_ChatT__c,Contact_Us_Form_Url__c,  
                             First_Name_Place_Holder__c,Last_Name_Place_Holder__c,Email_Place_Holder__c,Banner_Text__c,Supported_Language_Banner__c,Url_Key_Set__c,Version__c  FROM Locale_Region_Mapping_for_LiveAgent__mdt WHERE DeveloperName =:recordKey];
            }
            catch(Exception e){
                System.debug('Error from getLocaleConfigRecord Einstein Method' + e.getMessage());    
            }
        }
        return configRec;
    }
}