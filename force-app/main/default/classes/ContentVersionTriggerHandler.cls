/*
 * Copyright (c) 2018.  7Summits Inc.
 */

public class ContentVersionTriggerHandler
{

	private static String CONTENT_VERSION_DOWNLOAD_URL = System.Label.jp_content_version_download_url;

	public static void updateLogoUrlOnJobPosting(List<ContentVersion> listOfContentVersion)
	{
		Map<Id, Id> mapOfDocIdAndVersionId = new Map<Id, Id>();
		for (ContentVersion conVer : listOfContentVersion)
		{
			if (conVer.Title == 'OneTimeLogo')
			{
				mapOfDocIdAndVersionId.put(conVer.ContentDocumentId, conVer.Id);
			}
		}

		if (mapOfDocIdAndVersionId.size() > 0)
		{
			Set<Id> contDocIds = mapOfDocIdAndVersionId.keySet();
			List<Job_Posting__c> listOfJobPostingToUpdate = new List<Job_Posting__c>();
			for (ContentDocumentLink cdl :
			[
				SELECT LinkedEntityId, ContentDocumentId
				FROM ContentDocumentLink
				WHERE ContentDocumentId IN :contDocIds
			])
			{
				if (cdl.LinkedEntityId.getSobjectType() == Job_Posting__c.SObjectType)
				{
					listOfJobPostingToUpdate.add(
						new Job_Posting__c(
							Id = cdl.LinkedEntityId,
							LogoContentUrl__c = CONTENT_VERSION_DOWNLOAD_URL + mapOfDocIdAndVersionId.get(cdl.ContentDocumentId)));
				}
			}
			if (listOfJobPostingToUpdate.size() > 0)
			{
				update listOfJobPostingToUpdate;
			}
		}
	}
}