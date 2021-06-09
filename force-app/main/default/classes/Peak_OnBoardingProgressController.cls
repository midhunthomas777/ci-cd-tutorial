/*
 * Copyright (c) 2019. 7Summits Inc. All rights reserved.
 *
 */

public without sharing class Peak_OnBoardingProgressController
{

	@AuraEnabled
	public static ProgressWrapper getProgress()
	{
		User currentUser =
		[
			SELECT Completed_Groups_Slide__c, Completed_Notification_Slide__c, Completed_Profile_Slide__c,
				Completed_Tours_Slide__c, Completed_Welcome_Slide__c, Completed_Topics_Slide__c, Onboarding_Complete__c
			FROM User
			WHERE Id = :UserInfo.getUserId()
			LIMIT 1
		];

		ProgressWrapper wrapper = new ProgressWrapper(
			currentUser.Completed_Welcome_Slide__c, currentUser.Completed_Profile_Slide__c, currentUser.Completed_Notification_Slide__c,
			currentUser.Completed_Topics_Slide__c, currentUser.Completed_Groups_Slide__c, currentUser.Completed_Tours_Slide__c
		);

		return wrapper;
	}

	@AuraEnabled
	public static User getUserRecord()
	{
		User currentUser =
		[
			SELECT Completed_Groups_Slide__c, Completed_Notification_Slide__c, Completed_Profile_Slide__c, Completed_Topics_Slide__c,
				Completed_Tours_Slide__c, Completed_Welcome_Slide__c, FirstName, LastName, Onboarding_Complete__c
			FROM User
			WHERE Id = :UserInfo.getUserId()
			LIMIT 1
		];

		return currentUser;
	}

	public class ProgressWrapper
	{

		@AuraEnabled
		public Boolean completedWelcome { get; set; }
		@AuraEnabled
		public Boolean completedProfile { get; set; }
		@AuraEnabled
		public Boolean completedNotifications { get; set; }
		@AuraEnabled
		public Boolean completedTopics { get; set; }
		@AuraEnabled
		public Boolean completedGroups { get; set; }
		@AuraEnabled
		public Boolean completedTour { get; set; }

		public ProgressWrapper(Boolean completedWelcome, Boolean completedProfile, Boolean completedNotifications,
			Boolean completedTopics, Boolean completedGroups, Boolean completedTour)
		{
			this.completedWelcome = completedWelcome;
			this.completedProfile = completedProfile;
			this.completedNotifications = completedNotifications;
			this.completedTopics = completedTopics;
			this.completedGroups = completedGroups;
			this.completedTour = completedTour;
		}

	}


}