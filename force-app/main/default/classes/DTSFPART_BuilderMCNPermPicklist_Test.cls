@isTest
public with sharing class DTSFPART_BuilderMCNPermPicklist_Test {
    @isTest
    static void getDefaultValue() {
        DTSFPART_BuilderMCNPermissionPicklist mcnPermissionPicklist = new DTSFPART_BuilderMCNPermissionPicklist();
        VisualEditor.DataRow row = mcnPermissionPicklist.getDefaultValue();
        System.assertEquals('', row.getValue(), 'Default value was not an empty value.');
    }

    @isTest
    static void getValues() {
        Schema.DescribeFieldResult fieldResult = Contact.Contact_MCN_Permissions__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        Set<String> mcnPermissions = new Set<String>();
        for (Schema.PicklistEntry value : ple) {
            mcnPermissions.add(value.getValue());
        }
        
        DTSFPART_BuilderMCNPermissionPicklist mcnPermissionPicklist = new DTSFPART_BuilderMCNPermissionPicklist();
        VisualEditor.DynamicPickListRows picklistValues = mcnPermissionPicklist.getValues();
        List<VisualEditor.DataRow> rows = picklistValues.getDataRows();
        Set<String> picklistPermissions = new Set<String>();
        for (VisualEditor.DataRow row : rows) {
            picklistPermissions.add(String.valueOf(row.getValue()));
        }

        System.assertEquals(true, picklistPermissions.containsAll(mcnPermissions), 'Picklist sizes doesn\'t contain all elements.');
    }

}