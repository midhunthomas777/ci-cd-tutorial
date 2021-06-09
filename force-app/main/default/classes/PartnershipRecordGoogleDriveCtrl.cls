public without sharing class PartnershipRecordGoogleDriveCtrl {
    
    @auraEnabled
    public static FileWrapper downloadFile(String recId) {
        Partnership_Record__c partnerFile = [Select Name,Id,File_Id__c,Mime_Type__c,No_of_Downloads__c,Download_History__c,Content_Type__c,File_Type__c,Year__c
                                             from Partnership_Record__c where Id =: recId LIMIT 1];
        Http httpObj = new Http(); 
        HttpRequest request = new HttpRequest(); 
        request.setEndpoint('callout:EMEA_Google_Drive' + '/' + partnerFile.File_Id__c + '?alt=media'); 
        request.setMethod('GET'); 
        request.setCompressed(true);
        HttpResponse response  = httpObj.send(request);
        
        FileWrapper wrapper = new FileWrapper();
        wrapper.blobContent = EncodingUtil.base64Encode(response.getBodyasBlob());
        wrapper.fileName = partnerFile.Name + '_' +  partnerFile.File_Type__c + '_' + partnerFile.Year__c;
        wrapper.contentType = partnerFile.Content_Type__c;
        if(partnerFile.Mime_Type__c == 'PDF') {
            wrapper.extension = '.pdf';
        } else {
            wrapper.extension = '.xlsx';
        }
        //wrapper.body = httpResponse.getBody();
        
        updateRec(partnerFile.Id);
        return wrapper;
    }
    
    @TestVisible
    class FileWrapper{
        @auraEnabled
        public String blobContent{get;set;}
        @auraEnabled
        public String fileName{get;set;}
        @auraEnabled
        public String contentType{get;set;}
        @auraEnabled
        public String extension{get;set;}
    }
 
    @TestVisible 
    private static void updateRec(String recId) {
        Partnership_Record__c partnerFile = [Select Id,No_of_Downloads__c,Download_History__c from Partnership_Record__c where Id =: recId LIMIT 1];
        Decimal firstIndex = (partnerFile.No_of_Downloads__c == NULL? 0 : partnerFile.No_of_Downloads__c) + 1;
        update new Partnership_Record__c(
            Id = partnerFile.Id,
            No_of_Downloads__c = firstIndex,
            Download_History__c = String.isBlank(partnerFile.Download_History__c) ? 
            + firstIndex + '. '+ UserInfo.getFirstName() + ' ' + UserInfo.getLastName() + ' | ' + Datetime.now() 
            : firstIndex + '. '+ UserInfo.getFirstName() + ' ' + UserInfo.getLastName() + ' | ' + Datetime.now() + '\n' + partnerFile.Download_History__c
        );
    }
}