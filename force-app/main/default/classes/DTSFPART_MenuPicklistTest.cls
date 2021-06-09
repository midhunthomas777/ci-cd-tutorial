@isTest
public class DTSFPART_MenuPicklistTest {

    @isTest
    private static void getDefaultValueTest() {
        Test.startTest();
        DTSFPART_MenuPicklist customListViewPicklist = new DTSFPART_MenuPicklist();
        VisualEditor.DataRow rowData = customListViewPicklist.getDefaultValue();
        Test.stopTest();

        System.assertNotEquals(null, rowData);
    }

    @isTest
    private static void getValuesTest() {
        Test.startTest();
        DTSFPART_MenuPicklist customListViewPicklist = new DTSFPART_MenuPicklist();
        VisualEditor.DynamicPickListRows picklistListRow = customListViewPicklist.getValues();
        Test.stopTest();

        System.assertNotEquals(null, picklistListRow);
    }
}