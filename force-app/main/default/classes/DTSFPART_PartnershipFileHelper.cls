public with sharing class DTSFPART_PartnershipFileHelper {

    public static final Map<String, String> MIME_TYPE_TO_EXTENSION = new Map<String, String>{
        'Google Docs' => '.docx',
        'Microsoft Word' => '.docx',
        'Google Sheets' => '.xlsx',
        'Microsoft Excel' => '.xlsx',
        'Google Slides' => '.pptx',
        'Microsoft PowerPoint' => '.pptx'
    };

    public class FileWrapper {
        @AuraEnabled
        public String blobContent {get; set;}
        @AuraEnabled
        public String fileName {get; set;}
        @AuraEnabled
        public String contentType {get; set;}
        @AuraEnabled
        public String extension {get; set;}
    }

    public static String getFileExtensionBasedOnMimeType(String mimeType) {
        String fileExtension = MIME_TYPE_TO_EXTENSION.get(mimeType);

        if (String.isNotBlank(fileExtension)) {
            return fileExtension;
        }

        return '.pdf';
    }

    public static String getGoogleDriveRequestUrl(Partnership_Record__c partnerFile) {
        if (
            partnerFile.Mime_Type__c == 'Google Slides' ||
            partnerFile.Mime_Type__c == 'Google Sheets' ||
            partnerFile.Mime_Type__c == 'Google Docs'
        ) {
            return 'callout:EMEA_Google_Drive' + '/' + partnerFile.File_Id__c + '/export?mimeType=' + partnerFile.Content_Type__c;
        } 

        return 'callout:EMEA_Google_Drive' + '/' + partnerFile.File_Id__c + '?alt=media';
    }
}