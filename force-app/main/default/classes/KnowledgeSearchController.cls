public with sharing class KnowledgeSearchController {
    public KnowledgeSearchController() {
    }

    @AuraEnabled(cacheable=true)
    public static List<Knowledge__kav> getOnloadKnowledgeArticles() {
        String articleStatus = 'Online';
        String knowledgeQuery = 'SELECT Id, Title, Answer__c FROM Knowledge__kav WHERE  PublishStatus = ' + '\'' + articleStatus + '\' LIMIT 3000';
        List<Knowledge__kav> articleList = Database.query(knowledgeQuery); 
        return articleList; 
    }
}