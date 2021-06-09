public class ChildRecordsByParentCtrl {
    @AuraEnabled
    public static List<Sobject> getFieldValues(List<String> fieldNames, String objectApiName, String recordId , String parentFieldAPI){
        String fieldName = String.join(fieldNames,','); 
        system.debug('fieldName'+fieldName);
        //String query1 = 'SELECT ' +  fieldName + ' FROM Account WHERE Id = ' + recordId;
        //String query = 'SELECT Id,' + fieldName + ' FROM '  + objectApiName + ' WHERE ' +  parentFieldAPI+  '=:' + 'recordId' ;
        String query = 'SELECT Id,' + fieldName + ' FROM '  + objectApiName + ' WHERE ' +  parentFieldAPI+  '=:' + 'recordId' + ' AND ERP_Active__c = true';
        system.debug('query'+query);
        //  system.debug('query1'+query1);
        return Database.query(query);
    }
    
    
    public static List<sObject> queryObjects(String theObject, List<String> theFields, List<String> theFilters, String sortField, String sortOrder) {
          Set<String> uniqueFields = new Set<String>();
          uniqueFields.add('Id');
          uniqueFields.addAll(theFields);  
          String theQuery = 'SELECT ' + string.join(new List<String>(uniqueFields), ',');
          theQuery += ' FROM ' + theObject;
          Boolean firstFilter = true;
          for (String filter : theFilters) { //loop through the filters
               String clauseToUse = (firstFilter) ? ' WHERE ' : ' AND '; //get the right clause
               filter = filter.trim();
               filter = filter.replaceAll('(\\s+)', ' ');  //remove white spaces
               theQuery += clauseToUse + filter;  //add the filter to the query
               firstFilter = false;  //changes the filter clause
          }
          if(!String.isEmpty(sortField)) {
               theQuery += ' ORDER BY ' + sortField;
               if(!String.isEmpty(sortOrder)) {
                    theQuery += ' ' + sortOrder;
               }
          }
          String theQueryResult = string.escapeSingleQuotes(theQuery);
        //escapes the string
         
          system.debug('result*********'+theQuery);
        return database.query(theQuery);
     }
}