//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Modified Date: 1/27/2020
//Modified By: Anitha Mohankumar
//Description: SF-2024 -To handle "Too many SOQL queries error" on Messaging.renderStoredEmailTemplate
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
public class BidScrubFileUploader
{
    public String opppID{get;set;}
    public String nameFile{get;set;}
    public Blob contentFile{get;set;}
    public List<Id> oppID{get;set;}
    public String oppTransaction {get;set;}    
    //public String payload { get; private set;}    
    public String apcValue {get;Set;}
    public String wwapcValue {get;set;}    
    public String[] filelines {get;set;}
    public String productName{get;set;}
    public List<Bid_Scrub__c> bidscrubtoupload;
    public Boolean errorFlag{get;set;}
    
    public BidScrubFileUploader(ApexPages.StandardController controller) {        
        filelines = new String[]{};
            bidscrubtoupload = new List<Bid_Scrub__c>();
    }
    
    // Method to read csv file
    public Pagereference ReadFile()
    { 
        errorFlag = false;
        boolean ErrFlag = false;
        boolean isoCodeRep = false;
        boolean warningFlag = false;
        boolean wwapcErrFlag = false;//Modified for SF-2217 
        String[] errors = new List<String>();
        map<String,String> nameToCode = new map<String,String>();
        
        List<String> codesList = new List<String>();
        boolean check = false;
        if(contentFile!=null && nameFile.contains('.csv')){
            nameFile=contentFile.toString();
            filelines = nameFile.split('\n');
            bidscrubtoupload = new List<Bid_Scrub__c>();
            Map<String,ID> oppMap= new Map<String,ID>();
            set<String> transactionNumber = new set<String>();
            Set<String> productNames = new Set<String>();
            Map<String,ID> productMap= new Map<String,ID>();
            List<bid_scrub__c> ExistingScrubs = new List<bid_scrub__c>();
            List<Messaging.SingleEmailMessage> mailsToSend = new List<Messaging.SingleEmailMessage>(); // added by Anusha
            Set<ID> OppIds = new Set<ID>();
            
            // added by Anusha
            Set<String> PFAPC = new Set<String>();
            Set<String> PFWWAPC = new Set<String>();
            Map<String,id> fpfMapAPC= new Map<String,id>();
            Map<String,id> fpfMapWWAPC = new Map<String,id>();
            Map<String,String> ProductNameMapAPC = new Map<String,String>();
            Map<String,String> ProductNameMapWWAPC = new Map<String,String>();
            //end
            Set<String> bidName = new Set<String>();            
            //compare two values in the list
            Map<String, String> transactionNumberMap = new Map<String, String>();
            Map<String, String> oppProductsMap = new Map<String, String>();
            for (Integer i=1;i<filelines.size();i++){
                String[] bidscrubvalues = new String[]{};
                bidscrubvalues = filelines[i].split(',');
                oppTransaction=bidscrubvalues[0];
                transactionNumber.add(oppTransaction);
                apcValue = bidscrubvalues[1];
                wwapcValue = bidscrubvalues[2];
                PFAPC.add(apcValue);
                PFWWAPC.add(wwapcValue);                
            }
            
            List<Opportunity> oppDetails =[Select ID,SYM_Transaction_Number__c,Name, Ownerid,Owner.Email from Opportunity where SYM_Transaction_Number__c in:transactionNumber];
            System.debug('Transaction Num: '+transactionNumber);
            System.debug('opp details: '+oppDetails);
            for(Opportunity opp: oppDetails){
                oppMap.put(opp.SYM_Transaction_Number__c,opp.ID);
                OppIds.add(opp.Id);
            }           
            for(String tn: transactionNumber){
                transactionNumberMap.put(tn,tn);
            }            
            for(String opm: productNames){
                oppProductsMap.put(opm,opm);
            }
            for (Integer i=1;i<filelines.size();i++){
                String[] inputvalues = new String[]{};
                inputvalues = filelines[i].split(',');
                isoCodeRep = false;
                if(inputvalues.size() == 1) {
                    continue;
                }
                // added all to strings to avoid error for all null values
                String col1;
                String col2;
                String col3;
                String col4;
                String col5;
                String col6;
                try{
                    col1 = inputvalues[0];
                    col2 = inputvalues[1];
                    col3 = inputvalues[2];
                    col4 = inputvalues[3];
                    col5 = inputvalues[4];
                    col6 = inputvalues[5];
                }
                catch (Exception e)
                {
                    System.debug('Error while uploading file' + e);
                    ApexPages.addmessage(new ApexPages.Message(ApexPages.severity.Error,'Please choose a valid csv file ' + e));
                    return null;
                }                
                if((String.isBlank(col1) && String.isBlank(col2) && String.isBlank(col3) & String.isBlank(col4) && String.isBlank(col5) && String.isBlank(col6))){
                    System.debug('Break');
                    ErrFlag = true;
                    //break;
                }
                //end                
                Bid_Scrub__c bid = new Bid_Scrub__c();
                if(inputvalues[0] != ''){ bid.Opportunity_Transaction_Number__c = inputvalues[0];
                                         bid.Opportunity__c = oppMap.get(inputvalues[0]);}
                
                //added by Anusha
                if(inputvalues[1] != '') {                    
                    if(inputvalues[1].length() < 4){//Added this block as part of SF-2217
                        bid.Product_APC__c = inputvalues[1].leftPad(4, '0');
                    }else{
                        bid.Product_APC__c = inputvalues[1];
                    }
                }
                if(inputvalues[2] != '') {
                    if(inputvalues[2].length() < 4){//Added this block as part of SF-2217
                        bid.Product_WWAPC__c = inputvalues[2].leftPad(4, '0');
                    }else{
                        bid.Product_WWAPC__c = inputvalues[2];
                    }                    
                }else{//Added this block as part of SF-2217-APCs to restict null WWAPC Code in Bid Scrub loads                    
                    ApexPages.addmessage(new ApexPages.Message(ApexPages.severity.FATAL,' Error uploading the Bid Scrub with Transaction number :'+ bid.Opportunity_Transaction_Number__c + '. Please review and correct errors for missing Product WWAPC'));
                    System.debug('Break wwapcErrFlag');
                }
                try{
                    if(inputvalues[3] != '') { bid.Quantity__c = decimal.valueOf(inputvalues[3]); }                    
                    if(inputvalues[4] != '') { bid.UnitPrice__c = decimal.valueOf(inputvalues[4]); }
                }
                catch (Exception e)
                {
                    System.debug('Error while uploading file' + e);                    
                }                
                Set<String> validEntries = new set<String>();
                for (PicklistEntry entry : Bid_Scrub__c.CurrencyIsoCode.getDescribe().getPicklistValues()){
                    validEntries.add(entry.getValue());
                }
                
                String currencyisoCode = inputvalues[5];
                String currencycode = currencyisoCode.trim();
                System.debug('Sub String ##'+ currencycode);
                System.debug('size String $$: ' + currencycode.length() );
                if(currencyisoCode != null){
                    if(validEntries.contains(currencycode)){
                        bid.CurrencyIsoCode = currencycode;
                    }
                }
                
                System.debug('bid.Opportunity_Transaction_Number__c ##'+ bid.Opportunity_Transaction_Number__c);
                
                if (nameToCode.containsKey(bid.Opportunity_Transaction_Number__c) )
                {
                    String bidMapTransNumber = nameToCode.get(bid.Opportunity_Transaction_Number__c);
                    System.debug('map trans number::'+nameToCode.get(bid.Opportunity_Transaction_Number__c)+'IsoCode '+bid.CurrencyIsoCode);
                    System.debug('nameToCode.get(bid.Opportunity_Transaction_Number__c) ##'+ nameToCode.get(bid.Opportunity_Transaction_Number__c));
                    if (nameToCode.get(bid.Opportunity_Transaction_Number__c) != bid.CurrencyIsoCode ){
                        ApexPages.addmessage(new ApexPages.Message(ApexPages.severity.FATAL,' Error uploading the Bid Scrub with Transaction number :'+ bid.Opportunity_Transaction_Number__c +'.'+' Please review and correct errors for missing or invalid transaction numbers and/or currency codes.'));
                        isoCodeRep = true;
                        //return null;
                        //ApexPages.addmessage(new ApexPages.Message(ApexPages.severity.Warning,'File upload failed. Please review and correct errors for missing or invalid currency codes.')); 
                    }                   
                } else
                    nameToCode.put(bid.Opportunity_Transaction_Number__c,bid.CurrencyIsoCode);System.debug('name to code map ##' +nameToCode.put(bid.Opportunity_Transaction_Number__c,bid.CurrencyIsoCode) );
                
                System.debug('Break ErrFlag' + ErrFlag );                
                if((bid.Quantity__c != null && bid.UnitPrice__c != null && bid.CurrencyIsoCode != null && bid.Opportunity__c != null && bid.Name != 'N/A' && (!isoCodeRep) ))
                {
                    //ApexPages.addmessage(new ApexPages.Message(ApexPages.severity.Error,'Error uploading the Bid Scrub with Transaction number :'+ bid.Opportunity_Transaction_Number__c +' , ' +'APC : '+' '+ +bid.Product_APC__c+','+'WWAPC: '+' '+ bid.Product_WWAPC__c+ +'.'+ 'Missing or Invalid APC/WWAPC/Quantity/Unit Price/Currency Code/Transaction Number.'));
                    bidscrubtoupload.add(bid);
                    //payload = JSON.serialize(bidscrubtoupload);
                }                
                else if(!ErrFlag){//Modified for SF-2217                     
                    ApexPages.addmessage(new ApexPages.Message(ApexPages.severity.FATAL,'Error uploading the Bid Scrub with Transaction number :'+ bid.Opportunity_Transaction_Number__c +' , ' +'APC : '+' '+ +bid.Product_APC__c+','+'WWAPC: '+' '+ bid.Product_WWAPC__c+ ',bid.Name:'+ bid.Name +'bid.CurrencyIsoCode:'+ bid.CurrencyIsoCode + '.' + ' Missing or Invalid APC/WWAPC/Quantity/Unit Price/Currency Code/Transaction Number.'));
                    errorFlag = True; 					                 
                }                
            }
            if (ApexPages.hasMessages(ApexPages.Severity.FATAL)){
                ApexPages.addmessage(new ApexPages.Message(ApexPages.severity.WARNING,'Failed to upload file : Please verify the errors for above listed transactions'));
                bidscrubtoupload.clear();   
                return null;
            }            
            else try{
                if(transactionNumber.size()>0 && bidscrubtoupload.size() > 0){
                    system.debug('Entered Transaction number > 0');
                    if(oppDetails.size()<=50){  
                        if(oppMap.keySet().equals(transactionNumberMap.keySet()) || !(oppMap.keySet().equals(transactionNumberMap.keySet())) ){
                            system.debug('Entered line opp Map and trans num');
                            //ExistingScrubs = [Select id From Bid_scrub__c where Opportunity_Transaction_Number__c in :transactionNumber];
                            ExistingScrubs = [Select id From Bid_scrub__c where Opportunity__c in :OppIds];
                            System.debug('Existing scrubs:'+ExistingScrubs );
                            System.debug('Existing scrubs Size:'+ExistingScrubs.size());
                            If (ExistingScrubs.size()>0)
                                try{
                                    Delete ExistingScrubs;
                                    ApexPages.addmessage(new ApexPages.Message(ApexPages.severity.INFO,'Existing bid scrubs deleted Successfully'));
                                }catch (Exception e){
                                    System.debug('Error deleting the existing bid scrubs:' + e);
                                    ApexPages.Message errormsg = new ApexPages.Message(ApexPages.severity.ERROR,'Error deleting the existing bid scrubs:' + e);
                                    ApexPages.addMessage(errormsg);
                                    errorFlag = True;
                                    return null;
                                }                            
                            try{
                                insert bidscrubtoupload;
                                ApexPages.addmessage(new ApexPages.Message(ApexPages.severity.INFO,'File Uploaded Successfully'));
                            }catch (Exception e){
                                System.debug('Error when inserting bid scrubs:' + e);
                                ApexPages.Message errormsg = new ApexPages.Message(ApexPages.severity.ERROR,'Error uploading the new bid scrubs:' + e);
                                ApexPages.addMessage(errormsg);
                                errorFlag = True;
                                return null;
                            }                            
                            OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'info.na@motorolasolutions.com' limit 1];
                            List<EmailTemplate> bidScrubTemplate = [select id,createdby.name,Name,DeveloperName from emailtemplate  where DeveloperName='Bid_Scrub_Notification' limit 1];
                            String bidScrubTemplateId = '';                            
                            if(!bidScrubTemplate.isEmpty()){
                                bidScrubTemplateId = bidScrubTemplate.get(0).Id;
                            }                                                     
                            System.debug('oppDetails.size()====>' + oppDetails.size());                            
                            for(Opportunity opp: oppDetails){                             
                                Messaging.SingleEmailMessage mail = Messaging.renderStoredEmailTemplate(bidScrubTemplateId,opp.ownerId,opp.Id);
                                mail.saveAsActivity = false;                                           
                                if (owea.size() > 0) {
                                    mail.setOrgWideEmailAddressId(owea.get(0).Id);
                                }                            
                                mailsToSend.add(mail);
                                System.debug('Mails' +mailsToSend);                                                       
                            }                            
                            try{
                                System.debug('mailsToSend##'+mailsToSend);
                                if(mailsToSend.size() > 0){
                                    Messaging.sendEmail(mailsToSend);
                                    //insert NewTaskRecords;
                                    ApexPages.addmessage(new ApexPages.Message(ApexPages.severity.INFO,'Email notification sent to the Opportunity Booking owner'));
                                }                                
                            }catch (Exception e){
                                System.debug('Error when creating Activity history:' + e);
                                ApexPages.Message errormsg = new ApexPages.Message(ApexPages.severity.ERROR,'Failed to send email notification to the Opportunity Owner:' + e);
                                ApexPages.addMessage(errormsg);
                                errorFlag = True;
                            }
                        }                        
                        else{
                            ApexPages.Message errormsg = new ApexPages.Message(ApexPages.severity.Warning,'Failed to upload the file. Please verify the values');
                            ApexPages.addMessage(errormsg);                            
                        }
                    }else{                        
                        ApexPages.Message errormsg = new ApexPages.Message(ApexPages.severity.ERROR,'Total unique Opportunities count is {' + oppDetails.size() +'}.  Please load the file with 50 or fewer unique Opportunities.');
                        ApexPages.addMessage(errormsg);
                        errorFlag = True;
                    }
                }
            }
            catch (Exception e){
                ApexPages.Message errormsg = new ApexPages.Message(ApexPages.severity.ERROR,'An error has occured. Please check the template or try again later'+e);
                ApexPages.addMessage(errormsg);
                errorFlag = True;
            }            
        }
        else{   //Display error message when no CSV file is chosen
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,'Please choose a valid CSV file'));
            errorFlag = True;
        }        
        return null;
    }    
    public String getuploadedBidScrubs()
    {
        system.debug('errorFlag===>'+errorFlag);
        if (!bidscrubtoupload.isEmpty() && !errorFlag)            
            return 'PRODUCT FAMILY LINE ITEMS WITHOUT ERRORS : ' + bidscrubtoupload.size();
        else
            return null;
    }   
}