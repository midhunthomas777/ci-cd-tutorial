public class DTSFPART_TriggerConfigurationService {
    private static final String WILDCARD = 'ALL';
    private String currentTriggerName;
    private String currentApexHandlerClassName;

    public DTSFPART_TriggerConfigurationService(String currentTriggerName, String currentApexHandlerClassName) {
        this.currentTriggerName = currentTriggerName;
        this.currentApexHandlerClassName = currentApexHandlerClassName;
    }

    public Boolean isTriggerLogicDisabled() {
        try {
            TriggersConfiguration__mdt triggerConfiguration = getTriggerConfigurationForUserProfileAndHandlerName();

            if (triggerConfiguration != null) {
                String currentTriggerConfigurationField = getTriggerConfigurationField();

                return !(Boolean) triggerConfiguration.get(currentTriggerConfigurationField);
            }

            return false;
        } catch (Exception e) {
            LogError.saveError('DTSFPART_TriggerConfigurationService', '', 'Error in method isTriggerLogicDisabled. Error message: ' + e.getMessage());
            return false;
        }
    }

    private TriggersConfiguration__mdt getTriggerConfigurationForUserProfileAndHandlerName() {
        List<TriggersConfiguration__mdt> triggersConfiguration = [
            SELECT
                Id,
                AfterDelete__c,
                AfterInsert__c,
                AfterUndelete__c,
                AfterUpdate__c,
                BeforeDelete__c,
                Priority__c,
                Username__c,
                BeforeInsert__c,
                BeforeUpdate__c,
                ProfileName__c,
                TriggerApiName__c,
                TriggerHandlerApiName__c,
                IsActive__c
            FROM TriggersConfiguration__mdt
            WHERE
                (ProfileName__c = :getUserProfileName()
                OR ProfileName__c = :WILDCARD)
                AND (Username__c = :UserInfo.getUserName()
                OR Username__c = '')
                AND (TriggerHandlerApiName__c = :this.currentApexHandlerClassName
                OR TriggerHandlerApiName__c = :WILDCARD)
                AND (TriggerApiName__c = :this.currentTriggerName
                OR TriggerApiName__c = :WILDCARD)
                AND IsActive__c = TRUE
            ORDER BY Priority__c DESC
        ];

        if (!triggersConfiguration.isEmpty()) {
            return triggersConfiguration[0];
        }

        LogError.saveError('DTSFPART_TriggerConfigurationService', '', 'Missing TriggersConfiguration__mdt for handler: ' + this.currentApexHandlerClassName + ' and trigger: ' + this.currentTriggerName);
        return null;
    }

    private String getTriggerConfigurationField() {
        if (Trigger.isExecuting && Trigger.isBefore && Trigger.isInsert) {
            return 'BeforeInsert__c';
        } else if (Trigger.isExecuting && Trigger.isBefore && Trigger.isUpdate) {
            return 'BeforeUpdate__c';
        } else if (Trigger.isExecuting && Trigger.isBefore && Trigger.isDelete) {
            return 'BeforeDelete__c';
        } else if (Trigger.isExecuting && Trigger.isAfter && Trigger.isInsert) {
            return 'AfterInsert__c';
        } else if (Trigger.isExecuting && Trigger.isAfter && Trigger.isUpdate) {
            return 'AfterUpdate__c';
        } else if (Trigger.isExecuting && Trigger.isAfter && Trigger.isDelete) {
            return 'AfterDelete__c';
        } else if (Trigger.isExecuting && Trigger.isAfter && Trigger.isUndelete) {
            return 'AfterUndelete__c';
        }
        return null;
    }

    private String getUserProfileName() {
        Cache.OrgPartition profilePartition = Cache.Org.getPartition('local.ProfileData');

        if (profilePartition.contains(UserInfo.getProfileId())) {
            return (String) profilePartition.get(UserInfo.getProfileId());
        }

        List<Profile> currentUserProfile = [ SELECT Id, Name 
                                             FROM Profile 
                                             WHERE Id = :UserInfo.getProfileId() 
                                             LIMIT 1 ];

        if (!currentUserProfile.isEmpty()) {
            profilePartition.put(UserInfo.getProfileId(), currentUserProfile[0]?.Name, 86400);

            return currentUserProfile[0]?.Name;
        }                                      
        
        return WILDCARD; //Automated Process
    }
}