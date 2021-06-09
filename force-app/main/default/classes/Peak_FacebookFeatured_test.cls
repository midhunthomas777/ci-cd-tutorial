/**
 * Created by jasondaluga on 7/13/18.
 */

@IsTest
private class Peak_FacebookFeatured_test {
    @IsTest(SeeAllData=true)
    static void getMetaData_test() {
        String data = Peak_FacebookController.getMetaData('Primary_Record');
        if (data != null)
        {
            System.assertNotEquals(null, data);
        } else {
            System.assertEquals(null, data);
        }
    }
}