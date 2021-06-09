public inherited sharing class DynamicQueryGenerator {
    
    @AuraEnabled
    public static List<Id> getQueryResultByFieldSet(String theObject, String fieldSetName, List<String> ANDFilters, 
                                                    List<String> ORFilters,String ANDORFilter,String sortField, String sortOrder, String pageSize, String pageNumber) 
    {
        system.debug(pageSize + ' <= pageSize##############pageNumber => ' + pageNumber);
        List<Id> ids = new List<Id>();
        for(sObject obj : getQueryResultServerSide(theObject,GlobalUtility.fieldsByFieldSet(theObject, fieldSetName),ANDFilters,ORFilters,
                                                   ANDORFilter,sortField,sortOrder,pageSize,pageNumber)) {
            ids.add(obj.Id);
        }
        return ids;
    }
    
    @AuraEnabled
    public static List<FieldSetMemberWrapper> geFieldMemberByFieldSet(String theObject, String fieldSetName) {
        List<FieldSetMemberWrapper> FSMW = new List<FieldSetMemberWrapper>();
        for(Schema.FieldSetMember fieldMember : GlobalUtility.readFieldSet(fieldSetName, theObject)) {
            FSMW.add(new FieldSetMemberWrapper(fieldMember.getFieldPath(), fieldMember.getRequired(), fieldMember.getLabel(), 
                                               String.valueOf(fieldMember.getType())));
        }
        return FSMW;
    }
    
    public class FieldSetMemberWrapper{
        @AuraEnabled
        public String apiName{get;set;}
        @AuraEnabled
        public Boolean dbRequried{get;set;}
        @AuraEnabled
        public String labelName{get;set;}
        @AuraEnabled
        public String fieldType{get;set;}
        FieldSetMemberWrapper(String apiName, Boolean dbRequried, String labelName, String fieldType){
            this.apiName = apiName; this.dbRequried = dbRequried;this.labelName = labelName;this.fieldType = fieldType;
        }
    }
    
    @AuraEnabled
    public static List<sObject> getQueryResult(String theObject, List<String> theFields, List<String> ANDFilters, 
                                               List<String> ORFilters,String ANDORFilter,String sortField, String sortOrder) 
    {
        return Database.Query(getQueryClientSidePagination(theObject,theFields,ANDFilters,ORFilters,ANDORFilter,sortField,sortOrder));
    }
    
    @AuraEnabled
    public static List<sObject> getQueryResultServerSide(String theObject, List<String> theFields, List<String> ANDFilters, 
                                               List<String> ORFilters,String ANDORFilter,String sortField, String sortOrder, String pageSize, String pageNumber) 
    {
        return Database.Query(getQueryServerSidePagination(theObject,theFields,ANDFilters,ORFilters,ANDORFilter,sortField,sortOrder,pageSize,pageNumber));
    }
    
    @AuraEnabled
    public static String updateRecords(List<Sobject> editedValues){
        try{
            update editedValues;
            return 'Success';
        } catch(Exception e){
            return 'Error'+e.getMessage();
        }
    }

    @AuraEnabled
    public static String getQueryServerSidePagination(String theObject, List<String> theFields, List<String> ANDFilters,
                                                       List<String> ORFilters,String ANDORFilter,String sortField, String sortOrder, String pageSize, String pageNumber) 
    {
        String finalQuery = getQueryClientSidePagination(theObject, theFields, ANDFilters,ORFilters,ANDORFilter,sortField,sortOrder);
        Integer ps = Integer.valueOf(pageSize);
        Integer pn = Integer.valueOf(pageNumber)-1;
        finalQuery = finalQuery + ' LIMIT ' + ps + ' OFFSET ' + ps*pn;
        system.debug('getQueryServerSidePagination final query*********' + finalQuery);
        return finalQuery;
    }
    
    @AuraEnabled
    public static String getQueryClientSidePagination(String theObject, List<String> theFields, List<String> ANDFilters,
                                                       List<String> ORFilters,String ANDORFilter,String sortField, String sortOrder) 
    {
        Set<String> uniqueFields = new Set<String>();
        uniqueFields.add('Id');
        uniqueFields.addAll(theFields);  
        String theQuery = 'SELECT ' + String.join(new List<String>(uniqueFields), ',');
        theQuery += ' FROM ' + theObject ;
        if(!ANDFilters.isEmpty() || !ORFilters.isEmpty()){
            theQuery += ' WHERE ';
        }
        if(!ANDFilters.isEmpty()){
            Boolean firstFilter = true;
            for (String filter : ANDFilters) { 
                if(firstFilter){
                    theQuery+= '( ';
                }
                filter = filter.trim();
                filter = filter.replaceAll('(\\s+)', ' ');  
                theQuery +=  filter + ' AND '  ; 
                firstFilter = false;
            }
            theQuery = theQuery.removeEnd(' AND ');
            theQuery +=  ' ) ';
        }
        
        if(!ANDFilters.isEmpty() && !ORFilters.isEmpty()){
            theQuery += ' '+ANDORFilter+' ';
        }
        
        if(!ORFilters.isEmpty()){
            Boolean firstFilter = true;
            
            for (String filter : ORFilters) { //loop through the filters
                if(firstFilter){
                    theQuery+= '( ';
                }
                filter = filter.trim();
                filter = filter.replaceAll('(\\s+)', ' ');  //remove white spaces
                theQuery +=  filter + ' OR '  ;
                firstFilter = false;
            }
            theQuery = theQuery.removeEnd(' OR ');
            theQuery +=  ' ) ';
        }
        
        if(!String.isEmpty(sortField)) {
            theQuery += ' ORDER BY ' + sortField;
            if(!String.isEmpty(sortOrder)) {
                theQuery += ' ' + sortOrder;
            }
        }
        system.debug('final query*********'+theQuery);
        return theQuery;
    }
}