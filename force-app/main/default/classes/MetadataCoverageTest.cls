@isTest public class MetadataCoverageTest {
    @istest static  void testMetadataCoverageMethod(){
        
        List<FedTerritories__mdt> fedterr;
        Test.startTest();
        fedterr= new MetadataCoverage().getMetadatacoverageRecords('SELECT MasterLabel,DeveloperName FROM FedTerritories__mdt');
        Test.stopTest();  
      
    }
    public static void setMetadata(String query, List<SObject> records){
        MetadataCoverage.MetadatacoverageRecordsMap.put(query,records);
        
    }
    
    
    
}