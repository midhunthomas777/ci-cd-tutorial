@RestResource(urlMapping='/contact/c360sync/*')
global class DTSFPART_ContactC360SyncAPI {

    @HttpGet
    global static List<Contact> getContactC360Sync() {

        try {
            String contactId = RestContext.request.params.get('contactId'); //variable bind in query
            String requestQuery = DTSFPART_ApexRestService.getApexRestMetadataQueryByDeveloperName('UserSyncContact');
            
            DTSFPART_ApexRestService.validateRequestAndThrowErrorIfNotValid(contactId, requestQuery);

            return Database.query(requestQuery);

        } catch (Exception error) {
            LogError.saveError('DTSFPART_ContactC360SyncAPI.getContactC360Sync', '', error.getMessage());
            RestContext.response.statusCode = 500; 
        }

        return new List<Contact>();
    }
}