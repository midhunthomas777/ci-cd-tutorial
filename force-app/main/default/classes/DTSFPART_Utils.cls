/**
 * @author		Paweł Woźniak
 * @created		2020-07-27
 * @updated		2020-08-04
 * @description	Utility classes for DTSFPART project
 * @modified    Jan Sledziewski - added getRecordTypeId method
 */

public without sharing class DTSFPART_Utils {

	private static Boolean isSandbox = null;
	private static User currentUser;

	/*** SF Instance information ***/
	// Check if current org is Sandbox
	public static Boolean isSandbox() {
		if (isSandbox == null) {
			isSandbox = [SELECT Id, IsSandbox FROM Organization LIMIT 1].IsSandbox;
		}
		return isSandbox;
	}

	public static Boolean isAsynchronous(){
		return System.isScheduled() || System.isQueueable() || System.isBatch() || System.isFuture();
	}

	/* Get set of values from list of records. Example usage:
	   List<Opportunity> opps = [SELECT Id, Name, AccountId FROM Opportunity];
	   Set<Id> setOfAccountIds = DTSFPART_Utils.getSetOfIds(opps, 'AccountId');
	   List<Account> accs = [SELECT Id, Name FROM Account WHERE Id IN :setOfAccountIds];
	 */

	/**
	 * @param objectName Api name of source object
	 * @param recordTypeDeveloperName Developer name of object record name
	 *
	 * @return recordType Id
	 */
	public static Id getRecordTypeId(String objectName, String recordTypeDeveloperName){
		return Schema.getGlobalDescribe().get(objectName).getDescribe().getRecordTypeInfosByDeveloperName()
				.get(recordTypeDeveloperName).getRecordTypeId();
	}

	public static Boolean isPartnerRecordType(Id recordTypeId){
		return recordTypeId.equals(DTSFPART_Utils.getRecordTypeId('Account', 'Partner'));
	}
	
	/*** Operations on Lists ***/
	public static Set<Id> getSetOfIds(List<SObject> sfObject, String fieldName) {
		Set<Id> setOfValues = new Set<Id> ();
		for (SObject oneRecord : sfObject) {
			Id idFieldValue = (Id) oneRecord.get(fieldName);
			if (idFieldValue != null) {
				setOfValues.add(idFieldValue);
			}
		}
		return setOfValues;
	}

	public static Set<String> getSetOfStrings(List<SObject> sfObject, String fieldName) {
		Set<String> setOfValues = new Set<String> ();
		for (SObject oneRecord : sfObject) {
			String stringFieldValue = (String) oneRecord.get(fieldName);
			if (String.isNotEmpty(stringFieldValue)) {
				setOfValues.add(stringFieldValue);
			}
		}
		return setOfValues;
	}

	/*** Operations on Fields ***/
	public static Set<String> getPicklistActiveValuesByAPiName(String objectName, String fieldName) {
		return getPicklistActiveValues(objectName, fieldName, true);
	}

	public static Set<String> getPicklistActiveValuesByLabel(String objectName, String fieldName) {
		return getPicklistActiveValues(objectName, fieldName, false);
	}

	/*** Error handling ***/
	// Use this method to be able check message by e.getMessage() in tests.
	public static void throwAuraHandledException(String userVisibleMessage) {
		AuraHandledException ahe = new AuraHandledException(userVisibleMessage);
		ahe.setMessage(userVisibleMessage);
		throw ahe;
	}

	public static void throwExceptionAsAuraHandled(Exception ex) {
		AuraHandledException ahe = new AuraHandledException(ex.getMessage());
		ahe.setMessage(ex.getMessage());
		if (ex.getCause() != null) {
			ahe.initCause(ex.getCause());
		}
		throw ahe;
	}

	/**** Private class helpers *****/
	private static Set<String> getPicklistActiveValues(String objectName, String fieldName, Boolean byAPIName) {
		Set<String> picklistValues = new Set<String> ();

		Schema.DescribeFieldResult fieldDecribe = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap().get(fieldName).getDescribe();
		Schema.DisplayType fieldType = fieldDecribe.getType();
		if (fieldType == Schema.DisplayType.PICKLIST || fieldType == Schema.DisplayType.MULTIPICKLIST) {
			List<Schema.PicklistEntry> pickVals = fieldDecribe.getPicklistValues();
			for (Schema.PicklistEntry pv : pickVals) {
				if (pv.isActive()) {
					if (byAPIName) {
						picklistValues.add(pv.getValue());
					} else {
						picklistValues.add(pv.getLabel());
					}
				}
			}
		}
		return picklistValues;
	}

	public static Map<Id, List<SObject>> groupObjectsByIdField(List<SObject> objects, String fieldName) {
		Map<Id, List<SObject>> groupedObjects = new Map<Id, List<SObject>>();
		if(objects != null) {
			for (SObject obj : objects) {
				Id objId = (Id) obj.get(fieldName);
				if (!groupedObjects.containsKey(objId)) {
					groupedObjects.put(objId, new List<SObject>());
				}
				groupedObjects.get(objId).add(obj);
			}
		}
		return groupedObjects;
	}

	public static Mulesoft__mdt getMulesoftMetadata(String metaApiName){
		return [SELECT Id, Content_Type__c, Endpoint__c, Method_Type__c, UseFederationId__c FROM Mulesoft__mdt WHERE DeveloperName =: metaApiName LIMIT 1];
	}

	public static String getUserOAMSessionParam(String user, Boolean useFederationId){
		String oamSessionParam = 'oam_session=';
		return oamSessionParam + getCurrentUserFederationId(user, useFederationId);
	}

	public static String getCurrentUserFederationId(String user, Boolean useFederationId) {
		if (GlobalUtility.isLoggedinCustomerCommunityUser() || useFederationId) {
			if(currentUser == null){
				currentUser = [SELECT FederationIdentifier FROM User WHERE Id = : UserInfo.getUserId()];
			}
			
			return currentUser.FederationIdentifier;
		} else {
			return user;
		}		
	}

	public static String fetchUserSessionId(){
        PageReference sessionPage = Page.DTSFPART_UserSession;
        String vfContent = !Test.isRunningTest() ? sessionPage.getContent().toString() : '{ "sessionId": "Test" }';
        Map<String, Object> response = (Map<String, Object>) JSON.deserializeUntyped(vfContent);
        return response.get('sessionId').toString();
    }
	
	public static Map<Id,Account> getCustomerHubAccounts(List<User> users){
		Set<Id> accountsId = DTSFPART_Utils.getSetOfIds(users, 'Account_Id__c');
		Id customerRecordTypeId = DTSFPART_Utils.getRecordTypeId('Account', 'SoldToAccount');
		return new Map<Id,Account> ([SELECT ID, Partner_Hub_Enabled__c FROM Account WHERE ID IN : accountsId AND RecordTypeId = :customerRecordTypeId AND Partner_Hub_Enabled__c = true]);
	}

	public static boolean hasReceivedErrorFromC360(String newC360Response, String oldC360Response, String newPermissionStatus) {
		Boolean isNotSuccessResponse = newC360Response != oldC360Response && String.isNotBlank(newC360Response) && newC360Response != DTSFPART_CommonStrings.SUCCESS;
		Boolean isNotCompleted = newPermissionStatus != DTSFPART_CommonStrings.COMPLETED;

		return isNotCompleted && isNotSuccessResponse;
	}

}