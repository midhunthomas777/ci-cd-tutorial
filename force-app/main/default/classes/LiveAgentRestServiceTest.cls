@isTest
public class LiveAgentRestServiceTest {    
        
        
        static testMethod void testGet() {
            Locale_Region_Mapping_for_LiveAgent__mdt config = [ SELECT Id,DeveloperName,Default_Minimized_Text__c,Disabled_Minimized_Text__c,Check_Text__c,Display_Text__c,
                    Policy_URL__c,Privacy_Statement__c,Button_Id__c,Deployment_Id__c,Org_Id__c,First_Url__c,Second_Url_Channel__c,Live_Agent_Chat_Url__c,Embedded_Service_Deployment_Name__c,
                    baseLiveAgentContentURL__c,baseLiveAgentURL__c,eswLiveAgentDevName__c,isOfflineSupportEnabled__c,setAttribute_src__c,isDebug__c,Is_Display_Chat_Button__c 
                FROM Locale_Region_Mapping_for_LiveAgent__mdt limit 1 ];
            RestRequest req = new RestRequest(); 
            RestResponse res = new RestResponse();             
            req.requestURI = 'https://sit-mpecommunity.cs19.force.com/channel/services/apexrest/liveagentconfigurl?localename='+config.DeveloperName;
            req.httpMethod = 'GET';
            RestContext.request = req;
            RestContext.response= res;
            Locale_Region_Mapping_for_LiveAgent__mdt configResp = LiveAgentRestService.getLocaleConfigRecord();
            
        }
}