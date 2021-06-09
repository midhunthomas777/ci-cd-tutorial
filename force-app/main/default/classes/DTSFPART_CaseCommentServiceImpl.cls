public with sharing class DTSFPART_CaseCommentServiceImpl implements DTSFPART_CaseCommentService {
    public Id createCaseComment(CaseComment comment) {
        insert comment;
        return comment.Id;
    }
}