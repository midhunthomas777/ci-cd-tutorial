/**
 * @author       Sagar Sindhi
 * @created      2020-08-19
 * @updated      2021-27-01
 * @description  Queuable Job for user creation once contact updates to "Registration Completed"
 */

public without sharing class DTSFPART_PortalUserCreation implements Queueable {

	private Set<Id> contactIds;
	private Set<Id> accountIds;

	public DTSFPART_PortalUserCreation(Set<Id> contactIds, Set<Id> accountIds) {
		this.contactIds = contactIds;
		this.accountIds = accountIds;
	}

	public void execute(QueueableContext context) {
		List<User> usersToBeInserted = new List<User>();
		try {
			usersToBeInserted = createUsers();
		} catch(Exception e){
			LogError.saveExceptionPEvent('DTSFPART_PortalUserCreation.execute', '', '', e);
			throw e;
		}
		
		if (!usersToBeInserted.isEmpty()) {
			Set<Id> incomingActiveUsers = new Set<Id>();
			List<String> errorMessages = new List<String>();
			Database.SaveResult[] userResults = Database.insert(usersToBeInserted, false);
			for (Database.SaveResult result : userResults) {
				if (result.isSuccess()) {
					incomingActiveUsers.add(result.getId());
				} else {
					for(Database.Error err : result.getErrors()) {
						errorMessages.add(err.getMessage());
					}
					LogError.saveErrorFuture('DTSFPART_PortalUserCreation.execute',
						'DML Error while creating user', String.join(errorMessages, '')
					);
				}
			}

			if (!incomingActiveUsers.isEmpty()) {
				//calling future method as contact can not be updated after user insertion
				setCustomerHubDefaultPermissionSets(incomingActiveUsers);
				DTSFPART_PartnerAdminController.updateContactStatus(incomingActiveUsers);
			}
		}
	}

	private void setCustomerHubDefaultPermissionSets(Set<Id> newUsersIds){
		Set<Id> customerHubUsersIds = new Set<Id> ();
		List<User> newUsers = [SELECT Id, Account_Id__c, IsActive, ContactId FROM User Where Id IN :newUsersIds];
		Map<Id,Account> contactAccounts = DTSFPART_Utils.getCustomerHubAccounts(newUsers);

		for(User user : newUsers) {
			if( user.ContactId != null &&
				contactAccounts.get(user.Account_Id__c) != null &&
				user.IsActive == true ){
					customerHubUsersIds.add(user.Id);
			}
		}
		DTSFPART_PermissionUtils.assignPermissionSet(customerHubUsersIds, 'Customer_Hub_Access');
	} 

	private static Set<String> getExistingUsernames() {
		Set<String> existingUsernames = new Set<String>();
		String usernamePattern = '%@' + getUserNameSuffix();
		for(User eachUser : [SELECT Id, Username FROM User WHERE Username LIKE: usernamePattern LIMIT 5000]) {
			existingUsernames.add(eachUser.Username);
		}
		return existingUsernames;
	}

	private static String getUserNameSuffix() {
		Portal_User_Creation_Regions__c regSetting = Portal_User_Creation_Regions__c.getInstance('Current Settings');
		return regSetting.Username_Suffix__c;
	}

	private static Map<String, Applications_Access_Meta__mdt> getMetaData() {
		Map<String, Applications_Access_Meta__mdt>metaRecords = new Map<String, Applications_Access_Meta__mdt>();
		for (Applications_Access_Meta__mdt eachMeta: [
				SELECT Id, Profile__c, DeveloperName, License__c, Role__c
				FROM Applications_Access_Meta__mdt
			]) {
			metaRecords.put(eachMeta.DeveloperName, eachMeta);
		}
		return metaRecords;
	}

	private Map<String, Id> getUserRolesForGivenAccounts() {
		Map<String, Id>userRoleMap = new Map<String, Id>();
		for (UserRole eachUserRole: [
				SELECT Id, Name, PortalAccountId
				FROM UserRole
				WHERE PortalAccountId IN: accountIds LIMIT 50000
			]) {
			userRoleMap.put(eachUserRole.Name, eachUserRole.Id);
		}
		return userRoleMap;
	}

	private List<User> createUsers() {
		Set<String> existingUsernames = getExistingUsernames();
		Map<String, Applications_Access_Meta__mdt> metaRecords = getMetaData();
		List<User> usersToBeInserted = new List<User>();
		String usernameSuffix = getUserNameSuffix();
		for (Contact eachContact: [SELECT Id, FirstName, LastName, Email, AccountId, MailingCountry, MailingCity,
				MailingStreet, MailingState, MailingPostalCode, Persona__c, Status__c, Account.Name
				FROM Contact WHERE Id IN: contactIds LIMIT 50000
			]) {
			Applications_Access_Meta__mdt metaRecord = metaRecords.get(eachContact.Persona__c);
			System.debug('createUsers');
			System.debug(eachContact.Persona__c);
			System.debug(metaRecord);
			if (metaRecord != NULL) {
				String communityNickname = removeWhiteSpaces(eachContact.FirstName + eachContact.LastName + '.' + System.now().getTime());
				communityNickname = communityNickname.length() > 40 ? communityNickname.left(40) : communityNickname;

				String aliasVerified = String.isNotBlank(eachContact.FirstName) ? 
									   eachContact.FirstName.Left(1) + eachContact.LastName.Left(4) : 
									   eachContact.LastName.Left(4);

				// reterive unique username
				String userNameVerified  = getUniqueUsername(eachContact.LastName, existingUsernames.size(), existingUsernames, usernameSuffix);
				
				// remove white spaces
				userNameVerified = removeWhiteSpaces(userNameVerified);

				// create user instance
				User userInstance = new User(ContactId = eachContact.Id, ProfileId = metaRecord.Profile__c,
					Alias = aliasVerified, Email = eachContact.Email, IsActive = TRUE,
					FirstName = eachContact.FirstName, LastName = eachContact.LastName,
					CommunityNickname = communityNickname, LocaleSidKey = 'en_US',
					EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US', Username = userNameVerified,
					TimeZoneSidKey = 'America/Los_Angeles', Country = eachContact.MailingCountry,
					City = eachContact.MailingCity, Street = eachContact.MailingStreet,
					State = eachContact.MailingState, PostalCode = eachContact.MailingPostalCode,
					FederationIdentifier = String.isNotBlank(eachContact.Email) ? eachContact.Email.toLowercase() : '');

				List<String> customerLicenses = new List<String>{'Customer Community Plus'};
				List<String> partnerLicenses = new List<String>{'Gold Partner'};
				String roleName;
				if (partnerLicenses.contains(metaRecord.License__c)) {
					roleName = eachContact.Account.Name + ' Partner ' + metaRecord.Role__c;
				} else if (customerLicenses.contains(metaRecord.License__c)) {
					roleName = eachContact.Account.Name + ' Customer ' + metaRecord.Role__c;
				}
				
				if (String.isNotBlank(roleName)) {
					Map<String, Id> userRoleMap = getUserRolesForGivenAccounts();
					userInstance.UserRoleId = userRoleMap.get(roleName);
				}
				usersToBeInserted.add(userInstance);
				existingUsernames.add(userInstance.Username);
			}
		}
		return usersToBeInserted;
	}

	private static String getUniqueUsername(String lastName, Integer count, Set<String> usernames, String usernameSuffix) {
		String counterPart = count == 0? '' : String.valueOf(count);
		String uniqueName = lastName + '.' + getUserNamePrefix() + counterPart + '@' + usernameSuffix;

		if(usernames.contains(uniqueName)) {
			return getUniqueUsername(lastName, count++, usernames, usernameSuffix);
		}
		
		return uniqueName;
	}

	private static String getUserNamePrefix() {
		return UserInfo.getOrganizationId() + System.now().millisecond();
	}

	private static String removeWhiteSpaces(String actualValue) {
		return actualValue.replace(' ', '');
	}
}