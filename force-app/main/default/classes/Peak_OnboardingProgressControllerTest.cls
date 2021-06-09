/*
 * Copyright (c) 2019. 7Summits Inc. All rights reserved.
 *
 */

@IsTest
public with sharing class Peak_OnboardingProgressControllerTest
{
	@IsTest
	public static void testGetSharing()
	{
		Test.startTest();
		User testUser = Peak_Onboarding_TestUtils.createStandardUserNoContact();
		insert testUser;
		Test.stopTest();

		System.runAs(new User(Id = UserInfo.getUserId()))
		{
			testUser.Completed_Welcome_Slide__c = true;
			testUser.Completed_Profile_Slide__c = true;
			testUser.Completed_Notification_Slide__c = true;
			testUser.Completed_Topics_Slide__c = true;
			testUser.Completed_Groups_Slide__c = true;
			testUser.Completed_Tours_Slide__c = true;
			update testUser;
		}

		System.runAs(testUser)
		{
			User testUserReturn = Peak_OnBoardingProgressController.getUserRecord();
			Peak_OnBoardingProgressController.ProgressWrapper wrapper = Peak_OnBoardingProgressController.getProgress();
			System.assert(wrapper.completedTour == true);
			System.assert(testUser.Id == testUserReturn.Id);
		}
	}

}