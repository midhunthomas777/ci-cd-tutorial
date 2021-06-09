/**
 * Created by francois korb on 3/20/18.
 */

@IsTest
private class Match_Settings_Test
{
	@IsTest
	static void testMatchSettings()
	{
		Match_Settings settings = new Match_Settings();
		System.assertNotEquals(null, settings);

		Match_Settings_Model invalidSetting = settings.getSettings('noname');
		System.assertEquals(null, invalidSetting);

		Match_Settings_Model testModel = settings.getSettings(Match_TestConstants.TestScenarios[0]);
		System.assertNotEquals(null, testModel);
		testModel.dumpModel('testMatchSettings', true);
	}

	@IsTest
	static void testMatchSettingsModel()
	{
		Match_Settings_Model testModel = new Match_Settings_Model();
		System.assertNotEquals(null, testModel);
	}

	@IsTest
	static void testMetaDataBuildQuery()
	{
		String query = Match_Util_Metadata.buildQuery('Match_Field__mdt', '');
		System.debug('Match_Field__mdt query: ' + query);
		System.assert(query.length() > 0);

		query = Match_Util_Metadata.buildQuery('Match_Object__mdt', '');
		System.debug('Match_Object__mdt query: ' + query);
		System.assert(query.length() > 0);

		query = Match_Util_Metadata.buildQuery('Match_Attribute_Type__mdt', '');
		System.debug('Match_Object__mdt query: ' + query);
		System.assert(query.length() > 0);

		query = Match_Util_Metadata.buildQuery('Match_Filter_Set__mdt', '');
		System.debug('Match_Filter_Set__mdt query: ' + query);
		System.assert(query.length() > 0);

		query = Match_Util_Metadata.buildQuery('Match_Filter__mdt', '');
		System.debug('Match_Filter__mdt query: ' + query);
		System.assert(query.length() > 0);
	}

	@IsTest
	static void testMetadataBuildSubQuery()
	{
		String query = Match_Util_Metadata.buildQuery('Match_Field__mdt', '');

		List<String> subQueryParts = new List<String>();

		for (Integer i = 1; i <= 5; i++)
		{
			String subQuery = Match_Util_Metadata.buildSubQuery('Field_'+ i + '__r', query);
			System.debug('Field sub query: ' + subQuery);
			System.assert(subQuery.length() > 0);
			subQueryParts.add(subQuery);
		}

		query = Match_Util_Metadata.buildQuery('Match_Object__mdt', String.join(subQueryParts, ','));
		System.debug('Match_Object__mdt query: ' + query);
		System.assert(query.length() > 0);
	}
}