@isTest
public class DTSFPART_CustomListViewPicklistTest {
    
    @isTest
    private static void getDefaultValueTest() {
        Test.startTest();
        DTSFPART_CustomListViewPicklist customListViewPicklist = new DTSFPART_CustomListViewPicklist();
        VisualEditor.DataRow rowData = customListViewPicklist.getDefaultValue();
        Test.stopTest();

        System.assertNotEquals(null, rowData);
    }

    @isTest
    private static void getValuesTest() {
        Test.startTest();
        DTSFPART_CustomListViewPicklist customListViewPicklist = new DTSFPART_CustomListViewPicklist();
        VisualEditor.DynamicPickListRows picklistListRow = customListViewPicklist.getValues();
        Test.stopTest();

        System.assertNotEquals(null, picklistListRow);
    }
}