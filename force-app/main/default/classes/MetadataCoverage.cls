public class MetadataCoverage {
@testvisible static private Map<String, List<SObject>> MetadatacoverageRecordsMap = new Map<String, List<SObject>>();
    
    public List<SObject> getMetadatacoverageRecords(String query){
        if(!MetadatacoverageRecordsMap.containsKey(query))
        {
            MetadatacoverageRecordsMap.put(query, Database.query(query));
        }
        return MetadatacoverageRecordsMap.get(query);
        
    }
    
    
}