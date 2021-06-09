/*    
Class Name      : ImportCSVController
Purpose         : ImportCSVController Class for validating the input CSV files and start a batch to process the CSV Files.
Author          : Arunraj Radhakrishnan
Test Class      : 
Change History  : -
*/

public class ImportCSVController {

    public Blob fileContent{public get;public set;}
    public String processFileContent {public get; public set;}
    Public String strFileName{public get;public set;}
    Public String[] filelines = new String[]{};    
    public String strFileType {public get; public set;} 
    public String batchId {public get; public set;}   
    
    Map<String, String> sdsMapForCompareHeaders = new Map<String, String>();
    public Set<Integer> csvColHeaderSet = new Set<Integer>();      
    public List<List<String>> inputValues = new List<List<String>>();
    public Boolean fileColumnHeaderFlag {public get; public set;} 
    public List<String> colHeader = new List<String>();  
    public String errorColHeader; 
     
    public Boolean successErrorDisplayFlag {public get; public set;}
    public Boolean displayINPageMessage {public get; public set;}  
    public Boolean showApexJobStatus {public get; public set;}
    public String batchError {public get; public set;}
    String splLines = '\n';  
    String errorColumnHeaderRow = '';
    public String regionBasedonFiletype;
    public String fileTypeAfterSplit {public get;public set;}
     
    public List<SelectOption> getFileList(){
        List<SelectOption> optns = new List<Selectoption>();
        String fileType = '';
        String region = '';
        optns.add(new selectOption('none','--None--'));
        for(AggregateResult ar: [Select File_Name__c fname,region__c rg from SDS_Graph_Data_Mapping__c where Is_Active__c=TRUE group by File_Name__c,region__c ]){
            fileType = (String)ar.get('fname');
            region = (String)ar.get('rg');
            optns.add(new selectOption(region+'-'+fileType,region+' - '+fileType));                       
        }            
        return optns;
    } 
    
    Public void importCSVFile() { 
        try { 
            showApexJobStatus = false;
            batchError = '';
            if(strFileType == 'none') {
                addError('Please Select a File type.');
                successErrorDisplayFlag = false;
                displayINPageMessage =true;
            } else if(fileContent == null) {
                addError('Please Choose a File to Import.');
                successErrorDisplayFlag = false;
                displayINPageMessage =true;
            } else if( !strFileName.endsWithIgnoreCase('.csv')) {
                addError('Please Choose only CSV File to Import.');
                successErrorDisplayFlag = false;
                displayINPageMessage =true;
            } else {        
                csvColHeaderSet.clear();
                errorColHeader ='';
                sdsMapForCompareHeaders.clear();
                colHeader.clear();
                fileColumnHeaderFlag = false; 
                errorColumnHeaderRow ='';
                regionBasedonFiletype = '';
                
                String[] splFileType = strFileType.split('-');
                if(splFileType.size() > 0) {
                    regionBasedonFiletype = splFileType[0];
                    fileTypeAfterSplit= splFileType[1];
                }
                
                String fileFormatColumns = '';  
                for(SDS_Graph_Data_Mapping__c sds: [select id,Field_Api_Name__c,Col_Header_Name__c,Data_Type__c from SDS_Graph_Data_Mapping__c where Region__c=:regionBasedonFiletype and Is_Active__c=TRUE and File_Name__c=:fileTypeAfterSplit]) {                   
                    sdsMapForCompareHeaders.put(sds.Col_Header_Name__c.tolowerCase(),sds.Field_Api_Name__c);
                    fileFormatColumns += sds.Col_Header_Name__c +'<br/>';                    
                }
                
                System.debug('sdsMapForCompareHeaders:::'+sdsMapForCompareHeaders);
                System.debug('BlobfileContent:::'+fileContent);
                processFileContent = fileContent.toString();               
                //processFileContent = (EncodingUtil.base64Encode(fileContent)).trim();
              
                System.debug('processFileContent::::'+processFileContent);
                          
                String headerLines = processFileContent.subString(0, processFileContent.indexOf(splLines));
                String[] headerRow = headerLines.split(',');
                
                for (Integer i=0;i<headerRow.size();i++) {
                    System.debug('headerRow::'+headerRow.get(i));
                    String headerValueForComparision = (headerRow.get(i) != '') ? ((headerRow.get(i)).trim()).tolowerCase() : '';
                    System.debug('headerValueForComparision::'+headerValueForComparision); 
                    colHeader.add(sdsMapForCompareHeaders.get(headerValueForComparision)); 
                    System.debug('Resultvalue::'+sdsMapForCompareHeaders.Keyset()+':::'+headerValueForComparision);
                    System.debug('Result::'+sdsMapForCompareHeaders.Keyset().Contains(headerValueForComparision));
                    if(sdsMapForCompareHeaders.Keyset().Contains(headerValueForComparision) ) { 
                        errorColHeader += (headerRow.get(i)).trim() +',';                                                                                  
                        csvColHeaderSet.add(i); 
                        errorColumnHeaderRow +=  headerRow.get(i) + ',';
                    }
                }
                System.debug('colHeader::'+colHeader);
                if(errorColumnHeaderRow != '') {                
                    errorColumnHeaderRow += 'Error Message' + '\n';              
                }
                System.debug('csvColHeaderSet::'+csvColHeaderSet);
                System.debug('sdsMapForCompareHeaders::'+sdsMapForCompareHeaders);
               
               if(csvColHeaderSet.size() != sdsMapForCompareHeaders.size()) {                   
                    addError('Please check the File Format to include all the below columns as per the FileType. <br><br>'+fileFormatColumns);                    
                    successErrorDisplayFlag = false;
                    displayINPageMessage =true;
                    fileColumnHeaderFlag = true; 
                }
                
                if(!fileColumnHeaderFlag) {
                    List<AsyncApexJob> openJobs = [select Id from AsyncApexJob where Status = 'Processing' OR Status = 'Queued'];             
                    BatchProcessor objBatchProcess= new BatchProcessor(fileContent,fileTypeAfterSplit,csvColHeaderSet,colHeader,headerLines,errorColHeader,regionBasedonFiletype);
                  //  if(openJobs.size() < 5){
                        String strBatchId = Database.executeBatch(objBatchProcess,Integer.valueOf(Label.SDS_Partner_Scorecard_Batch_Size));
                        batchId = strBatchId;
                        showApexJobStatus = true;
                  //  } else{
                     //   batchError = 'Please wait for some time and then Try again. Only Active five batch jobs can be executed at a time.';
                 //   }
                }  
                 
            }
         } catch (Exception e) {
            displayINPageMessage =true;
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, e.getMessage()));
        }        
    }
    
    public static void addError(String error) {
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, error));
    }        
    
    public static String blobToString(Blob input, String inCharset){
        String hex = EncodingUtil.convertToHex(input);
        System.assertEquals(0, hex.length() & 1);
        final Integer bytesCount = hex.length() >> 1;
        String[] bytes = new String[bytesCount];
        for(Integer i = 0; i < bytesCount; ++i)
            bytes[i] =  hex.mid(i << 1, 2);
        return EncodingUtil.urlDecode('%' + String.join(bytes, '%'), inCharset);
    } 
}