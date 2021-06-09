/*
 * Copyright (c) 2018  7Summits Inc.
 */

/**
 * Created by francois korb on 5/9/18.
 */

public with sharing class Match_Attribute_Type
{
	@AuraEnabled
	public String id, name;

	@AuraEnabled
	public Decimal multiplier;

	public Match_Attribute_Type()
	{
		id         = '';
		name       = '';
		multiplier = 1;
	}

	public void dumpModel(String title)
	{
		System.debug('Dump Match_Attribute_Type model   : ' + title);
		System.debug('  id         : ' + this.id);
		System.debug('  name       : ' + this.name);
		System.debug('  multiplier : ' + this.multiplier);
	}
}