@RestResource(urlMapping='/account/c360sync/*')
global class DTSFPART_AccountC360SyncAPI {
    
    @HttpGet
    global static List<Account> getAccountC360Sync() {

        try {
            String accountId = RestContext.request.params.get('accountId'); //variable bind in query
            String requestQuery = DTSFPART_ApexRestService.getApexRestMetadataQueryByDeveloperName('EnterpriseSyncAccount');
            
            DTSFPART_ApexRestService.validateRequestAndThrowErrorIfNotValid(accountId, requestQuery);
			System.debug('#######Database.query(requestQuery)###### => ' + Database.query(requestQuery));
            return Database.query(requestQuery);

        } catch (Exception error) {
            LogError.saveError('DTSFPART_AccountC360SyncAPI.getAccountC360Sync', '', error.getMessage());
            RestContext.response.statusCode = 500; 
        }

        return new List<Account>();
    }

}