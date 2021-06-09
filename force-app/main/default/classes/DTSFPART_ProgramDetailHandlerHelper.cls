public with sharing class DTSFPART_ProgramDetailHandlerHelper {
    public static final String IN_PROGRESS_STATUS = 'In Progress';
    public static final String TRIGGER_STATUS = 'Trigger';

    public static void setEnterprisePermissionStatusToInProgessOnRelatedAccounts(List<Technology_Specialization__c> newProgramDetails) {
        setEnterprisePermissionStatusToInProgessOnRelatedAccounts(newProgramDetails, null);
    }

    public static void setEnterprisePermissionStatusToInProgessOnRelatedAccounts(
        List<Technology_Specialization__c> newProgramDetails,
        Map<Id, Technology_Specialization__c> oldProgramDetails
    ) {
        setEnterprisePermissionStatusOnRelatedAccounts(newProgramDetails, oldProgramDetails, IN_PROGRESS_STATUS);
    }

    public static void setEnterprisePermissionStatusToTriggerOnRelatedAccounts(List<Technology_Specialization__c> newProgramDetails) {
        setEnterprisePermissionStatusToTriggerOnRelatedAccounts(newProgramDetails, null);
    }

    public static void setEnterprisePermissionStatusToTriggerOnRelatedAccounts(
        List<Technology_Specialization__c> newProgramDetails,
        Map<Id, Technology_Specialization__c> oldProgramDetails
    ) {
        setEnterprisePermissionStatusOnRelatedAccounts(newProgramDetails, oldProgramDetails, TRIGGER_STATUS);
    }

    private static void setEnterprisePermissionStatusOnRelatedAccounts(
        List<Technology_Specialization__c> newProgramDetails,
        Map<Id, Technology_Specialization__c> oldProgramDetails,
        String status
    ) {
        Set<Id> enterpriseIds = new Set<Id>();

        for (Technology_Specialization__c newProgramDetail : newProgramDetails) {
            Technology_Specialization__c oldProgramDetail = oldProgramDetails != null ? oldProgramDetails.get(newProgramDetail.Id) : null;

            if (
                (oldProgramDetail == null || areProgramDetailsEnterpriseStatusUpdateConditionsMet(newProgramDetail, oldProgramDetail)) &&
                String.isNotBlank(newProgramDetail?.Account__c)
            ) {
                enterpriseIds.add(newProgramDetail?.Account__c);
            }
        }

        if (!enterpriseIds.isEmpty()) {
            DTSFPART_PermissionUtils.setEnterprisePermissionStatusOnAccounts(enterpriseIds, status);
        }
    }

    public static void setupProgramDetailsPermissionsBasedOnMetadata(List<Technology_Specialization__c> newProgramDetails) {
        setupProgramDetailsPermissionsBasedOnMetadata(newProgramDetails, null);
    }

    public static void setupProgramDetailsPermissionsBasedOnMetadata(
        List<Technology_Specialization__c> newProgramDetails,
        Map<Id, Technology_Specialization__c> oldProgramDetails
    ) {
        List<Technology_Specialization__c> modifiedProgramDetails = new List<Technology_Specialization__c>();
        Set<Id> accountsIds = new Set<id>();

        for (Technology_Specialization__c newProgramDetail : newProgramDetails) {
            Technology_Specialization__c oldProgramDetail = oldProgramDetails != null ? oldProgramDetails.get(newProgramDetail.Id) : null;

            if (oldProgramDetail == null || areProgramDetailsEnterpriseStatusUpdateConditionsMet(newProgramDetail, oldProgramDetail)) {
                modifiedProgramDetails.add(newProgramDetail);

                if(String.isNotBlank(newProgramDetail.Account__c)){
                    accountsIds.add(newProgramDetail.Account__c);
                } else {
                    LogError.saveErrorPEvent('DTSFPART_ProgramDetailHandlerHelper', 'Account__c BLANK!', 'newProgramDetails.Id');
                }
            }
        }

        if (!modifiedProgramDetails.isEmpty()) {
            setProgramDetailPermissions(modifiedProgramDetails, populateCountryMap(accountsIds));
        }
    }

    private static void setProgramDetailPermissions(List<Technology_Specialization__c> programDetails, Map<Id, Account> enterpriseCountry) {
        Map<String, Default_Communities_Permissions__mdt> permissionsByCommunity = getPermissionsByCommunityMap();

        for (Technology_Specialization__c programDetail : programDetails) {
            programDetail.MCN_Permissions__c = '';
            programDetail.Contact_Mcn_Permissions__c = '';

            if (programDetail.Account__c != null && String.isNotBlank(programDetail.Community_Type__c)) {
                Default_Communities_Permissions__mdt permission = permissionsByCommunity.get(programDetail.Community_Type__c);

                Set<String> contactMcnPermissions = new Set<String>(permission.Contact_Mcn_Permissions__c.split(';'));
                DTSFPART_PermissionUtils.removeCanadaPermissions(contactMcnPermissions, enterpriseCountry.get(programDetail.Account__c).BillingCountry);
    
                System.debug('Perms after removal: ' + contactMcnPermissions);
                if (permission != null) {
                    programDetail.MCN_Permissions__c = permission.MCN_Permissions__c;
                    programDetail.Contact_Mcn_Permissions__c = String.join((Iterable<String>) contactMcnPermissions, ';');
                }
            }
        }
    }

    private static Map<String, Default_Communities_Permissions__mdt> getPermissionsByCommunityMap() {
        Map<String, Default_Communities_Permissions__mdt> permissionsByCommunity = new Map<String, Default_Communities_Permissions__mdt>();

        for (Default_Communities_Permissions__mdt permission : Default_Communities_Permissions__mdt.getall().values()) {
            if (permission.Type__c == 'Program Details') {
                permissionsByCommunity.put(permission.Community_Type__c, permission);
            }
        }

        return permissionsByCommunity;
    }

    private static Boolean areProgramDetailsEnterpriseStatusUpdateConditionsMet(
        Technology_Specialization__c newProgramDetail,
        Technology_Specialization__c oldProgramDetail
    ) {
        return newProgramDetail?.Community_Type__c != oldProgramDetail?.Community_Type__c ||
            newProgramDetail?.Type__c != oldProgramDetail?.Type__c ||
            newProgramDetail?.Technology_Specialization__c != oldProgramDetail?.Technology_Specialization__c ||
            newProgramDetail?.Technology_Specialization_Level__c != oldProgramDetail?.Technology_Specialization_Level__c ||
            newProgramDetail?.Technology_Specialization_Status__c != oldProgramDetail?.Technology_Specialization_Status__c;
    }

    private static Map<Id, Account> populateCountryMap(Set<Id> accountIds){
        return new Map<Id, Account>([SELECT Id, BillingCountry FROM Account WHERE Id IN :accountIds]);
    }
}