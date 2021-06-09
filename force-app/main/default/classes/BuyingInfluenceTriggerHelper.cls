public class BuyingInfluenceTriggerHelper {
    
    @future
    public static void createContactRoles(Set<Id> incomingIds) {
        Map<ID, Buying_Influences__c> newMap = new Map<ID, Buying_Influences__c>();
        for(Buying_Influences__c BI : [Select Id,Contact__c,Opportunity__c,Role__c from Buying_Influences__c where Id IN : incomingIds]) {
            newMap.put(BI.Id, BI);
        }
        Map<Id, Set<Id>> allBIOpps = new Map<Id, Set<Id>>();
        Map<Id, Set<Id>> allOCROpps = new Map<Id, Set<Id>>();
        Map<String, Buying_Influences__c> uniqueBuyingInfluence = new Map<String, Buying_Influences__c>();
        for(Buying_Influences__c BI : newMap.values()) {
            uniqueBuyingInfluence.put(BI.Opportunity__c+'#'+BI.Contact__c, BI);
            if(allBIOpps.get(BI.Opportunity__c) != null) {
                Set<Id> allCons = allBIOpps.get(BI.Opportunity__c);
                allCons.add(BI.Contact__c);
                allBIOpps.put(BI.Opportunity__c, allCons);
            } else {
                Set<Id> conIds = new Set<Id>();
                conIds.add(BI.Contact__c);
                allBIOpps.put(BI.Opportunity__c, conIds);
            }
        }
        for(OpportunityContactRole OCR : [Select Id,ContactId,OpportunityId from OpportunityContactRole where OpportunityId IN: allBIOpps.keySet()]) {
            if(allOCROpps.get(OCR.OpportunityId) != null) {
                Set<Id> allCons = allOCROpps.get(OCR.OpportunityId);
                allCons.add(OCR.ContactId);
                allOCROpps.put(OCR.OpportunityId, allCons);
            } else {
                Set<Id> conIds = new Set<Id>();
                conIds.add(OCR.ContactId);
                allOCROpps.put(OCR.OpportunityId, conIds);
            }
        }
        List<OpportunityContactRole> toBeInsertedOCR = new List<OpportunityContactRole>();
        for(Id oppId : allBIOpps.keySet()) {
            Set<Id> newRecords = new Set<Id>();
            Set<Id> oldRecords = new Set<Id>();
            newRecords = allBIOpps.get(oppId);
            oldRecords = allOCROpps.get(oppId);
            if(!newRecords.isEmpty()) {
                if(oldRecords != null) {
                    newRecords.removeAll(oldRecords);
                }
                for(Id conId : newRecords) {
                    toBeInsertedOCR.add(new OpportunityContactRole(ContactId = conId, OpportunityId = oppId,
                                                                   Role = uniqueBuyingInfluence.get(oppId+'#'+conId).Role__c));
                }
            }
            insert toBeInsertedOCR;
        }        
    }
    
    @future
    public static void updateContactRole(String mapUpdated) {
        Set<Id> allOps = new Set<Id>();
        Map<String, Buying_Influences__c> updatedRecMap = new Map<String, Buying_Influences__c>();
        Map<String, String> updatedMap = (Map<String, String>) JSON.deserialize(mapUpdated, Map<String, String>.class);
        for(Buying_Influences__c updateRecord : [Select Id,Contact__c,Opportunity__c,Role__c from Buying_Influences__c where Id IN : updatedMap.values()]) {
            allOps.add(updateRecord.Opportunity__c);
            updatedRecMap.put(updateRecord.Id, updateRecord);
        }
        List<OpportunityContactRole> toBeUpdated = new List<OpportunityContactRole>();
        for(OpportunityContactRole OCR : [Select Id,ContactId,OpportunityId from OpportunityContactRole where OpportunityId IN: allOps]) {
            system.debug('#####BI#### => ' + OCR.OpportunityId+'#'+OCR.ContactId);
            Buying_Influences__c BI = updatedRecMap.get(updatedMap.get(OCR.OpportunityId+'#'+OCR.ContactId));
            system.debug('#####BI#### => ' + BI);
            if(BI != null) {
                system.debug('######BI##### => ' + BI);
                OCR.ContactId = BI.Contact__c;
                OCR.Role = BI.Role__c;
                toBeUpdated.add(OCR);
            }
        }
        system.debug('######toBeUpdated##### => ' + toBeUpdated);
        update toBeUpdated;
    }
    
    @future
    public static void deleteOCRs(String mapDelete) {
        Map<String, String> deletedMap = (Map<String, String>) JSON.deserialize(mapDelete, Map<String, String>.class);
        List<OpportunityContactRole> toBeDeletedAllOCRs = new List<OpportunityContactRole>();
        Map<String, OpportunityContactRole> uniqueOCRMap = new Map<String, OpportunityContactRole>();
        for(OpportunityContactRole OCR : [Select Id,ContactId,OpportunityId from OpportunityContactRole where OpportunityId IN: deletedMap.values()]) {
            uniqueOCRMap.put(OCR.OpportunityId+'#'+OCR.ContactId, OCR);
        }
        for(String key : deletedMap.keySet()) {
            OpportunityContactRole toBeDeletedOCR = uniqueOCRMap.get(key);
            if(toBeDeletedOCR != null) {
                toBeDeletedAllOCRs.add(toBeDeletedOCR);
            }
        }
        if(!toBeDeletedAllOCRs.isEmpty()) delete toBeDeletedAllOCRs;
    }
}