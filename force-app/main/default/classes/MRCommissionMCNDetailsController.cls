public  without sharing class MRCommissionMCNDetailsController {
    @AuraEnabled
    public static void deleteMRCalculator(String recordId){
        system.debug('recordId is==='+recordId);
        MR_Commission_Calculator__c mrCalc= new MR_Commission_Calculator__c();
        mrCalc.Id=recordId;
        delete mrCalc;
    }
}