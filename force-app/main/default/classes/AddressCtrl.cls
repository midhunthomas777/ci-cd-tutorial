public class AddressCtrl {
    
    public class AddressDef{
        @AuraEnabled public string label {get;set;}
        @AuraEnabled public string value {get;set;}
        public AddressDef(String label,String value){
            this.label=label;
            this.value=value;
        }
    } 
    
    @AuraEnabled
    public static List<AddressDef> fetchCountry(){
        List<AddressDef> lstAddressDef = new List<AddressDef>();
        map<String,String> country = fetchPicklistsByObjectAndField('Account', 'BillingCountryCode');
        for(String cntry : country.keySet()){
            lstAddressDef.add(new AddressDef (country.get(cntry),cntry));
        }
        return lstAddressDef;
    }
    @AuraEnabled
    public static  List<AddressDef> fetchStates(String country, Boolean isStandardAddress){
        return getFieldDependencies('Account', 'BillingCountryCode', 'BillingStateCode',isStandardAddress).get(country);
    }
    public static map<String,String> fetchPicklistsByObjectAndField(String objectName, String fieldName){ 
        map<String,String> pickDef = new map<String,String>();
        List<String> lstPickvals=new List<String>();
        List<String> lstPickvalsLabel=new List<String>();
        Schema.SObjectType targetType = Schema.getGlobalDescribe().get(objectName);
        Sobject Object_name = targetType.newSObject();
        Schema.sObjectType sobject_type = Object_name.getSObjectType();
        Schema.DescribeSObjectResult sobject_describe = sobject_type.getDescribe();
        Map<String, Schema.SObjectField> field_map = sobject_describe.fields.getMap();
        List<Schema.PicklistEntry> pick_list_values = field_map.get(fieldName).getDescribe().getPickListValues();
        for (Schema.PicklistEntry a : pick_list_values) {
            if(a.isActive()) {
                pickDef.put(a.getValue(), a.getLabel()) ;         
                lstPickvals.add(a.getValue());  
                lstPickvalsLabel.add(a.getLabel());
            }
        }
        //return lstPickvals;
        return pickDef;
    }
    
    
    public static Map<String, List<AddressDef>> getFieldDependencies(String objectName, String controllingField, String dependentField ,Boolean isStandardAddress)
    {
        Map<String, List<AddressDef>> controllingInfoMap = new Map<String, List<AddressDef>>();
        Schema.SObjectType objType = Schema.getGlobalDescribe().get(objectName);
        
        Schema.DescribeSObjectResult describeResult = objType.getDescribe();
        Schema.DescribeFieldResult controllingFieldInfo = describeResult.fields.getMap().get(controllingField).getDescribe();
        Schema.DescribeFieldResult dependentFieldInfo = describeResult.fields.getMap().get(dependentField).getDescribe();
        
        List<Schema.PicklistEntry> controllingValues = controllingFieldInfo.getPicklistValues();
        List<Schema.PicklistEntry> dependentValues = dependentFieldInfo.getPicklistValues();
        
        for(Schema.PicklistEntry currControllingValue : controllingValues)
        {
            System.debug('ControllingField: Label:' + currControllingValue.getLabel());
            if(isStandardAddress){
                controllingInfoMap.put(currControllingValue.getValue(), new List<AddressDef>());                
            }else{
                controllingInfoMap.put(currControllingValue.getLabel(), new List<AddressDef>());
            }
        }
        
        for(Schema.PicklistEntry currDependentValue : dependentValues)
        {
            String jsonString = JSON.serialize(currDependentValue);
            
            MyPickListInfo info = (MyPickListInfo) JSON.deserialize(jsonString, MyPickListInfo.class);
            
            String hexString = EncodingUtil.convertToHex(EncodingUtil.base64Decode(info.validFor)).toUpperCase();
            
            System.debug('DependentField: Label:' + currDependentValue.getLabel() + ' ValidForInHex:' + hexString + ' JsonString:' + jsonString);
            
            Integer baseCount = 0;
            
            for(Integer curr : hexString.getChars())
            {
                Integer val = 0;
                
                if(curr >= 65)
                {
                    val = curr - 65 + 10;
                }
                else
                {
                    val = curr - 48;
                }
                
                if((val & 8) == 8)
                {
                    List<AddressDef> lstAddressDef = new List<AddressDef>();
                    if(isStandardAddress){
                    lstAddressDef.add(new AddressDef (currDependentValue.getLabel(),currDependentValue.getValue()));
                    controllingInfoMap.get(controllingValues[baseCount + 0].getValue()).addAll(lstAddressDef);
                    }else{
                        lstAddressDef.add(new AddressDef (currDependentValue.getLabel(),currDependentValue.getLabel()));
                        controllingInfoMap.get(controllingValues[baseCount + 0].getLabel()).addAll(lstAddressDef);
                    }
                }
                if((val & 4) == 4)
                {
                    List<AddressDef> lstAddressDef = new List<AddressDef>();
                    if(isStandardAddress){
                    lstAddressDef.add(new AddressDef (currDependentValue.getLabel(),currDependentValue.getValue()));
                    controllingInfoMap.get(controllingValues[baseCount + 1].getValue()).addAll(lstAddressDef);
                    }else{
                        lstAddressDef.add(new AddressDef (currDependentValue.getLabel(),currDependentValue.getLabel()));
                        controllingInfoMap.get(controllingValues[baseCount + 1].getLabel()).addAll(lstAddressDef);
                    }
                }
                if((val & 2) == 2)
                {
                    List<AddressDef> lstAddressDef = new List<AddressDef>();
                    if(isStandardAddress){
                    lstAddressDef.add(new AddressDef (currDependentValue.getLabel(),currDependentValue.getValue()));
                    controllingInfoMap.get(controllingValues[baseCount + 2].getValue()).addAll(lstAddressDef);
                    }else{
                        lstAddressDef.add(new AddressDef (currDependentValue.getLabel(),currDependentValue.getLabel()));
                        controllingInfoMap.get(controllingValues[baseCount + 2].getLabel()).addAll(lstAddressDef);
                    }
                }
                if((val & 1) == 1)
                {
                    List<AddressDef> lstAddressDef = new List<AddressDef>();
                    if(isStandardAddress){
                    lstAddressDef.add(new AddressDef (currDependentValue.getLabel(),currDependentValue.getValue()));
                    controllingInfoMap.get(controllingValues[baseCount + 3].getValue()).addAll(lstAddressDef);
                    }else{
                        lstAddressDef.add(new AddressDef (currDependentValue.getLabel(),currDependentValue.getLabel()));
                        controllingInfoMap.get(controllingValues[baseCount + 3].getLabel()).addAll(lstAddressDef);
                    }                    
                }
                
                baseCount += 4;
            }            
        } 
        System.debug('ControllingInfoMap With Val: ' + controllingInfoMap.get('US'));
        System.debug('ControllingInfoMap With Label: ' + controllingInfoMap.get('United States'));
        return controllingInfoMap;
    }
    public class MyPickListInfo{
        public String validFor;
    }
}