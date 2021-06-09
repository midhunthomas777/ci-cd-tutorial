/**
 * Created by QGBC67 on 21.07.2020.
 */

public with sharing class DTSFPART_ProgramDetailTriggerHandler implements ITriggerHandler {
    public static Boolean TriggerDisabled = false;

    public Boolean isDisabled() {
        return TriggerDisabled || new DTSFPART_TriggerConfigurationService('ProgramDetailTrigger', 'DTSFPART_ProgramDetailTriggerHandler').isTriggerLogicDisabled();
    }

    public void beforeInsert(List<SObject> newItems) {
        try {
            List<Technology_Specialization__c> newProgramDetails = newItems != null ? (List<Technology_Specialization__c>) newItems :
                                                                                       new List<Technology_Specialization__c>();

            DTSFPART_ProgramDetailHandlerHelper.setEnterprisePermissionStatusToInProgessOnRelatedAccounts(newProgramDetails);
            DTSFPART_ProgramDetailHandlerHelper.setupProgramDetailsPermissionsBasedOnMetadata(newProgramDetails);

        } catch (Exception e) {
            LogError.saveExceptionPEvent('DTSFPART_ProgramDetailTriggerHandler.beforeInsert', '', '', e);
            throw e;
        }
    }

    public void beforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
        try {
            Map<Id, Technology_Specialization__c> newProgramDetails = newItems != null ? (Map<Id, Technology_Specialization__c>) newItems :
                                                                                          new Map<Id, Technology_Specialization__c>();
            Map<Id, Technology_Specialization__c> oldProgramDetails = oldItems != null ? (Map<Id, Technology_Specialization__c>) oldItems :
                                                                                          new Map<Id, Technology_Specialization__c>();

            DTSFPART_ProgramDetailHandlerHelper.setEnterprisePermissionStatusToInProgessOnRelatedAccounts(newProgramDetails.values(), oldProgramDetails);
            DTSFPART_ProgramDetailHandlerHelper.setupProgramDetailsPermissionsBasedOnMetadata(newProgramDetails.values(), oldProgramDetails);

        } catch (Exception e) {
            LogError.saveExceptionPEvent('DTSFPART_ProgramDetailTriggerHandler.beforeUpdate', '', '', e);
            throw e;
        }
    }

    public void beforeDelete(Map<Id, SObject> oldItems) {}

    public void afterInsert(Map<Id, SObject> newItems) {
        try {
            Map<Id, Technology_Specialization__c> newProgramDetails = newItems != null ? (Map<Id, Technology_Specialization__c>) newItems :
                                                                                          new Map<Id, Technology_Specialization__c>();

            DTSFPART_ProgramDetailHandlerHelper.setEnterprisePermissionStatusToTriggerOnRelatedAccounts(newProgramDetails.values());

        } catch (Exception e) {
            LogError.saveExceptionPEvent('DTSFPART_ProgramDetailTriggerHandler.afterInsert', '', '', e);
            throw e;
        }
    }

    public void afterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
        try {
            Map<Id, Technology_Specialization__c> newProgramDetails = newItems != null ? (Map<Id, Technology_Specialization__c>) newItems :
                                                                                          new Map<Id, Technology_Specialization__c>();
            Map<Id, Technology_Specialization__c> oldProgramDetails = oldItems != null ? (Map<Id, Technology_Specialization__c>) oldItems :
                                                                                          new Map<Id, Technology_Specialization__c>();
                                                                        
            DTSFPART_ProgramDetailHandlerHelper.setEnterprisePermissionStatusToTriggerOnRelatedAccounts(newProgramDetails.values(), oldProgramDetails);
            
        } catch (Exception e) {
            LogError.saveExceptionPEvent('DTSFPART_ProgramDetailTriggerHandler.afterUpdate', '', '', e);
            throw e;
        }
    }

    public void afterDelete(Map<Id, SObject> oldItems) {
        try {
            Map<Id, Technology_Specialization__c> newProgramDetails = oldItems != null ? (Map<Id, Technology_Specialization__c>) oldItems :
                                                                                          new Map<Id, Technology_Specialization__c>();

            DTSFPART_ProgramDetailHandlerHelper.setEnterprisePermissionStatusToTriggerOnRelatedAccounts(newProgramDetails.values());

        } catch (Exception e) {
            LogError.saveExceptionPEvent('DTSFPART_ProgramDetailTriggerHandler.afterDelete', '', '', e);
            throw e;
        }
    }

    public void afterUndelete(Map<Id, SObject> oldItems) {}

}