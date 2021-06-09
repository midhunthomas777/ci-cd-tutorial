public with sharing class DTSFPART_CaseClosureRequestModalCtrl {
    private static DTSFPART_CaseCommentServiceImpl caseCommentService = new DTSFPART_CaseCommentServiceImpl();

    @AuraEnabled
    public static Id createCaseComment(CaseComment comment) {
        try {
            return caseCommentService.createCaseComment(comment);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}