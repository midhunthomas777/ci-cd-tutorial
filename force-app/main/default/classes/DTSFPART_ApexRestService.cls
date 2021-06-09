public class DTSFPART_ApexRestService {
   
    public static String getApexRestMetadataQueryByDeveloperName(String developerName) {

        List<ApexRest__mdt> apexRests = [ SELECT EndpointQuery__c, DeveloperName
                                          FROM ApexRest__mdt 
                                          WHERE DeveloperName = :developerName ];
                                         
        if (!apexRests.isEmpty()) {
            return apexRests[0].EndpointQuery__c;
        }   
        
        return null;
    }

    public static void validateRequestAndThrowErrorIfNotValid(String requestParam, String requestQuery) {
        CalloutException calloutException = new CalloutException();

        if (String.isBlank(requestParam) || !(requestParam instanceOf Id)) {
            calloutException.setMessage('Invalid request parameter.');
            throw calloutException;
        }
            
        if (String.isBlank(requestQuery)) {
            calloutException.setMessage('ApexRest__mdt query not found.');
            throw calloutException;
        } 
    }
}