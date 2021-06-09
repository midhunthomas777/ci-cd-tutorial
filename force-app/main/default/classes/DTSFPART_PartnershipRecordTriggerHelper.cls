public inherited sharing class DTSFPART_PartnershipRecordTriggerHelper {
    
    public static void setPartnershipRecordAccountBasedOnPartnerEmpowerId(List<Partnership_Record__c> partnershipRecords) {

        Map<String, Id> partnerMembershipIdToAccountId = getPartnerMambershipIdToAccountIdMap(partnershipRecords);
        
        for (Partnership_Record__c partnershipRecord : partnershipRecords){
            if (String.isNotBlank(partnershipRecord.Partner_Empower_ID__c) && partnerMembershipIdToAccountId.containsKey(partnershipRecord.Partner_Empower_ID__c)){
                partnershipRecord.Account__c = partnerMembershipIdToAccountId.get(partnershipRecord.Partner_Empower_ID__c);
            } else {
                partnershipRecord.addError('Not Found Account with selected Partner Empower ID. Partner Empower ID should be the same as some existing Account Partner Membership ID.');
            }
        } 
    }

    private static Map<String, Id> getPartnerMambershipIdToAccountIdMap(List<Partnership_Record__c> partnershipRecords) {
        Map<String, Id> partnerMembershipIdToAccountId = new Map<String, Id>();
        Set<String> parntershipRecordsParnterEmpowersIds = getPartnerEmpowerIdsFromPartnershipRecords(partnershipRecords);

        if (!parntershipRecordsParnterEmpowersIds.isEmpty()){
            for (Account partnerAccount : [ SELECT Id, Partner_Membership_Id__c 
                                            FROM Account 
                                            WHERE RecordType.DeveloperName = 'Partner' 
                                            AND Partner_Membership_Id__c IN :parntershipRecordsParnterEmpowersIds ]){

                partnerMembershipIdToAccountId.put(partnerAccount.Partner_Membership_Id__c, partnerAccount.Id);
            }
        }

        return partnerMembershipIdToAccountId;
    }

    private static Set<String> getPartnerEmpowerIdsFromPartnershipRecords(List<Partnership_Record__c> partnershipRecords) {
        Set<String> parntershipRecordsParnterEmpowersIds = new Set<String>();

        for (Partnership_Record__c partnershipRecord : partnershipRecords){
            if (String.isNotBlank(partnershipRecord.Partner_Empower_ID__c)){
                parntershipRecordsParnterEmpowersIds.add(partnershipRecord.Partner_Empower_ID__c);
            }
        } 

        return parntershipRecordsParnterEmpowersIds;
    }
}