public with sharing class DTSFPART_HideButtonsController {

    private static final String CASE_CLOSED = 'Closed';

    @AuraEnabled
    public static List<String> hideButtons(Id recordId) {
        List<String> hideButtonsList = new List<String>();
        if(String.isNotBlank(recordId)) {
            Schema.SObjectType token = recordId.getSObjectType();
            Schema.DescribeSObjectResult dr = token.getDescribe();
            String objectName = dr.getName();

            if(objectName.equals('Case')) {
                hideButtonsList.add(hideRequestClosureButton(recordId));
            }
        }

        return hideButtonsList;
    }

    private static String hideRequestClosureButton(Id recordId) {
        Case caseRecord = [SELECT Id, Status FROM Case WHERE Id = :recordId];
        if(caseRecord.Status.equals(CASE_CLOSED)) {
            return System.Label.PP_Labels_Request_Closure;
        }
        return '';
    }
}