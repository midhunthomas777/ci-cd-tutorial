/*
 * Copyright (c) 2019. 7Summits Inc. All rights reserved.
 *
 */

public class Peak_OnboardingController
{
	private static final String ACTIVITY_ACTION_FOLLOW = 'Follow';
	private static final String ACTIVITY_ACTION_UNFOLLOW = 'Unfollow';
	private static final String ACTIVITY_ACTION_JOIN = 'Join';
	private static final String ACTIVITY_ACTION_LEAVE = 'Leave';

	private static final String ACTIVITY_TYPE_GROUP = 'Group';
	private static final String ACTIVITY_TYPE_TOPIC = 'Topic';

	private static final String ACTIVITY_PROCESS_DEFAULT    = 'Default';
	@TestVisible
	private class activityEntry {
		String id, name;

		public activityEntry(String entryId, String entryName) {
			this.id   = entryId;
			this.name = entryName;
		}
	}

	@TestVisible
	private class activityTracking
	{
		public Boolean followTopic, unFollowTopic, joinGroup, leaveGroup;
	}

	@TestVisible
	private static activityTracking TrackActivities
	{
		get
		{
			if (TrackActivities == null)
			{
				String communityQuery = 'SELECT Track_Join_Group__c, Track_Leave_Group__c, Track_Follow_Topic__c, Track_Unfollow_Topic__c FROM X7s_Onboarding_Settings__mdt WHERE Community_ID__c = :Network.getNetworkId() LIMIT 1';

				if (Test.isRunningTest())
				{
					communityQuery = 'SELECT Track_Join_Group__c, Track_Leave_Group__c, Track_Follow_Topic__c, Track_Unfollow_Topic__c FROM X7s_Onboarding_Settings__mdt WHERE DeveloperName = \'Default\' LIMIT 1';
				}

				List<X7s_Onboarding_Settings__mdt> settings = (List<X7s_Onboarding_Settings__mdt>)Database.query(communityQuery);

				if (!settings.isEmpty())
				{
					activityTracking tracking = new activityTracking();

					tracking.joinGroup = settings[0].Track_Join_Group__c;
					tracking.leaveGroup = settings[0].Track_Leave_Group__c;
					tracking.followTopic = settings[0].Track_Follow_Topic__c;
					tracking.unFollowTopic = settings[0].Track_Unfollow_Topic__c;

					TrackActivities = tracking;
				}
			}
			return TrackActivities;
		}

		set
		{
			TrackActivities = value;
		}
	}

	@TestVisible
	private static void DumpTracking()
	{
		System.debug('Tracking:');
		activityTracking myTracking = TrackActivities;

		System.debug('    join      : ' + myTracking.joinGroup);
		System.debug('    leave     : ' + myTracking.leaveGroup);
		System.debug('    follow    : ' + myTracking.followTopic);
		System.debug('    unFollow  : ' + myTracking.unFollowTopic);
	}

	@AuraEnabled
	public static User getUserRecord()
	{
		User currentUser =
		[
			SELECT Completed_Groups_Slide__c,
				Last_Topic_Slide_Completed__c,
				Completed_Notification_Slide__c,
				Completed_Profile_Slide__c,
				Completed_Topics_Slide__c,
				Completed_Additional_User_Data__c,
				Completed_Tours_Slide__c,
				Completed_Welcome_Slide__c,
				FirstName,
				LastName,
				Onboarding_Complete__c,
				Title,
				CompanyName,
				Email,
				MobilePhone,
				AboutMe,
// TODO: Dynamic Query Builder for custom fields
//					Industry__c,
//					Region__c,
				CommunityNickname
			FROM User
			WHERE Id = :UserInfo.getUserId()
			LIMIT 1
		];

		return currentUser;
	}

	@AuraEnabled
	public static Boolean getIsModalViewEnabled()
	{
		List<X7s_Onboarding_Settings__mdt> onboardingSetting =
		[
			SELECT Enable_Onboarding_via_Modal__c
			FROM X7s_Onboarding_Settings__mdt
			WHERE Community_ID__c = :Network.getNetworkId()
			LIMIT 1
		];
		if (!onboardingSetting.isEmpty())
		{
			return onboardingSetting[0].Enable_Onboarding_via_Modal__c;
		}
		return false;
	}

	@AuraEnabled
	public static void updateUserNames(User currentUser)
	{
		//System.debug('currentUser >>>'+currentUser);
		update currentUser;
	}

	@AuraEnabled
	public static List<String> getPicklistFromUser(String ObjectApi_name, String Field_name)
	{
		return Peak_Onboarding_Utils.getPicklistValues(ObjectApi_name, Field_name);
	}

	@AuraEnabled
	public static void updatePreferences(Boolean decision)
	{
		Id networkId1 = [
			SELECT NetworkId
			FROM NetworkMember
			WHERE MemberId = :UserInfo.getUserId()
			LIMIT 1
		].NetworkId;
		NetworkMember member =
		[
			SELECT PreferencesDisableAllFeedsEmail
			FROM NetworkMember
			WHERE MemberId = :UserInfo.getUserId() AND NetworkId = :networkId1
		];
		if (!decision)
		{
			member.PreferencesDisableAllFeedsEmail = true;
		} else if (decision)
		{
			member.PreferencesDisableAllFeedsEmail = false;
		}
		update member;
	}

	@AuraEnabled
	public static void insertGroupMember(
		String groupOneId, String groupOneEmail, Boolean groupOneJoined,
		String groupTwoId, String groupTwoEmail, Boolean groupTwoJoined,
		String groupThreeId, String groupThreeEmail, Boolean groupThreeJoined,
		String groupFourId, String groupFourEmail, Boolean groupFourJoined
	)
	{
		//DumpTracking();
		List<activityEntry> activityEntries;
		List <Id> groupIds = new List <Id> {groupOneId, groupTwoId, groupThreeId, groupFourId};
		List <CollaborationGroupMember> membershipsToDelete = new List <CollaborationGroupMember>();

		Set <Id> existingMembershipIds = new Set <Id>();
		Map <Id, CollaborationGroupMember> membershipGroupToMemberMap = new Map <Id, CollaborationGroupMember>();

		for (CollaborationGroupMember member :
		[
			SELECT Id, CollaborationGroupId, CollaborationGroup.Name
			FROM CollaborationGroupMember
			WHERE MemberId = :UserInfo.getUserId() AND
			CollaborationGroupId IN :groupIds
		])
		{
			existingMembershipIds.add(member.CollaborationGroupId);
			membershipGroupToMemberMap.put(member.CollaborationGroupId, member);
			System.debug('Member :' + member);
		}

		Map<Id, CollaborationGroup> groupsMap = new Map<Id, CollaborationGroup>(
		[SELECT Id, Name FROM CollaborationGroup WHERE Id IN :groupIds]);


		// delete membership for each group if it exists in the db but the joined attribute was changed to false in the component
		if (existingMembershipIds.size() > 0)
		{
			activityEntries = new List<activityEntry>();

			if (!groupOneJoined && existingMembershipIds.contains(groupOneId))
			{
				AddActivityEntry(activityEntries, groupsMap, groupOneId);
				membershipsToDelete.add(membershipGroupToMemberMap.get(groupOneId));
			}
			if (!groupTwoJoined && existingMembershipIds.contains(groupTwoId))
			{
				AddActivityEntry(activityEntries, groupsMap, groupTwoId);
				membershipsToDelete.add(membershipGroupToMemberMap.get(groupTwoId));
			}
			if (!groupThreeJoined && existingMembershipIds.contains(groupThreeId))
			{
				AddActivityEntry(activityEntries, groupsMap, groupThreeId);
				membershipsToDelete.add(membershipGroupToMemberMap.get(groupThreeId));
			}
			if (!groupFourJoined && existingMembershipIds.contains(groupFourId))
			{
				AddActivityEntry(activityEntries, groupsMap, groupFourId);
				membershipsToDelete.add(membershipGroupToMemberMap.get(groupFourId));
			}

			if (membershipsToDelete.size() > 0)
			{
				System.debug('Deleting membership: ' + membershipsToDelete);
				if (TrackActivities != null && TrackActivities.leaveGroup)
				{
					AddActivities(activityEntries, ACTIVITY_ACTION_LEAVE, ACTIVITY_TYPE_GROUP, ACTIVITY_PROCESS_DEFAULT);
				}

				delete membershipsToDelete;
			}
		}

		List <CollaborationGroupMember> membershipsToAdd = new List <CollaborationGroupMember>();
		activityEntries = new List<activityEntry>();

		if (groupOneJoined)
		{
			if (!existingMembershipIds.contains(groupOneId)) {
				AddActivityEntry(activityEntries, groupsMap, groupOneId);
			}
			membershipsToAdd.add(getNewOrExistingGroup(groupOneId, groupOneEmail, membershipGroupToMemberMap));
		}

		if (groupTwoJoined)
		{
			if (!existingMembershipIds.contains(groupTwoId)) {
				AddActivityEntry(activityEntries, groupsMap, groupTwoId);
			}
			membershipsToAdd.add(getNewOrExistingGroup(groupTwoId, groupTwoEmail, membershipGroupToMemberMap));
		}

		if (groupThreeJoined)
		{
			if (!existingMembershipIds.contains(groupThreeId)) {
				AddActivityEntry(activityEntries, groupsMap, groupThreeId);
			}
			membershipsToAdd.add(getNewOrExistingGroup(groupThreeId, groupThreeEmail, membershipGroupToMemberMap));
		}

		if (groupFourJoined)
		{
			if (!existingMembershipIds.contains(groupFourId)) {
				AddActivityEntry(activityEntries, groupsMap, groupFourId);
			}
			membershipsToAdd.add(getNewOrExistingGroup(groupFourId, groupFourEmail, membershipGroupToMemberMap));
		}

		if (membershipsToAdd.size() > 0)
		{
			System.debug('Adding memberships: ' + membershipsToAdd);

			if (TrackActivities != null && TrackActivities.joinGroup && activityEntries.size() > 0)
			{
				AddActivities(activityEntries, ACTIVITY_ACTION_JOIN, ACTIVITY_TYPE_GROUP, ACTIVITY_PROCESS_DEFAULT);
			}

			upsert membershipsToAdd;
		}
	}

	private static void AddActivityEntry(
		List<activityEntry> entries,
		Map <Id, CollaborationGroup> groupMap,
		String groupId)
	{
		entries.add(new activityEntry(groupId, groupMap.get(groupId).Name));
	}

	/*
		Create a new record or update the existing if joined
	 */
	private static CollaborationGroupMember getNewOrExistingGroup(
		String groupId,
		String notification,
		Map <Id, CollaborationGroupMember> membershipGroupToMemberMap)
	{
		CollaborationGroupMember newMember = membershipGroupToMemberMap.get(groupId);
		if (newMember == null)
		{
			newMember = new CollaborationGroupMember();
			newMember.CollaborationGroupId = groupId;
			newMember.MemberId = UserInfo.getUserId();
		}
		newMember.NotificationFrequency = notification;

		return newMember;
	}

	@AuraEnabled
	public static void completeSlide(String slide)
	{
		if (!String.isBlank(slide))
		{
			String queryString;
			Map <String, String> slideMap = new Map <String, String>
			{
				'Welcome' => 'Completed_Welcome_Slide__c',
				'Additional' => 'Completed_Additional_User_Data__c',
				'Profile' => 'Completed_Profile_Slide__c',
				'Notification' => 'Completed_Notification_Slide__c',
				'Topic' => 'Completed_Topics_Slide__c',
				'Group' => 'Completed_Groups_Slide__c',
				'Tours' => 'Completed_Tours_Slide__c'
			};
			String slideName = slideMap.get(slide);
			String userId = UserInfo.getUserId();

			if (slide != 'Done')
			{
				queryString = 'Select ' + slideName + ', Onboarding_Complete__c FROM User WHERE Id = :userId';
			} else
			{
				queryString = 'Select Onboarding_Complete__c FROM User WHERE Id = :userId';
			}
			User userRecord = Database.query(queryString);

			// complete slide checkbox as 'Save & Next' is hit.  These checkboxes keep track of the user's progress, and also
			// direct the user to the last uncompleted slide when this component is next initalized
			if (slide == 'Welcome')
			{
				userRecord.Completed_Welcome_Slide__c = true;
			} else if (slide == 'Profile')
			{
				userRecord.Completed_Profile_Slide__c = true;
			} else if (slide == 'Notification')
			{
				userRecord.Completed_Notification_Slide__c = true;
			} else if (slide == 'Topic')
			{
				userRecord.Completed_Topics_Slide__c = true;
			} else if (slide == 'Additional')
			{
				userRecord.Completed_Additional_User_Data__c = true;
			} else if (slide == 'Group')
			{
				userRecord.Completed_Groups_Slide__c = true;
			} else if (slide == 'Tours')
			{
				userRecord.Completed_Tours_Slide__c = true;
			} else if (slide == 'Done')
			{
				userRecord.Onboarding_Complete__c = true;
			}
			System.debug('userrecord: ' + userRecord);
			update userRecord;
		}
	}

	@AuraEnabled
	public static List <OnboardingWrapper> getGroups(List <Id> groupIds)
	{
		List<OnboardingWrapper> groupWrappers = new List<OnboardingWrapper>();
		Map <Id, String> groupsAlreadyJoined = new Map <Id, String>();
		for (CollaborationGroupMember grp :
		[
			SELECT CollaborationGroupId, NotificationFrequency
			FROM CollaborationGroupMember
			WHERE MemberId = :UserInfo.getUserId()
		])
		{
			groupsAlreadyJoined.put(grp.CollaborationGroupId, grp.NotificationFrequency);
		}

		for (CollaborationGroup grp :
		[
			SELECT Id, Name, Description
			FROM CollaborationGroup
			WHERE Id IN :groupIds
		])
		{
			OnboardingWrapper wrapper = new OnboardingWrapper(grp.Name, grp.Id, false, grp.Description, 'W');
			if (groupsAlreadyJoined.containsKey(grp.Id))
			{
				wrapper.following = true;
				wrapper.notificationFrequency = groupsAlreadyJoined.get(grp.Id);
			}
			System.debug('Adding group: ' + wrapper);

			groupWrappers.add(wrapper);
		}
		System.debug('GetGroups: ' + groupWrappers);
		return groupWrappers;
	}

/*
	TODO: Dynamic Query Builder for custom fields
	This method currently assumes the existence of custom fields that are not necessarily part of Onboarding, such as
	Region__c or Industry__c... This needs to be updated to allow for user configured fields before being packaged as
	part of product
	@AuraEnabled
	public static List<OnboardingWrapper> getUserSpecificGroups(){
		List<X7S_Onboarding_Group_Setting__mdt> onboardingGroupSettingList = new List<X7S_Onboarding_Group_Setting__mdt>();
		List<OnboardingWrapper> onboardingWrapperList = new List<OnboardingWrapper>();
		List<Id> groupIds = new List<Id>();
		for(X7S_Onboarding_Group_Setting__mdt metadata : [SELECT Id,Label,Group_Ids__c,User_Field_API_Name__c,User_Field_Value__c FROM X7S_Onboarding_Group_Setting__mdt]){
			onboardingGroupSettingList.add(metadata);
		}
		for(User user : [SELECT Id,Region__c,Industry__c FROM User WHERE Id =: UserInfo.getUserId() AND (Region__c != Null OR Industry__c != Null) LIMIT 1]){
			for(X7S_Onboarding_Group_Setting__mdt metadata : onboardingGroupSettingList){
				if( metadata.User_Field_API_Name__c == 'Region__c' && user.Region__c == metadata.User_Field_Value__c ||
					metadata.User_Field_API_Name__c == 'Industry__c' && user.Industry__c == metadata.User_Field_Value__c){
					groupIds.add(metadata.Group_Ids__c);
				}
			}
		}
		if (!groupIds.isEmpty()){
			onboardingWrapperList = getGroups(groupIds);
		} else{
			return null;
		}
		return onboardingWrapperList;
	}
*/

	@AuraEnabled
	public static ConnectApi.Photo uploadUserPhoto(Id documentId, String filename)
	{
		Id userId = UserInfo.getUserId();
		String communityId = Network.getNetworkId();
		// Take the first photo
		ContentVersion content =
		[
			SELECT ContentModifiedById,ContentDocumentId,FileExtension,FileType,ContentSize,ContentUrl,VersionData,VersionNumber
			FROM ContentVersion
			WHERE ContentDocumentId = :documentId
			LIMIT 1
		];
		// Set photo
		ConnectApi.BinaryInput bi = new ConnectApi.BinaryInput(content.VersionData, 'image/' + content.FileType.toLowerCase(), filename);
		ConnectApi.Photo photo = ConnectApi.UserProfiles.setPhoto(communityId, userId, bi);
		return ConnectApi.UserProfiles.getPhoto(communityId, userId);
	}

	@AuraEnabled
	public static OnboardingWrapper getGroup(Id groupId)
	{
		Boolean following = false;
		String notification = 'W';

		Map <Id, String> groupsAlreadyJoined = new Map <Id, String>();
		for (CollaborationGroupMember grp :
		[
			SELECT CollaborationGroupId, NotificationFrequency
			FROM CollaborationGroupMember
			WHERE MemberId = :UserInfo.getUserId() AND
			CollaborationGroupId = :groupId
		])
		{
			groupsAlreadyJoined.put(grp.CollaborationGroupId, grp.NotificationFrequency);
		}

		CollaborationGroup grp =
		[
			SELECT Id, Name, Description
			FROM CollaborationGroup
			WHERE Id = :groupId
		];

		if (groupsAlreadyJoined.containsKey(grp.Id))
		{
			following = true;
			notification = groupsAlreadyJoined.get(grp.Id);
		}

		OnboardingWrapper wrapper = new OnboardingWrapper(grp.Name, grp.Id, following, grp.Description, notification);
		return wrapper;
	}

	@AuraEnabled
	public static void removeGroupMember(Id groupId)
	{

		List <CollaborationGroupMember> grps =
		[
			SELECT CollaborationGroupId
			FROM CollaborationGroupMember
			WHERE MemberId = :UserInfo.getUserId() AND
			CollaborationGroupId = :groupId
		];

		if (grps.size() > 0)
		{
			CollaborationGroupMember grpMember = grps[0];
			delete grpMember;
		}
	}

	@AuraEnabled
	public static void followTopic(String topicId)
	{
		List <EntitySubscription> memberIds =
		[
			SELECT ParentId, SubscriberId
			FROM EntitySubscription
			WHERE SubscriberId = :UserInfo.getUserId() AND
			ParentId = :topicId
			LIMIT 500
		];

		if (memberIds.size() == 0)
		{
			EntitySubscription subscription = new EntitySubscription();
			subscription.ParentId = topicId;
			subscription.SubscriberId = UserInfo.getUserId();

			String topicName = [SELECT Id, Name FROM Topic WHERE Id = :topicId].Name;
			Id networkId1    = [SELECT NetworkId FROM NetworkMember WHERE MemberId = :UserInfo.getUserId() LIMIT 1].NetworkId;
			subscription.NetworkId = networkId1;

			insert subscription;

			if (TrackActivities.followTopic)
			{
				AddActivities(new List<activityEntry> {new activityEntry(topicId, topicName)}, ACTIVITY_ACTION_FOLLOW, ACTIVITY_TYPE_TOPIC, ACTIVITY_PROCESS_DEFAULT);
			}
		} else
		{
			System.debug('already following, no subscription');
		}
	}

	@AuraEnabled
	public static void unfollowTopic(String topicId)
	{
		List <EntitySubscription> memberIds =
		[
			SELECT Id, ParentId, SubscriberId, Parent.Name
			FROM EntitySubscription
			WHERE SubscriberId = :UserInfo.getUserId()
			AND ParentId = :topicId
			LIMIT 500
		];

		if (memberIds.size() > 0)
		{
			EntitySubscription subscriptionToDelete = memberIds[0];

			delete subscriptionToDelete;
			if (TrackActivities.unFollowTopic)
			{
				AddActivities(new List<activityEntry> {
						new activityEntry(
							subscriptionToDelete.Id,
							subscriptionToDelete.Parent.Name)
					}, ACTIVITY_ACTION_UNFOLLOW, ACTIVITY_TYPE_TOPIC, ACTIVITY_PROCESS_DEFAULT);
			}
		}
	}

	@AuraEnabled
	public static List <OnboardingWrapper> getTopics(List <Id> topicIds)
	{
		List<OnboardingWrapper> topicWrappers = new List<OnboardingWrapper>();
		Set <Id> topicsAlreadyFollowedIds = new Set <Id>();
		for (EntitySubscription member :
		[
			SELECT ParentId
			FROM EntitySubscription
			WHERE SubscriberId = :UserInfo.getUserId()
			LIMIT 500
		])
		{
			topicsAlreadyFollowedIds.add(member.ParentId);
		}

		for (Topic top :
		[
			SELECT Id, Name
			FROM Topic
			WHERE Id IN :topicIds
		])
		{
			OnboardingWrapper wrapper = new OnboardingWrapper(top.Name, top.Id, false, null, null);

			if (topicsAlreadyFollowedIds.contains(top.Id))
			{
				wrapper.following = true;
			}
			topicWrappers.add(wrapper);
		}
		return topicWrappers;
	}

	@AuraEnabled
	public static List<TopicSlide> grabTopics()
	{
		List<X7S_Onboarding_Topic_Setting__mdt> topicSettings =
		[
			SELECT Id, Parent_Label__c, Topic_Ids__c,Message__c,Action__c, Label, Max_Topics_Per_Page__c
			FROM X7S_Onboarding_Topic_Setting__mdt
		];

		List<String> topicIds = new List<String>();
		for (X7S_Onboarding_Topic_Setting__mdt topicSetting : topicSettings)
		{
			String topicIdString = topicSetting.Topic_Ids__c.trim();
			List<String> singleTopicIds = topicIdString.split(',');
			topicIds.addAll(singleTopicIds);
		}
		Set <Id> topicsAlreadyFollowedIds = new Set <Id>();
		for (EntitySubscription member :
		[
			SELECT ParentId
			FROM EntitySubscription
			WHERE SubscriberId = :UserInfo.getUserId()
			LIMIT 500
		])
		{
			topicsAlreadyFollowedIds.add(member.ParentId);
		}

		Map<Id, OnboardingWrapper> topicWrappers = new Map<Id, OnboardingWrapper>();

		for (Topic top :
		[
			SELECT Id, Name
			FROM Topic
			WHERE Id IN :topicIds
		])
		{

			OnboardingWrapper wrapper = new OnboardingWrapper(top.Name, top.Id, false, null, null);

			if (topicsAlreadyFollowedIds.contains(top.Id))
			{
				wrapper.following = true;
			}
			topicWrappers.put(top.Id, wrapper);
		}

		List<TopicSlide> topicSlides = new List<TopicSlide>();

		for (X7S_Onboarding_Topic_Setting__mdt topicSetting : topicSettings)
		{

			String topicIdString = topicSetting.Topic_Ids__c.trim();
			List<String> singleTopicIds = topicIdString.split(',');

			List<OnboardingWrapper> onboardingWrappers = new List<OnboardingWrapper>();
			for (String singleTopicId : singleTopicIds)
			{

				OnboardingWrapper onboardingWrapper = topicWrappers.get(singleTopicId);
				onboardingWrappers.add(onboardingWrapper);
			}

			TopicSlide newTopicSlide = new TopicSlide(onboardingWrappers, topicSetting.Parent_Label__c, topicSetting.Message__c, topicSetting.Action__c, topicSetting.Label, topicSetting.Max_Topics_Per_Page__c);
			topicSlides.add(newTopicSlide);
		}

		return topicSlides;
	}

	public class OnboardingWrapper
	{
		@AuraEnabled
		public String name { get; set; }
		@AuraEnabled
		public String id { get; set; }
		@AuraEnabled
		public Boolean following { get; set; }
		@AuraEnabled
		public String description { get; set; }
		@AuraEnabled
		public String notificationFrequency { get; set; }

		public OnboardingWrapper(String name, String id, Boolean following, String theDescription, String frequency)
		{
			this.name = name;
			this.id = id;
			this.following = following;
			this.description = theDescription;
			this.notificationFrequency = frequency;
		}

	}

	public class TopicSlide
	{
		@AuraEnabled
		public List<OnboardingWrapper> topics { get; set; }
		@AuraEnabled
		public String parentLabel { get; set; }
		@AuraEnabled
		public String message { get; set; }
		@AuraEnabled
		public String action { get; set; }
		@AuraEnabled
		public String label { get; set; }
		@AuraEnabled
		public Decimal maxTopics { get; set; }

		public TopicSlide(List<OnboardingWrapper> wrappers, String slideName, String message, String action, String labelString, Decimal perPageTopics)
		{
			this.parentLabel = slideName;
			this.message = message;
			this.action = action;
			this.topics = wrappers;
			this.label = labelString;
			this.maxTopics = perPageTopics;
		}
	}

	@TestVisible
	private static void AddActivities(List<activityEntry> entityList, String actionType, String activityType, String processName)
	{
		List<x7s_Onboarding_Activity__c> activities = new List<x7s_Onboarding_Activity__c>();

		for (activityEntry entityEntry : entityList)
		{
			activities.add(new x7s_Onboarding_Activity__c(
				Community_Id__c     = System.Network.getNetworkId(),
				Action_Type__c      = actionType,
				Activity_Type__c    = activityType,
				Process_Name__c     = processName,
				Entity_Record_ID__c = entityEntry.id,
				Entity_Name__c      = entityEntry.name));
		}

		insert activities;
	}
}