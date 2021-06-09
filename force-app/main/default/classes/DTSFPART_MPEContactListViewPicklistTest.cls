@isTest
public class DTSFPART_MPEContactListViewPicklistTest {

    @isTest
    private static void getDefaultValueTest() {
        Test.startTest();
        DTSFPART_MPEContactListViewPicklist customListViewPicklist = new DTSFPART_MPEContactListViewPicklist();
        VisualEditor.DataRow rowData = customListViewPicklist.getDefaultValue();
        Test.stopTest();

        System.assertNotEquals(null, rowData);
    }

    @isTest
    private static void getValuesTest() {
        Test.startTest();
        DTSFPART_MPEContactListViewPicklist customListViewPicklist = new DTSFPART_MPEContactListViewPicklist();
        VisualEditor.DynamicPickListRows picklistListRow = customListViewPicklist.getValues();
        Test.stopTest();

        System.assertNotEquals(null, picklistListRow);
    }
}