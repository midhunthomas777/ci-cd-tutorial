public class DnBHelper {
    public static String reqEndpoint (Map<String, String> headers, String extension){
        String url = '';
        String removeSpace;
        Integer i = 0;
        System.debug('headers==='+headers);
        System.debug('headers==='+headers.size());
        for(String key: headers.keySet()){
            i++;
            if (headers.get(key) != null){
                removeSpace = EncodingUtil.urlEncode(headers.get(key), 'UTF-8').replace('+', '%20');
                url += key + '=' + removeSpace;
                System.debug('url=='+url);
                if(i != headers.size()){
                    url +='&'; 
                }
                System.debug('url after appending &====' +url);
            }
            else if (headers.get(key) == null && i == headers.size()){
                //url = url.removeEnd('&');
                url = url.substring(0,url.length()-1);
            }
            
        }
        return extension+url;    
    }
}