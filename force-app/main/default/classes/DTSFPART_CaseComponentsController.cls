/**
 * @author		Krzysztof Pintscher
 * @created		2020-10-01
 * @updated		2020-10-27
 * @description	Provide data for custom Case components
 */
public with sharing class DTSFPART_CaseComponentsController {

    @AuraEnabled(cacheable=false) // so it also retrieves newly created cases
    public static List<Case> getCasesWithFields(String fields, String whereClause, String searchString, String orderBy, String limitString){
        try {
            String query = 'SELECT '  + fields + ' FROM Case';
            if (String.isNotBlank(whereClause) || String.isNotBlank(searchString)) {
                query += ' WHERE ';
            }
            if (String.isNotBlank(whereClause)) {
                query += whereClause + ' ';
            }
            if (String.isNotBlank(whereClause) && String.isNotBlank(searchString)) {
                query += ' AND ';
            }   
            if (String.isNotBlank(searchString)) {
                String orStr = '%\' OR ';
                query += ' ( ';
                query += 'CaseNumber LIKE \'' + searchString + orStr;
                query += 'Subject LIKE \'%' + searchString + orStr;
                query += 'Priority LIKE \'%' + searchString + orStr;
                query += 'Status LIKE \'%' + searchString + '%\'';
                query += ' ) ';
            }
            if (String.isNotBlank(orderBy)) {
                query += ' ORDER BY ' + orderBy;
            }
            if (String.isNotBlank(limitString)) {
                query += ' ' + limitString;
            }
            return Database.query(query);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

}