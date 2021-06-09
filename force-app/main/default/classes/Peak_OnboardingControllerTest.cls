/*
 * Copyright (c) 2019. 7Summits Inc. All rights reserved.
 *
 */

@IsTest(SeeAllData=true)
public class Peak_OnboardingControllerTest
{

	@IsTest
	public static void setup()
	{
		List <Network> testnetworkList = [SELECT Id FROM Network];
		Id networkId = testnetworkList[0].Id;

		Test.startTest();
		User testUser = Peak_Onboarding_TestUtils.createStandardUserNoContact();
		insert testUser;
		System.assertNotEquals(null, testUser);
		Test.stopTest();

		List <CollaborationGroup> testGroups = new List <CollaborationGroup>();
		for (Integer i = 0; i < 4; i++)
		{
			CollaborationGroup colGroup = new CollaborationGroup(
				Name = 'Test Chatter Group' + i,
				CollaborationType = 'Public',
				CanHaveGuests = false,
				NetworkId = networkId);
			testGroups.add(colGroup);
		}

		insert testGroups;

		List <Topic> testTopics = new List <Topic>();
		for (Integer i = 0; i < 2; i++)
		{
			Topic testTopic = new Topic(Name = 'Test Topic ' + i, Description = 'Test Topic1 Description', NetworkId = networkId);
			testTopics.add(testTopic);
		}

		insert testTopics;
	}

	@IsTest
	public static void testGetIsModalViewEnabled()
	{
		setup();

		User testUser = [SELECT Id, Onboarding_Complete__c FROM User WHERE Email = :Peak_Onboarding_TestConstants.STANDARD_USERNAME LIMIT 1];
		System.runAs(testUser)
		{
			Boolean isModalViewEnabled = Peak_OnboardingController.getIsModalViewEnabled();
			System.assertNotEquals(null, isModalViewEnabled);
		}
	}

	@IsTest
	public static void testGetOnboardingComplete()
	{
		setup();

		User testUser = [SELECT Id, Onboarding_Complete__c FROM User WHERE Email = :Peak_Onboarding_TestConstants.STANDARD_USERNAME LIMIT 1];
		testUser.Onboarding_Complete__c = true;
		update testUser;
		System.runAs(testUser)
		{
			User testUser1 = Peak_OnboardingController.getUserRecord();
			System.assert(testUser1.Onboarding_Complete__c == true);
		}
	}

	@IsTest
	public static void testUpdateUserNames()
	{
		setup();
		User testUser = [SELECT Id, Onboarding_Complete__c FROM User WHERE Email = :Peak_Onboarding_TestConstants.STANDARD_USERNAME LIMIT 1];
		testUser.FirstName = 'TestChange';
		System.runAs(testUser)
		{
			Peak_OnboardingController.updateUserNames(testUser);
			User testUserName = [SELECT Id, FirstName FROM User WHERE Email = :Peak_Onboarding_TestConstants.STANDARD_USERNAME LIMIT 1];
			System.assert(testUserName.FirstName == 'TestChange');
		}
	}

	@IsTest
	public static void testUpdatePreferences()
	{
		setup();
		User testUser = [SELECT Id, Onboarding_Complete__c FROM User WHERE Email = :Peak_Onboarding_TestConstants.STANDARD_USERNAME LIMIT 1];
		System.runAs(testUser)
		{
			Peak_OnboardingController.updatePreferences(false);
			NetworkMember testUserName = [SELECT PreferencesDisableAllFeedsEmail FROM NetworkMember WHERE MemberId = :testUser.Id LIMIT 1];
			System.assert(testUserName.PreferencesDisableAllFeedsEmail == true);
			Peak_OnboardingController.updatePreferences(true);
			NetworkMember testUserName2 = [SELECT PreferencesDisableAllFeedsEmail FROM NetworkMember WHERE MemberId = :testUser.Id LIMIT 1];
			System.assert(testUserName2.PreferencesDisableAllFeedsEmail == false);
		}
	}

	@IsTest
	public static void testInsertGroupMember()
	{
		setup();

		User testUser = [SELECT Id, Onboarding_Complete__c, Email FROM User WHERE Email = :Peak_Onboarding_TestConstants.STANDARD_EMAIL LIMIT 1];
		System.debug('testUser: ' + testUser);

		List <CollaborationGroup> testGroups =
		[
			SELECT Id
			FROM CollaborationGroup
			WHERE Name = 'Test Chatter Group0'
			OR Name = 'Test Chatter Group1'
			OR Name = 'Test Chatter Group2'
			OR Name = 'Test Chatter Group3'
		];

		System.runAs(testUser)
		{
			Peak_OnboardingController.insertGroupMember(testGroups[0].Id, 'D', true, testGroups[1].Id, 'W', true,
				testGroups[2].Id, null, true, testGroups[3].Id, null, true);

			List <CollaborationGroupMember> memberList =
			[
				SELECT Id
				FROM CollaborationGroupMember
				WHERE MemberId = :testUser.Id
			];

			System.assert(memberList.size() == 4);
		}
	}

	@IsTest
	public static void testInsertGroupMemberRemove()
	{
		setup();
		User testUser = [SELECT Id, Onboarding_Complete__c FROM User WHERE Email = :Peak_Onboarding_TestConstants.STANDARD_USERNAME LIMIT 1];

		List <CollaborationGroupMember> testMembers = new List <CollaborationGroupMember>();

		for (CollaborationGroup grp :
		[
			SELECT Id
			FROM CollaborationGroup
			WHERE Name = 'Test Chatter Group0'
			OR Name = 'Test Chatter Group1'
			OR Name = 'Test Chatter Group2'
			OR Name = 'Test Chatter Group3'
		])
		{
			CollaborationGroupMember member = new CollaborationGroupMember(CollaborationGroupId = grp.Id, MemberId = testUser.Id);
			testMembers.add(member);
		}

		insert testMembers;

		System.runAs(testUser)
		{
			Peak_OnboardingController.insertGroupMember(testMembers[0].CollaborationGroupId, null, false, testMembers[1].CollaborationGroupId, null, false,
				testMembers[2].CollaborationGroupId, null, false, testMembers[3].CollaborationGroupId, null, false);

			List <CollaborationGroupMember> memberList =
			[
				SELECT Id
				FROM CollaborationGroupMember
				WHERE MemberId = :testUser.Id
			];

			System.assert(memberList.size() == 0);
		}
	}

	@IsTest
	public static void testCompleteSlide()
	{
		setup();
		User testUser = [SELECT Id FROM User WHERE Email = :Peak_Onboarding_TestConstants.STANDARD_USERNAME LIMIT 1];
		System.runAs(testUser)
		{
			Peak_OnboardingController.completeSlide('Welcome');
			Peak_OnboardingController.completeSlide('Profile');
			Peak_OnboardingController.completeSlide('Notification');
			Peak_OnboardingController.completeSlide('Topic');
			Peak_OnboardingController.completeSlide('Group');
			Peak_OnboardingController.completeSlide('Tours');
			Peak_OnboardingController.completeSlide('Done');

			User testUserName = [SELECT Completed_Tours_Slide__c, Onboarding_Complete__c FROM User WHERE Email = :Peak_Onboarding_TestConstants.STANDARD_USERNAME LIMIT 1];
			System.assert(testUserName.Completed_Tours_Slide__c == true);
			System.assert(testUserName.Onboarding_Complete__c == true);
		}
	}


	@IsTest
	public static void testGetTopics()
	{
		setup();
		User testUser = [SELECT Id FROM User WHERE Email = :Peak_Onboarding_TestConstants.STANDARD_USERNAME LIMIT 1];
		List <Id> topicIds = new List <Id>();
		for (Topic top : [SELECT Id FROM Topic WHERE Name = 'Test Topic 0' OR Name = 'Test Topic 1'])
		{
			topicIds.add(top.Id);
		}
		Id networkId1 = [SELECT Id FROM Network LIMIT 1].Id;
		EntitySubscription subscription = new EntitySubscription(ParentId = topicIds[0], SubscriberId = testUser.Id, NetworkId = networkId1);
		insert subscription;

		System.runAs(testUser)
		{
			List <Peak_OnboardingController.OnboardingWrapper> topicWrapper = Peak_OnboardingController.getTopics(topicIds);
			System.assert(topicWrapper.size() == 2);
		}
	}

	@IsTest
	public static void testGetGroups()
	{
		setup();
		User testUser = [SELECT Id FROM User WHERE Email = :Peak_Onboarding_TestConstants.STANDARD_USERNAME LIMIT 1];
		List <Id> groupIds = new List <Id>();
		for (CollaborationGroup grp : [SELECT Id FROM CollaborationGroup WHERE Name = 'Test Chatter Group0' OR Name = 'Test Chatter Group1'])
		{
			groupIds.add(grp.Id);
		}

		CollaborationGroupMember member = new CollaborationGroupMember(CollaborationGroupId = groupIds[0], MemberId = testUser.Id);
		insert member;
		System.runAs(testUser)
		{
			List <Peak_OnboardingController.OnboardingWrapper> groupWrapper = Peak_OnboardingController.getGroups(groupIds);
			System.assert(groupWrapper.size() == 2);
		}
	}

	@IsTest
	public static void testGetGroup()
	{
		setup();
		User testUser = [SELECT Id FROM User WHERE Email = :Peak_Onboarding_TestConstants.STANDARD_USERNAME LIMIT 1];
		String groupId = [SELECT Id FROM CollaborationGroup WHERE Name = 'Test Chatter Group1' LIMIT 1].Id;

		CollaborationGroupMember member = new CollaborationGroupMember(CollaborationGroupId = groupId, MemberId = testUser.Id);
		insert member;

		System.runAs(testUser)
		{
			Peak_OnboardingController.OnboardingWrapper groupWrapper = Peak_OnboardingController.getGroup(groupId);
			System.assert(groupWrapper.id == groupId);
		}
	}

	@IsTest
	public static void testFollowTopic()
	{
		setup();
		User testUser = [SELECT Id FROM User WHERE Email = :Peak_Onboarding_TestConstants.STANDARD_USERNAME LIMIT 1];
		String topicId = [SELECT Id FROM Topic WHERE Name = 'Test Topic 0' LIMIT 1].Id;

		System.runAs(testUser)
		{
			Peak_OnboardingController.followTopic(topicId);
			List <EntitySubscription> userFollow = [SELECT Id FROM EntitySubscription WHERE ParentId = :topicId AND SubscriberId = :testUser.Id LIMIT 1];
			System.assert(userFollow.size() == 1);
		}
	}

	@IsTest
	public static void testRemoveGroupMember()
	{
		setup();
		User testUser = [SELECT Id FROM User WHERE Email = :Peak_Onboarding_TestConstants.STANDARD_USERNAME LIMIT 1];
		CollaborationGroup testGroup = [SELECT Id FROM CollaborationGroup WHERE Name = 'Test Chatter Group3' LIMIT 1];
		CollaborationGroupMember member = new CollaborationGroupMember(CollaborationGroupId = testGroup.Id, MemberId = testUser.Id);
		insert member;

		System.runAs(testUser)
		{
			Peak_OnboardingController.removeGroupMember(testGroup.Id);
			List <CollaborationGroupMember> userFollow = [SELECT Id FROM CollaborationGroupMember WHERE MemberId = :testUser.Id];
			System.assert(userFollow.size() == 0);
		}
	}

	@IsTest
	public static void testUnFollowTopic()
	{
		setup();
		User testUser = [SELECT Id FROM User WHERE Email = :Peak_Onboarding_TestConstants.STANDARD_USERNAME LIMIT 1];
		Id networkId1 = [SELECT Id FROM Network LIMIT 1].Id;
		String topicId = [SELECT Id FROM Topic WHERE Name = 'Test Topic 0' LIMIT 1].Id;
		EntitySubscription topicFollow = new EntitySubscription(NetworkId = networkId1, ParentId = topicId, SubscriberId = testUser.Id);
		insert topicFollow;

		System.runAs(testUser)
		{
			Peak_OnboardingController.unfollowTopic(topicId);
			List <EntitySubscription> userFollow = [SELECT Id FROM EntitySubscription WHERE ParentId = :topicId AND SubscriberId = :testUser.Id LIMIT 1];
			System.assert(userFollow.size() == 0);
		}
	}

/*
	TODO: Dynamic query builder for custom fields
	@IsTest
	public static void testGetUserSpecificGroups()
	{
		setup();
		User testUser = [SELECT Id,Region__c FROM User WHERE Email = :Peak_Onboarding_TestConstants.STANDARD_USERNAME LIMIT 1];
		testUser.Region__c = 'Northeast';
		update testUser;
		List <Id> groupIds = new List <Id>();
		for (CollaborationGroup grp : [SELECT Id FROM CollaborationGroup WHERE Name = 'Test Chatter Group0' OR Name = 'Test Chatter Group1'])
		{
			groupIds.add(grp.Id);
		}

		CollaborationGroupMember member = new CollaborationGroupMember(CollaborationGroupId = groupIds[0], MemberId = testUser.Id);
		insert member;

		System.runAs(testUser)
		{

			List <Peak_OnboardingController.OnboardingWrapper> OnboardingWrapperList = Peak_OnboardingController.getUserSpecificGroups();
			System.assert(OnboardingWrapperList.size() == 1);
		}
	}
 */

	@IsTest(SeeAllData=true)
	public static void testUploadUserPhoto()
	{
		setup();
		User testUser = [SELECT Id FROM User WHERE Email = :Peak_Onboarding_TestConstants.STANDARD_USERNAME LIMIT 1];
		//update testUser;

		ContentVersion contentVersionInsert = new ContentVersion(
			Title           = 'User Photo',
			PathOnClient    = Peak_Onboarding_TestConstants.TEST_FILENAME,
			VersionData     = Blob.valueOf(Peak_Onboarding_TestConstants.BASE64FILE),
			IsMajorVersion  = true
		);
		insert contentVersionInsert;

		ContentDocument documents = [SELECT Id, Title,FileType, LatestPublishedVersionId FROM ContentDocument LIMIT 1];

		System.runAs(testUser)
		{
			ConnectApi.Photo uploadUserPhoto = Peak_OnboardingController.uploadUserPhoto(documents.Id, documents.FileType);
			System.assertNotEquals(null, uploadUserPhoto);
		}
	}

	@IsTest
	public static void testGetTrackingOptions() {
		Peak_OnboardingController.activityTracking myTracking = Peak_OnboardingController.TrackActivities;
		System.assertNotEquals(null, myTracking);
		Peak_OnboardingController.DumpTracking();
	}

	@IsTest
	public static void testActivityEntry()
	{
		Peak_OnboardingController.activityEntry entry = new Peak_OnboardingController.activityEntry('ID1', 'Name');
		System.assertNotEquals(null, entry);
	}
}