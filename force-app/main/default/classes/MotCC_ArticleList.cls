/**
 * Created by tricia.igoe on 4/9/20.
 */

public with sharing class MotCC_ArticleList {

    @AuraEnabled
    public static Peak_Response grabArticleList(String topicId){
        Peak_Response peakResponse = new Peak_Response();
        try{
            Map<Id, KnowledgeArticleVersion> articleVersionsMap = new Map<Id, KnowledgeArticleVersion>([SELECT Title, Summary, LastPublishedDate, VersionNumber, UrlName  FROM KnowledgeArticleVersion WHERE PublishStatus = 'Online' AND Language = 'en_US']);
            //Query for all Article Version Ids related to this topic
            List<TopicAssignment> assignments = [SELECT EntityId, Id FROM TopicAssignment WHERE TopicId =: topicId AND EntityId IN: articleVersionsMap.keySet()];
            peakResponse.messages.add(String.valueOf(assignments.size()));
            List<Id> entityIds = new List<Id>();
            for(TopicAssignment assignment : assignments) {
                entityIds.add(assignment.EntityId);
            }
            //Query for all Article Ids
            List<KnowledgeArticleVersion> articleVersions = [SELECT Title, Summary, LastPublishedDate, VersionNumber, UrlName  FROM KnowledgeArticleVersion WHERE PublishStatus = 'Online' AND Language = 'en_US' AND Id IN : entityIds];
            peakResponse.messages.add(String.valueOf(articleVersions.size()));
            peakResponse.results = articleVersions;
        } catch(Exception e) {
            peakResponse.success = false; peakResponse.messages.add(e.getMessage());peakResponse.messages.add(e.getStackTraceString());
        }
        return peakResponse;
    }

}