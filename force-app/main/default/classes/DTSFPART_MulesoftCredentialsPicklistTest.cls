@isTest
public class DTSFPART_MulesoftCredentialsPicklistTest {
    
    @isTest
    private static void getDefaultValueTest() {
        Test.startTest();
        DTSFPART_MulesoftCredentialsPicklist customListViewPicklist = new DTSFPART_MulesoftCredentialsPicklist();
        VisualEditor.DataRow rowData = customListViewPicklist.getDefaultValue();
        Test.stopTest();

        System.assertNotEquals(null, rowData);
    }

    @isTest
    private static void getValuesTest() {
        Test.startTest();
        DTSFPART_MulesoftCredentialsPicklist customListViewPicklist = new DTSFPART_MulesoftCredentialsPicklist();
        VisualEditor.DynamicPickListRows picklistListRow = customListViewPicklist.getValues();
        Test.stopTest();

        System.assertNotEquals(null, picklistListRow);
    }
}