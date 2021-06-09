/**
 * @author		Krzysztof Pintscher
 * @created		2020-10-13
 * @updated		2020-12-09
 * @description	Provide methods for custom List View component
 */

public class DTSFPART_CustomListViewCompController {

    @AuraEnabled(cacheable=true)
    public static List<ListView> getListViews(String objectType, String[] listViews){
        return [SELECT Name, DeveloperName, SobjectType FROM ListView WHERE SobjectType =: objectType AND DeveloperName IN :listViews ORDER BY Name];
    }

    @AuraEnabled(cacheable=true)
    public static String getListViewMetadata(String objectType, String listView){
        String instance = URL.getOrgDomainUrl().toExternalForm();
        String restApi = instance + '/services/data/v50.0/ui-api/list-info/' + objectType + '/' + listView;
        String sessionID = DTSFPART_Utils.fetchUserSessionId();
        HttpRequest req = new HttpRequest();
        req.setEndpoint(restApi);
        req.setMethod('GET');
        req.setHeader('Authorization', 'Bearer ' + sessionID);
    
        String body = '';
        try {
            Http h = new Http();
            HttpResponse res = h.send(req);
            body = res.getBody();
            if (res.getStatusCode() == 200) {
                return body;
            } else {
                System.debug(res.getStatusCode());
                System.debug('Error body ' + body);
            }
        } catch (System.CalloutException ex){
            throw new AuraHandledException(ex.getMessage());
        }
        return body;
    }

    @AuraEnabled(cacheable=true)
    public static List<Custom_ListView__mdt> getCustomListViews(String[] listViews){
        return [SELECT MasterLabel, DeveloperName, Columns__c, Payload__c FROM Custom_ListView__mdt WHERE DeveloperName IN :listViews];
    }    

}