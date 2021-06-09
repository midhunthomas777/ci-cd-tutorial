@IsTest
public with sharing class DTSFPART_CaseClosureRequestModalCtrlTest {

    @IsTest
    private static void createCaseCommentTest() {
        Case testCase = new Case(
            Status = 'Open'
        );

        insert testCase;

        CaseComment comment = new CaseComment(
            CommentBody = 'Test',
            ParentId = testCase.Id
        );

        Id commentId = null;
        
        Test.startTest();
        commentId = DTSFPART_CaseClosureRequestModalCtrl.createCaseComment(comment);
        Test.stopTest();

        System.assertNotEquals(null, commentId, 'Comment was not created.');
    }
}