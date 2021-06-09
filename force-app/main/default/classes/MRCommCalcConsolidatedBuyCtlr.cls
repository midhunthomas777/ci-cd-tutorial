public class MRCommCalcConsolidatedBuyCtlr {
    
    @AuraEnabled
    public static CPQUtility.AccountDetailsWrapper fetchAccountDetails(String motoNum){
        return CPQUtility.fetchAccDetailsForMSILED(motoNum);
    }
    @AuraEnabled
    public static String fetchSitePrefix(){
        return CPQUtility.fetchSitePrefix();
    }

}