/*
	Copyright (c) 2018. 7Summits Inc.
*/

/**
 * Created by francois korb on 3/20/18.
 */

public with sharing class Match_Settings_Model
{
	@AuraEnabled
	public String name, label;

	@AuraEnabled
	public Match_Object source, target;

	@AuraEnabled
	public Match_Field pagingField;

	@AuraEnabled
	public Decimal multiplier;


	public Match_Settings_Model()
	{
		this.name           = '';
		this.multiplier     = 1;
		this.pagingField    = null;
	}

	public void dumpModel(String title, Boolean depth)
	{
		System.debug('Match Settings model: ' + title);
		System.debug('  name            : ' + this.name);
		System.debug('  label           : ' + this.label);
		System.debug('  multiplier      : ' + this.multiplier);

		if (depth)
		{

			if (pagingField != null)
			{
				pagingField.dumpModel('Paging field');
			}

			if (source != null)
			{
				source.dumpModel('Source');
			}

			if (target != null)
			{
				target.dumpModel('Target');
			}
		}
	}
}