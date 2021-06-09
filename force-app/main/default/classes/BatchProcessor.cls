/*    
Class Name      : BatchProcessor
Purpose         : BatchProcessor Class for processing the CSV Files into chunk of records based on the Batch Size
Author          : Arunraj Radhakrishnan
Test Class      : 
Change History  : -
*/

global class BatchProcessor implements Database.batchable<String>, Database.Stateful{ 

    global Blob blobCSV;
    global String sourceFileType;
    global Set<Integer> csvColHeaderSet;
    global Map<String, String> sdsDataTypeMap = new Map<String, String>();
    global Map<String, String> sdsFieldLabelMap = new Map<String, String>();
    global Map<String, String> sdsMapForCompareHeaders = new Map<String, String>();
    global Map<String, String> sdsCurrencyDataTypeMap = new Map<String, String>();
    global List<String> colHeader = new List<String>();
    global String strFirstRowCSV;  
    global String strErrorColHeaderLabel;
    global List<Id> successIdList = new List<Id>();
    global Integer successCount {public get; public set;}
    global Integer errorCount {public get; public set;}        
    global Integer totalCount;
    global List<TotalSDSdData> sdsErrorMsgForEmailList {public get; public set;}
    global Map<Integer, SDS_Graphs_Data__c> sdsIndexErrorMap = new Map<Integer, SDS_Graphs_Data__c>();
    global String strRegionBasedOnFileName;
        
    global class TotalSDSdData{
        public SDS_Graphs_Data__c sdsTotal{public get; public set;}
        public String errorMsgForEmail {public get; public set;}
    }
    
    global BatchProcessor(Blob strInputCSVLines,String strFileType,Set<Integer> csvColHeaderSet,List<String> sourceColHeaderApiName,String strFirstRowCSV,String sourceErrorColHeaderLabel,String sourceRegion) {
        this.blobCSV = strInputCSVLines;
        this.sourceFileType = strFileType;
        this.csvColHeaderSet = csvColHeaderSet;
        this.colHeader = sourceColHeaderApiName;
        this.strFirstRowCSV = strFirstRowCSV;    
        this.strErrorColHeaderLabel = sourceErrorColHeaderLabel;
        this.strRegionBasedOnFileName = sourceRegion;
    }
    
    global Iterable<String> start(Database.BatchableContext bc) {    
        sdsErrorMsgForEmailList = new List<TotalSDSdData>();
        for(SDS_Graph_Data_Mapping__c sds: [select id,Field_Api_Name__c,Col_Header_Name__c,Data_Type__c from SDS_Graph_Data_Mapping__c where Region__c=:strRegionBasedOnFileName and Is_Active__c=TRUE and File_Name__c=:sourceFileType]) {
            sdsDataTypeMap.put(sds.Field_Api_Name__c,sds.Data_Type__c);
            sdsFieldLabelMap.put(sds.Field_Api_Name__c,sds.Col_Header_Name__c);
            sdsMapForCompareHeaders.put(sds.Col_Header_Name__c.tolowerCase(),sds.Field_Api_Name__c);
            if(sds.Data_Type__c == 'Currency') {
                sdsCurrencyDataTypeMap.put(sds.Field_Api_Name__c,sds.Data_Type__c); 
            }
        }        
        return new CSVBatchIterator(this.blobCSV.toString(), '\n');
    }
    
    public void execute(Database.BatchableContext bc, List<String> scope) {     
        String tempStr = '';   
       // successIdList.clear();

        for (Integer i=0;i<scope.size();i++) { 
            System.debug('Element at Row'+scope.get(i));
            if(!(scope.get(i).contains(strFirstRowCSV))) {   
                tempStr += scope.get(i)+'\n';
            }           
        }
        
        List<List<String>> inputList;
        if(tempStr !='') {
            inputList = ParseCSVUtilityController.parseCSV(tempStr,false);
        }
       
        for(SDS_Graph_Data_Mapping__c sds: [select id,Field_Api_Name__c,Col_Header_Name__c,Data_Type__c from SDS_Graph_Data_Mapping__c where Region__c=:strRegionBasedOnFileName and Is_Active__c=TRUE and File_Name__c=:sourceFileType]) {
            sdsDataTypeMap.put(sds.Field_Api_Name__c,sds.Data_Type__c);
            sdsMapForCompareHeaders.put(sds.Col_Header_Name__c.tolowerCase(),sds.Field_Api_Name__c);
            if(sds.Data_Type__c == 'Currency') {
                sdsCurrencyDataTypeMap.put(sds.Field_Api_Name__c,sds.Data_Type__c); 
            }
        }
        
        SDS_Graphs_Data__c sds; 
        String colValues ='';
        String extIdKey ='';
        Map<String,SDS_Graphs_Data__c> sdsFinalGraphDataMap = new Map<String,SDS_Graphs_Data__c>();
        List<SDS_Graphs_Data__c> upsertList = new List<SDS_Graphs_Data__c>();
        Decimal oldCurrencyValue;
        Decimal newCurrencyValue;        
        String sdsErrormsg;
        TotalSDSdData errorSDSData;
        Integer index = 0;
        for (Integer i=0;i<inputList.size();i++) {             
            colValues ='';
            extIdKey ='';
            sdsErrormsg ='';
            errorSDSData = new TotalSDSdData();
            
            sds = new SDS_Graphs_Data__c();
            sds.put('File_Name__c',sourceFileType);
            sds.put('Apex_Job_ID__c',bc.getJobId());
            sds.put('SDS_Region__c',strRegionBasedOnFileName);
            
            for(Integer j=0;j<inputList.get(i).size();j++) {
            
                if(csvColHeaderSet.contains(j)) {                       
                                                                        
                    System.debug('Element at Row'+i+' Column'+j+':::'+inputList.get(i).get(j));                     
                 
                 /*   
                    if(j==0) {
                        sds = new SDS_Graphs_Data__c();
                        sds.put('File_Name__c',sourceFileType);
                        sds.put('Apex_Job_ID__c',bc.getJobId());
                        sds.put('SDS_Region__c',strRegionBasedOnFileName);
                    }
                    */
                    String headerValue = colHeader.get(j).trim();
                    
                    if(inputList[i][j] != null && inputList[i][j] != '') {   
                        if(sdsDataTypeMap.get(headerValue) == 'Text') {                                   
                            sds.put(colHeader.get(j),inputList[i][j].trim());
                        } else if( sdsDataTypeMap.get(headerValue) == 'Currency') {                                                                    
                            if(validateDecimalValues(inputList[i][j].trim()) != null) {
                                sds.put(colHeader.get(j),validateDecimalValues(inputList[i][j].trim()));
                            } else {
                                sdsErrormsg += 'Invalid '+sdsFieldLabelMap.get(headerValue)+' Value : '+inputList[i][j].trim()+' ; '; 
                                sds.put(colHeader.get(j),null);
                            }
                        } else if(sdsDataTypeMap.get(headerValue) == 'Date') {
                            if(validateDateValues(inputList[i][j].trim()) == 'Valid Date') {
                                sds.put(colHeader.get(j),date.parse(inputList[i][j].trim()));          
                            }  else if(validateDateValues(inputList[i][j].trim()) == 'Invalid Value') {
                                sdsErrormsg += 'Invalid '+sdsFieldLabelMap.get(headerValue)+' Value : '+inputList[i][j].trim()+' ; ';
                                sds.put(colHeader.get(j),null);     
                            }  else if(validateDateValues(inputList[i][j].trim()) == 'Invalid Format') {
                                sdsErrormsg += 'Invalid '+sdsFieldLabelMap.get(headerValue)+' Format: '+inputList[i][j].trim()+'. The Expected Format is MM/DD/YYYY.; ';
                                sds.put(colHeader.get(j),null);    
                            }
                        }                                                      
                    } else {                      
                        if( (sdsDataTypeMap.get(headerValue) == 'Currency') || (sdsDataTypeMap.get(headerValue) == 'Date') ) {
                            sds.put(colHeader.get(j),null);
                        } else {
                            sds.put(colHeader.get(j),'');
                        }                     
                    }  
                                       
                    if(j+1 == inputList.get(i).size()) {
                        
                        if(colValues !=null) {
                            colValues += inputList[i][j].trim(); 
                        }
                        
                        if(sds.Motorola_Enterprise_ID__c !=null) {
                            extIdKey = sds.Motorola_Enterprise_ID__c+'-'+sds.Refresh_Date__c+'-'+sourceFileType;                              
                            sds.put('Ent_Ven_Refresh_Dt_File_Type__c',extIdKey);      
                        } else if(sds.Vendor_Number__c!=null) {
                            extIdKey = sds.Vendor_Number__c+'-'+sds.Refresh_Date__c+'-'+sourceFileType;  
                            sds.put('Ent_Ven_Refresh_Dt_File_Type__c',extIdKey);
                        } else {
                             extIdKey = sds.Motorola_Enterprise_ID__c+'-'+sds.Refresh_Date__c+'-'+sourceFileType;
                             sds.put('Ent_Ven_Refresh_Dt_File_Type__c',extIdKey);     
                        }
                        System.debug('extIdKey::'+extIdKey);
                                                
                        if(sdsErrormsg == '')  {
                            
                            if(sdsFinalGraphDataMap.containskey(extIdKey) ){
                                System.debug('Index in If::'+extIdKey);
                                for(String fldApiName: sdsCurrencyDataTypeMap.keyset()) {
                                    SDS_Graphs_Data__c sdtemp = sdsFinalGraphDataMap.get(extIdKey);                                            
                                    oldCurrencyValue = (Decimal) sdtemp.get(fldApiName)!=null ? (Decimal)sdtemp.get(fldApiName) : 0;
                                    newCurrencyValue = (Decimal) sds.get(fldApiName) != null ? (Decimal) sds.get(fldApiName) : 0; 
                                    System.debug('oldCurrencyValue :::'+oldCurrencyValue); 
                                    System.debug('newCurrencyValue :::'+newCurrencyValue);                                     
                                    sds.put(fldApiName,oldCurrencyValue+newCurrencyValue);                                                    
                                }
                                sdsFinalGraphDataMap.put(extIdKey,sds);
                                upsertList.add(sds);
                                index = index +1;
                                sdsIndexErrorMap.put(index,sds);
                            } else {
                                System.debug('Index in else::'+extIdKey);
                                sdsFinalGraphDataMap.put(extIdKey,sds);
                                upsertList.add(sds);
                                index = index +1;
                                sdsIndexErrorMap.put(index,sds);
                            } 
                        } else {
                            errorSDSData = new TotalSDSdData();
                            errorSDSData.sdsTotal =sds;        
                            errorSDSData.errorMsgForEmail =sdsErrormsg;
                            sdsErrorMsgForEmailList.add(errorSDSData);                             
                        }    
                                         
                    } else {
                        if( inputList[i][j].contains(',')) {
                            colValues += (inputList[i][j]).replaceAll(',','')+',';    
                        } else {
                            colValues += inputList[i][j] +','; 
                        }
                    }
                } 
            
            }
        }    
        
        System.debug('sdsFinalGraphDataMap:::'+sdsFinalGraphDataMap);
        Database.UpsertResult[] srList;             
        if(upsertList != null) {                                      
            srList = Database.upsert(upsertList,Schema.SDS_Graphs_Data__c.Ent_Ven_Refresh_Dt_File_Type__c,false);            
        } 
        
        Integer i=0;       
        TotalSDSdData databaseErrorSDSData;  
        
        
        for (Database.UpsertResult sr : srList) {
            if (sr.isSuccess()) {
                i=i+1;
                successIdList.add(sr.getId());
            }
            else {                
                for(Database.Error err : sr.getErrors()) {
                    databaseErrorSDSData = new TotalSDSdData();
                    i=i+1;
                    String tempExtId = (String) sdsIndexErrorMap.get(i).get('Ent_Ven_Refresh_Dt_File_Type__c');                 
                    System.debug('tempExtId::'+tempExtId);
                    databaseErrorSDSData.sdsTotal =sdsFinalGraphDataMap.get(tempExtId);
                    System.debug('Sds::::'+databaseErrorSDSData.sdsTotal);
                    //databaseErrorSDSData.sdsTotal =sdsIndexErrorMap.get(i);
                    databaseErrorSDSData.errorMsgForEmail =err.getMessage();
                    System.debug('ErrorMessage::::'+err.getMessage());
                    sdsErrorMsgForEmailList.add(databaseErrorSDSData);  
                }
                
            }                
            
            
        }     
        /*
        for(Integer idx = srList.size() - 1; idx >=0; idx--) {
            if(srList[idx].isSuccess()) {
                i=i+1;
                successIdList.add(srList[idx].getId());    
            } else {   
                
                for(Database.Error err : srList[idx].getErrors()) {
                    databaseErrorSDSData = new TotalSDSdData();
                    i=i+1;
                    String tempExtId = (String) sdsIndexErrorMap.get(i).get('Ent_Ven_Refresh_Dt_File_Type__c');  
                    System.debug('tempExtId::'+tempExtId);
                    databaseErrorSDSData.sdsTotal =sdsFinalGraphDataMap.get(tempExtId);
                    System.debug('Sds::::'+databaseErrorSDSData.sdsTotal);
                    //databaseErrorSDSData.sdsTotal =sdsIndexErrorMap.get(i);
                    databaseErrorSDSData.errorMsgForEmail =err.getMessage();
                    System.debug('ErrorMessage::::'+err.getMessage());
                    sdsErrorMsgForEmailList.add(databaseErrorSDSData);
                    
                    System.debug('BackwordError::::'+idx+':::'+err.getMessage());
                    
                  
                }
                
                 
            }
        } 
         */
        
        errorCount = sdsErrorMsgForEmailList.size();     
        successCount =successIdList.size();
        totalCount = successCount+ errorCount;         
    }
    
    global void finish(Database.BatchableContext bc) {
        String errorColumnLinesOccurs ='';
        String strDate;
        String strError;
        if(sdsErrorMsgForEmailList.size() > 0) {
            System.debug('sdsErrorMsgForEmailList:::'+sdsErrorMsgForEmailList);
            errorColumnLinesOccurs='';
            errorColumnLinesOccurs = strErrorColHeaderLabel + 'ErrorMessage' + '\n';
            for(TotalSDSdData sdsDt: sdsErrorMsgForEmailList) {
                for(String str: colHeader) {
                    if(str != null) {
                        if(sdsDataTypeMap.get(str) == 'Date') {                          
                           strDate = sdsDt.sdsTotal.get(str) != null ? String.valueOf(sdsDt.sdsTotal.get(str)).replace(' 00:00:00','') : '';
                           errorColumnLinesOccurs += strDate +','; 
                        } else {
                            strError = sdsDt.sdsTotal.get(str) != null ? String.valueOf(sdsDt.sdsTotal.get(str)) : '';
                            errorColumnLinesOccurs += strError +',';                        
                        }
                    }                    
                }
                errorColumnLinesOccurs += sdsDt.errorMsgForEmail +'\n';       
            }           
        }
        
        System.debug('errorColumnLinesOccurs:::'+errorColumnLinesOccurs);
        
        if(errorColumnLinesOccurs!=null && errorColumnLinesOccurs!='') {
            Messaging.EmailFileAttachment csvAttc = new Messaging.EmailFileAttachment();
            Blob csvBlob = Blob.valueOf(errorColumnLinesOccurs);
            string csvname= sourceFileType+'_ErrorFile.csv';
            csvAttc.setFileName(csvname);
            csvAttc.setBody(csvBlob);
            Messaging.SingleEmailMessage email =new Messaging.SingleEmailMessage();            
            //String[] toAddresses = new String[] {'gpkx38@motorolasolutions.com'};
            String[] toAddresses = new String[] {UserInfo.getUserEmail()};          
            String subject ='Partner Scorecard Data Error File for '+sourceFileType;            
            email.setSubject(subject);
            email.setToAddresses( toAddresses );
            String bodyOfEmail = '';
            bodyOfEmail += '<font color=\'blue\'> Hi '+UserInfo.getFirstName()+' '+UserInfo.getLastName()+',</font><br/><br/>';
            bodyOfEmail += '<font color=\'blue\'>Below are the results of Partner Scorecard Data Import you have performed</font><br/><br/>';
            bodyOfEmail += '<font color=\'blue\'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;File Type: '+sourceFileType+'</font><br/><br/>';
            bodyOfEmail += '<font color=\'green\'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<b>Success Records: '+successCount+'</b></font><br/><br/>';
            bodyOfEmail += '<font color=\'red\'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<b>Error Records: '+errorCount+' (Attached is the Error File)</b></font><br/><br/>';
            bodyOfEmail += '<font color=\'blue\'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Total Records Processed: '+totalCount+'</font><br/><br/>';
            bodyOfEmail += '<font color=\'blue\'>Regards,<br/>Motorola Solutions</font><br/><br/>';
            email.setHtmlBody(bodyOfEmail);
            email.setFileAttachments(new Messaging.EmailFileAttachment[]{csvAttc});
            Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email}); 
        } else if(successCount > 0) {
            Messaging.SingleEmailMessage email =new Messaging.SingleEmailMessage();            
            //String[] toAddresses = new String[] {'gpkx38@motorolasolutions.com'};
            String[] toAddresses = new String[] {UserInfo.getUserEmail()};          
            String subject ='Partner Scorecard Data Success Result for '+sourceFileType;            
            email.setSubject(subject);
            email.setToAddresses( toAddresses );
            String bodyOfEmail = '';
            bodyOfEmail += '<font color=\'blue\'> Hi '+UserInfo.getFirstName()+' '+UserInfo.getLastName()+',</font><br/><br/>';
            bodyOfEmail += '<font color=\'blue\'>Below are the results of Partner Scorecard Data Import you have performed</font><br/><br/>';
            bodyOfEmail += '<font color=\'blue\'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;File Type: '+sourceFileType+'</font><br/><br/>';
            bodyOfEmail += '<font color=\'green\'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<b>Success Records: '+successCount+'</b></font><br/><br/>';
            bodyOfEmail += '<font color=\'blue\'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Total Records Processed: '+totalCount+'</font><br/><br/>';
            bodyOfEmail += '<font color=\'blue\'>Regards,<br/>Motorola Solutions</font><br/><br/>';
            email.setHtmlBody(bodyOfEmail);
            Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});                 
        }         
    
    }
    
    public String validateDateValues(String inputDateStrvalue) {
        System.debug('inputDateStrvalue:::'+inputDateStrvalue);             
        String dateRegEx = '(0?[1-9]|1[012])/(0?[1-9]|[12][0-9]|3[01])/((19|20)\\d\\d)';
        Pattern MyPattern = Pattern.compile(dateRegEx);
        Matcher MyMatcher = MyPattern.matcher(inputDateStrvalue);
        Boolean result = MyMatcher.matches();
        Date parsedDate ;  
        String dateErrormsg = '';
        if(result) {        
            String[] dtStr = inputDateStrvalue.split('/');
            if(dtStr.size() > 0 ) {
                Date myDate = date.newInstance(Integer.valueOf(dtStr[2]),Integer.valueOf(dtStr[0]),1);
                System.debug('actualmyDate:::'+myDate);
                myDate = myDate.addMonths(1);
                System.debug('myDate:::'+myDate);
                myDate = date.newInstance(myDate.year(),myDate.month(),1).addDays(-1);
                System.debug('myDate:::'+myDate);
                if(Integer.valueOf(dtStr[1]) <= myDate.day() ) {
                     dateErrormsg = 'Valid Date';
                } else {
                     dateErrormsg = 'Invalid Value';
                }
            }            
        } else {
            dateErrormsg = 'Invalid Format';
        }
        return dateErrormsg;
    }
    
    public Decimal validateDecimalValues(String inputDecStrvalue) {
        Boolean negativeFlag = false;
        Decimal retValue;
        if (inputDecStrvalue.contains('$')) {
          inputDecStrvalue = inputDecStrvalue.replace('$','');
        }
        if (inputDecStrvalue.contains(',')) {
          inputDecStrvalue = inputDecStrvalue.replace(',','');
          
        }
        if (inputDecStrvalue.startsWith('"') && inputDecStrvalue.endsWith('"')) {
          inputDecStrvalue = inputDecStrvalue.replace('"','');          
        }
        
        if (inputDecStrvalue.contains('(') && inputDecStrvalue.contains(')') ) {
          inputDecStrvalue = inputDecStrvalue.replace('(','');
          inputDecStrvalue = inputDecStrvalue.replace(')','');
          negativeFlag = true;
        }
        if (inputDecStrvalue.contains('-')) {
          inputDecStrvalue = inputDecStrvalue.replace('-','');
          negativeFlag =true;      
        }
        
        if(inputDecStrvalue.isNumeric()) {
            if(negativeFlag) {
                retValue= -Decimal.valueOf(inputDecStrvalue);
            } else {
                retValue= Decimal.valueOf(inputDecStrvalue);  
            }
        } else {
             retValue=null;   
        }        
        System.debug('retValue::'+retValue);
        return retValue;         
    }

}