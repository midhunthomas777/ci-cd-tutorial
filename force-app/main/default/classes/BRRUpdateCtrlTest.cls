@isTest
public class BRRUpdateCtrlTest {
@isTest
    public static void revenueTest(){
        Test.startTest();
        BRRUpdateCtrl.getRegions('Opportunity', 'Region__c');
        Test.stopTest();
        BRRUpdateCtrl.getRegionTerritory('NA', 'Opportunity','Region__c','Territory__c',false);
    }
}