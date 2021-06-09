/*
 * Copyright (c) 2018  7Summits Inc.
 */

/**
 * Created by francois korb on 3/22/18.
 */

public with sharing class Match_Field
{
	@AuraEnabled
	public String id, name, apiName, label, fieldType, align, info;

	@AuraEnabled
	public Decimal sequence;

	public Match_Field()
	{
		id        = '';
		name      = '';
		apiName   = '';
		label     = '';
		info      = '';
		fieldType = 'text';
		sequence  = 0;
		align     = 'left';
	}

	public void dumpModel(String title)
	{
		System.debug('Dump Match_Field model   : ' + title);
		System.debug('  id       : ' + this.id);
		System.debug('  name     : ' + this.name);
		System.debug('  apiName  : ' + this.apiName);
		System.debug('  label    : ' + this.label);
		System.debug('  info     : ' + this.info);
		System.debug('  type     : ' + this.fieldType);
		System.debug('  sequence : ' + this.sequence);
		System.debug('  align    : ' + this.align);
	}
}