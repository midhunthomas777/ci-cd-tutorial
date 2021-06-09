public class LeadRoutingHelper {
    
    private Id globalRecTypeId = GlobalUtility.recordTypeId('Lead', 'Global Lead Record');
    Public static Boolean isLeadSurveyCreated = false;
    
    
    public void leadRouting(List<Lead> leadIncomingList){
        system.debug('In leadRouting');
        Set<String> emailDomainSet = new Set<String>();
        Set<Id> customerAccountIds = new Set<id>();
        Boolean isTrackDirect = false;
        Map<Id,Lead> AccountLeadMap = new Map<Id,Lead>();
        Map<Id,Id> AccountOwnerMap = new Map<Id,Id>();
        Map<Id,String> OwnerMap = new Map<Id,String>();
        Map<Id,String> AccountOwnerEmailMap = new Map<Id,String>();
        
        
        for(Lead leadRecord : leadIncomingList){
            if(leadRecord.Account__c!=null){
                customerAccountIds.add(leadRecord.Account__c);
            }
            
            if(leadRecord.Visitor_Info__c!=null) {
                String googleAnalyticsURL= leadRecord.Visitor_Info__c;
                Map<String,String> decodedURLMap = new Map<String,String>();
                decodedURLMap.putAll(new LM_PartnerLeadManagementHelper().decodeGoogleAnalyticsURL(googleAnalyticsURL));
                if(decodedURLMap!=null && !(decodedURLMap.isEmpty())) {
                    leadRecord.Source__c = decodedURLMap.get('utm_source');
                    leadRecord.Medium__c = decodedURLMap.get('utm_medium');
                    leadRecord.Content__c = decodedURLMap.get('utm_content');
                    leadRecord.Campaign_URL__c = decodedURLMap.get('utm_campaign');
                }
            }
            
        }        
        
        Map<String,List<CAM_Geo_Map__c>> usCamGeoMappings=new Map<String,List<CAM_Geo_Map__c>>();
        Map<String,List<CAM_Geo_Map__c>> defCamGeoMappings=new Map<String,List<CAM_Geo_Map__c>>();
        Map<String,List<CAM_Geo_Map__C>> trackVertTechGeoMap = new Map<String,List<CAM_Geo_Map__C>>();
        Map<String,List<CAM_Geo_Map__C>> trackTechGeoMap = new Map<String,List<CAM_Geo_Map__C>>();
        Map<String,List<CAM_Geo_Map__C>> trackVertGeoMap = new Map<String,List<CAM_Geo_Map__C>>();
        Map<String,List<CAM_Geo_Map__C>> trackGeoMap = new Map<String,List<CAM_Geo_Map__C>>();
        
        
        for(CAM_Geo_Map__c camRecord : [SELECT ID, Country__c, State_Province__c, track__c, Territory__c,Vertical__c,product_family__c,Product_Family__r.name,Channel_Account_Manager__r.id, 
                                        Indirect_Channel_Account_Manager__c, Status__c, Channel_Account_Manager__r.name,region__c,Functions__c, Channel_Account_Manager__r.email,Channel_Account_Manager__r.IsActive,
                                        Indirect_Channel_Account_Manager__r.IsActive,Director__r.IsActive,SE_Sales_Rep__c FROM CAM_Geo_Map__c]){
                                            //SF- 1968 -Modified camRecord.product_family__c = NULL && camRecord.Vertical__c == '' to String.isBlank(String.isBlank(camRecord.product_family__c) && String.isBlank(camRecord.Vertical__c)) && String.isBlank(camRecord.Vertical__c)
                                            if(camRecord.Functions__c == 'Lead Mgt' && (camRecord.region__c == 'NAMR' || camRecord.region__c == 'NA') && String.isBlank(camRecord.product_family__c) && String.isBlank(camRecord.Vertical__c)) {
                                                
                                                if(String.isNotBlank(camRecord.State_Province__c)) {                    
                                                    if(usCamGeoMappings.get(camRecord.State_Province__c) == null){
                                                        usCamGeoMappings.put(camRecord.State_Province__c,new List<CAM_Geo_Map__c>());
                                                        usCamGeoMappings.get(camRecord.State_Province__c).add(camRecord);
                                                    }else{
                                                        usCamGeoMappings.get(camRecord.State_Province__c).add(camRecord);
                                                    }
                                                } 
                                            } else if(camRecord.Functions__c == 'Lead Mgt' && camRecord.Country__c == 'DEFAULT OWNER NAMR' && camRecord.region__c == 'NAMR') {
                                                
                                                if(defcamGeoMappings.get(camRecord.track__c)==null){
                                                    defcamGeoMappings.put(camRecord.track__c,new List<CAM_Geo_Map__c>());
                                                    defcamGeoMappings.get(camRecord.track__c).add(camRecord );
                                                }else{
                                                    defcamGeoMappings.get(camRecord.track__c).add(camRecord );
                                                }            
                                            }else if(camRecord.product_family__c != NULL || camRecord.Vertical__c != '') {
                                                
                                                String tempProdName = '';
                                                if(camRecord.product_family__c != null){
                                                    tempProdName = camRecord.Product_Family__r.name;                            
                                                }               
                                                if(String.isNotBlank(tempProdName) && String.isNotBlank(camRecord.Track__c) && String.isNotBlank(camRecord.Vertical__c)){
                                                    
                                                    if(!trackVertTechGeoMap.keyset().contains(tempProdName+';'+camRecord.track__c+';'+camRecord.Vertical__c)){
                                                        trackVertTechGeoMap.put(tempProdName+';'+camRecord.track__c+';'+camRecord.Vertical__c,new List<CAM_Geo_Map__c>());
                                                        trackVertTechGeoMap.get(tempProdName+';'+camRecord.track__c+';'+camRecord.Vertical__c).add(camRecord);
                                                    } else {
                                                        trackVertTechGeoMap.get(tempProdName+';'+camRecord.track__c+';'+camRecord.Vertical__c).add(camRecord);
                                                    }
                                                }                
                                                if(String.isNotBlank(tempProdName) && String.isNotBlank(camRecord.Track__c)){
                                                    
                                                    if(!trackTechGeoMap.keyset().contains(tempProdName+';'+camRecord.track__c)) {
                                                        trackTechGeoMap.put(tempProdName+';'+camRecord.track__c,new List<CAM_Geo_Map__c>());
                                                        trackTechGeoMap.get(tempProdName+';'+camRecord.track__c).add(camRecord);
                                                    } else {
                                                        trackTechGeoMap.get(tempProdName+';'+camRecord.track__c).add(camRecord);
                                                    } 
                                                }
                                                if(String.isNotBlank(camRecord.Track__c) && String.isNotBlank(camRecord.Vertical__c)){
                                                    
                                                    if(!trackVertGeoMap .keyset().contains(camRecord.Vertical__c+';'+camRecord.track__c)){
                                                        trackVertGeoMap .put(camRecord.Vertical__c+';'+camRecord.track__c,new List<CAM_Geo_Map__c>());
                                                        trackVertGeoMap .get(camRecord.Vertical__c+';'+camRecord.track__c).add(camRecord); 
                                                    } else {
                                                        trackVertGeoMap .get(camRecord.Vertical__c+';'+camRecord.track__c).add(camRecord);
                                                    }
                                                }                
                                                if(String.isNotBlank(camRecord.Track__c)){
                                                    
                                                    if(!trackGeoMap .keyset().contains(camRecord.track__c)){
                                                        trackGeoMap .put(camRecord.track__c,new List<CAM_Geo_Map__c>());
                                                        trackGeoMap .get(camRecord.track__c).add(camRecord); 
                                                    } else {
                                                        trackGeoMap .get(camRecord.track__c).add(camRecord);
                                                    }
                                                }                
                                            }
                                        }
        
        system.debug('usCamGeoMappings :='+usCamGeoMappings);
        system.debug('defCamGeoMappings :='+defCamGeoMappings);
        system.debug('trackVertTechGeoMap :='+trackVertTechGeoMap);
        system.debug('trackTechGeoMap :='+trackTechGeoMap);
        system.debug('trackVertGeoMap :='+trackVertGeoMap);
        system.debug('trackGeoMap :='+trackGeoMap);
        
        
        //MR Program Start///////
        Group iSSLEDQueue = [Select Id from Group where Type = 'Queue' AND Name = 'Inside Led RTM' LIMIT 1];
        system.debug('iSSLEDQueue :='+iSSLEDQueue);
        
        //MR Program End///////        
        Map<Id,List<Account>> custMcnMap = new Map<Id,List<Account>>();
        for(Account mcnAcc : [select id,Customer_or_Prospect_Account__c,Primary_Route_to_Market__c,Assigned_MR__c,Customer_or_Prospect_Account__r.ownerid FROM 
                              Account WHERE recordtype.name='Motorola Customer Number' and Customer_or_Prospect_Account__c IN : customerAccountIds])
        {
            if(!(custMcnMap.keyset().contains(mcnAcc.Customer_or_Prospect_Account__c))){
                custMcnMap.put(mcnAcc.Customer_or_Prospect_Account__c,new List<Account>());
            }
            custMcnMap.get(mcnAcc.Customer_or_Prospect_Account__c).add(mcnAcc);
        }
        system.debug('custMcnMap :='+custMcnMap);        
        boolean tempBool1 = false;
        boolean tempBool2 = false;
        boolean leadToActionFlag = true;
        List<CAM_Geo_Map__c> tempMappings = new List<CAM_Geo_Map__c>();

        for(Lead updatedLead : leadIncomingList) { 
            String stateCodefromAPI = '';
            String countryFromCS = '';
            if(LM_StateCode__c.getInstance(updatedLead.State) != null){
                stateCodefromAPI = LM_StateCode__c.getInstance(updatedLead.State).State_Code__c;   
            }
            
            if(CDH_Country_Region_Mapping__c.getInstance(updatedLead.Countrycode) != null){
                countryFromCS = CDH_Country_Region_Mapping__c.getInstance(updatedLead.Countrycode).country__c;
            }
            
            
            if(updatedLead.Region__c == 'NA' && updatedLead.Track__c == 'Direct' && updatedLead.Technology_Segment__c != null){
                //Call last method
                isTrackDirect = true;
            }
            
            if(updatedLead.Account__c != NULL && updatedLead.Region__c == 'NA'  && updatedLead.status == 'Marketing Lead' && updatedLead.Track__c == 'Direct') {
                system.debug('Check for Record entry - check account!=null');
                Set<String> routeSet = New Set<String>();
                if(!custMcnMap.isEmpty() &&  custMcnMap.keyset().contains(updatedLead.Account__c)) {
                    for(Account mcnAcc : custMcnMap.get(updatedLead.Account__c)){
                        routeSet.add(mcnAcc.Primary_Route_to_Market__c);   
                    }
                    system.debug('custMcnMap :='+custMcnMap);
                    system.debug('routeSet :='+routeSet);
                    if(routeSet.size() == 1) {
                        if(custMcnMap.get(updatedLead.Account__c) != null && custMcnMap.get(updatedLead.Account__c).size() > 0){
                            Account mcnAccountCheck = custMcnMap.get(UpdatedLead.Account__c)[0];
                            if(mcnAccountCheck.Primary_Route_to_Market__c=='Partner Led' || mcnAccountCheck.Primary_Route_to_Market__c=='MSI Led' || mcnAccountCheck.Primary_Route_to_Market__c=='MR Led') {
                                updatedLead.OwnerId = mcnAccountCheck.Customer_or_Prospect_Account__r.OwnerId;    
                                leadToActionFlag = false;
                            }
                        }
                    } else{
                        leadToActionFlag=false; 
                    }
                }
            }
            system.debug('leadToActionFlag :='+leadToActionFlag);
            
            if(updatedLead.Region__c == 'NA' && updatedLead.Track__c != null && updatedLead.Status == 'Marketing Lead'){ 
                system.debug('Check for Record entry - doesn\'t check account');
                //MR Program Start///////
                Set<String> routeSet = New Set<String>();            
                if(!custMcnMap.isEmpty() && custMcnMap.keyset().contains(updatedLead.Account__c)) {
                    for(Account mcnAcc : custMcnMap.get(updatedLead.Account__c)){
                        routeSet.add(mcnAcc.Primary_Route_to_Market__c);   
                    }
                    system.debug('custMcnMap :='+custMcnMap);
                    system.debug('routeSet :='+routeSet);
                    if(routeSet.size() == 1) {
                        Account mcnAccountCheck = custMcnMap.get(UpdatedLead.Account__c)[0];
                        if(mcnAccountCheck.Primary_Route_to_Market__c=='Inside Sales/Tele-Sales Led' ) {
                            updatedLead.OwnerId = iSSLEDQueue.Id;    
                            leadToActionFlag = false;
                        }
                    }
                }
                system.debug('leadToActionFlag :='+leadToActionFlag);
                
                //MR Program End///////
                if(leadToActionFlag){
                    if(updatedLead.Statecode != null) {
                        tempBool1 = updatedLead.Countrycode !=null && updatedLead.Statecode !=null && usCamGeoMappings.get(updatedLead.Statecode) != null;
                        tempMappings= usCamGeoMappings.get(updatedLead.Statecode);
                    }
                    if(String.isNotBlank(updatedLead.State)) {
                        if(LM_StateCode__c.getInstance(updatedLead.State) != null){
                            if(LM_StateCode__c.getInstance(updatedLead.State).State_Code__c != null) {
                                tempBool2 = String.isNotBlank(updatedLead.Country) && String.isNotBlank(updatedLead.State) && usCamGeoMappings.get(LM_StateCode__c.getInstance(updatedLead.State).State_Code__c) != null;
                                tempMappings = usCamGeoMappings.get(LM_StateCode__c.getInstance(updatedLead.State).State_Code__c);
                                
                            } 
                        }
                    }                
                    system.debug('tempBool1 :='+tempBool1);
                    system.debug('tempBool2 :='+tempBool2);
                    if(tempBool1 || tempBool2){
                        for(CAM_Geo_Map__c camTrackRecord : tempMappings) {
                            
                            if((camTrackRecord.track__c == updatedLead.Track__c && camTrackRecord.State_Province__c == updatedLead.Statecode && 
                                camTrackRecord.Country__c == CDH_Country_Region_Mapping__c.getInstance(updatedLead.Countrycode).country__C) || 
                               (camTrackRecord.track__c == updatedLead.Track__c && camTrackRecord.State_Province__c== LM_StateCode__c.getInstance(updatedLead.State).State_Code__c && 
                                camTrackRecord.Country__c== updatedLead.Country)) {
                                    
                                    updatedLead.OwnerID = camTrackRecord.Channel_Account_Manager__c;
                                    updatedLead.CAM_Assigned_To__c = camTrackRecord.ID;
                                    if(globalRecTypeId ==  updatedLead.Recordtypeid && updatedLead.Region__c == 'NA' &&  camTrackRecord.Indirect_Channel_Account_Manager__c!=null){
                                        updatedLead.Indirect_CAM__c= camTrackRecord.Indirect_Channel_Account_Manager__c;
                                    }
                                    updatedLead.CAM_Assigned_Date__c = DateTime.now();
                                } 
                        }
                    } else {
                        if(defcamGeoMappings.size()>0 && (defcamGeoMappings.get(updatedLead.Track__c)!=null)) {
                            system.debug('defcamGeoMappings :='+defcamGeoMappings);
                            
                            for(CAM_Geo_Map__c camTrackRecord : defcamGeoMappings.get(updatedLead.Track__c) ) {
                                if(camTrackRecord.track__c == updatedLead.Track__c) {
                                    updatedLead.OwnerID = camTrackRecord.Channel_Account_Manager__c;
                                    updatedLead.CAM_Assigned_To__c = camTrackRecord.ID;
                                    updatedLead.CAM_Assigned_Date__c = datetime.now();
                                }
                            }
                        }
                    }
                }
            }
            
            system.debug('trackVertTechGeoMap :='+trackVertTechGeoMap);
            system.debug('trackTechGeoMap :='+trackTechGeoMap);
            system.debug('trackVertGeoMap :='+trackVertGeoMap);
            system.debug('trackGeoMap :='+trackGeoMap);
            system.debug('');
            
            if(!trackVertTechGeoMap.isEmpty() || !trackTechGeoMap.isEmpty() || !trackVertGeoMap.isEmpty() || !trackGeoMap.isEmpty()) {
                updatedLead.Technology_Segment__c = convertNULLtoBlank(updatedLead.Technology_Segment__c);
                updatedLead.Track__c = convertNULLtoBlank(updatedLead.Track__c);
                updatedLead.Industry = convertNULLtoBlank(updatedLead.Industry);
                
                List<CAM_Geo_Map__c> PRMGeoMappings = new List<CAM_Geo_Map__c>();
                if(trackVertTechGeoMap.get(updatedLead.Technology_Segment__c+';'+updatedLead.Track__c+';'+updatedLead.Industry) != null){
                    PRMGeoMappings = trackVertTechGeoMap.get(updatedLead.Technology_Segment__c+';'+updatedLead.Track__c+';'+updatedLead.Industry);
                } else if(trackTechGeoMap.get(updatedLead.Technology_Segment__c+';'+updatedLead.Track__c)!=null) {
                    if(updatedLead.Technology_Segment__c!=null && updatedLead.Technology_Segment__c!='') {
                        PRMGeoMappings = trackTechGeoMap.get(updatedLead.Technology_Segment__c+';'+updatedLead.Track__c);   
                    }
                } else if(trackVertGeoMap.get(updatedLead.Industry+';'+updatedLead.Track__c)!=null){
                    if(updatedLead.Industry!=null && updatedLead.Industry!='') {
                        PRMGeoMappings = trackVertGeoMap.get(updatedLead.Industry+';'+updatedLead.Track__c);   
                    }
                } else if(trackGeoMap.get(updatedLead.Track__c)!=null){
                    PRMGeoMappings = trackGeoMap.get(updatedLead.Track__c);
                }
                
                system.debug('PRMGeoMappings "='+PRMGeoMappings);
                system.debug('leadToActionFlag :='+leadToActionFlag);
                system.debug('isTrackDirect :='+isTrackDirect);
                
                
                if(PRMGeoMappings != null && (leadToActionFlag || isTrackDirect)) {
                    
                    for(CAM_Geo_Map__c TechTrack: PRMGeoMappings) {
                        
                        //Assign to SE Sales Rep
                        if(updatedLead.status == 'Marketing Lead'){
                            
                            if(updatedLead.Populate_SE_Sales_Rep__c == true) {
                                System.debug('List 2 Product assignment to SE Sales Rep');
                                
                                if((TechTrack.State_Province__c == updatedLead.Statecode || TechTrack.State_Province__c == stateCodefromAPI) &&
                                   (TechTrack.Country__c == updatedLead.Country || TechTrack.Country__c == countryFromCS) && String.isNotBlank(updatedLead.Region__c) //){
                                   && TechTrack.product_family__r.name == updatedLead.Technology_Segment__c){ //SF-1968
                                       
                                       system.debug('TechTrack.SE_Sales_Rep__c ='+TechTrack.SE_Sales_Rep__c);
                                       
                                       if(String.isNotBlank(TechTrack.SE_Sales_Rep__c)){
                                           updatedLead.OwnerID = TechTrack.SE_Sales_Rep__c;    
                                       }                                   
                                       updatedLead.Indirect_CAM__c= TechTrack.Indirect_Channel_Account_Manager__c;
                                       updatedLead.CAM_Assigned_To__c = TechTrack.ID;
                                       updatedLead.CAM_Assigned_Date__c = datetime.now();                             
                                   }
                            }
                            
                            //Assign to Channel Account Manager
                            else {
                                system.debug('Other Product assignment to Channel Account Manager');
                                
                                if((TechTrack.State_Province__c == updatedLead.Statecode || TechTrack.State_Province__c == stateCodefromAPI) &&
                                   (TechTrack.Country__c == updatedLead.Country || TechTrack.Country__c == countryFromCS) && String.isNotBlank(updatedLead.Region__c) //){
                                   && TechTrack.product_family__r.name == updatedLead.Technology_Segment__c){ //SF-1968
                                       
                                       if(String.isNotBlank(TechTrack.Channel_Account_Manager__c)){
                                           updatedLead.OwnerID = TechTrack.Channel_Account_Manager__c;    
                                       }                                   
                                       updatedLead.Indirect_CAM__c= TechTrack.Indirect_Channel_Account_Manager__c;
                                       updatedLead.CAM_Assigned_To__c = TechTrack.ID;
                                       updatedLead.CAM_Assigned_Date__c = datetime.now();                             
                                   }
                            }  
                            system.debug('updatedLead.ownerid ='+updatedLead.OwnerId);
                        } 
                    }
                }
                
                
                if(!AccountLeadMap.containsKey(updatedLead.Account__c)){
                    AccountLeadMap.put(updatedLead.Account__c,updatedLead);
                }
            }
            
            //Populate Account owner email on the Lead record 

        }
        for(Account account: [SELECT Id,Name,OwnerId FROM Account WHERE Id IN: AccountLeadMap.KeySet()]){
            AccountOwnerMap.put(account.Id,account.OwnerId);
        }
        
        for(User user : [SELECT Id,Email FROM User WHERE Id IN: AccountOwnerMap.values()]){
            OwnerMap.put(user.Id,user.Email);
        }
        
        for(Id accId:AccountOwnerMap.keySet()){
            Id ownerId = AccountOwnerMap.get(accId);
            
            if(OwnerMap.containsKey(ownerId)){
                AccountOwnerEmailMap.put(accId,OwnerMap.get(ownerId));
            }
        }
        
        
        for(Id accId : AccountLeadMap.keySet()){
            
            if(AccountOwnerEmailMap.containsKey(accId)){
                Lead lead = AccountLeadMap.get(accId);
                
                if(lead.Account_Owner_Email__c == null)
                    lead.Account_Owner_Email__c = AccountOwnerEmailMap.get(accId);
            }
        }
    }
    
    private static String convertNULLtoBlank(String nullString) {
        if(nullString == null) {
            return '';
        }
        return nullString;
    }
    
    public void insertSurveyToCustomer(Set<Lead> leads){ 
        List<Lead_Survey__c> toBeInserted = new List<Lead_Survey__c>();
        if(!isLeadSurveyCreated){
            for(Lead leadRecords : leads){
                if(String.isNotBlank(leadRecords.Partner_Assigned_Contact_NA__c)){
                    Lead_Survey__c leadSurvey = new Lead_Survey__c();
                    leadSurvey.Account_External_Id__c= leadRecords.Partner_Account_NA__c;
                    leadSurvey.Account__c      = leadRecords.Partner_Account_NA__c;
                    leadSurvey.Assigned_On__c  = datetime.now();
                    leadSurvey.Contact__c      = leadRecords.Partner_Assigned_Contact_NA__c;
                    leadSurvey.Customer_Email__c = leadRecords.Email;
                    leadSurvey.Lead__c = leadRecords.Id;
                    leadSurvey.Status__c = 'Schedule';
                    toBeInserted.add(leadSurvey);
                }
            }
        }
        if(!toBeInserted.isEmpty()){
            database.insert(toBeInserted,false);
            isLeadSurveyCreated = true;
        }
    }
    
    public Map<Id,Account> fetchAccounts (Set<Id> AccountIds){
        system.debug('--fetchAccounts--');
        Map<Id,Account> accountsToReturn = new Map<Id,Account>();
        List<Account> accountsFetched = [SELECT Id,Name,OwnerId FROM Account WHERE Id IN : AccountIds];
        for(Account acc:accountsFetched){
            if(accountsToReturn.get(acc.id) == null)
                accountsToReturn.put(acc.id, acc);
        }

        return accountsToReturn;
    }
    
    /* SF-2468 - Leads where Track = 'Direct
Checks for the Product and Account on Lead and send the Leads for routing*/
    
    public List<Lead> methodForTrackDirect(Set<String> productsOnLead,Map<String,Lead> accountLeadMap,Map<String,Lead> productLeadMap,List<Lead> newItems){
        system.debug('called methodForTrackDirect');
        List<Product2> productsListfetched = new List<Product2>();
        List<Lead> leadListWithoutAccount = new List<Lead>();
        List<Lead> leadListtoBeRouted = new List<Lead>();
        List<Account> accountListFetched = new List<Account>();
        List<Product2> productsWithNoRTM = new List<PRoduct2>();
        List<Lead> leadstoBeAssignedToUser;
        List<Account> accountsReturned = new List<Account>();
        List<Lead> leadList = new List<Lead>();
        
        Set<Id> accountIds = new Set<Id>();
        Set<String> list1Products = new Set<string>();
        Set<String> otherProducts = new Set<string>();
        Set<String> routeSet = New Set<String>();
        
        Map<String,Product2> list2techSegProductMap = new Map<String,Product2>();
        Map<Lead,Account> leadAccountMap = new Map<Lead,Account>();
        Map<String,Account> accountMap = new Map<String,Account>();
        Map<Id,List<Account>> custMcnMap = new Map<Id,List<Account>>();
        Map<Id,Account> accountOwnerMap = new Map<Id,Account>();
        
        Account mcnAccountCheck;
        
        //Fetch product fields of Product populated on Lead
        if(!productLeadMap.isEmpty()){
            system.debug('productLeadMap :='+productLeadMap);
            productsListfetched = [Select Id, Name, RTM_Values_For_Lead_Assignment__c FROM Product2 WHERE Name IN: productLeadMap.keyset()];
            
            for(Product2 product : productsListfetched){
                system.debug('product :='+product);
                system.debug('product.RTM_Values_For_Lead_Assignment__c :='+product.RTM_Values_For_Lead_Assignment__c);
                
                if(product.RTM_Values_For_Lead_Assignment__c == NULL){
                    productsWithNoRTM.add(product);   
                }
                else if(!String.isEmpty(product.RTM_Values_For_Lead_Assignment__c) ){
                    
                    if(product.RTM_Values_For_Lead_Assignment__c.contains('MSI Led') && 
                       product.RTM_Values_For_Lead_Assignment__c.contains('MR Led') &&
                       product.RTM_Values_For_Lead_Assignment__c.contains('Partner Led') &&
                       product.RTM_Values_For_Lead_Assignment__c.contains('Inside Sales/Tele-Sales Led') &&
                       product.RTM_Values_For_Lead_Assignment__c.contains('Open'))
                    {
                        System.debug('List1 Product');
                        list1Products.add(product.Name);   //Products of List#1
                    }
                    
                    else if(product.RTM_Values_For_Lead_Assignment__c.contains('MR Led') &&
                            product.RTM_Values_For_Lead_Assignment__c.contains('Partner Led') &&
                            product.RTM_Values_For_Lead_Assignment__c.contains('Inside Sales/Tele-Sales Led') &&
                            product.RTM_Values_For_Lead_Assignment__c.contains('Open')){
                                system.debug('List2 Product');
                                list2techSegProductMap.put(product.Name, product); //Products of List#2
                            }
                    
                    else if(product.RTM_Values_For_Lead_Assignment__c.contains('Partner Led') &&
                            product.RTM_Values_For_Lead_Assignment__c.contains('Inside Sales/Tele-Sales Led') &&
                            product.RTM_Values_For_Lead_Assignment__c.contains('Open')){                    
                                system.debug('List3 Product');
                                otherProducts.add(product.Name); //Products which refer to neither in List#1 or List#2
                            }
                }
                system.debug('list1Products :='+list1Products);
                system.debug('list2techSegProductMap :='+list2techSegProductMap);
                system.debug('otherProducts :='+otherProducts);
            }
        }
        
        List<Account> mcnAccountList = new List<Account>();
        Map<Id,List<Account>> accountMcnMap = new Map<Id,List<Account>>();
        
        
        //Fetch Account fields of Account populated on Lead
        if(accountLeadMap.size()>0){
            accountListFetched = [Select Id, Name, Primary_Route_to_Market__c, OwnerId FROM Account WHERE Id IN: accountLeadMap.keySet()];
            mcnAccountList = [select id,Customer_or_Prospect_Account__c,Primary_Route_to_Market__c,Assigned_MR__c,Customer_or_Prospect_Account__r.ownerid FROM 
                              Account WHERE recordtype.name='Motorola Customer Number' and Customer_or_Prospect_Account__c IN : accountLeadMap.keySet() ];
            
            for(Account account : accountListFetched){
                system.debug('account :='+account);
                if(accountLeadMap.containsKey(account.id))	
                    accountMap.put(account.id,account);  
                
                for(Account mcnacc:mcnAccountList){
                    system.debug('mcnacc :='+mcnacc);
                    if(mcnacc.Customer_or_Prospect_Account__c == account.Id){
                        if(!accountMcnMap.keySet().contains(account.id)){
                            //accountMcnMap.get(account.id);
                            accountMcnMap.put(account.id,new List<Account>());
                            accountMcnMap.get(account.id).add(mcnacc);
                        } else {
                            accountMcnMap.get(account.id).add(mcnacc);
                        }
                    }
                }
            }
        }           
        
        
        //Identify Leads to be routed based on the list#1, list#2 and Other products
        for(Lead lead : (List<Lead>) newItems){
            if(!productsWithNoRTM.isEmpty()){
                system.debug('Leads with no RTM product');
                if(lead.Account__c != null){
                    leadList.add(lead);
                    accountIds.add(lead.Account__c);
                }
                else
                    lead.OwnerId = UserInfo.getUserId();
                
            }
            
            //fetch custom setting for Budget check
            List<Lead_Budget_Value_Benchmark__c> mc = Lead_Budget_Value_Benchmark__c.getall().values();
            
            if(list1Products.contains(lead.Technology_Segment__c)){
                system.debug('Add list1 products to the list to be routed');
                //lead.Assignment_from_PRMGeoMap__c = true;
                leadListtoBeRouted.add(lead);
            }
            else if(otherProducts.contains(lead.Technology_Segment__c)){
                //Logic for MSI Led and MR Led Leads with Products from Other Products List
                if(lead.Account__c != null && lead.status == 'Marketing Lead'){
                    List<Account> mcnAccountsList;
                    Account acc = accountMap.get(lead.Account__c); 
                    system.debug('acc :='+acc);
                    
                    if(accountMcnMap.keyset().contains(lead.Account__c)){
                        for(Id accountId : accountMcnMap.keyset()){
                            mcnAccountsList = accountMcnMap.get(lead.Account__c);
                            
                            for(Account mcn : mcnAccountsList){
                                system.debug('mcn :='+mcn);
                                routeSet.add(mcn.Primary_Route_to_Market__c);
                            }
                        }
                    }
                    
                    if(routeSet.size()==1){
                        mcnAccountCheck = mcnAccountsList[0];
                        if(mcnAccountCheck.Primary_Route_to_Market__c == 'MSI Led' || mcnAccountCheck.Primary_Route_to_Market__c == 'MR Led'){
                            lead.Assignment_from_PRMGeoMap__c = false;
                            lead.OwnerId = acc.OwnerId;
                        }
                        else{
                            lead.Assignment_from_PRMGeoMap__c = false;
                            leadListtoBeRouted.add(lead);
                            
                        }
                    }   
                    
                    else{
                        lead.Assignment_from_PRMGeoMap__c = false;
                        leadListtoBeRouted.add(lead);
                    }
                    
                }
                else{
                    lead.Assignment_from_PRMGeoMap__c = false;
                    leadListtoBeRouted.add(lead);
                }
            }
            else if(list2techSegProductMap.keyset().contains(lead.Technology_Segment__c)){
                
                
                if(lead.Account__c != null && lead.status == 'Marketing Lead'){
                    List<Account> mcnAccountsList;
                    Account acc = accountMap.get(lead.Account__c); 
                    system.debug('acc :='+acc);
                    
                    if(accountMcnMap.keyset().contains(lead.Account__c)){
                        for(Id accountId : accountMcnMap.keyset()){
                            mcnAccountsList = accountMcnMap.get(lead.Account__c);
                            
                            for(Account mcn : mcnAccountsList){
                                system.debug('mcn :='+mcn);
                                routeSet.add(mcn.Primary_Route_to_Market__c);
                            }
                        }
                    }
                    
                    if(routeSet.size()==1){
                        system.debug('routeSet.size()==1');
                        mcnAccountCheck = mcnAccountsList[0];
                        if(mcnAccountCheck.Primary_Route_to_Market__c == 'MSI Led' && Lead.Budget_Value__c >= mc[0].Budget_Benchmark__c){
                            lead.Populate_SE_Sales_Rep__c = false;
                            lead.Assignment_from_PRMGeoMap__c = false;
                            lead.OwnerId = acc.OwnerId;
                        }
                        
                        else if(mcnAccountCheck.Primary_Route_to_Market__c == 'MSI Led' && Lead.Budget_Value__c < mc[0].Budget_Benchmark__c)
                        {
                            
                            lead.Populate_SE_Sales_Rep__c = true;
                            lead.Assignment_from_PRMGeoMap__c = true;
                            leadListtoBeRouted.add(lead);
                        }
                        
                        /*else if(!(mcnAccountCheck.Primary_Route_to_Market__c == 'Inside Sales/Tele-Sales Led' || mcnAccountCheck.Primary_Route_to_Market__c == 'Open') || 
                                (mcnAccountCheck.Primary_Route_to_Market__c == 'MSI Led' && Lead.Budget_Value__c < mc[0].Budget_Benchmark__c)){
                            lead.Populate_SE_Sales_Rep__c = true;
                            lead.Assignment_from_PRMGeoMap__c = false;
                            leadListtoBeRouted.add(lead);
                        }
                        
                        else{
                            if(mcnAccountCheck.Primary_Route_to_Market__c =='MR Led' ||
                               mcnAccountCheck.Primary_Route_to_Market__c =='Inside Sales/Tele-Sales Led' ||
                               mcnAccountCheck.Primary_Route_to_Market__c =='Open'){
                                   lead.Assignment_from_PRMGeoMap__c = false;
                                   leadListtoBeRouted.add(lead);
                               }*/
                        else if(mcnAccountCheck.Primary_Route_to_Market__c == 'MR Led'){
                            lead.Populate_SE_Sales_Rep__c = true;
                            lead.Assignment_from_PRMGeoMap__c = false;
                            leadListtoBeRouted.add(lead);
                        }
                        
                        else{
                            if(mcnAccountCheck.Primary_Route_to_Market__c =='Inside Sales/Tele-Sales Led' ||
                               mcnAccountCheck.Primary_Route_to_Market__c =='Open'){
                                   lead.Populate_SE_Sales_Rep__c = false;
                                   lead.Assignment_from_PRMGeoMap__c = false;
                                   leadListtoBeRouted.add(lead);
                               }
                        }
                    }   
                    
                    else{
                        leadListtoBeRouted.add(lead);
                    }
                    
                }
                //Account i NULL
                else{
                    lead.Populate_SE_Sales_Rep__c = true;
                    lead.Assignment_from_PRMGeoMap__c = false;
                    leadListtoBeRouted.add(lead);
                }
                
            } // End of Else
        } // end of FOR
        
        accountOwnerMap = fetchAccounts(accountIds);
        
        for(Lead lead:leadList){
            if(accountOwnerMap.containsKey(lead.Account__c)){
                system.debug('Assigning Account owner as Lead owner');
                lead.OwnerId = accountOwnerMap.get(lead.Account__c).OwnerId;
            }
        }
        system.debug('leadListtoBeRouted ='+leadListtoBeRouted);
        return leadListtoBeRouted;
    }
    
    /* SF-2468 - Leads where Track = 'Direct */
}