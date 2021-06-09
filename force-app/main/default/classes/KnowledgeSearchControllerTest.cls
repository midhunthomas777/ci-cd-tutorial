@isTest
public class KnowledgeSearchControllerTest {
	static testMethod void testGet() {
        KnowledgeSearchController obj = new KnowledgeSearchController();
        list<Knowledge__kav> listKnow = KnowledgeSearchController.getOnloadKnowledgeArticles();
    }
}