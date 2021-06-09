//  Copyright (c) 2018. 7Summits Inc.
//  Created by 7Summits - Melinda Grad on 7/25/18.

@isTest
public with sharing class Adventure_ContentObjectHelperTest
{

    @isTest
    public static void testFormatPeakContentObject() {
        // Create a Peak Content Object from helper
        Adventure_ContentObjectHelper contentObjectHelper = new Adventure_ContentObjectHelper();
        Adventure_ContentObject testObject = Adventure_ContentObjectHelper.formatPeakContentObject(null,null);

        // Assert its name property was set
        System.assertEquals(testObject.adventure, null);
    }


}