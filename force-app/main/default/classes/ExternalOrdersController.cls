/**
* @author Gurditta Garg
* @date March 2020
*
* @group Orders
* @group-content ../../Orders/orders.htm
*
* @description Controller for getting the orders related data from external system using Mulesoft as Middleware
*/
public without sharing class ExternalOrdersController {
    
    /*******************************************************************************************************
* @description Returns Orders List from MOL
* @param orderWrapper payload param which contains all the configs for orders list to be returned
* @return JSON of Orders
*/
    @AuraEnabled
    public static String ordersList(String orderWrapper) {
        try {
            system.debug('######ordersList######## => ');
            String params = '?oam_session=b2b_sit@mailinator.com';
            if(GlobalUtility.isLoggedinCustomerCommunityUser()) {
                User currentUser = [SELECT FederationIdentifier FROM User WHERE Id = : UserInfo.getUserId()];
                params = '?oam_session=' + currentUser.FederationIdentifier;
            }
    		system.debug('######orderWrapper######## => ' + orderWrapper);
            HTTPAPIResponse res = MulesoftHelper.callMuleByMetadata(params, orderWrapper, 'MOL_Orders', 'Mulesoft_OAuth');
            if(res.responseStatus == 200 || res.responseStatus == 201) {
                System.debug('response body: ' + res.response.getBody());
                return res.response.getBody();
                
            } else {
                return 'APIError';
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    /*******************************************************************************************************
* @description GET request to get order detail by order number
* @param orderNumber Order number of the order
* @return JSON of Order detail
*/
    @AuraEnabled
    public static String orderDetail(String confirmationNumber) {
        
        try {
            String oamSession = EncodingUtil.urlEncode('b2b_sit@mailinator.com', 'UTF-8');
            String encConfirmationNumber = EncodingUtil.urlEncode(confirmationNumber, 'UTF-8');
            if(GlobalUtility.isLoggedinCustomerCommunityUser()) {
                User currentUser = [SELECT FederationIdentifier FROM User WHERE Id = : UserInfo.getUserId()];
                oamSession = EncodingUtil.urlEncode(currentUser.FederationIdentifier, 'UTF-8');
            }
            String params = '?order_conf_num='+confirmationNumber+'&oam_session='+oamSession;
            HTTPAPIResponse res = MulesoftHelper.callMuleByMetadata(params, NULL, 'MOL_Order_Details', 'Mulesoft_OAuth');
            system.debug('#####res##### => ' + res);
            if(res.responseStatus == 200 || res.responseStatus == 201) {
                return res.response.getBody();
            } else {
                return 'APIError';
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    /*******************************************************************************************************
* @description GET request to get order tracking details by order number
* @param orderNumber Order number of the order
* @return JSON of Tracking detail
*/
    @AuraEnabled
    public static String orderTracking(String confirmationNumber) {
        String apiErrorMessage = 'APIError';
        
        try {
            String oamSession = EncodingUtil.urlEncode('b2b_sit@mailinator.com', 'UTF-8');
            String encConfirmationNumber = EncodingUtil.urlEncode(confirmationNumber, 'UTF-8');
            if(GlobalUtility.isLoggedinCustomerCommunityUser()) {
                User currentUser = [SELECT FederationIdentifier FROM User WHERE Id = : UserInfo.getUserId()];
                oamSession = EncodingUtil.urlEncode(currentUser.FederationIdentifier, 'UTF-8');
            }
            String params = '?order_conf_num='+encConfirmationNumber+'&oam_session='+oamSession;
            HTTPAPIResponse res = MulesoftHelper.callMuleByMetadata(params, NULL, 'MOL_Order_Tracking', 'Mulesoft_OAuth');
            if(res.responseStatus == 200 || res.responseStatus == 201) {
                return res.response.getBody();
            } else {
                return apiErrorMessage;
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    /*******************************************************************************************************
* @description Method to retrieve Order Line Status mapping from custom metadata 
* @param NA
* @return Map<String, String>
*/
    @AuraEnabled 
    public static Map<String,String> getOrderLineStatusMapping()
    {
        try {
            Map<String,String> codeToStatus = new Map<String,String>();
            List<MR_Digitization_Settings__mdt> odrderLineStatus = [Select Label, Values__c from MR_Digitization_Settings__mdt where Category__c = 'Order Line Status Map'];
            for(MR_Digitization_Settings__mdt mdt :odrderLineStatus)
            {
                codeToStatus.put(mdt.Label,mdt.Values__c);
            }
            return codeToStatus;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }        
    }
    
    /*******************************************************************************************************
* @description Method to retrieve Order Status mapping from custom metadata 
* @param NA
* @return Map<String, String>
*/
    @AuraEnabled
    public static Map<String,String> getOrderStatusMapping()
    {
        try {
            Map<String,String> codeToStatus = new Map<String,String>();
            List<MR_Digitization_Settings__mdt> orderStatus = [Select Label, Values__c from MR_Digitization_Settings__mdt where Category__c = 'Order Header Status Map'];
            for(MR_Digitization_Settings__mdt mdt :orderStatus)
            {
                codeToStatus.put(mdt.Label,mdt.Values__c);
            }
            return codeToStatus;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        
    }
    
    /*******************************************************************************************************
* @description Method to retrieve all MCNs of the current Account
* @param accountId
* @return String comma separated String of MCNs
*/
    @AuraEnabled
    public static String getAllMCNs(String accountId) {
        try {
            Set<String> MCNs = new Set<String>();
            if(String.isNotBlank(accountId) ) {
                for(Account currentAccount : [Select Motorola_Enterprise_ID__c,(Select Motorola_Customer_Number__c from ChildAccounts) from Account where Id =: accountId]) {
                    for(Account childAccount : currentAccount.ChildAccounts) {
                        MCNs.add(childAccount.Motorola_Customer_Number__c);
                    }
                    MCNs.add(currentAccount.Motorola_Enterprise_ID__c);
                }
            }
            system.debug('#######MCNs###### => ' + MCNs);
            String mcnsToBePassed = String.join(new List<String>(MCNs), ',');
            mcnsToBePassed = mcnsToBePassed.removeEnd(',');
            return mcnsToBePassed;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
     /****
     * @description get last_ship_complete_status list for open orders
     * @return list of String values for Open Orders
    */
    @AuraEnabled
    public static String getOpenOrdersParameters(){
        return [SELECT DeveloperName, Values__c FROM MR_Digitization_Settings__mdt	WHERE DeveloperName = 'Open_Orders_Parameters' LIMIT 1].Values__c;
    }
}