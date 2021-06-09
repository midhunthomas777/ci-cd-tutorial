/*
 * Copyright (c) 2018  7Summits Inc.
 */

/**
 * Created by francois korb on 4/11/18.
 */

public with sharing class Match_List
{

	@AuraEnabled
	public List<Match_Model> items { get; set; }

	@AuraEnabled
	public Decimal processed { get; set; }

	@AuraEnabled
	public Decimal paginationLimit { get; set; }

	@AuraEnabled
	public Object paginationValue { get; set;}

	@AuraEnabled
	public Decimal total { get; set; }

	@AuraEnabled
	public Decimal pageCount { get; set; }

	@AuraEnabled
	public Decimal pageSize { get; set; }

	@AuraEnabled
	public Decimal pageCurrent { get; set; }

	@AuraEnabled
	public Boolean pageHasNext { get; set; }

	@AuraEnabled
	public Boolean pageHasPrevious { get; set; }

	public Match_List()
	{
		this.items           = new List<Match_Model>();
		this.total           = 0;
		this.processed       = 0;
		this.pageCount       = 0;
		this.pageSize        = 0;
		this.pageCurrent     = 0;
		this.paginationLimit = 0;
		this.paginationValue = null;
		this.pageHasNext     = false;
		this.pageHasPrevious = false;
	}

	public Match_Model containsItem(String itemId)
	{
		Match_Model found = null;

		for (Match_Model item : this.items)
		{
			if (item.id == itemId)
			{
				found = item;
				break;
			}
		}

		return found;
	}

	public void criticalOnly()
	{
		List<Match_Model> keep = new List<Match_Model>();

		for (Match_Model item : this.items)
		{
			if (item.critical)
			{
				keep.add(item);
			}
		}

		this.items = keep;
	}

	public void ratingRange(String rangeString)
	{
		List<Match_Model> keep  = new List<Match_Model>();
		List<Decimal>     range = Match_Util.getDecimalValues(rangeString);

		for (Match_Model item : this.items)
		{
			if (range.contains((Decimal)item.rating))
			{
				keep.add(item);
			}
		}

		this.items = keep;
	}

	public void matchRange(String rangeString)
	{
		List<Match_Model> keep  = new List<Match_Model>();
		List<Decimal>     range = Match_Util.getRangeValues(rangeString);

		// convert to percentage
		Decimal minValue = range[0] / 100;
		Decimal maxValue = range[1] / 100;

		for (Match_Model item : this.items)
		{
			if (item.match >= minValue && item.match <= maxValue)
			{
				keep.add(item);
			}
		}

		this.items = keep;
	}

	public void limitDataSet(Decimal pageSize, Decimal currentPage)
	{
		List<Match_Model> keep = new List<Match_Model>();
		Integer startPosition  = (Integer)(((currentPage > 1 ? currentPage -1 : 0)) * pageSize);
		Integer endPosition    = Math.min((Integer)(startPosition + pageSize), items.size());

		System.debug('limitDataSet -- pageSize:'+ pageSize + ', pageCurrent:' + currentPage + ' start:' + startPosition + ', end:' + endPosition);
		for (Integer position = startPosition; position < endPosition; position++)
		{
			keep.add(this.items[position]);
		}


		this.items = keep;
	}

	public void dumpModel(String title, Boolean depth)
	{
		System.debug('Dump Match_List: ' + title);
		System.debug('  model.processed    : ' + this.processed);
		System.debug('  model.total        : ' + this.total);
		System.debug('  model.pageCount    : ' + this.pageCount);
		System.debug('  model.pageSize     : ' + this.pageSize);
		System.debug('  model.pageCurrent  : ' + this.pageCurrent);
		System.debug('  model.hasNext      : ' + this.pageHasNext);
		System.debug('  model.hasPrevious  : ' + this.pageHasPrevious);
		System.debug('  model.items        : ' + this.items.size());
		System.debug('  paging limit       : ' + this.paginationLimit);
		System.debug('  paging value       : ' + this.paginationValue);

		if (depth)
		{

			if (items.size() > 0)
			{
				Integer count = 1;

				for (Match_Model item : this.items)
				{
					item.dumpModel('item ' + count,depth);
					count += 1;
				}
			}
		}
	}
}