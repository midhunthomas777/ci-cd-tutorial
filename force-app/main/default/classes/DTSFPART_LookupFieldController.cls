public with sharing class DTSFPART_LookupFieldController {
	@AuraEnabled(cacheable=true)
	public static List<LookupSearchResult> searchRecords(
			String objectName,
			String titleField,
			String subtitleField,
			String searchKey,
			String selectedId,
			String icon
	) {
		try {
			List<LookupSearchResult> results = new List<LookupSearchResult>();
			String searchKeyword = String.escapeSingleQuotes(searchKey) + '*';
			String returningQuery = String.escapeSingleQuotes(objectName)
					+ ' ( Id, ' + String.escapeSingleQuotes(titleField)
					+ ', ' + String.escapeSingleQuotes(subtitleField)
					+ ' WHERE Id != :selectedId)';
			String query = 'FIND :searchKeyword IN ALL FIELDS RETURNING ' + returningQuery + ' LIMIT 2000';
			List<List<SObject>> sobjectList = Search.query(query);
			SObject[] records = (List<SObject>) sobjectList[0];
			for (SObject record : records) {
				results.add(
						new LookupSearchResult(
								record.Id,
								objectName,
								icon,
								(String) record.get(titleField),
								(String) record.get(subtitleField)
						)
				);
			}
			return results;
		} catch (Exception e) {
			throw new AuraHandledException(e.getMessage());
		}
	}

	@AuraEnabled(Cacheable=true)
	public static List<LookupSearchResult> getRecentlyViewed(String objectName, String titleField, String subtitleField, String icon) {
		try {
			List<LookupSearchResult> results = new List<LookupSearchResult>();
			String networkId = Network.getNetworkId();
			String query = 'SELECT Id, Name, Type'
					+ ' FROM RecentlyViewed WHERE Type = \'' + String.escapeSingleQuotes(objectName) + '\''
					+ ' AND NetworkId = :networkId'
					+ ' ORDER BY LastViewedDate DESC LIMIT 5';
			for (SObject recentRecord : Database.query(query)) {
				results.add(
						new LookupSearchResult(
								recentRecord.Id,
								objectName,
								icon,
								(String) recentRecord.get('Name'),
								(String) recentRecord.get('Type')
						)
				);
			}
			return results;
		} catch (Exception e) {
			throw new AuraHandledException(e.getMessage());
		}
	}
}