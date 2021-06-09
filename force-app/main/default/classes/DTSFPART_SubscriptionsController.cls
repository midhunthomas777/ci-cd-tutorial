public class DTSFPART_SubscriptionsController {

    public static final String VALUE_ADDED_RESELLER = 'Value Added Reseller';
    public static final String SOFTWARE_AND_SOLUTIONS = 'Software and Solutions';
    public static final String ION = 'MOTOTRBO Ion';

    @AuraEnabled(cacheable=true)
    public static Boolean hasCurrentUserAccountValidProgramDetail() {
        List<Technology_Specialization__c> programDetails = [
            SELECT Id, Community_Type__c, Technology_Specialization__c, Account__c
            FROM Technology_Specialization__c
            WHERE Account__c = :getCurrentUserAccountId() 
                AND Technology_Specialization_Status__c = 'Active'
                AND Technology_Specialization__c = :VALUE_ADDED_RESELLER
                AND Community_Type__c = :SOFTWARE_AND_SOLUTIONS
        ];

        return !programDetails.isEmpty();
    }
    
    @AuraEnabled(cacheable=true)
    public static Boolean hasCurrentUserAccountValidTechnologySubSegment() {
        List<Technology_SubSegment__c> technologySubSegments = [
            SELECT Id, Sub_Segment__c, Account__c
            FROM Technology_SubSegment__c
            WHERE Account__c = :getCurrentUserAccountId() 
                AND Sub_Segment__c = :ION
        ];

        return !technologySubSegments.isEmpty();
    }

    @AuraEnabled(cacheable=true)
    public static List<String> getSubscriptionIdsListWithAccessToDetailPage(Map<String, List<String>> customerNumberToSubscriptionsIds) {//TODO Just pass String customerNumber and return true or false
        try {
            List<String> subscriptionIdsWithAccess = new List<String>();

            for (Contact_Permissions__c contactMcnPermission : [ SELECT Motorola_Customer_Number__c, Contact__c, Contact_MCN_Permissions__c
                                                                 FROM Contact_Permissions__c
                                                                 WHERE Contact__c = :getCurrentUserContactId() 
                                                                 AND Motorola_Customer_Number__c IN :customerNumberToSubscriptionsIds.keySet() ]) {

                if (String.isNotBlank(contactMcnPermission.Contact_MCN_Permissions__c) 
                    && contactMcnPermission.Contact_MCN_Permissions__c.contains('OrderSubmission')) {

                    subscriptionIdsWithAccess.addAll(
                        customerNumberToSubscriptionsIds.get(contactMcnPermission.Motorola_Customer_Number__c)
                    );
                } 
            }  

            return subscriptionIdsWithAccess;                                               
        } catch (Exception e) {
            return new List<String>();
        }       
    }

    @AuraEnabled
    public static String getAccountPartyId(Id accountId){
       return [ SELECT Id, Party_Number__c
                FROM Account
                WHERE Id = :accountId ]?.Party_Number__c;
    }

    private static Id getCurrentUserAccountId() {
        return DTSFPART_DashboardComponentsController.getCurrentUser()?.Contact?.AccountId;
    }

    private static Id getCurrentUserContactId() {
        return DTSFPART_DashboardComponentsController.getCurrentUser()?.ContactId;
    }
}