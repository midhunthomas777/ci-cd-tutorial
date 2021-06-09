public without sharing class DTSFPART_McnPermissionRemovalService {
    @Future
    public static void remove(Set<Id> removeAllMcnPermissions, Set<Id> customerOrPartnerAccounts, Set<Id> mcnAccountsToBeCleaned) {
        try {
            List<MCN_Permission__c> mcns = [
                SELECT Id, Customer_OR_Partner_Account__r.Name
                FROM MCN_Permission__c
                WHERE
                    MCN_Account__c IN :removeAllMcnPermissions
                    OR (MCN_Account__c IN :mcnAccountsToBeCleaned
                    AND Customer_OR_Partner_Account__c IN :customerOrPartnerAccounts)
            ];

            delete mcns;
        } catch (Exception e) {
            LogError.saveExceptionPEvent('DTSFPART_AccountTriggerHanlder', 'Service: DTSFPART_McnPermissionRemovalService', e.getMessage(), e);
        }
    }
}