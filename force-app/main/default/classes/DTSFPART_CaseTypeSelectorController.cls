/**
 * Created by QGBC67 on 19.10.2020.
 */

public without sharing class DTSFPART_CaseTypeSelectorController {
    @AuraEnabled(Cacheable=true)
    public static List<RadioButtonGroupSettings> getCaseTypeByCategory() {
        try {
            Map<String, RecordTypeInfo> recordTypeInfos = Schema.SObjectType.Case.getRecordTypeInfosByName();
            Set<String> permissionNames = getUserPermissionNames();
            System.debug(permissionNames);
            Map<String, RadioButtonGroupSettings> caseTypesByCategory = new Map<String, RadioButtonGroupSettings>();
            for (DTSFPART_CaseTypesConfiguration__mdt caseType : [
                    SELECT Category__c, Type__c, RequiredPermission__c, RecordTypeName__c, DisplayedValue__c, order__c
                    FROM DTSFPART_CaseTypesConfiguration__mdt ORDER BY order__c ASC NULLS LAST, DisplayedValue__c ASC]) {
                if(!String.isBlank(caseType.RequiredPermission__c))
                {
                    System.debug(caseType);
                    System.debug(permissionNames.contains(caseType.RequiredPermission__c));
                }
                if ((String.isBlank(caseType.RecordTypeName__c) || (recordTypeInfos.get(caseType.RecordTypeName__c) != null && recordTypeInfos.get(caseType.RecordTypeName__c).isAvailable()))
                        && String.isBlank(caseType.RequiredPermission__c) || permissionNames.contains(caseType.RequiredPermission__c)) {
                    if (!caseTypesByCategory.containsKey(caseType.Category__c)) {
                        RadioButtonGroupSettings rbs = new RadioButtonGroupSettings(caseType.Category__c + ' requests', caseType.Category__c.replace(' ', '_'));
                        caseTypesByCategory.put(caseType.Category__c, rbs);
                    }
                    caseTypesByCategory.get(caseType.Category__c).add(caseType.DisplayedValue__c, caseType.Type__c);
                }
            }
            System.debug(caseTypesByCategory);
            System.debug(caseTypesByCategory.values());
            return caseTypesByCategory.values();
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    private static Set<String> getUserPermissionNames() {
        User runningUser = [SELECT ContactId, Contact.AccountId FROM User WHERE Id = :UserInfo.getUserId()];
        List<Contact_Permissions__c> contactPermissions = [SELECT Contact_MCN_Permissions__c
        FROM Contact_Permissions__c
        WHERE MCN_Account__r.Customer_or_Prospect_Account__c = :runningUser.Contact.AccountId AND Contact__c = :runningUser.ContactId];
        Set<String> permissionNames = new Set<String>();
        for (Contact_Permissions__c permission : contactPermissions)
        {
            permissionNames.addAll(DTSFPART_PermissionUtils.splitPermissions(permission.Contact_MCN_Permissions__c));
        }
        return permissionNames;
    }

    public class RadioButtonGroupSettings {
        @AuraEnabled
        public String label { get; set; }
        @AuraEnabled
        public String name { get; set; }
        @AuraEnabled
        public List<LabelValueWrapper> options { get; set; }

        public RadioButtonGroupSettings(String label, String name) {
            this.label = label;
            this.name = name;
            this.options = new List<LabelValueWrapper>();
        }
        public void add(String label,String value) {
            options.add(new LabelValueWrapper(label, value));
        }
    }

    public class LabelValueWrapper {
        @AuraEnabled
        public String label { get; set; }
        @AuraEnabled
        public String value { get; set; }

        public LabelValueWrapper(String label, String value) {
            this.label = label;
            this.value = value;
        }
    }
}