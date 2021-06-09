@isTest
public class AccountDashboardScheduler_test{

     static testmethod void AccScheduler(){
     
       test.startTest();
        AccountDashboardScheduler m = new AccountDashboardScheduler();
        String str = Datetime.now().addSeconds(10).format('s m H d M ? yyyy');  
        String jobID = system.schedule('Test Feed', str , m);

       test.stopTest();
     }
}