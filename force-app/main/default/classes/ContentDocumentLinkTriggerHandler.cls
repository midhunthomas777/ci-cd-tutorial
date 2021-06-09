/*
 * Copyright (c) 2018.  7Summits Inc.
 */

public class ContentDocumentLinkTriggerHandler
{

	public static void onBeforeInsert(List<ContentDocumentLink> listOfContentDocLinks)
	{
		for (ContentDocumentLink cdl : listOfContentDocLinks)
		{
			if (cdl.LinkedEntityId.getSobjectType() == Job_Posting__c.SObjectType)
			{
				cdl.Visibility = 'AllUsers';
			}
		}
	}
}