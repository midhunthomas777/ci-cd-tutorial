public with sharing class MetadataTriggerService {
    public class MetadataTriggerServiceException extends Exception {
    }
    private String objType = '';
    public Profile userProfile = null;

    public MetadataTriggerService(String objectTypeName) {
        this.objType = objectTypeName;
        this.userProfile = [SELECT Name FROM Profile WHERE Id = :userinfo.getProfileid()];
    }

    /**
     * @description This query finds an ordered list trigger handler classes
     * to execute. It ignores any classes that are marked as disabled.
     *
     * Note: It will exclude any triggerHandler metadata records for which
     * the user's email address is found in a related disabled_for__mdt
     * record.
     *
     * Admin's and Developers can selectively disable trigger handlers
     * for all or selected individuals *without* deploying.
     * @return      `List<Metadata_Driven_Trigger__mdt>`
     */
    public List<Metadata_Driven_Trigger__mdt> getMetadataTriggers() {
        return [
            SELECT Class__c, Run_for_Profile_Group__r.Profiles__c, Dont_Run_for_Profile_Group__r.Profiles__c
            FROM Metadata_Driven_Trigger__mdt
            WHERE
                Object__r.QualifiedApiName = :this.objType
                AND Enabled__c = TRUE
            ORDER BY Execution_Order__c
        ];
    }

    /**
     * @description This determines the active sObject type by describing the first
     * record in the trigger New / Old list
     * @return      `String`
     */
    public static String getSObjectType() {
        if (Trigger.new != null) {
            return Trigger.new[0].getSObjectType().getDescribe().getName();
        } else if (Trigger.old != null) {
            return Trigger.old[0].getSObjectType().getDescribe().getName();
        }
        throw new MetadataTriggerServiceException(
            'Trigger.new && Trigger.old are both null. Are you excercising this method outside of a trigger context?'
        );
    }
}