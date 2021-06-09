/*
 * Copyright (c) 2018. 7Summits Inc.
 */

/**
 * Created by francoiskorb on 6/11/18.
 */

public with sharing class Match_Util_Label_Value
{
	@AuraEnabled
	public String label, value;

	public Match_Util_Label_Value(String label, String value)
	{
		this.label = label;
		this.value = value;
	}

	public void dumpModel(String title)
	{
		System.debug('Dump label value pair: ' + title);

		System.debug('label: ' + label);
		System.debug('value: ' + value);

	}
}