/**
* @author Chad Armstrong
* @date March 2020
*
* @group Community
* @group-content ../../Community/dynbanner.htm
*
* @description Retrieves the statistics used to populate the dynamic banner
*/
public with sharing class MotoCommunityBannerController {

	/*******************************************************************************************************
	* @description retrieves stats related to the current user ( like Tier )
	* @return Map<String,Object> each map entry is a key/value pair related to the current user
	*/
	@AuraEnabled
	public static Map<String, Object> getUserDetails() {

		Map<String, Object> data = new Map<String, Object>{
				'tier' => 'N/A',
				'accountName' => 'N/A'
		};

		if (GlobalUtility.isLoggedinCustomerCommunityUser() || GlobalUtility.isLoggedinPartnerUser()) {
			// current user is a partner user, get their account tier
			User currentUser = [SELECT Contact.Account.Name, Contact.Account.Metal_Level__c, Contact.Account.Motorola_Customer_Number__c FROM User WHERE Id = :UserInfo.getUserId()];
			data.put('tier', currentUser.Contact.Account.Metal_Level__c);
			data.put('accountName', currentUser.Contact.Account.Name);
		}
		system.debug('#####data####### => ' + data);
		return data;
	}

	/*******************************************************************************************************
	* @description retrieves stats related to the current user's orders
	* @param requestParamsStr String a URL query string that is appended to the API request
	* @return Integer count of orders
	*/
	@AuraEnabled
	public static Integer getOrderCount(String requestParamsStr) {
        system.debug('#######getOrderCount####### => ' + requestParamsStr);
		String params = '?oam_session=b2b_sit@mailinator.com';
		if (GlobalUtility.isLoggedinCustomerCommunityUser() || GlobalUtility.isLoggedinPartnerUser()) {
			User currentUser = [SELECT FederationIdentifier FROM User WHERE Id = :UserInfo.getUserId()];
			params = '?oam_session=' + currentUser.FederationIdentifier;
			if (String.isNotEmpty(currentUser.FederationIdentifier)) {
				HTTPAPIResponse jsonString = MulesoftHelper.callMuleByMetadata(params, requestParamsStr, 'MOL_Orders', 'Mulesoft_OAuth');
				if (jsonString.responseStatus == 200 || jsonString.responseStatus == 201) {
					Map<String, Object> res = (Map<String, Object>) JSON.deserializeUntyped(jsonString.response.getBody());
					system.debug('#######res####### => ' + res);
					return res.get('totalrec') == NULL || (res.get('totalrec') != NULL && String.isBlank(String.valueOf(res.get('totalrec'))))
                        ? 0 : Integer.valueOf(res.get('totalrec'));
				} else {
					return -1;
				}
			} else {
				return -1;
			}
		}
		return -1;
	}
	/*******************************************************************************************************
	* @description retrieves stats related to the current user's cases
	* @param requestParams Map<String,String> map of key/value pairs that will be added to the API request payload
	* @return Integer count of cases
	*/
	@AuraEnabled
	public static Integer getCaseCount(Map<String, String> requestParams) {

		if (GlobalUtility.isLoggedinCustomerCommunityUser() || GlobalUtility.isLoggedinPartnerUser()) {
			// current user is a partner user, overwrite whatever is coming from the component with the current user's customer number
			User currentUser = [SELECT Contact.Account.Motorola_Enterprise_ID__c FROM User WHERE Id = :UserInfo.getUserId()];
			requestParams.put('sysparm_query', 'partner.u_motorola_enterprise_id=' + currentUser.Contact.Account.Motorola_Enterprise_ID__c + '^closed_atISEMPTY');
		}

		String params = '?' + GlobalUtility.buildHttpUrl(requestParams);
		HTTPAPIResponse jsonString = MulesoftHelper.callMuleByMetadata(params, null, 'Vesta_Snow_Case_Stats', 'Mulesoft');
		if (jsonString.responseStatus == 200 || jsonString.responseStatus == 201) {
			Map<String, Object> res = (Map<String, Object>) JSON.deserializeUntyped(jsonString.response.getBody());
			Map<String, Object> result = (Map<String, Object>) res.get('result');
			Map<String, Object> stats = (Map<String, Object>) result.get('stats');
			return Integer.valueOf(stats.get('count'));
		} else {
			return -1;
		}
	}

	/*******************************************************************************************************
	* @description Mulesoft is missing Contract count endpoint, for now use existing Contract endpoint (retrieve all)
	* @return  JSON containing list of contracts
	*/
	@AuraEnabled
	public static String getContracts() {
		return ExternalContractsController.contractList('');
	}

}