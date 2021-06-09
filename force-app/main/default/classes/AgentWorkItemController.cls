public class AgentWorkItemController{
	@AuraEnabled
	public static void changePhoneCallStatus(String taskPureCloudId, String SFUserID){
		List<Phone_Call__c> toBeUpdated = new List<Phone_Call__c>();
		System.debug('taskPureCloudId****' + taskPureCloudId);
		for (Phone_Call__c phonerec : [SELECT Id, Purecloud_Conversation_ID__c
		                               FROM Phone_Call__c
		                               WHERE Purecloud_Conversation_ID__c = :taskPureCloudId AND OwnerID = :SFUserID AND Work_Item_Status__c = 'In Progress']){
			System.debug('phonerec*********8' + phonerec);
			phonerec.Work_Item_Status__c = 'Closed';
			toBeUpdated.add(phonerec);
		}
		if (!toBeUpdated.isEmpty()){
			try{
				update toBeUpdated;
				System.debug('###toBeUpdated###' + toBeUpdated);
			} catch (Exception e){
				System.debug('###Error in updating the Phone Call record###' + e);
			}
		}
	}

	@AuraEnabled
	public static String changePureCloudStatus(String userId, String statusApiName){
		System.debug('##1# In the changePureCloudStatus method###');
		String response = '';
		//callPureCloud
		callPureCloud(userId, statusApiName);
		return response;
	}

	@AuraEnabled
	public static String changePureCloudStatusOnCapacity1(String userId, String parameter){
		System.debug('##1# In the changePureCloudStatusOnCapacity method###');
		System.debug('##1#  userId#' + userId);
		System.debug('##1#  parameter#' + parameter);
		String response = '';
		String statusApiName = '';
		//First find the current users status
		List<User> userAgent = [SELECT Id, PureCloud_User_ID__c
		                        FROM User
		                        WHERE Id = :userId
		                        LIMIT 1];
		System.debug('##1# In the userAgent method###' + userAgent);
		List<UserServicePresence> userAgentStatus = [SELECT Id, AverageCapacity, AtCapacityDuration, ConfiguredCapacity, ServicePresenceStatus.DeveloperName, UserId
		                                             FROM UserServicePresence
		                                             WHERE UserId = :userId
		                                             ORDER BY createddate DESC
		                                             LIMIT 1];
		System.debug('##1# In the userAgentStatus method###' + userAgentStatus);
		//if status is avaliable phone/case and the agent purecloud Id is not NULL. then call purecloud
		if (!userAgent.isEmpty() && !userAgentStatus.isEmpty()){
			System.debug('####userAgentStatus[0].ServicePresenceStatus.DeveloperName: ' + userAgentStatus[0].ServicePresenceStatus.DeveloperName);
			if (userAgentStatus[0].ServicePresenceStatus.DeveloperName != ''){
				List<PureCloud_Status_Sync__mdt> purecloudStatuses = [SELECT Id, PureCloud_Agent_Status__c, PureCloud_Status__c, DeveloperName, Enabled_for_Phone__c
				                                                      FROM PureCloud_Status_Sync__mdt
				                                                      WHERE DeveloperName = :userAgentStatus[0].ServicePresenceStatus.DeveloperName and Enabled_for_Phone__c = TRUE];
				System.debug('##1#  purecloudStatuses#' + purecloudStatuses);
				if (!purecloudStatuses.isEmpty() && parameter == 'FULL'){
					System.debug('##IN FULL CAPACITY##Status: ' + statusApiName + '###USer:' + userId);
					statusApiName = 'Available_Case';
					callPureCloud(userId, statusApiName);
					return response;
				} else if (!purecloudStatuses.isEmpty() && parameter == 'NOT FULL'){
					System.debug('##NOT in FULL CAPACITY##Status: ' + statusApiName + '###USer:' + userId);
					statusApiName = userAgentStatus[0].ServicePresenceStatus.DeveloperName;
					callPureCloud(userId, statusApiName);
					return response;
				}

			}
		}
		//else do nothing
		//callPureCloud
		System.debug('##END OF changePureCloudStatusOnCapacity method ##');
		//callPureCloud(userId, statusApiName);
		return response;
	}

	public static HTTPAPIResponse callPureCloud(String userId, String statusApiName){
		System.debug('##2# In the cal PureCloud method###');
		HttpRequest req = new HttpRequest();
		Http http = new Http();
		HTTPAPIResponse serResponse = new HTTPAPIResponse();
		String namedCredentialName = 'PureCloud_Omni_Sync';
		System.debug('###statusApiName##' + statusApiName);
		List<User> userAgent = [SELECT Id, PureCloud_User_ID__c
		                        FROM User
		                        WHERE Id = :userId
		                        LIMIT 1];
		List<PureCloud_Status_Sync__mdt> purecloudStatuses = [SELECT Id, PureCloud_Agent_Status__c, PureCloud_Status__c, DeveloperName
		                                                      FROM PureCloud_Status_Sync__mdt
		                                                      WHERE DeveloperName = :statusApiName];

		if (!userAgent.isEmpty() && !purecloudStatuses.isEmpty() && String.isNotBlank(userAgent[0].PureCloud_User_ID__c)){
			PureCloud_Status_Sync__mdt purecloudStatus = purecloudStatuses.get(0);
			req.setEndpoint('callout:PureCloud_Omni_Sync/users/' + userAgent[0].PureCloud_User_ID__c + '/presences/purecloud');
			req.setMethod('PATCH');
			req.setHeader('Content-Type', 'application/json; charset=utf-8');
			req.setbody('{ "name": "","source": "","primary": "true","presenceDefinition": {"id":"' + purecloudStatuses.get(0).PureCloud_Agent_Status__c + '","systemPresence": ""},"message": "", "modifiedDate": ""}');
		}

		HTTPResponse res = http.send(req);
		System.debug('##req####' + req);
		System.debug('##res###' + res);
		serResponse.response = res;
		serResponse.responseStatus = res.getStatusCode();
		serResponse.errorMsg = '';
		System.debug('#####serResponse######## => ' + serResponse);
		return serResponse;
	}
}