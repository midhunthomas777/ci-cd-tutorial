/**
 * Created by jasondaluga on 7/10/18.
 */

public with sharing class Peak_FacebookController {

    @AuraEnabled
    public static String getMetaData(String recordLabel){
        System.debug(recordLabel);
        X7Summits_Social_Component_Settings__mdt setting = [SELECT Facebook_Featured_Posts__c FROM X7Summits_Social_Component_Settings__mdt WHERE DeveloperName = :recordLabel];
        return setting.Facebook_Featured_Posts__c;
    }
}