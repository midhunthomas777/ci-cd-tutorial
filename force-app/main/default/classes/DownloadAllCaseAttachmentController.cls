public class DownloadAllCaseAttachmentController {
  
    
     @AuraEnabled
     public static String getInitialValue(String pId){
         System.debug('************* in getInitialValue method');
         Id parentId = Id.valueOf(pId);
         String DownloadURl='';
         String FileIds='';
         String domainUrl=URL.getSalesforceBaseUrl().toExternalForm();
         List<ContentDocumentLink> conDocLinkList = new List<ContentDocumentLink>();
         
         for(ContentDocumentLink cdl: [SELECT ContentDocumentId, LinkedEntityId  FROM ContentDocumentLink where LinkedEntityId =:parentId])
         {
             conDocLinkList.add(cdl);
         }
         
         for(ContentDocumentLink cdl: [SELECT ContentDocumentId,Id FROM ContentDocumentLink WHERE LinkedEntityId IN (SELECT ID From EmailMessage WHERE ParentId =: parentId and HasAttachment = true)])
         {
               conDocLinkList.add(cdl);
         }
         
         for(ContentDocumentLink cdl: conDocLinkList)
         {
                  FileIds = FileIds + cdl.ContentDocumentId + '/';      
             
         }
         DownloadURl=domainUrl+ '/sfc/servlet.shepherd/document/download/' + FileIds;
		 system.debug('###DownloadURl###'+DownloadURl); 
          system.debug('###FileIds###'+FileIds); 
         
         System.debug('####parentId###'+parentId);
         
         if(!(String.isBlank(FileIds)))
         return DownloadURl;
         else
         {
             DownloadURl='';
              system.debug('###DownloadURl22###'+DownloadURl);
             return DownloadURl;
         }   
             
     }
}