/*
 * Copyright (c) 2018. 7Summits Inc.
 */

/**
 * Created by francoiskorb on 8/9/18.
 */

public with sharing class Match_UserAttributeWizard
{
	public static List<String> listOfApplicableTypes;

	@AuraEnabled
	public static String getAttributesGroupByType(String applicableTypes, String targetObjectName, String parentFieldName, String parentFieldValue)
	{
		List<AttributeCategoryWrapper> listOfResults = new List<AttributeCategoryWrapper>();
		String       nameSpace = Match_Util_Metadata.getNameSpacePrefix();

		//get already selected attributes
		Map<Id, SObject> mapOfSelectedAttribute = new Map<Id, SObject>();
		try
		{
			String recordQueryString = String.format(' select id,Match_Attribute__c,Critical__c from {0} where {1} =: {2} ', new List<String> {nameSpace+targetObjectName, parentFieldName, 'parentFieldValue'});
			for (SObject selectedAttribute : Database.query(recordQueryString))
			{
				mapOfSelectedAttribute.put((Id) selectedAttribute.get('Match_Attribute__c'), selectedAttribute);
			}
		}
		catch (Exception e)
		{
			System.debug(e.getMessage());
		}

		if (!String.isEmpty(applicableTypes))
		{
			listOfApplicableTypes = applicableTypes.split(',');
		}

		//create map of Attribute types to list of Attributes
		Map<String, List<AttributeWrapper>> mapOfAttributeNameToList = new Map<String, List<AttributeWrapper>>();
		String queryString = 'select id,name,type__c from Match_Attribute__c ';
		if (listOfApplicableTypes != null && listOfApplicableTypes.size() > 0)
		{
			queryString += ' where type__c IN : listOfApplicableTypes';
		}
		queryString += ' order by name,type__c';

		for (Match_Attribute__c attribute : (List<Match_Attribute__c>) Database.query(queryString))
		{
			if (!mapOfAttributeNameToList.containsKey(attribute.Type__c))
			{
				mapOfAttributeNameToList.put(attribute.Type__c, new List<AttributeWrapper>());
			}

			Id existingId = mapOfSelectedAttribute.containsKey(attribute.Id) ? (Id) mapOfSelectedAttribute.get(attribute.Id).get('Id') : null;
			Boolean isCritical = mapOfSelectedAttribute.containsKey(attribute.Id) && (Boolean) mapOfSelectedAttribute.get(attribute.Id).get('Critical__c') ? true : false;
			mapOfAttributeNameToList.get(attribute.Type__c).add(new AttributeWrapper(attribute, existingId, isCritical));
		}

		for (String category : mapOfAttributeNameToList.keySet())
		{
			AttributeCategoryWrapper result = new AttributeCategoryWrapper();
			result.category = category;
			result.listOfAttributes = mapOfAttributeNameToList.get(category);
			listOfResults.add(result);
		}
		listOfResults.sort();

		return JSON.serialize(listOfResults);
	}

	//wrapper class to wrap list of attributes with Category
	public class AttributeCategoryWrapper implements Comparable
	{
		@AuraEnabled public String category;
		@AuraEnabled public List<AttributeWrapper> listOfAttributes;

		public Integer compareTo(Object compareTo)
		{
			AttributeCategoryWrapper compareToItem = (AttributeCategoryWrapper) compareTo;

			//if categories are specified in property builder, sort according to them
			if (listOfApplicableTypes != null && listOfApplicableTypes.size() > 0)
			{
				if (listOfApplicableTypes.indexOf(category) == listOfApplicableTypes.indexOf(compareToItem.category)) return 0;
				if (listOfApplicableTypes.indexOf(category) > listOfApplicableTypes.indexOf(compareToItem.category)) return 1;
				return -1;
			}
			else
			{ //otherwise sort alphabetically
				if (category == compareToItem.category) return 0;
				if (category > compareToItem.category) return 1;
				return -1;
			}
		}
	}


	//wrapper class to wrap attributes with selected
	public class AttributeWrapper
	{
		@AuraEnabled public Match_Attribute__c attribute;
		@AuraEnabled public Boolean isSelected;
		@AuraEnabled public Boolean isCritical;
		@AuraEnabled public Id existingId;

		public AttributeWrapper(Match_Attribute__c attribute, Id existingId, Boolean isCritical)
		{
			this.attribute = attribute;
			this.isCritical = isCritical;
			if (existingId != null)
			{
				this.isSelected = true;
				this.existingId = existingId;
			}
			else
			{
				this.isSelected = false;
			}
		}
	}

	//method to save the records
	@AuraEnabled
	public static Match_Return saveUserAttributes(String targetObjectName, String parentFieldName, String parentFieldValue, String recordsAsJSON)
	{
		String       nameSpace = Match_Util_Metadata.getNameSpacePrefix();
		Match_Return response  = new Match_Return();

		List<AttributeWrapper> listOfAttributeWrapper = (List<AttributeWrapper>) JSON.deserialize(recordsAsJSON, List<AttributeWrapper>.class);

		List<SObject> listOfRecordsToInsert = new List<SObject>();
		List<SObject> listOfRecordsToDelete = new List<SObject>();

		//check if target object exists
		Schema.SObjectType sObjType = Schema.getGlobalDescribe().get(nameSpace+targetObjectName);
		SObject newRecord ;

		//if object doesn't exist , show error
		if (sObjType == null)
		{
			response.isSuccess = false;
			response.message = 'Target Object does not exist';
			return response;
		}
		else
		{ //else create the records for selected attributes
			for (AttributeWrapper record : listOfAttributeWrapper)
			{
				if (record.isSelected)
				{
					newRecord = Schema.getGlobalDescribe().get(nameSpace+targetObjectName).newSObject();
					newRecord.put('Match_Attribute__c', record.attribute.Id);
					newRecord.put('type__c', record.attribute.Type__c);
					newRecord.put('Critical__c', record.isCritical);

					if (record.existingId != null)
					{
						newRecord.put('Id', record.existingId);
					}

					newRecord.put(parentFieldName, parentFieldValue);
					listOfRecordsToInsert.add(newRecord);
				}
				else if (record.existingId != null)
				{
					//if an attribute was selected before but removed now, delete that
					newRecord = Schema.getGlobalDescribe().get(nameSpace+targetObjectName).newSObject();
					newRecord.put('Id', record.existingId);
					listOfRecordsToDelete.add(newRecord);
				}
			}
		}

		//insert all records
		if (listOfRecordsToInsert.size() > 0)
		{
			//cast from list<sObject> to listOfSpecificObject as upsert is not allowed on sObject
			String listType = 'List<' + nameSpace+targetObjectName + '>';
			List<SObject> castRecords = (List<SObject>) Type.forName(listType).newInstance();
			castRecords.addAll(listOfRecordsToInsert);
			try
			{
				upsert castRecords;
				response.isSuccess = true;
				response.message = 'Records inserted successfully';
			}
			catch (Exception e)
			{
				response.isSuccess = false;
				response.message = 'Error while inserting records.' + e.getMessage();
			}
		}

		//delete if there are some attributes to delete
		if (listOfRecordsToDelete.size() > 0)
		{
			delete listOfRecordsToDelete;
		}

		return response;
	}

}