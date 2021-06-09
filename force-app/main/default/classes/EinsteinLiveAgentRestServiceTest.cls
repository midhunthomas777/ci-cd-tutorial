@isTest(SeeAllData = true)
public class EinsteinLiveAgentRestServiceTest {    
    static testMethod void testGetEinstein1() {
        
        Locale_Region_Mapping_for_LiveAgent__mdt obj = new Locale_Region_Mapping_for_LiveAgent__mdt();
        obj.Site_Url__c = 'https://aem-dev-publish.motorolasolutions.com/en_us/partner-central.html';
        obj.DeveloperName = 'NAPC';
        String check = utility(obj.Site_Url__c);
        system.assertEquals(obj.DeveloperName,check);
    }
    static testMethod void testGetEinstein2() {
        
        Locale_Region_Mapping_for_LiveAgent__mdt obj = new Locale_Region_Mapping_for_LiveAgent__mdt();
        obj.Site_Url__c = 'https://aem-dev-publish.motorolasolutions.com/en_us';
        obj.DeveloperName = 'NAMSI';
        String check = utility(obj.Site_Url__c);
        system.assertEquals(obj.DeveloperName,check);
        
    }
    static testMethod void testGetEinstein3() {         
        Locale_Region_Mapping_for_LiveAgent__mdt obj = new Locale_Region_Mapping_for_LiveAgent__mdt();
        obj.Site_Url__c = 'https://aem-dev-publish.motorolasolutions.com/eloqua';
        obj.DeveloperName = 'NAMSI';
        String check = utility(obj.Site_Url__c);
        system.assertEquals(obj.DeveloperName,check);
        
    }
    static testMethod void testGetEinstein4() {         
        Locale_Region_Mapping_for_LiveAgent__mdt obj = new Locale_Region_Mapping_for_LiveAgent__mdt();
        obj.Site_Url__c = 'https://aem-dev-publish.motorolasolutions.com/blog';
        obj.DeveloperName = 'NAMSI';
        String check = utility(obj.Site_Url__c);
        system.assertEquals(obj.DeveloperName,check);
        
    }
    
    
    
    public static String utility(String url){
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();                  
        req.requestURI = 'https://chatdev-mpecommunity.cs78.force.com/channel/services/apexrest/einsteinconfigurl';
        req.addParameter('siteurl',url);
        req.httpMethod = 'GET';
        RestContext.request = req;
        RestContext.response= res;
        Locale_Region_Mapping_for_LiveAgent__mdt configResp = EinsteinLiveAgentRestService.getLocaleConfigRecord();
        System.debug('========'+configResp);
        return configResp.DeveloperName;
    }
}