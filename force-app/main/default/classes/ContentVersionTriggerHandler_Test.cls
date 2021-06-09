/*
 * Copyright (c) 2018.  7Summits Inc.
 */

@IsTest
private class ContentVersionTriggerHandler_Test
{

	static testMethod void getTopicAssg_test()
	{
		Job_Posting__c jp = new Job_Posting__c();
		jp.Job_Title__c = 'Developer';
		insert jp;

		Job_Posting__c jps = new Job_Posting__c();

		List<Topic> topics = [SELECT Id FROM Topic LIMIT 5];
		List<String> topicItems = new List<String>();
		for (Topic tp : topics)
		{
			topicItems.add(tp.Id);
		}

		Test.startTest();
		jp_JobPostingFormController.getJobPostingData(jp.Id);
		Test.stopTest();
	}
}