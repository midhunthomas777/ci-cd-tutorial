/**
 * Copyright 2020 Motorola Solutions Inc. All rights reserved.
 */

@IsTest
private class MotoCustomerAuthBannerControllerTest {
    @IsTest
    public static void testGetUserDetails() {
        Map<String,Object> userInfo = MotoCustomerAuthBannerController.getAccountName();
        System.assertNotEquals(null, userInfo);
    }
}