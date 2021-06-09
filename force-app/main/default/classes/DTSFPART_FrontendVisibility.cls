/**
 * @author		Paweł Woźniak
 * @author		Krzysztof Pintscher
 * @created		2020-07-28
 * @updated		2020-12-18
 * @description	Used on fronted to display visible Menu and Dashboards items.
 * @JIRA		DTSFPART-279, DTSFPART-295, DTPART-673, DTPART-809
 */

public without sharing class DTSFPART_FrontendVisibility {

	/**
	 * Main function invoked from DTSFPART_CommunityMenu child - permissionHelper component
	 * It provides permissions matrix for whole community and dashboard components
	 * @link https://jira.mot-solutions.com/browse/DTPART-279
	 * @link https://jira.mot-solutions.com/browse/DTPART-809
	 */
	@AuraEnabled(cacheable = true)
	public static PermissionedItemsWrapper getAllPermissionedSettings(String NavigationLinkSetDevName, String communityHub) {
		try {
			List<String> currentMcnPermissions = getAllPermissions();
			Set<String> mcnPermissionsSet = new Set<String>();
			mcnPermissionsSet.addAll(currentMcnPermissions);
	
			User currentUser = getCurrentUser();
			List<String> tags = getCurrentUserTags(currentUser);
			List<String> tagsWithRegion = getCurrentUserTagsWithRegion(currentUser, tags);
					
			List<Component_Permission__mdt> metadataPermissions =
				[
					SELECT Id, Contact_MCN_Permissions__c, Dashboard_Item__c, Menu_Item__c, Always_Visible__c, Salesforce_Object__c, Tag__c
					FROM Component_Permission__mdt
					WHERE (Partner_Region__c =: currentUser.Contact.Partner_Region__c OR Partner_Region__c = '') AND 
					      (Community_Hub__c =: communityHub OR Community_Hub__c = '')				
				];
	
			PermissionedItemsWrapper permissionedItemsWrapper = new PermissionedItemsWrapper();
			permissionedItemsWrapper.permissions = currentMcnPermissions;
			permissionedItemsWrapper.dashboardItems = getDashboardPermissionedItems(metadataPermissions, mcnPermissionsSet, tags);
			permissionedItemsWrapper.menuItems = getPermissionedMenuItems(NavigationLinkSetDevName, metadataPermissions, mcnPermissionsSet, tags);
			permissionedItemsWrapper.tags = tags;
			permissionedItemsWrapper.tagsWithRegion = tagsWithRegion;
			
			return permissionedItemsWrapper;
		} catch (Exception e) {
			throw new AuraHandledException(e.getMessage());
		}
	}

	/**
	 * @link https://jira.mot-solutions.com/browse/DTPART-809
	 */
    private static List<String> getAllPermissions(){
		try {
			User runningUser = [SELECT ContactId, Contact.AccountId FROM User WHERE Id = :UserInfo.getUserId()];
			List<Contact_Permissions__c> contactPermissions = [SELECT Id, Contact_MCN_Permissions__c
																FROM Contact_Permissions__c
																WHERE Contact__c = :runningUser.ContactId
																AND Contact_MCN_Permissions__c != NULL];
			Set<String> allPermissions = new Set<String>();
			for (Contact_Permissions__c contactPermission : contactPermissions) {
				allPermissions.addAll(contactPermission.Contact_MCN_Permissions__c.split('[;]'));
			}
	
			List<String> uniquePermissions = new List<String>();
			uniquePermissions.addAll(allPermissions);
	
			return uniquePermissions;
		} catch (Exception e) {
			throw new AuraHandledException(e.getMessage());
		}
	}

	/**
	 * @link https://jira.mot-solutions.com/browse/DTPART-809
	 */
	private static List<dashboardItemWrapper> getDashboardPermissionedItems(List<Component_Permission__mdt> metadataPermissions, Set<String> mcnPermissionsSet, List<String> userTags) {
		try {
			List<dashboardItemWrapper> dashboardItemWrapper = new List<dashboardItemWrapper>();
	
			for (Component_Permission__mdt metadata : metadataPermissions) {
				if (String.isNotBlank(metadata.Dashboard_Item__c)) {
					dashboardItemWrapper dbIw = new dashboardItemWrapper();
					dbIw.name = metadata.Dashboard_Item__c;			
					if (String.isNotBlank(metadata.Salesforce_Object__c)) {
						SObjectType salesforceObj = Schema.getGlobalDescribe().get(metadata.Salesforce_Object__c);
						dbIw.enabled = salesforceObj.getDescribe().isAccessible();
					}
					else if (
						mcnPermissionsSet.contains(metadata.Contact_MCN_Permissions__c) ||
						userTags.contains(metadata.Tag__c) ||
						metadata.Always_Visible__c
					) {
						dbIw.enabled = true;
					} else {
						dbIw.enabled = false;
					}
					dashboardItemWrapper.add(dbIw);
				}
			}
	
			return dashboardItemWrapper;
		} catch (Exception e) {
			throw new AuraHandledException(e.getMessage());
		}
	}

	/**
	 * @link https://jira.mot-solutions.com/browse/DTPART-279
	 * @link https://jira.mot-solutions.com/browse/DTPART-809
	 */
	private static List<menuItemWrapper> getPermissionedMenuItems(String NavigationLinkSetDevName, List<Component_Permission__mdt> metadataPermissions, Set<String> mcnPermissionsSet, List<String> userTags){
		try {
			List<menuItemWrapper> visibleMenuItems = new List<menuItemWrapper>();
	
			// Find parent menu item by devloper name
			List <String> menuLabels = new List<String>();
	
			List<NavigationMenuItem> menuItems = [SELECT Id, Label, Type, Target, Position, Parentid,  DefaultListViewid, TargetPrefs, Status, DraftRowid
			                                      FROM NavigationMenuItem
			                                      WHERE NavigationLinkSet.DeveloperName = :NavigationLinkSetDevName
			                                                                              AND Status = 'Live'
			];
	
			Map<Id, NavigationMenuItem> menuItemsTranslated = new Map<Id, NavigationMenuItem>();
			menuItemsTranslated.putAll([SELECT Id, toLabel(Label)
			                            FROM NavigationMenuItem
			                            WHERE NavigationLinkSet.DeveloperName = : NavigationLinkSetDevName
			                                                                    AND Status = 'Live'
			                           ]);
	
			Set<String> filteredMenuItems = new Set<String>();
	
			for (Component_Permission__mdt metadata : metadataPermissions) {
				if (String.isNotBlank(metadata.Menu_Item__c)) {
					if (mcnPermissionsSet.contains(metadata.Contact_MCN_Permissions__c) || userTags.contains(metadata.Tag__c) || metadata.Always_Visible__c) {
						filteredMenuItems.add(metadata.Menu_Item__c.toLowercase());					
					}
				}
			}
	
			// Add visible menu items.
			for (NavigationMenuItem oneMenuItem : menuItems) {
				if (filteredMenuItems.contains(oneMenuItem.Label.toLowercase()) || oneMenuItem.Type.equals('SalesforceObject')) {
					menuItemWrapper mwr = new menuItemWrapper();
					mwr.label = oneMenuItem.Label;
					mwr.labelTranslation = menuItemsTranslated.get(oneMenuItem.Id).Label;
					mwr.target = oneMenuItem.Target;
					visibleMenuItems.add(mwr);
				}
			}
	
			return visibleMenuItems;
		} catch (Exception e) {
			throw new AuraHandledException(e.getMessage());
		}
	}	

	/**
	 * @link https://jira.mot-solutions.com/browse/DTPART-279
	 * @link https://jira.mot-solutions.com/browse/DTPART-809
	 */
	@testVisible
	private static List<String> getCurrentUserTags() {
		try {
			Id currentUserId = UserInfo.getUserId();
			List<String> tagLabels = new List<String>(); // PW:Cutom Metadata Label is composed form Region Name and Tag name. Using label as from contact details we can't generate developer name.
	
			User currentUser = [SELECT Id, ContactId, Contact.Partner_Region__c, Contact.Tag__c, Contact.Contact_MCN_Permissions__c, Contact.Contact_level_Internal_permissions__c
								FROM User
								WHERE Id = :currentUserId];
	
			// Validate if we have needed data. In case of missing data return empty permissions. Nothing visible to user.
			if (currentUser.ContactId == null) {
				System.debug ('## Error ## User don\'t have contact linked.');
				return tagLabels;
			}
			if (String.isBlank(currentUser.Contact.Partner_Region__c)) {
				System.debug ('## Error ## No Partner_Region__c set for contact. Nothing to do. Skipping.');
				return tagLabels;
			}
			if (String.isBlank(currentUser.Contact.Tag__c) && String.isBlank(currentUser.Contact.Contact_MCN_Permissions__c) && String.isBlank(currentUser.Contact.Contact_level_Internal_permissions__c)) {
				System.debug ('## Error ## No values in all Tag__c, Contact_MCN_Permissions__c, Contact_level_Internal_permissions__c for contact. Nothing to do. Skipping.');
				return tagLabels;
			}
	
			String regionName = currentUser.Contact.Partner_Region__c;
			List<String> tags = new List<String>();
			if (String.isNotBlank(currentUser.Contact.Tag__c)) {
				tags.addAll(currentUser.Contact.Tag__c.split('[;]'));
			}
			if (String.isNotBlank(currentUser.Contact.Contact_MCN_Permissions__c)) {
				tags.addAll(currentUser.Contact.Contact_MCN_Permissions__c.split('[;]'));
			}
			if (String.isNotBlank(currentUser.Contact.Contact_level_Internal_permissions__c)) {
				tags.addAll(currentUser.Contact.Contact_level_Internal_permissions__c.split('[;]'));
			}
	
			for (String tag : tags) {
				tagLabels.add(regionName + ' ' + tag);
			}
	
			return tagLabels;
		} catch (Exception e) {
			throw new AuraHandledException(e.getMessage());
		}
	}

	/**
	 * @link https://jira.mot-solutions.com/browse/DTPART-279
	 * @link https://jira.mot-solutions.com/browse/DTPART-809
	 */
	@testVisible
	private static List<String> getCurrentUserTags(User currentUser) {
		try {
			List<String> tagLabels = new List<String>(); // PW:Cutom Metadata Label is composed form Region Name and Tag name. Using label as from contact details we can't generate developer name.
	
			// Validate if we have needed data. In case of missing data return empty permissions. Nothing visible to user.
			if (currentUser.ContactId == null) {
				System.debug ('## Error ## User don\'t have contact linked.');
				return tagLabels;
			}
			if (String.isBlank(currentUser.Contact.Partner_Region__c)) {
				System.debug ('## Error ## No Partner_Region__c set for contact. Nothing to do. Skipping.');
				return tagLabels;
			}
			if (String.isBlank(currentUser.Contact.Tag__c) && String.isBlank(currentUser.Contact.Contact_MCN_Permissions__c) && String.isBlank(currentUser.Contact.Contact_level_Internal_permissions__c)) {
				System.debug ('## Error ## No values in all Tag__c, Contact_MCN_Permissions__c, Contact_level_Internal_permissions__c for contact. Nothing to do. Skipping.');
				return tagLabels;
			}
	
			if (String.isNotBlank(currentUser.Contact.Tag__c)) {
				tagLabels.addAll(currentUser.Contact.Tag__c.split('[;]'));
			}
			// if (String.isNotBlank(currentUser.Contact.Contact_MCN_Permissions__c)) {
			// 	tagLabels.addAll(currentUser.Contact.Contact_MCN_Permissions__c.split('[;]'));
			// }
			// if (String.isNotBlank(currentUser.Contact.Contact_level_Internal_permissions__c)) {
			// 	tagLabels.addAll(currentUser.Contact.Contact_level_Internal_permissions__c.split('[;]'));
			// }
	
			return tagLabels;
		} catch (Exception e) {
			throw new AuraHandledException(e.getMessage());
		}
	}	

	private static List<String> getCurrentUserTagsWithRegion(User currentUser, List<String> tags) {
		try {
			List<String> tagLabels = new List<String>();
			String regionName = currentUser.Contact.Partner_Region__c;
			
			for (String tag : tags) {
				tagLabels.add(regionName + ' ' + tag);
			}
	
			return tagLabels;
		} catch (Exception e) {
			throw new AuraHandledException(e.getMessage());
		}
	}	

	private static User getCurrentUser() {
		Id currentUserId = UserInfo.getUserId();
		User currentUser = [SELECT Id, ContactId, Contact.Partner_Region__c, Contact.Tag__c, Contact.Contact_MCN_Permissions__c, Contact.Contact_level_Internal_permissions__c
							FROM User
							WHERE Id = :currentUserId];
		return currentUser;		
	}

	/**
	 * Deprecated
	 * @TODO: Remove with tests
	 */
	// https://jira.mot-solutions.com/browse/DTPART-279
	@AuraEnabled
	public static List<menuItemWrapper> getVisibleMenuItems(String NavigationLinkSetDevName, List<String> visibleItems){

		try {
			List<menuItemWrapper> visibleMenuItems = new List<menuItemWrapper>();
	
			// Find parent menu item by devloper name
			List <String> menuLabels = new List<String>();
	
			List<NavigationMenuItem> menuItems = [SELECT Id, Label, Type, Target, Position, Parentid,  DefaultListViewid, TargetPrefs, Status, DraftRowid
			                                      FROM NavigationMenuItem
			                                      WHERE NavigationLinkSet.DeveloperName = :NavigationLinkSetDevName
			                                                                              AND Status = 'Live'
			];
	
			Map<Id, NavigationMenuItem> menuItemsTranslated = new Map<Id, NavigationMenuItem>();
			menuItemsTranslated.putAll([SELECT Id, toLabel(Label)
			                            FROM NavigationMenuItem
			                            WHERE NavigationLinkSet.DeveloperName = : NavigationLinkSetDevName
			                                                                    AND Status = 'Live'
			                           ]);
	
			// Get Current User details and visible items for him based on Custom Metadata "Tags with Permission Set"
			Id currentUserId = UserInfo.getUserId();
			itemsVisibilityWrapper itemsVisibility = getVisibleItems(currentUserId);
	
			// Add visible menu items.
			for (NavigationMenuItem oneMenuItem : menuItems) {
				if (itemsVisibility.menuItems.contains(oneMenuItem.Label) || oneMenuItem.Type.equals('SalesforceObject') || visibleItems.contains(oneMenuItem.Label)) {
					menuItemWrapper mwr = new menuItemWrapper();
					mwr.label = oneMenuItem.Label;
					mwr.labelTranslation = menuItemsTranslated.get(oneMenuItem.Id).Label;
					mwr.target = oneMenuItem.Target;
					visibleMenuItems.add(mwr);
				}
			}
	
			return visibleMenuItems;
		} catch (Exception e) {
			throw new AuraHandledException(e.getMessage());
		}
	}

	/**
	 * Deprecated
	 * @TODO: Remove with tests
	 */
	// https://jira.mot-solutions.com/browse/DTPART-295
	@AuraEnabled
	public static List<dashboardItemWrapper> getVisibleDashboardsComponents(){
		try {
			List<dashboardItemWrapper> dashboardItemWrapper = new List<dashboardItemWrapper>();
	
			// Get Current User details
			Id currentUserId = UserInfo.getUserId();
			itemsVisibilityWrapper itemsVisibility = getVisibleItems(currentUserId);
	
			// Add visible dashboards items.
			for (String oneDbItem : itemsVisibility.dashboardsItems) {
				dashboardItemWrapper dbIv = new dashboardItemWrapper();
				dbIv.name = oneDbItem;
				dbIv.enabled = true;
				dashboardItemWrapper.add(dbIv);
			}
	
			return dashboardItemWrapper;
		} catch (Exception e) {
			throw new AuraHandledException(e.getMessage());
		}
	}

	/**
	*  Check if user can see card.
	*  One card can have multiple Group Names. If user is a member of at least one group he can see the card.;
	*  @link https://jira.mot-solutions.com/browse/DTPART-673
	*  @param groupNames list of group names read from card. 
	*  @return Boolean true when user is a memember of at least 1 group.
	*/
	@AuraEnabled(cacheable=true)
	public static Boolean isEmpowerToolsCardVisible(String groupNames){
		Set<String> groupsFromCard = new Set<String>();
		Set<String> groupsForAccount = new Set<String>();
		User currentUser;

		try {
			// No groups assigned can be visible to all
			if (String.isBlank(groupNames)) {
				return true;
			}

			groupsFromCard = new Set<String>(groupNames.toLowerCase().split(';'));
			
			currentUser = [SELECT Id, ContactId, Contact.AccountId
							FROM User
							WHERE Id = :UserInfo.getUserId()];

			if (!String.isBlank(currentUser?.Contact?.AccountId)) {
				List<Account_to_Group_Mapping__c> accToGroup = [SELECT Account_Id__c, Groups__c FROM Account_to_Group_Mapping__c 
																WHERE Account_Id__c = :currentUser.Contact.AccountId];

				if(accToGroup.size() > 0) {
					groupsForAccount = new Set<String>(accToGroup[0].Groups__c?.toLowerCase().split(';'));
				}
			}

			groupsFromCard.retainAll(groupsForAccount);

			//If there are any common groups size of set will be bigger than 1. 
			// We don't care exaclty which groups left as if user have access to any of listed groups then card can be show.
			if (groupsFromCard.size() > 0) {
				return true;
			}
			return false;
		} catch (Exception e) {
			LogError.saveExceptionPEvent('DTSFPART_FrontendVisibility.isEmpowerToolsCardVisible()', 'Exception catched', 'User: ' + JSON.serializePretty(currentUser), e);
			throw new AuraHandledException(e.getMessage());
		}
	}

	// Helpers

	/**
	 * Deprecated
	 * @TODO: Remove with tests
	 */	
	// Get visible items for user based on Custom Metadata "Tags with Permission Set"
	public static itemsVisibilityWrapper getVisibleItems(Id userId) {

		try {
			itemsVisibilityWrapper ivWrap = new itemsVisibilityWrapper();
	
			User currentUser = [SELECT Id, ContactId, Contact.Partner_Region__c, Contact.Tag__c, Contact.Contact_MCN_Permissions__c, Contact.Contact_level_Internal_permissions__c
			                    FROM User
			                    WHERE Id = :userId];
	
			// Validate if we have needed data. In case of missing data return empty permissions. Nothing visible to user.
			if (currentUser.ContactId == null) {
				System.debug ('## Error ## User don\'t have contact linked.');
				return ivWrap;
			}
			if (String.isBlank(currentUser.Contact.Partner_Region__c)) {
				System.debug ('## Error ## No Partner_Region__c set for contact. Nothing to do. Skipping.');
				return ivWrap;
			}
			if (String.isBlank(currentUser.Contact.Tag__c) && String.isBlank(currentUser.Contact.Contact_MCN_Permissions__c) && String.isBlank(currentUser.Contact.Contact_level_Internal_permissions__c)) {
				System.debug ('## Error ## No values in all Tag__c, Contact_MCN_Permissions__c, Contact_level_Internal_permissions__c for contact. Nothing to do. Skipping.');
				return ivWrap;
			}
	
			// Check visibility
			List<Tags_with_Permission_Sets__mdt> tagsWithPermisions = new List<Tags_with_Permission_Sets__mdt>();
	
			String regionName = currentUser.Contact.Partner_Region__c;
			List<String> tags = new List<String>();
			if (String.isNotBlank(currentUser.Contact.Tag__c)) {
				tags.addAll(currentUser.Contact.Tag__c.split('[;]'));
			}
			if (String.isNotBlank(currentUser.Contact.Contact_MCN_Permissions__c)) {
				tags.addAll(currentUser.Contact.Contact_MCN_Permissions__c.split('[;]'));
			}
			if (String.isNotBlank(currentUser.Contact.Contact_level_Internal_permissions__c)) {
				tags.addAll(currentUser.Contact.Contact_level_Internal_permissions__c.split('[;]'));
			}
	
			List<String> tagLabels = new List<String>(); // PW:Cutom Metadata Label is composed form Region Name and Tag name. Using label as from contact details we can't generate developer name.
			for (String tag : tags) {
				tagLabels.add(regionName + ' ' + tag);
			}
	
			tagsWithPermisions = [SELECT Id, Label, Menu_Items__c, Dashboard_Items__c
			                      FROM Tags_with_Permission_Sets__mdt
			                      WHERE Label IN :tagLabels ];
	
			for (Tags_with_Permission_Sets__mdt oneTagWithperm : tagsWithPermisions) {
				if (String.isNotBlank(oneTagWithperm.Menu_Items__c)) {
					ivWrap.menuItems.addAll(oneTagWithperm.Menu_Items__c.split('[;,]'));
				}
				if (String.isNotBlank(oneTagWithperm.Dashboard_Items__c)) {
					ivWrap.dashboardsItems.addAll(oneTagWithperm.Dashboard_Items__c.split('[;,]'));
				}
			}
	
			return ivWrap;
		} catch (Exception e) {
			throw new AuraHandledException(e.getMessage());
		}
	}

	// Data wrappers
	public class menuItemWrapper {
		@AuraEnabled
		public String label { get; set; }
		@AuraEnabled
		public String labelTranslation { get; set; }
		@AuraEnabled
		public String target { get; set; }
	}

	public class dashboardItemWrapper {
		@AuraEnabled
		public String name {get; set;}
		@AuraEnabled
		public Boolean enabled {get; set;}

	}

	public class PermissionedItemsWrapper {
		@AuraEnabled
		public List<String> permissions { get; set; }
		@AuraEnabled
		public List<menuItemWrapper> menuItems { get; set; }
		@AuraEnabled
		public List<dashboardItemWrapper> dashboardItems { get; set; }
		@AuraEnabled
		public List<String> tags { get; set; }
		@AuraEnabled
		public List<String> tagsWithRegion { get; set; }
	}

	/**
	 * Deprecated
	 * @TODO: Remove with tests
	 */
	public class itemsVisibilityWrapper {
		public Set<String> menuItems {get; set;}
		public Set<String> dashboardsItems {get; set;}

		itemsVisibilityWrapper () {
			menuItems = new Set<String>();
			dashboardsItems = new Set<String>();
		}

	}

}