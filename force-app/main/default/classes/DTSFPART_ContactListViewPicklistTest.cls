@isTest
public class DTSFPART_ContactListViewPicklistTest {
    
    @isTest
    private static void getDefaultValueTest() {
        Test.startTest();
        DTSFPART_ContactListViewPicklist customListViewPicklist = new DTSFPART_ContactListViewPicklist();
        VisualEditor.DataRow rowData = customListViewPicklist.getDefaultValue();
        Test.stopTest();

        System.assertNotEquals(null, rowData);
    }

    @isTest
    private static void getValuesTest() {
        Test.startTest();
        DTSFPART_ContactListViewPicklist customListViewPicklist = new DTSFPART_ContactListViewPicklist();
        VisualEditor.DynamicPickListRows picklistListRow = customListViewPicklist.getValues();
        Test.stopTest();

        System.assertNotEquals(null, picklistListRow);
    }
}