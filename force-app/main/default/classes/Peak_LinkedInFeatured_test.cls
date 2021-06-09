/**
 * Created by jasondaluga on 7/13/18.
 */

@IsTest
private class Peak_LinkedInFeatured_test {
    @IsTest(SeeAllData=true)
    static void test_getMetaData() {
        String data = Peak_LinkedInController.getMetaData('Primary_Record');
        System.assertNotEquals(null, data);
    }
}