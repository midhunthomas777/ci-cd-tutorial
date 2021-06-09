@isTest
public class DTSFPART_CaseSupportCategoryCtrlTest {
    @isTest
    private static void getSupportCategoriesTest() {
        Test.startTest();
        List<Case_Support_Category__mdt> supportCategories = DTSFPART_CaseSupportCategoryController.getSupportCategories();
        Test.stopTest();

        System.assertNotEquals(null, supportCategories);
    }
}