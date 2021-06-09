@isTest
public class MRCommCalcConsolidatedBuyCtlrTest {
@isTest
    public static void mrCommissionMCNDetailsTest(){
        TestDataSetUpUtils.insertCustomSettings();
        String mncNumber=string.valueof(integer.valueof(math.random()*1000000000)*100);
        User partneruser= TestDataSetUpUtils.createPortalUser();
        system.runAs(partneruser){
            MRCommCalcConsolidatedBuyCtlr.fetchSitePrefix();
            MRCommCalcConsolidatedBuyCtlr.fetchAccountDetails(mncNumber);

        
        }
     }
}