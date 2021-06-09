@isTest
public class DTSFPART_CaseCommentServiceImplTest {
   
    @isTest
    private static void createCaseCommentTest() {
 
        Case testCase = new Case(
            Status = 'Closed'
        );

        insert testCase;

        CaseComment comment = new CaseComment(
            CommentBody = 'Test',
            ParentId = testCase.Id
        );

        Id commentId = null;

        Test.startTest();
        DTSFPART_CaseCommentServiceImpl caseCommentService = new DTSFPART_CaseCommentServiceImpl();
        commentId = caseCommentService.createCaseComment(comment);
        Test.stopTest();

        System.assertNotEquals(null, commentId);
    }

    @isTest 
    private static void createCaseCommentCatchTest() {
        Exception error = null;
        try {
            DTSFPART_CaseClosureRequestModalCtrl.createCaseComment(null);
        } catch(Exception e) {
            error = e;
        }
        System.assert(error != null);
    }
}