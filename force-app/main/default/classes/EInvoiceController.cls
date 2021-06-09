public class EInvoiceController{
    
    @AuraEnabled
    public static String handleCustomerPref(String customerNum, String siteNum, String metaName) {
        String result = '';
        system.debug('######UserInfo.getUserType()##### => ' + UserInfo.getUserType());
        if(isLoggedinPartnerUser()){
            List<Account> accountsList = [SELECT Id, Assigned_MR__c, Name, Motorola_Customer_Number__c FROM Account WHERE Motorola_Customer_Number__c = : customerNum AND Assigned_MR__c != NULL];
            if(!accountsList.isEmpty()){
                result = fetchCustomerInfo(customerNum, siteNum, metaName);
            } else {
                result = 'NOACCESS';
            }
        } else {
            result = fetchCustomerInfo(customerNum, siteNum, metaName);
        }
        system.debug('result => ' + result);
        return result;
    }
    
    @AuraEnabled
    public static Boolean isLoggedinPartnerUser() {
        return GlobalUtility.isLoggedinPartnerUser();
    }
    
    @AuraEnabled
    public static Boolean isLoggedinInvoiceUser() {
        if(UserInfo.getUserId() == System.Label.EInvoice_UserID) {
            return TRUE;
        }
        return FALSE;
    }
    
    @AuraEnabled
    public static String fetchLoggedinUserDetails() { 
        String result = '';
    	try{
            if(isLoggedinInvoiceUser()){
                result = 'InvoiceUser';
            } else {
                List<User> currentUser = [SELECT Email,FederationIdentifier FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
                result = JSON.serialize(currentUser[0]);                
            }
        } catch(Exception ex){
            result = ex.getMessage();
        }
        return result;
    }
    
    @AuraEnabled
    public static String fetchCustomerInfo(String customerNum, String siteNum, String metaName) {
        //siteNum = String.isBlank(siteNum) ? NULL : '';
        String payload = '{"P_ACCT_NUM":"'+customerNum+'","P_PARTY_SITE_NUM":"'+siteNum+'"}';
        HTTPAPIResponse res = MulesoftHelper.callMuleByMetadata(null, payload, metaName, 'Mulesoft');
        if(res.responseStatus == 200 || res.responseStatus == 201) {
            return res.response.getBody();
        } else {
            return 'APIError';
        }
    }
    
    @AuraEnabled
    public static String handleInvoiceRecords(String customerNum, String requesterEmail,String requestType,String coreId) { 
        String result = '';
        String reqEmail = requesterEmail;
        try{
            /*if(isLoggedinPartnerUser()){
                List<User> currentUser = [SELECT Id,Name,Email,FederationIdentifier FROM User 
                                          WHERE Id = :UserInfo.getUserId() LIMIT 1];
                reqEmail = currentUser[0].Email;
                System.debug('reqEmail in partner if === '+reqEmail);
            }*/
            System.debug('reqEmail === '+reqEmail+' and customerNum == '+customerNum);
            if(String.isNotBlank(customerNum) && String.isNotBlank(reqEmail)){
                E_Invoice_Tracking__c eit = new E_Invoice_Tracking__c();
                eit.Customer_Number__c = customerNum;
                eit.Requester_Email__c = reqEmail;
                eit.Type_of_Request__c = requestType;
                eit.Core_ID__c 		   = coreId;
                insert eit;
                result = 'INVOICECREATED';
            }else {
                result = 'ERROR';
                System.debug('check Customer Number or Requester Email.');
            }
        }catch(Exception ex){
            result = ex.getMessage();
        }
        return result;
    }

	@AuraEnabled
    public static String serverRequest(String contactsForDelete,String newContacts,String retainedContacts,String genericAPData,String customerData) { 
        Object blankJSON = '[]';
        List<EInvoiceWrapper.CONTACT_ROLE_DATA> allContacts = new List<EInvoiceWrapper.CONTACT_ROLE_DATA>();
        List<EInvoiceWrapper.CUSTOMER_DATA> customerInformation = new List<EInvoiceWrapper.CUSTOMER_DATA>();
        
        if(!customerData.equals(blankJSON)){
        	customerInformation.addAll((List<EInvoiceWrapper.CUSTOMER_DATA>) System.JSON.deserialize(customerData, List<EInvoiceWrapper.CUSTOMER_DATA>.class));
        }
        if(!contactsForDelete.equals(blankJSON)){
            allContacts.addAll((List<EInvoiceWrapper.CONTACT_ROLE_DATA>) System.JSON.deserialize(contactsForDelete, List<EInvoiceWrapper.CONTACT_ROLE_DATA>.class));
        }
        if(!newContacts.equals(blankJSON)){
            allContacts.addAll((List<EInvoiceWrapper.CONTACT_ROLE_DATA>) System.JSON.deserialize(newContacts, List<EInvoiceWrapper.CONTACT_ROLE_DATA>.class));
        }
        if(!retainedContacts.equals(blankJSON)){
            allContacts.addAll((List<EInvoiceWrapper.CONTACT_ROLE_DATA>) System.JSON.deserialize(retainedContacts, List<EInvoiceWrapper.CONTACT_ROLE_DATA>.class));
        }
        if(!genericAPData.equals(blankJSON)){
            allContacts.addAll((List<EInvoiceWrapper.CONTACT_ROLE_DATA>) System.JSON.deserialize(genericAPData, List<EInvoiceWrapper.CONTACT_ROLE_DATA>.class));
        }
        
        EInvoiceWrapper wrapper = new EInvoiceWrapper(customerInformation[0],allContacts);
        
        System.debug('##############################');
        system.debug(JSON.serializePretty(wrapper));
        
        String Payload = JSON.serializePretty(wrapper);
        HTTPAPIResponse res = MulesoftHelper.callMuleByMetadata(null, Payload, 'EInvoice_AddDelete', 'Mulesoft');
        if(res.responseStatus == 200 || res.responseStatus == 201) {
            return res.response.getBody();
        } else {
            return 'APIError';
        }
    }
    
    @AuraEnabled
    public static String callMuleAPI(String payload, String metaName) { 
        HTTPAPIResponse res = MulesoftHelper.callMuleByMetadata(null, payload, metaName, 'Mulesoft');
        if(res.responseStatus == 200 || res.responseStatus == 201) {
            return res.response.getBody();
        } else {
            return 'APIError';
        }
    } 
    
    @AuraEnabled
    public static boolean isCommunity(){
        Id siteId = Site.getSiteId(); 
        if (siteId != null) {
            return true;
        }
        return false;
    }
}