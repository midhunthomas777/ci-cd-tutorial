public class Peak_InstagramController {
    @AuraEnabled
    public static String getInstagramPost(String postUrl){
        String url = 'https://api.instagram.com/oembed/?url='+postUrl;
        HttpRequest req = new HttpRequest();
        Http http = new Http();
        req.setMethod('GET');    
        req.setEndpoint(url);
        HttpResponse res = http.send(req);
        return res.getBody();   
    }
    
    @AuraEnabled
    public static String getMetaData(String recordLabel){
        X7Summits_Social_Component_Settings__mdt setting = [SELECT Instagram_Featured_Posts__c FROM X7Summits_Social_Component_Settings__mdt WHERE DeveloperName = :recordLabel];
        return setting.Instagram_Featured_Posts__c;
    }
}