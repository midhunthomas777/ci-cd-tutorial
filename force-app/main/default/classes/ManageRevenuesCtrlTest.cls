@isTest
public class ManageRevenuesCtrlTest {
    @isTest
    public static void ManageRevenuesCtrl(){
        TestDataSetUpUtils.insertCustomSettings();      
        Run_Rate_Definition__c runRate=new Run_Rate_Definition__c();
        runrate.Year__c='2021';        
        runrate.Region__c='AP';
        runrate.Booking_Owner__c=userInfo.getUserId();       
        runRate.Territory__c='AP';
        runRate.Frequency__c='Monthly';
        runRate.Run_Rate_Product_Group__c='APAC ANZ Channel';
        runRate.Country_of_Destination__c='Bhutan';
        test.startTest();
        insert runRate;  
        test.stopTest();
        ManageRevenuesCtrl.getProgress('');
        ManageRevenuesCtrl.getProductFamilies(runRate.Id);
        ManageRevenuesCtrl.getRunRateRevenue(runRate.Id);
        ManageRevenuesCtrl.getBatchStatus(runRate.Id);
        ManageRevenuesCtrl.getBatchStatus('');
        ManageRevenuesCtrl.updateRRDBatchStatus(runRate.Id,'test');        
        ManageRevenuesCtrl.updateRRDBatchStatus(null,null);   
        List<OpportunitylineItem> oppLineItems = [SELECT id ,Run_Rate_Revenue_Amount__c from OpportunitylineItem limit 10];
        ManageRevenuesCtrl.updateRevenueWithPrice(oppLineItems);
  }   
}