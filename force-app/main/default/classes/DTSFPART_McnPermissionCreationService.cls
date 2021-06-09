public without sharing class DTSFPART_McnPermissionCreationService {

    public static void create(DTSFPART_McnPermissionServiceWrapper wrapper) {
        wrapper.prepareAllToRecalculate();
        Map<Id, DTSFPART_AccountPermissionsWrapper> permissionForParent = wrapper.getPreparedPermissionsForParent();
        Map<Id, DTSFPART_AccountPermissionsWrapper> permissionForMR = wrapper.getPreparedPermissionsForMR();

        List<MCN_Permission__c> newMcnPermissions = new List<MCN_Permission__c>();
        newMcnPermissions.addAll(createParentPermissions(wrapper));
        newMcnPermissions.addAll(createMRPermissions(wrapper));
        
        try {
            insert newMcnPermissions;
            // if (!Test.isRunningTest()) {
            //     System.enqueueJob(
            //         new DTSFPART_UpdateContactMCNPermissions(
            //             new Map<Id, MCN_Permission__c>(newMcnPermissions),
            //             new Map<Id, MCN_Permission__c>(),
            //             new DTSFPART_ContactMcnPermRemovalReference()
            //         )
            //     );
            // }
        } catch(Exception e){
            LogError.saveExceptionPEvent('DTSFPART_McnPermissionCreationService', '', 'newMcnPermissions: ' + newMcnPermissions, e);
        }
    }

    private static List<MCN_Permission__c> createParentPermissions(DTSFPART_McnPermissionServiceWrapper wrapper){
        List<MCN_Permission__c> newMcnPermissions = new List<MCN_Permission__c>();
        Map<Id, DTSFPART_AccountPermissionsWrapper> permissionForParent = wrapper.getPreparedPermissionsForParent();

        for(Id accountId: wrapper.recalculateByParent.keySet()){
            for(Id mcnId: wrapper.recalculateByParent.get(accountId)){
                newMcnPermissions.add(new MCN_Permission__c(
                    MCN_Account__c = mcnId,
                    MCN_Permissions__c = permissionForParent.get(accountId).mcnPermissions,
                    Contact_MCN_Permissions__c = permissionForParent.get(accountId).contactMCNPermissions,
                    Customer_OR_Partner_Account__c = accountId
                ));
            }
        }

        return newMcnPermissions;
    }

    private static List<MCN_Permission__c> createMRPermissions(DTSFPART_McnPermissionServiceWrapper wrapper){
        List<MCN_Permission__c> newMcnPermissions = new List<MCN_Permission__c>();
        Map<Id, DTSFPART_AccountPermissionsWrapper> permissionForMR = wrapper.getPreparedPermissionsForMR();

        for(Id accountId: wrapper.recalculateByMR.keySet()){
            for(Id mcnId: wrapper.recalculateByMR.get(accountId)){
                newMcnPermissions.add(new MCN_Permission__c(
                    MCN_Account__c = mcnId,
                    MCN_Permissions__c = permissionForMR.get(accountId).mcnPermissions,
                    Contact_MCN_Permissions__c = permissionForMR.get(accountId).contactMCNPermissions,
                    Customer_OR_Partner_Account__c = accountId
                ));
            }
        }

        return newMcnPermissions;
    }
}