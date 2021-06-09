@RestResource(urlMapping='/account/ldapsync/*')
global class DTSFPART_AccountLdapSyncAPI {
 
    @HttpGet
    global static List<Account> getAccountLdapSync() {

        try {
            String accountId = RestContext.request.params.get('accountId'); //variable bind in query
            String requestQuery = DTSFPART_ApexRestService.getApexRestMetadataQueryByDeveloperName('UserSyncAccount');
            
            DTSFPART_ApexRestService.validateRequestAndThrowErrorIfNotValid(accountId, requestQuery);

            return Database.query(requestQuery);

        } catch (Exception error) {
            LogError.saveError('DTSFPART_AccountLdapSyncAPI.getAccountLdapSync', '', error.getMessage());
            RestContext.response.statusCode = 500; 
        }

        return new List<Account>();
    }
}