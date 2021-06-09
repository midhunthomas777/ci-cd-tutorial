public class BRRUpdateCtrl {
    @AuraEnabled
    public static List<String> getRegions(String objectName, String fieldName){
       return GlobalUtility.fetchPicklistsByObjectAndField(objectName,fieldName);
    }
    
    @AuraEnabled
    public static List<String> getRegionTerritory(String region,String objectName, String controllingField, String dependentField ,Boolean isStandardAddress){
       	Map<String, List<AddressCtrl.AddressDef>> mapTerritory = AddressCtrl.getFieldDependencies(objectName, controllingField, dependentField , isStandardAddress);
        List<String> lstRegionTerritory = new List<String>();
        for(AddressCtrl.AddressDef addDef : mapTerritory.get(region)){
            lstRegionTerritory.add(addDef.value);
        }
        return lstRegionTerritory;
    }
}