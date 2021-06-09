/**
 * Copyright 2020 Motorola Solutions Inc. All rights reserved.
 */

public with sharing class MotoCustomerAuthBannerController {
    @AuraEnabled
    public static Map<String,Object> getAccountName() {
        Map<String,Object> data = new Map<String,Object>{'accountName'=>' '};

        User currentUser = [SELECT Contact.Account.Name FROM User WHERE Id = : UserInfo.getUserId()];
        if (currentUser.Contact.Account.Name != null) { data.put('accountName', currentUser.Contact.Account.Name); }

        return data;
    }
}