/*
 * Copyright (c) 2018. 7Summits Inc.
 */

/**
 * Created by jasondaluga on 7/17/18.
 */

public class Peak_GoogleMapsController
{
	private static final String STR_ENCODE_SCHEME   = 'UTF-8';
	private static final String STR_FIELD_SEPARATOR = ',';

	@AuraEnabled
	public static String getAddress(
		String recordId,
		String street,
		String city,
		String state,
		String postalCode,
		String country,
		String geoLocation)
	{
		if (recordId == null) { return null;}

		String data          = '';
		String fieldNames    = '';
		String objectAPIName = '';

		String keyPrefix = recordId.substring(0, 3);

		for (Schema.SObjectType obj : Schema.getGlobalDescribe().values())
		{
			if (obj.getDescribe().getKeyPrefix() == keyPrefix)
			{
				objectAPIName = obj.getDescribe().getName();
				break;
			}
		}

		fieldNames = addToString(fieldNames, geoLocation);
		fieldNames = addToString(fieldNames, street);
		fieldNames = addToString(fieldNames, city);
		fieldNames = addToString(fieldNames, state);
		fieldNames = addToString(fieldNames, postalCode);
		fieldNames = addToString(fieldNames, country);

		if (String.isNotBlank(objectAPIName))
		{
			Id longId = Id.valueOf(recordId);

			String dynamicQuery = 'SELECT Id, ' + fieldNames + ' FROM ' + objectAPIName + ' WHERE Id = \'' + longId + '\' LIMIT 1';
			System.debug('getAddress Query: ' + dynamicQuery);

			SObject response = null;
			try
			{
				response = Database.query(dynamicQuery);
			}
			catch (QueryException e) {
				System.debug(e.getMessage());
			}

			System.debug('getAddress - Query response: ' + response);

			if (response != null)
			{
				if (String.isNotBlank(geoLocation) && (System.Location) response.get(geoLocation) != null)
				{
					data = makeGeoLocation(response, geoLocation);
				}

				if (String.isBlank(data))
				{
					data = makeAddress(response, street, city, state, postalCode, country);
				}

				System.debug('getAddress - data = ' + data);
			}
		}

		return data;
	}

	@TestVisible
	private static String addToString(String original, String addition)
	{
		if (String.isBlank(original))
		{
			return addition;
		}

		if (String.isBlank(addition))
		{
			return original;
		}

		return original + STR_FIELD_SEPARATOR + addition;
	}

	@TestVisible
	private static String makeAddress(SObject addressObject, String street, String city, String state, String postalCode, String country)
	{
		System.debug('addressObject: ' + addressObject);

		String address = '';

		if (street != null && String.isNotBlank(street))
		{
			address = (String) addressObject.get(street);
		}
		if (city != null && String.isNotBlank(city))
		{
			address = address + ' ' + (String) addressObject.get(city);
		}
		if (state != null && String.isNotBlank(state))
		{
			address = address + ' ' + (String) addressObject.get(state);
		}
		if (postalCode != null && String.isNotBlank(postalCode))
		{
			address = address + ' ' + (String) addressObject.get(postalCode);
		}
		if (country != null && String.isNotBlank(country))
		{
			address = address + ' ' + (String) addressObject.get(country);
		}

		return  encodeString(address);
	}

	@TestVisible
	private static String encodeString(String value)
	{
		return String.isNotBlank(value) ? EncodingUtil.urlEncode(value, STR_ENCODE_SCHEME) : value;
	}

	@TestVisible
	private static String makeGeoLocation(SObject addressObject, String fieldName)
	{
		System.Location location = (System.Location) addressObject.get(fieldName);
		return location != null ? location.latitude + STR_FIELD_SEPARATOR + location.longitude : null;
	}
}