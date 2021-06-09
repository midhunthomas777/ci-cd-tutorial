/**
 * Created by tricia.igoe on 4/9/20.
 */
@isTest
public with sharing class MotCC_ArticleList_Test {
	/*  @testSetup
    static void testSetUp() {
        TestDataSetUpUtils.insertCustomSettings();
    }*/
     @isTest (seeAllData =true)
    public static void ArticleList_Test(){
		List<TopicAssignment> assignments = [SELECT Id,EntityId,TopicId FROM TopicAssignment LIMIT 1];
        MotCC_ArticleList.grabArticleList(assignments.get(0).Id);
        MotCC_ArticleList.grabArticleList('a');
    }
}