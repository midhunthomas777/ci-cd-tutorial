@isTest
public with sharing class DTSFPART_BuilderTagPicklist_Test {
    @isTest
    static void getDefaultValue() {
        DTSFPART_BuilderTagPicklist tagPicklist = new DTSFPART_BuilderTagPicklist();
        VisualEditor.DataRow row = tagPicklist.getDefaultValue();
        System.assertEquals('', row.getValue(), 'Default value was not an empty value.');
    }

    @isTest
    static void getValues() {
        Schema.DescribeFieldResult fieldResult = Contact.Tag__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        Set<String> tags = new Set<String>();
        for (Schema.PicklistEntry value : ple) {
            tags.add(value.getValue());
        }
        
        DTSFPART_BuilderTagPicklist tagPicklist = new DTSFPART_BuilderTagPicklist();
        VisualEditor.DynamicPickListRows picklistValues = tagPicklist.getValues();
        List<VisualEditor.DataRow> rows = picklistValues.getDataRows();
        Set<String> picklistTags = new Set<String>();
        for (VisualEditor.DataRow row : rows) {
            picklistTags.add(String.valueOf(row.getValue()));
        }

        System.assertEquals(true, picklistTags.containsAll(tags), 'Picklist sizes doesn\'t contain all elements.');
    }

}