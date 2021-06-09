@isTest
public class DTSFPART_CaseListViewPicklistTest {
    
    @isTest
    private static void getDefaultValueTest() {
        Test.startTest();
        DTSFPART_CaseListViewPicklist customListViewPicklist = new DTSFPART_CaseListViewPicklist();
        VisualEditor.DataRow rowData = customListViewPicklist.getDefaultValue();
        Test.stopTest();

        System.assertNotEquals(null, rowData);
    }

    @isTest
    private static void getValuesTest() {
        Test.startTest();
        DTSFPART_CaseListViewPicklist customListViewPicklist = new DTSFPART_CaseListViewPicklist();
        VisualEditor.DynamicPickListRows picklistListRow = customListViewPicklist.getValues();
        Test.stopTest();

        System.assertNotEquals(null, picklistListRow);
    }
}