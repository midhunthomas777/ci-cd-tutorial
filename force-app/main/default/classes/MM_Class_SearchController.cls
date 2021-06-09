public class MM_Class_SearchController {
    public QuickLinkPanel qlPanel {get;set;}
    public String emailAddress {get;set;}
    public String styleClass {get;set;}
    public Transient Cookie qlCookie {get;set;}
    public Paginate paginater {get;set;} 
    public DeepLinking deepLink {get;set;}
    public ApplicationSearch appSearch {get;set;}
    public PartnerSearch partnerSearch {get;set;}
    public String pageState {get;set;}
    public String subPageState {get;set;}
    public String partnerDataLocationsJS {get;set;}
    public String partnerPrimaryLocationsJS {get;set;}     // Added by SaiHarish as a part of INC0387757 
    public String partnerDataLocationsCenter {get;set;}
    public Integer numberOfResults {get;set;}
    public Boolean displayDetailLinks {get;set;}
    public Boolean showAllResults {get;set;}
    public Boolean runAllQueries {get;set;}
    public Boolean showNext {get;set;}
    public Boolean showPrevious {get;set;}
    public Boolean hasSearched {get;set;}
    public Integer numberOfChannelPartners {get;set;}
    public Integer numberOfDistributors {get;set;}
    public Integer numberOfSoftwareVendors {get;set;}
    public Integer numberOfChannelAndSoftware {get;set;}
    public ApplicationData appData {get;set;}
    public List<List<ApplicationDataStripped>> appDataAllList {get;set;}
    public List<ApplicationDataStripped> appDataList {get;set;}
    public PartnerData partnerData {get;set;}
    public List<PartnerData> partnerGenericList{get;set;}
    public List<List<PartnerData>> partnerAllGenericList{get;set;}
    public List<PartnerData> partnerChannelList;
    public List<PartnerData> partnerDistributorList;
    public List<PartnerData> partnerSoftwareList;
    public List<PartnerData> partnerChannelAndSoftwareList;
    public String allTechs{get;set;}
    
    public List<Id> channelIds = new List<Id>();
    public List<Id> distributorIds = new List<Id>();
    public List<Id> softwareIds = new List<Id>();
    public List<Id> channelAndSoftwareIds = new List<Id>();
    
    public Set<Id> accountIdSet {get;set;}
    public enum State {START, RESULTS, DETAIL, MAP_VIEW, ADDITIONAL_LOCATIONS, QUICK_LINK, QL_START, QL_EMAIL, QL_SENT, CHANNEL_PARTNERS, DISTRIBUTORS, SOFTWARE_VENDORS, CHANNEL_PARTNER_AND_SOFTWARE,ENTERPRISE_SOFTWARE,RADIO_SOFTWARE}
    public Map<State, String> pageStateMap = new Map<State, String>{State.START => 'start', State.RESULTS => 'results', State.DETAIL => 'detail', State.MAP_VIEW => 'map', State.QUICK_LINK => 'quickLinks', State.ADDITIONAL_LOCATIONS => 'additionalLocations'}; 
    public Map<State, String> subPageStateMap = new Map<State, String>{State.QL_START => 'qlStart', State.QL_EMAIL => 'qlEmail', State.QL_SENT => 'qlSent', State.CHANNEL_PARTNERS => 'channelPartners', State.DISTRIBUTORS => 'distributors', State.SOFTWARE_VENDORS => 'softwareVendors', State.CHANNEL_PARTNER_AND_SOFTWARE => 'channelPartnerAndSoftware',State.ENTERPRISE_SOFTWARE=>'enterprisesoftware',State.RADIO_SOFTWARE=>'radiosoftware'}; 
    public Map<String, State> destToSubPageStateMap = new Map<String, State>{'Channel' => State.CHANNEL_PARTNERS, 'Distributor' => State.DISTRIBUTORS, 'AppPartner' => State.SOFTWARE_VENDORS, 'Channel Application' => State.CHANNEL_PARTNER_AND_SOFTWARE};
    public String previousState = 'start'; 
    public String previousSubState = 'Channel';
    public String idOfSelectedRecord {get;set;}
    public String nameOfSelectedRecord {get;set;}
    public static Map<String, String> regionMap = new Map<String, String>{'Asia Pacific' => 'APAC', 'EMEA' => 'EMEA', 'Latin America' => 'LACR', 'North America' => 'NAMR', 'U.S. Federal Government' => 'US Federal'};
    private String previousPageState;
    
    //Added by Sathish
    public Map<String,String> technologyToTrackMap= new Map<String,String>();
    public Set<Id> enterpriseApplicationIds = new Set<Id>();
    public Set<Id> radioApplicationIds = new Set<Id>();
    //public Integer numberOfEntApps {get;set;}
    //public Integer numberOfRadioApps {get;set;}
    //public String selectedAppSubPageState {get;set;}
    Public String AppBusVal{get;set;} //Added by Ananth as part of INC0671758 
    Public String PageIdentifier{get;set;} //Added by Ananth as part of INC0671758 
    
      
    public MM_Class_SearchController(){
        this.numberOfResults = 0; 
        this.deepLink = new DeepLinking();
        System.debug(LoggingLevel.ERROR, 'this.deepLink:  ' + this.deepLink);
        
        appSearch = new ApplicationSearch(this.deepLink);
        partnerSearch = new PartnerSearch(this.deepLink);
        populatePageState(State.START);
        //populateSubPageState(State.CHANNEL_PARTNERS);
        this.partnerGenericList = new List<PartnerData>();
        this.showAllResults = false;
        this.runAllQueries = true;
        this.partnerDataLocationsJS = '';
        this.partnerPrimaryLocationsJS = ''; //Added by SaiHarsih
        this.partnerDataLocationsCenter = '';
        this.previousPageState = '';
        this.showNext = true;
        this.showPrevious = true;
        this.hasSearched = false;
        this.styleClass = (this.deepLink.showActive || (isEmpty(this.deepLink.appId) && isEmpty(this.deepLink.partnerId)) || (!isEmpty(this.deepLink.appId) && !isEmpty(this.deepLink.partnerId)))?'active':'';
        this.displayDetailLinks = true;

        
        this.qlPanel = new QuickLinkPanel();
        qlCookie = ApexPages.currentPage().getCookies().get('quickLinks');
        if(qlCookie == null){
            qlCookie = new Cookie('quickLinks', '1', null, -1, false);
        }else{
            try{
                this.qlPanel = (QuickLinkPanel)JSON.deserializeStrict(qlCookie.getValue(), QuickLinkPanel.class);
            }catch(Exception e){
                this.qlPanel = new QuickLinkPanel();
            }
        }
        system.debug('this.deepLink.partnerId'+this.deepLink.partnerId); 
        system.debug('this.deepLink.currentPage'+this.deepLink.currentPage);
        if(this.deepLink.currentPage == 'partner' && this.deepLink.partnerId != ''){
            this.displayDetailLinks = false;
            Id pId = this.deepLink.partnerId;
            //Modified by Sathish For Day 1 Days 1
            List<String> trackForSearch = new List<String>();
              if(this.partnerSearch.stage.E_or_G__c != null && this.partnerSearch.stage.E_or_G__c == 'E' ){
                    trackForSearch.add('WNS');
                    trackForSearch.add('Mobility');
                }else{
                    trackForSearch.add('RADIO');
                    trackForSearch.add('SCADA');
                }
            Account a = [Select Id,Owner_Business_Group__c, MM_Fed_Specialization_Sort__c, MM_Partner_Type_Sort__c, MM_Metal_Level_Sort__c, Partner_Region__c, MEGO_Order__c, Name, NameLocal, Partner_Account_Name__c, Value_Add__c, Company_Description__c, Socio_Economic_Status__c, Website_URL__c, Metal_Level__c, (Select Id, IsDeleted, Name, CurrencyIsoCode, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, ConnectionReceivedId, ConnectionSentId, Account__c, Account_Product__c, ProductKey__c, Product_Ext_Ref_Id__c, Product__c, Product_offering__c, Publish_Flag__c, Account_Unique_Id__c, Account__r.Partner_Region__c From Product_Offered__r),(Select UPL_CommunityMarketTerm__c, Type__c, Technology_Specialization__c, Technology_Specialization_Status__c, Technology_Specialization_Level__c, Tech_Specialization_Compliant_Status__c, SystemModstamp, Sort_Order__c, Program__c, Partner_Zone__c, Partner_Program__c, Partner_Category__c, Name, Market_Term__c, LastModifiedDate, LastModifiedById, LastActivityDate, IsDeleted, Id, CurrencyIsoCode, CreatedDate, CreatedById, ConnectionSentId, ConnectionReceivedId, Compliance_Review_Date__c, Community_Type__c, Authorized__c, Account__c, Account_Unique_Id__c, AccountPartnerRegion__c, Acc_Prgm_Track_Cmnty__c, Partner_Program__r.Status__c, MM_Distributor_Sort__c, MM_Sort_Order__c, Country__c FROM Technology_Specializations__r where program__c in :trackForSearch ), (Select SystemModstamp, Name, Market_Specialization__c, Market_Specialization_Level__c, LastModifiedDate, LastModifiedById, LastActivityDate, IsDeleted, Id, CurrencyIsoCode, CreatedDate, CreatedById, ConnectionSentId, ConnectionReceivedId, Account__c, MM_Sort_Order__c FROM Market_Specializations__r), (Select street__c, SystemModstamp, State__c, State_Code__c, Postal_code__c, Phone__c, PartnerName__c, Name, Longitude__c, Location_Publish_Flag__c, Location_Key__c, Location_Ext_Ref_Id__c, Latitude__c, LastModifiedDate, LastModifiedById, Keyword__c, IsPrimary__c, IsDeleted, Id, Federal_Status__c, Fax__c, CurrencyIsoCode, CreatedDate, CreatedById, Country_Code__c, Country1__c, ConnectionSentId, ConnectionReceivedId, City__c, Address_Type__c, Address_Line3__c, Address_Line2__c, Address_Line1__c, Account__c, Account_Website_URL__c, Account_Name__c, Account_Location__c FROM Partner_Locations__r) FROM Account WHERE Id = :pId];
            // Modified by Sathish for Day 1 Ends
            if(a == null){
                return;
            }
            this.partnerData = new PartnerData(a, this.partnerSearch, this.deepLink.allParams, QueryType.CHANNEL_PARTNER, getPartnerQLIds());
            populatePageState(State.DETAIL);
            return;         
        }else if(this.deepLink.currentPage == 'application' && this.deepLink.appId != ''){
            this.displayDetailLinks = false;
            populateTechTrackMap();
            doDetailAppProcess();
            return;
        }
        populateTechTrackMap();
        if(!isEmpty(this.deepLink.technology)
            && !isEmpty(this.deepLink.os)  
            && this.technologyToTrackMap.get(this.deepLink.technology) == 'RADIO' ){
            this.deepLink.os = '' ;
        }
        if(this.deeplink.technology !=null && !isEmpty(this.deeplink.technology)){
           String business= this.technologyToTrackMap.get(this.deeplink.technology) == 'RADIO' ? 'G' : 'E' ;
           this.deeplink.business= business ;
           this.partnerSearch.stage.E_or_G__c= business ;
           // this.appSearch.stage.E_or_G__c= business ; 
          /* Commented by Ananth as a part of INC0671758*/
            this.appSearch.stage.E_or_G__c= 'E' ; // Modified by Ananth as part of INC0671758 
        }        
        //this.numberOfEntApps = 0;
        //this.numberOfRadioApps = 0;
        //System.debug(LoggingLevel.ERROR, 'this.partnerSearch.stage.Partner_Region__c:  ' + this.partnerSearch.stage.Partner_Region__c);

    } 
    
    public Set<Id> getPartnerQLIds(){
        Set<Id> idSet = new Set<Id>();
        for(QuickLink ql : this.qlPanel.partnerLinks){
            idSet.add(ql.id);
        }
        return idSet;
    }
    
    public Set<Id> getApplicationQLIds(){
        Set<Id> idSet = new Set<Id>();
        /*for(QuickLink ql : this.qlPanel.enterpriseAppLinks){ // Modified by Nimesh for MOTOTRBO Changes
            idSet.add(ql.id);
        }
        for(QuickLink ql : this.qlPanel.radioAppLinks){
            idSet.add(ql.id);
        }*/
        for(QuickLink ql : this.qlPanel.applicationLinks){
            idSet.add(ql.id);
        }
        return idSet;
    }
    
    public PageReference runSearchFromPage(){
        if(!isEmpty(this.partnerSearch.stage.Partner_Country__c) || !isEmpty(this.appSearch.stage.Country__c)){
            for(MM_Country_Mapping__c cm : MM_Country_Mapping__c.getall().values()){
                if(cm.Name.equalsIgnoreCase(this.partnerSearch.stage.Partner_Country__c) && cm.Region__c != this.partnerSearch.stage.Partner_Region__c){
                    this.partnerSearch.stage.Partner_Country__c = '';
                }               
                if(cm.Name.equalsIgnoreCase(this.appSearch.stage.Country__c) && cm.Region__c != this.appSearch.stage.Region__c){
                    this.appSearch.stage.Country__c = '';
                }               
            }
        }
        
        if(!isEmpty(this.deepLink.dest)){
            ApexPages.currentPage().getParameters().put('dest', '');
            if(this.deepLink.dest == 'Application' && this.deepLink.currentPage == 'application'){
                this.deepLink = new DeepLinking();
                return appSearch();
            }else{
                if(this.destToSubPageStateMap.containsKey(this.deepLink.dest)){
                    System.debug(LoggingLevel.ERROR, 'this.destToSubPageStateMap.get(this.deepLink.dest):  ' + this.destToSubPageStateMap.get(this.deepLink.dest));
                    populateSubPageState(this.destToSubPageStateMap.get(this.deepLink.dest));
                    this.deepLink = new DeepLinking();
                    return partnerSearchAll();
                }
            }
        }
        return null;
    }
    
    public void doDetailAppProcess(){
        this.appData = null;
        Set<Id> qlIds = this.getApplicationQLIds();
        /*for(Software_Applications__c sa : [Select s.Account_C__r.Name, s.Account_C__r.NameLocal, s.Account_C__r.Partner_HQ_Country__c, (Select Id, Name, ContentType From Attachments), s.Version__c, s.Uses_a_MSI_Rho_Development_Framework__c, s.Type_of_Application_Build_Per_Client__c, s.Tested_Date__c, s.Target_Customer_Size__c, s.SystemModstamp, s.Supported_Peripherals__c, s.Supported_Operating_Systems__c, s.Status__c, s.Short_Description__c, s.Request_Motorola_Validation__c, s.Publish_on_Motorola_com__c, s.Offer_Countries_Partner_to_Partner__c, s.Offer_Countries_End_User__c, s.Name, s.Motorola_Tested__c, s.MM_Motorola_Tested_Sort__c, s.Account_C__r.Metal_Level_Sort__c, s.Market_Ready_Offering__c, s.Long_Description__c, s.LastModifiedDate, s.LastModifiedById, s.LastActivityDate, s.Languages__c, s.IsDeleted, s.Id, s.End_Date__c, s.Customer__c, s.CurrencyIsoCode, s.CreatedDate, s.CreatedById, s.ConnectionSentId, s.ConnectionReceivedId, s.Account_C__c, s.System_Type__c 
                                           From Software_Applications__c s 
                                           WHERE Id = :this.deepLink.appId]){
            this.appData = new ApplicationData();
            this.appData.application = sa;
            this.appData.appId = sa.Id;
            this.appData.Name = sa.Name;
            this.appData.motorolaTested = sa.Motorola_Tested__c;
            this.appData.Version = sa.Version__c;
            this.appData.isInQuickList = (qlIds.contains(sa.Id))?true:false;
            
            this.appData.appIconUrl = '';
            for(Attachment att : sa.Attachments){
                this.appData.appIconUrl = '/servlet/servlet.FileDownload?file=' + att.Id;
            }*/
            /*Commenting as part of SF-491 - Delete unused custom objects - Start
            for(Screenshots__c sc : [Select Id, ImageAttachmentId__c, ThumbnailPreviewImageID__c, Software_Applications__c From Screenshots__c WHERE Software_Applications__c = :sa.Id]){
                this.appData.screenshots.add(new Screenshot(sc.Id, sc.ThumbnailPreviewImageID__c, sc.ImageAttachmentId__c));
            }
            System.debug('*****************Check**********'+appData.screenshots);
            Commenting as part of SF-491 - Delete unused custom objects - End*/
            
            /*Set<String> industrySet = new Set<String>();
            for(Industries_Solutions__c is : [Select Vertical__c, Solutions__c FROM Industries_Solutions__c WHERE Software_Applications__c = :sa.Id]){
                Industries_Solutions__c tempIs = new Industries_Solutions__c();
                if(!industrySet.contains(is.Vertical__c) && !isEmpty(is.Vertical__c)){
                    tempIs.Vertical__c = is.Vertical__c;
                    industrySet.add(is.Vertical__c);
                }
                if(!industrySet.contains(is.Solutions__c) && !isEmpty(is.Solutions__c)){
                    tempIs.Solutions__c = is.Solutions__c;
                    industrySet.add(is.Solutions__c);
                }
                this.appData.industrySolutions.add(tempIs);
            }
            
            Set<String> businessNeed = new Set<String>();
            for(Cross_Industries_Solutions__c is : [Select Cross_Industries__c, Solutions__c FROM Cross_Industries_Solutions__c WHERE Software_Applications__c = :sa.Id]){
                if(!businessNeed.contains(is.Cross_Industries__c) || !businessNeed.contains(is.Solutions__c)){
                    if(is.Cross_Industries__c == is.Solutions__c){
                        is.Solutions__c = '';
                    }
                    this.appData.crossIndustrySolutions.add(is);
                    businessNeed.add(is.Cross_Industries__c);
                    businessNeed.add(is.Solutions__c);
                }
            }
            
            Set<String> techSegSet = new Set<String>();
            Set<String> modelNameSet = new Set<String>();*/
            /*for(Supported_Products__c is : [Select Technology_Segment__c, Model_Name__c FROM Supported_Products__c WHERE Software_Applications__c = :sa.Id]){
                // Modified by Sathish for Day 1 Starts
                if(techSegSet.add(is.Technology_Segment__c) &&
                ((this.technologyToTrackMap.get(is.Technology_Segment__c) == 'RADIO' && this.appSearch.stage.E_or_G__c == 'G' )
                        || ((this.technologyToTrackMap.get(is.Technology_Segment__c) == 'WNS' || this.technologyToTrackMap.get(is.Technology_Segment__c) == 'Mobility' ) && this.appSearch.stage.E_or_G__c == 'E'))){
                    this.appData.supportedProducts.add(new Supported_Products__c(Technology_Segment__c = is.Technology_Segment__c));
                    techSegSet.add(is.Technology_Segment__c);
                    
                    if(is.Model_Name__c != null){
                        if(!modelNameSet.contains(is.Model_Name__c)){
                            this.appData.modelNames.add(new Supported_Products__c(Model_Name__c = is.Model_Name__c));
                            modelNameSet.add(is.Model_Name__c);
                        }
                    }
                }
                // Modified by Sathish for Day 1 Ends
                
            }*/
            
           /* for(Customer_References__c cr : [Select Customer_Name__c FROM Customer_References__c WHERE Software_Applications__c = :sa.Id]){
                this.appData.Customer_Name.add(cr.Customer_Name__c);
            }*/
            
            // added a new parameter to the appdata which states the type of application Nimesh
           // Map<String,String> appTypeMap=getAppTypes();
            /*for(Supported_Products__c sp : appData.supportedProducts){
                if(this.technologyToTrackMap.get(sp.Technology_Segment__c) == 'WNS' || this.technologyToTrackMap.get(sp.Technology_Segment__c) == 'Mobility'){
                    this.appData.ApplicationType.add('ENTERPRISE');
                }
                if(this.technologyToTrackMap.get(sp.Technology_Segment__c) == 'RADIO' ){
                    this.appData.ApplicationType.add('RADIO');
                }
            }*/
            // added a new parameter to the appdata which states the type of application Nimesh
        //}
        if(this.appData != null){
            populatePageState(State.DETAIL);
        }           
    }
    
    public void populatePageState(State s){
        this.pageState = pageStateMap.get(s);
    }
    
    public void populateSubPageState(State s){
        this.subPageState = subPageStateMap.get(s);
    }
    
    public PageReference partnerSearchAll(){
        this.channelIds = new List<Id>();
        this.distributorIds = new List<Id>();
        this.softwareIds = new List<Id>();
        this.channelAndSoftwareIds = new List<Id>();
        
        this.runAllQueries = true;
        
        if(this.subPageState == '' || this.subPageState == null){
            this.populateSubPageState(State.CHANNEL_PARTNERS);
        }    
        system.debug('Nimsi all techs' +allTechs);
        return partnerSearch();
    }
    
    public PageReference partnerSearch(){
    System.Debug('Ananth Entered partnerSearch()');
        this.partnerSearch.stage.Partner_Technology__c = (isEmpty(this.partnerSearch.stage.Partner_Industry__c))?this.partnerSearch.stage.Partner_Technology__c:this.partnerSearch.stage.Partner_Technology_Industry__c;
        this.hasSearched = true;
        if(isEmpty(this.partnerSearch.stage.Partner_Region__c)){
            this.partnerSearch.stage.Partner_Region__c.addError('Region is required');
            return null;
        }
        
        this.partnerGenericList = new List<PartnerData>();
        this.partnerAllGenericList = new List<List<PartnerData>>();
        this.partnerChannelList = new List<PartnerData>();
        this.partnerDistributorList = new List<PartnerData>();
        this.partnerSoftwareList = new List<PartnerData>();
        this.partnerChannelAndSoftwareList = new List<PartnerData>();
        
        this.paginater = new Paginate(0, 0);
        
        System.debug(LoggingLevel.ERROR, 'pageState:  ' + pageState);
        System.debug(LoggingLevel.ERROR, 'runAllQueries:  ' + runAllQueries);
        System.debug(LoggingLevel.ERROR, 'this.distributorIds.isEmpty():  ' + this.distributorIds.isEmpty());
        System.debug(LoggingLevel.ERROR, 'this.subPageStateMap.get(State.DISTRIBUTORS):  ' + this.subPageStateMap.get(State.DISTRIBUTORS));
        System.debug(LoggingLevel.ERROR, 'subPageState:  ' + subPageState);
        
        if(this.runAllQueries || 
          ((this.channelIds.isEmpty() && 
           this.subPageStateMap.get(State.CHANNEL_PARTNERS) == this.subPageState) ||
           (this.distributorIds.isEmpty() && 
           this.subPageStateMap.get(State.DISTRIBUTORS) == this.subPageState) ||
           (this.softwareIds.isEmpty() && 
           this.subPageStateMap.get(State.SOFTWARE_VENDORS) == this.subPageState) ||
           (this.channelAndSoftwareIds.isEmpty() && 
           this.subPageStateMap.get(State.CHANNEL_PARTNER_AND_SOFTWARE) == this.subPageState))){
            
            Map<Id, QueryType> accountIdToQueryTypeMap = new Map<Id, QueryType>();
            Map<QueryType, Set<Id>> queryTypeMap = new Map<QueryType, Set<Id>>();
            Set<Id> allAcctIds = new Set<Id>();
            partnerSearch.partnerQueries = new List<PartnerQuery>();
            System.debug(LoggingLevel.ERROR, 'this.partnerSearch.stage:  ' + this.partnerSearch.stage);
            partnerSearch.createQueries();
            
            Map<QueryType, State> queryTypeToPageState = new Map<QueryType, State>{QueryType.CHANNEL_PARTNER => State.CHANNEL_PARTNERS, QueryType.CHANNEL_PARTNER2 => State.CHANNEL_PARTNERS, QueryType.DISTRIBUTOR => State.DISTRIBUTORS, QueryType.APP_PARTNER => State.SOFTWARE_VENDORS, QueryType.CHANNEL_APP => State.CHANNEL_PARTNER_AND_SOFTWARE, QueryType.CHANNEL_APP2 => State.CHANNEL_PARTNER_AND_SOFTWARE}; 
            Set<Id> tempSetForQueryChannel = new Set<Id>();
            Set<Id> tempSetForQueryChannel2 = new Set<Id>();
            Set<Id> tempSetForQueryDistributor = new Set<Id>();
            Set<Id> tempSetForQueryApp = new Set<Id>();
            Set<Id> tempSetForQueryChannelAndApp = new Set<Id>();
            Set<Id> tempSetForQueryChannelAndApp1 = new Set<Id>();
            Set<Id> tempSetForQueryChannelAndApp2 = new Set<Id>();
            String tempSearchTerm = (isEmpty(this.partnerSearch.searchTerm) || this.partnerSearch.searchTerm == 'Partner Name')?'':'%' + String.escapeSingleQuotes(this.partnerSearch.searchTerm) + '%';
            for(PartnerQuery pq : partnerSearch.partnerQueries){ 
                System.debug(LoggingLevel.ERROR, 'searchTerm:  ' + this.partnerSearch.searchTerm);
                pq.query += (tempSearchTerm == '')?'':' AND (NameLocal LIKE \'' + tempSearchTerm + '\' OR Partner_Account_Name__c LIKE \'' + tempSearchTerm + '\' OR Name LIKE \'' + tempSearchTerm + '\')';
                if(pq.queryType == QueryType.CHANNEL_PARTNER){
                    if(((this.partnerSearch.stage.Partner_Region__c == 'U.S. Federal Government') || (this.partnerSearch.stage.Partner_Region__c != 'US Federal' && this.partnerSearch.stage.Partner_Industry__c == 'US Federal')) && isEmpty(this.partnerSearch.stage.Partner_Technology__c)){
                        pq.query += ' ORDER BY MM_Fed_Specialization_Sort__c ASC, MM_Metal_Level_Sort__c ASC, MM_Partner_Type_Sort__c ASC';
                    }else{
                        pq.query += ' ORDER BY MM_Metal_Level_Sort__c ASC, MM_Partner_Type_Sort__c ASC, MM_Fed_Specialization_Sort__c ASC';
                    }
                }else{
                    pq.query += ' ORDER BY MM_Metal_Level_Sort__c ASC, MM_Partner_Type_Sort__c ASC, MM_Fed_Specialization_Sort__c ASC';
                }
                pq.query += (pq.queryType == QueryType.CHANNEL_APP || pq.queryType == QueryType.CHANNEL_APP2 || pq.queryType == QueryType.DISTRIBUTOR)?'':' LIMIT 200';          
                System.debug(LoggingLevel.ERROR, 'pq.query:  ' + pq.query);
                System.debug(LoggingLevel.ERROR, 'pq.queryType:  ' + pq.queryType);
                //QueryType {CHANNEL_PARTNER, DISTRIBUTOR, APP_PARTNER, CHANNEL_APP, CHANNEL_APP2}
                if(this.runAllQueries || subPageStateMap.get(queryTypeToPageState.get(pq.queryType)) == this.subPageState){
                    for(sObject acct : Database.query(pq.query)){
                        Account a = (Account)acct;
                        if((pq.objTypeSet.contains(Obj.TECH_SPEC) && a.Technology_Specializations__r.isEmpty()) ||
                           (pq.objTypeSet.contains(Obj.MARKET_SPEC) && a.Market_Specializations__r.isEmpty()) || 
                           (pq.objTypeSet.contains(Obj.PARTNER_TYPE) && a.Partner_Types__r.isEmpty()) || 
                           (pq.objTypeSet.contains(Obj.PARTNER_LOCATION) && a.Partner_Locations__r.isEmpty()) || 
                           (pq.objTypeSet.contains(Obj.PRODUCT_OFFERED) && a.Product_Offered__r.isEmpty()) ||
                           (pq.objTypeSet.contains(Obj.SALES_TERRITORY) && a.Sales_Territory__r.isEmpty())){
                            //Do nothing...
                        }else{
                            if(pq.queryType == QueryType.CHANNEL_PARTNER && tempSetForQueryChannel.size() <Integer.valueOf(System.Label.MM_Number_of_Channel_Partners)){
                                SYSTEM.debug('Ananth Nimsi tempSetForQueryChannel -->  '+a.Id+'****'+tempSetForQueryChannel.size());
                                tempSetForQueryChannel.add(a.Id);
                            }else if(pq.queryType == QueryType.CHANNEL_PARTNER2 && tempSetForQueryChannel2.size() < 100){
                                SYSTEM.debug('Ananth Nimsi tempSetForQueryChannel2 -->  '+a.Id+'****'+tempSetForQueryChannel2.size());
                                tempSetForQueryChannel2.add(a.Id);
                            }else if(pq.queryType == QueryType.DISTRIBUTOR && tempSetForQueryDistributor.size() < 100){
                                SYSTEM.debug('Ananth Nimsi tempSetForQueryDistributor -->  '+a.Id+'****'+tempSetForQueryDistributor.size());
                                tempSetForQueryDistributor.add(a.Id);
                            }else if(pq.queryType == QueryType.APP_PARTNER && tempSetForQueryApp.size() < 100){
                                tempSetForQueryApp.add(a.Id);
                            }else if(pq.queryType == QueryType.CHANNEL_APP){
                                tempSetForQueryChannelAndApp1.add(a.Id);
                            }else if(pq.queryType == QueryType.CHANNEL_APP2){
                                tempSetForQueryChannelAndApp2.add(a.Id);
                            }           
                        }
                    }
                }
            }
            
            for(Id tempChannelAndAppId : tempSetForQueryChannelAndApp1){
                if(tempSetForQueryChannelAndApp2.contains(tempChannelAndAppId) && tempSetForQueryChannelAndApp.size() < 100){
                    tempSetForQueryChannelAndApp.add(tempChannelAndAppId);
                }
            }
            
            for(Id tempChannelId : tempSetForQueryChannel2){
                if(tempSetForQueryChannel.size() < Integer.valueOf(System.Label.MM_Number_of_Channel_Partners)){
                    tempSetForQueryChannel.add(tempChannelId);
                }else{
                    break;
                }
            }
            SYSTEM.debug('Ananth Nimsi -->  '+allAcctIds.size());
            allAcctIds.addAll(tempSetForQueryChannel);
            allAcctIds.addAll(tempSetForQueryDistributor);
            allAcctIds.addAll(tempSetForQueryApp);
            allAcctIds.addAll(tempSetForQueryChannelAndApp);
            SYSTEM.debug('Ananth Nimsi -->  '+allAcctIds.size());
            //this.allPartnerDataList = new List<PartnerData>();
            System.Debug('Ananth Exit partnerSearch()');
            return continuePartnerSearch(allAcctIds, tempSetForQueryChannel, tempSetForQueryDistributor, tempSetForQueryApp, tempSetForQueryChannelAndApp, false);
        }
        
        Set<Id> allAcctIds = new Set<Id>();
        if(this.subPageStateMap.get(State.CHANNEL_PARTNERS) == this.subPageState){
            allAcctIds.addAll(this.channelIds);
        }else if(this.subPageStateMap.get(State.DISTRIBUTORS) == this.subPageState){
            System.debug(LoggingLevel.ERROR, 'allAcctIds:  ' + allAcctIds);
            System.debug(LoggingLevel.ERROR, 'distributorIds:  ' + distributorIds);
            allAcctIds.addAll(this.distributorIds);
        }else if(this.subPageStateMap.get(State.SOFTWARE_VENDORS) == this.subPageState){
            allAcctIds.addAll(this.softwareIds);
        }else if(this.subPageStateMap.get(State.CHANNEL_PARTNER_AND_SOFTWARE) == this.subPageState){
            allAcctIds.addAll(this.channelAndSoftwareIds);              
        }
        System.Debug('Ananth Exit partnerSearch()');
        return continuePartnerSearch(allAcctIds, new Set<Id>(), new Set<Id>(), new Set<Id>(), new Set<Id>(), true);
    }
    
    public PageReference continuePartnerSearch(Set<Id> allAcctIds, Set<Id> tempSetForQueryChannel, Set<Id> tempSetForQueryDistributor, Set<Id> tempSetForQueryApp, Set<Id> tempSetForQueryChannelAndApp, Boolean hasExistingIds){
    System.Debug('Ananth Entered continuePartnerSearch()');
        QueryType qt;
        if(this.subPageStateMap.get(State.CHANNEL_PARTNERS) == this.subPageState){
            qt = QueryType.CHANNEL_PARTNER;
        }else if(this.subPageStateMap.get(State.DISTRIBUTORS) == this.subPageState){
            qt = QueryType.DISTRIBUTOR;
        }else if(this.subPageStateMap.get(State.SOFTWARE_VENDORS) == this.subPageState){
            qt = QueryType.APP_PARTNER;
        }else if(this.subPageStateMap.get(State.CHANNEL_PARTNER_AND_SOFTWARE) == this.subPageState){
            qt = QueryType.CHANNEL_APP;
        }
        
        Set<Id> partnerIds = getPartnerQLIds();
        
        List<String> trackForSearch = new List<String>();
        String trackForSearchStr='';
          if(this.partnerSearch.stage.E_or_G__c != null && this.partnerSearch.stage.E_or_G__c == 'E' ){
                trackForSearch.add('WNS');
                trackForSearch.add('Mobility');
               // trackForSearchStr= '\''+'WNS'+'\',\''+'Mobility'+'\'' ;
               trackForSearchStr= '\''+'Mobility'+'\'' ;
            }else{
                trackForSearch.add('RADIO');
                trackForSearch.add('SCADA');
                trackForSearchStr= '\''+'RADIO'+ '\',\''+'SCADA'+'\'';
            }
                
        for(Account a : [Select Id, Owner_Business_Group__c,Partner_Region__c, Value_Add__c, MEGO_Order__c, MM_Fed_Specialization_Sort__c, MM_Partner_Type_Sort__c, MM_Metal_Level_Sort__c, Name, NameLocal, Partner_Account_Name__c, Company_Description__c, Socio_Economic_Status__c, Website_URL__c, Metal_Level__c, (Select Status__c, Partner_Track__c, Partner_Level__c, Program__c From Partner_Types__r WHERE Status__c = 'Active' AND (Program__c = 'RADIO' OR Program__c = 'SCADA') ORDER BY Program__c), (Select Id, IsDeleted, Name, CurrencyIsoCode, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, ConnectionReceivedId, ConnectionSentId, Account__c, Account_Product__c, ProductKey__c, Product_Ext_Ref_Id__c, Product__c, Product_offering__c, Publish_Flag__c, Account_Unique_Id__c, Account__r.Partner_Region__c From Product_Offered__r), (Select UPL_CommunityMarketTerm__c, Type__c, Technology_Specialization__c, Technology_Specialization_Status__c, Technology_Specialization_Level__c, Tech_Specialization_Compliant_Status__c, SystemModstamp, Sort_Order__c, Program__c, Partner_Zone__c, Partner_Program__c, Partner_Category__c, Name, Market_Term__c, LastModifiedDate, LastModifiedById, LastActivityDate, IsDeleted, Id, CurrencyIsoCode, CreatedDate, CreatedById, ConnectionSentId, ConnectionReceivedId, Compliance_Review_Date__c, Community_Type__c, Authorized__c, Account__c, Account_Unique_Id__c, AccountPartnerRegion__c, Acc_Prgm_Track_Cmnty__c, MM_Distributor_Sort__c, MM_Sort_Order__c, Partner_Program__r.Status__c, Partner_Program__r.US_Federal__c,Country__c FROM Technology_Specializations__r where program__c in :trackForSearch), (Select SystemModstamp, Name, Market_Specialization__c, Market_Specialization_Level__c, LastModifiedDate, LastModifiedById, LastActivityDate, IsDeleted, Id, CurrencyIsoCode, CreatedDate, CreatedById, ConnectionSentId, ConnectionReceivedId, Account__c, MM_Sort_Order__c FROM Market_Specializations__r ), (Select street__c, SystemModstamp, State__c, State_Code__c, Postal_code__c, Phone__c, PartnerName__c, Name, Longitude__c, Location_Publish_Flag__c, Location_Key__c, Location_Ext_Ref_Id__c, Latitude__c, LastModifiedDate, LastModifiedById, Keyword__c, IsPrimary__c, IsDeleted, Id, Federal_Status__c, Fax__c, CurrencyIsoCode, CreatedDate, CreatedById, Country_Code__c, Country1__c, ConnectionSentId, ConnectionReceivedId, City__c, Address_Type__c, Address_Line3__c, Address_Line2__c, Address_Line1__c, Account__c, Account_Website_URL__c, Account_Name__c, Account_Location__c FROM Partner_Locations__r ORDER BY State__c ASC) FROM Account WHERE Id IN :allAcctIds]){
            if(hasExistingIds){
                System.debug(LoggingLevel.ERROR, 'qt:  ' + qt);
                System.debug(LoggingLevel.ERROR, 'a:  ' + a);
            
                fillPartnerData(a, qt, partnerIds);
            }else{
                if(tempSetForQueryChannel.contains(a.Id)){
                    fillPartnerData(a, QueryType.CHANNEL_PARTNER, partnerIds);
                }
                if(tempSetForQueryDistributor.contains(a.Id)){
                    fillPartnerData(a, QueryType.DISTRIBUTOR, partnerIds);
                }
                if(tempSetForQueryApp.contains(a.Id)){
                    fillPartnerData(a, QueryType.APP_PARTNER, partnerIds);
                }
                if(tempSetForQueryChannelAndApp.contains(a.Id)){
                    fillPartnerData(a, QueryType.CHANNEL_APP, partnerIds);
                }
            }
        }
        
        System.debug(LoggingLevel.ERROR, 'this.partnerDistributorList:  ' + partnerDistributorList);
        if(this.runAllQueries){
            this.numberOfChannelPartners = this.partnerChannelList.size();
            this.numberOfDistributors = this.partnerDistributorList.size();
            this.numberOfSoftwareVendors = this.partnerSoftwareList.size();
            this.numberOfChannelAndSoftware = this.partnerChannelAndSoftwareList.size();
        }

        if(this.pageState != this.pageStateMap.get(State.MAP_VIEW)){
            this.populatePageState(State.RESULTS);
        }
        
        if((this.partnerChannelList.size() > 0 || this.partnerDistributorList.size() > 0 || this.partnerSoftwareList.size() > 0 || this.partnerChannelAndSoftwareList.size() > 0) && !hasExistingIds){
            if((this.subPageState == this.subPageStateMap.get(State.CHANNEL_PARTNERS) && this.partnerChannelList.size() == 0) ||
                (this.subPageState == this.subPageStateMap.get(State.DISTRIBUTORS) && this.partnerDistributorList.size() == 0) ||
                (this.subPageState == this.subPageStateMap.get(State.SOFTWARE_VENDORS) && this.partnerSoftwareList.size() == 0) ||
                (this.subPageState == this.subPageStateMap.get(State.CHANNEL_PARTNER_AND_SOFTWARE) && this.partnerChannelAndSoftwareList.size() == 0)){
                if(this.partnerChannelList.size() > 0){
                    this.populateSubPageState(State.CHANNEL_PARTNERS);
                }else if(this.partnerDistributorList.size() > 0){
                    this.populateSubPageState(State.DISTRIBUTORS);
                }else if(this.partnerSoftwareList.size() > 0){
                    this.populateSubPageState(State.SOFTWARE_VENDORS);
                }else if(this.partnerChannelAndSoftwareList.size() > 0){
                    this.populateSubPageState(State.CHANNEL_PARTNER_AND_SOFTWARE);
                }
            }
            setupLists();
            populateGenericList();          
        }
        
        if(hasExistingIds){
            setupLists();
            populateGenericList();          
        }

        System.debug(LoggingLevel.ERROR, 'subPageState:  ' + subPageState);
        System.debug(LoggingLevel.ERROR, 'pageState:  ' + pageState);
        
        this.runAllQueries = false;
        System.Debug('Ananth Exit continuePartnerSearch()');
        return null;
    }
    
    public void setupLists(){
        if(this.subPageState == this.subPageStateMap.get(State.CHANNEL_PARTNERS)){
            if(this.channelIds.isEmpty()){
                this.partnerChannelList.sort();
                this.channelIds = this.mapSortedListToIdList(this.partnerChannelList);
            }else{
                this.partnerChannelList = makeCurrentPartnerDataListMatchIdList(this.channelIds, this.partnerChannelList);
            }   
            this.partnerDistributorList = new List<PartnerData>();
            this.partnerSoftwareList = new List<PartnerData>();
            this.partnerChannelAndSoftwareList = new List<PartnerData>();
        }else if(this.subPageState == this.subPageStateMap.get(State.DISTRIBUTORS)){
            if(this.distributorIds.isEmpty()){
                this.partnerDistributorList.sort();
                this.distributorIds = this.mapSortedListToIdList(this.partnerDistributorList);
            }else{
                this.partnerDistributorList = makeCurrentPartnerDataListMatchIdList(this.distributorIds, this.partnerDistributorList);
            }   
            this.partnerChannelList = new List<PartnerData>();
            this.partnerSoftwareList = new List<PartnerData>();
            this.partnerChannelAndSoftwareList = new List<PartnerData>();
        }else if(this.subPageState == this.subPageStateMap.get(State.SOFTWARE_VENDORS)){
            if(this.softwareIds.isEmpty()){
                this.partnerSoftwareList.sort();
                this.softwareIds = this.mapSortedListToIdList(this.partnerSoftwareList);
            }else{
                this.partnerSoftwareList = makeCurrentPartnerDataListMatchIdList(this.softwareIds, this.partnerSoftwareList);
            }   
            this.partnerDistributorList = new List<PartnerData>();
            this.partnerChannelList = new List<PartnerData>();
            this.partnerChannelAndSoftwareList = new List<PartnerData>();
        }else if(this.subPageState == this.subPageStateMap.get(State.CHANNEL_PARTNER_AND_SOFTWARE)){
            if(this.channelAndSoftwareIds.isEmpty()){
                this.partnerChannelAndSoftwareList.sort();
                this.channelAndSoftwareIds = this.mapSortedListToIdList(this.partnerChannelAndSoftwareList);
            }else{
                this.partnerChannelAndSoftwareList = makeCurrentPartnerDataListMatchIdList(this.channelAndSoftwareIds, this.partnerChannelAndSoftwareList);
            }   
            this.partnerDistributorList = new List<PartnerData>();
            this.partnerSoftwareList = new List<PartnerData>();
            this.partnerChannelList = new List<PartnerData>();
        }
    }
    
    public List<Id> mapSortedListToIdList(List<PartnerData> pdList){
        List<Id> tempList = new List<Id>();
        for(PartnerData pd : pdList){
            tempList.add(pd.acctId);
        }       
        System.debug(LoggingLevel.ERROR, 'tempList:  ' + tempList);
        return tempList;
    }
    
    public List<PartnerData> makeCurrentPartnerDataListMatchIdList(List<Id> idList, List<PartnerData> oldPdList){
        Map<String, PartnerData> pdMap = new Map<String, PartnerData>();
        List<PartnerData> pdList = new List<PartnerData>();
        for(PartnerData pd : oldPdList){
            pdMap.put(pd.acctId, pd);
        }
        for(Id aId : idList){
            pdList.add(pdMap.get(aId));
        }
        return pdList;
    }
    
    public void fillPartnerData(Account a, QueryType qt, Set<Id> partnerIds){
    System.Debug('Ananth Entered fillPartnerData()');
        if(qt == QueryType.CHANNEL_PARTNER){
            this.partnerChannelList.add(new PartnerData(a, this.partnerSearch, this.deepLink.allParams, QueryType.CHANNEL_PARTNER, partnerIds));
        }else if(qt == QueryType.DISTRIBUTOR){
            System.debug(LoggingLevel.ERROR, 'qt in distribute:  ' + qt);
            
            this.partnerDistributorList.add(new PartnerData(a, this.partnerSearch, this.deepLink.allParams, QueryType.DISTRIBUTOR, partnerIds));
        }else if(qt == QueryType.APP_PARTNER){
            this.partnerSoftwareList.add(new PartnerData(a, this.partnerSearch, this.deepLink.allParams, QueryType.APP_PARTNER, partnerIds));
        }else if(qt == QueryType.CHANNEL_APP){
            this.partnerChannelAndSoftwareList.add(new PartnerData(a, this.partnerSearch, this.deepLink.allParams, QueryType.CHANNEL_APP, partnerIds));
        }
        System.Debug('Ananth Exit fillPartnerData()');
    }
    
    public PageReference appSearch(){
        this.hasSearched = true;
        //Map<Id, Software_Applications__c> softwareAppMap = new Map<Id, Software_Applications__c>();
        Map<Id, Industries_Solutions__c> industrySolutionsMap = new Map<Id, Industries_Solutions__c>();
        Map<Id, Cross_Industries_Solutions__c> crossIndustriesMap = new Map<Id, Cross_Industries_Solutions__c>();
       // Map<Id, Supported_Products__c> supportedProductsMap = new Map<Id, Supported_Products__c>();
        this.paginater = new Paginate(0, 0);
        this.appDataList = new List<ApplicationDataStripped>();
        this.appDataAllList = new List<List<ApplicationDataStripped>>();
      
          
        /*
        Set<Id> tempAccountSet = new Set<Id>();
        for(Account a : [Select Id FROM Account WHERE Partner_Locator_Status__c = 'Active']){
            tempAccountSet.add(a.Id);
        }
        */
        
        String searchTerm = (!isEmpty(this.appSearch.searchTerm) && !this.appSearch.searchTerm.containsIgnoreCase('search'))?'%' + this.appSearch.searchTerm + '%':'';
        Set<Id> tempSaIds = new Set<Id>();
        System.debug(LoggingLevel.ERROR, 'searchTerm:  ' + searchTerm);
        System.debug(LoggingLevel.ERROR, 'this.appSearch.searchTerm:  ' + this.appSearch.searchTerm);
        if(searchTerm != ''){
           /* for(Supported_Products__c sp : [Select Software_Applications__c FROM Supported_Products__c WHERE Technology_Segment__c LIKE :searchTerm]){
                tempSaIds.add(sp.Software_Applications__c);
            }*/
           /* for(Industries_Solutions__c sp : [Select Industries__c, Solutions__c FROM Industries_Solutions__c WHERE Industries__c != null OR Solutions__c != null]){
                if((sp.Industries__c != null && sp.Industries__c.containsIgnoreCase(this.appSearch.searchTerm)) || 
                   (sp.Solutions__c != null && sp.Solutions__c.containsIgnoreCase(this.appSearch.searchTerm))){
                    //tempSaIds.add(sp.Software_Applications__c);
                }
            }
            for(Cross_Industries_Solutions__c sp : [Select Industries__c, Solutions__c, Cross_Industry__c FROM Cross_Industries_Solutions__c WHERE Industries__c != null OR Solutions__c != null OR Cross_Industry__c != null]){
                if((sp.Industries__c != null && sp.Industries__c.containsIgnoreCase(this.appSearch.searchTerm)) || 
                    (sp.Solutions__c != null && sp.Solutions__c.containsIgnoreCase(this.appSearch.searchTerm)) || 
                    (sp.Cross_Industry__c != null && sp.Cross_Industry__c.containsIgnoreCase(this.appSearch.searchTerm))){
                    //tempSaIds.add(sp.Software_Applications__c);
                }
            }*/
        }       
        
        System.debug(LoggingLevel.ERROR, 'selected sys types:  ' + this.appSearch.stage.System_Type__c);

        Map<String, String> regionToFieldNameMap = new Map<String, String>{'Asia Pacific' => 'All APAC Countries', 'EMEA' => 'All EMEA Countries', 'Latin America' => 'All Latin America Countries', 'North America' => 'All North America Countries'};
        //Modified Query by Sat for Mototrbo appFinder Enhancement
        /*String query = 'Select s.system_type__c,s.Account_C__r.Partner_Account_Name__c,s.Account_C__r.Metal_Level_Sort__c, s.Account_C__r.NameLocal, s.Account_C__r.Name, s.Account_C__r.Partner_HQ_Country__c, s.MM_Motorola_Tested_Sort__c, s.Version__c, s.Uses_a_MSI_Rho_Development_Framework__c, s.Type_of_Application_Build_Per_Client__c, s.Tested_Date__c, s.Target_Customer_Size__c, s.SystemModstamp, s.Supported_Peripherals__c, s.Supported_Operating_Systems__c, s.Status__c, s.Short_Description__c, s.Request_Motorola_Validation__c, s.Publish_on_Motorola_com__c, s.Offer_Countries_Partner_to_Partner__c, s.Offer_Countries_End_User__c, s.Name, s.Motorola_Tested__c, s.Market_Ready_Offering__c, s.Long_Description__c, s.LastModifiedDate, s.LastModifiedById, s.LastActivityDate, s.Languages__c, s.IsDeleted, s.Id, s.End_Date__c, s.Customer__c, s.CurrencyIsoCode, s.CreatedDate, s.CreatedById, s.ConnectionSentId, s.ConnectionReceivedId, s.Account_C__c ';
        query += 'From Software_Applications__c s ';
        query += 'WHERE ';
        if(searchTerm != ''){
            //query += 'AND (Name LIKE \'' + searchTerm + '\' OR Name LIKE \'' + this.appSearch.searchTerm + '\') ';
        }
        query += ' Status__c = \'Active\' ';
        query += 'AND Account_C__r.Partner_Locator_Status__c = \'Active\' ';
        //query += 'AND Motorola_Tested__c != \'Expired Test\' ';
        query += (isEmpty(this.appSearch.stage.Supported_Operating_Systems__c))?'':'AND Supported_Operating_Systems__c INCLUDES (\'' + this.appSearch.stage.Supported_Operating_Systems__c + '\') ';
        query += 'AND Publish_on_Motorola_com__c = \'Yes\' ';
        query += 'AND Customer__c INCLUDES (\'' + ((this.deepLink.isAppX)?'Partner to Partner':'End Customer') + '\')';
        
        if(!isEmpty(this.appSearch.stage.Product__c)){
            query += ' AND Id IN (Select Software_Applications__c FROM Supported_Products__c WHERE Model_Name__c = \'' + this.appSearch.stage.Product__c + '\'';
            query += (this.appSearch.stage.Technology__c == 'Mobile Computing')?' OR Model_Name__c = \'All MCD products\'':'';
            query += ') ';
        }
        
        query += (isEmpty(this.appSearch.stage.Supported_Language__c))?'':' AND Languages__c INCLUDES (\'' + this.appSearch.stage.Supported_Language__c + '\')';
        
        String countryField = (this.deepLink.isAppx)?'Offer_Countries_Partner_to_Partner__c':'Offer_Countries_End_User__c';
        
        if(this.appSearch.stage.System_Type__c!=null && !isEmpty(this.appSearch.stage.System_Type__c)){
            String[] sysTypes=this.appSearch.stage.System_Type__c.split(';');
            System.debug(LoggingLevel.ERROR, 'selected sys types splites:  ' + sysTypes);
            query +=' AND ( ';
            for(Integer count=0;count<sysTypes.size();count++){
                if(count==0){
                    query +=' System_Type__c INCLUDES (\''+sysTypes[count]+'\')';
                }else if(count>0){
                    query +=' OR System_Type__c INCLUDES (\''+sysTypes[count]+ '\')';
                }//else if(count==(sysTypes.size()-1)){
                    //query +=')';  
                //} 
            }
            query +=')'; 
        }
        if(!isEmpty(this.appSearch.stage.Country__c) || !isEmpty(this.appSearch.stage.Region__c)){
            query += ' AND (' + countryField + ' INCLUDES (\'Worldwide\')';
            String tempRegion = '';
            if(isEmpty(this.appSearch.stage.Region__c)){
                for(MM_Country_Mapping__c cMapping : MM_Country_Mapping__c.getAll().values()){
                    if(cMapping.Name == this.appSearch.stage.Country__c){
                        tempRegion = cMapping.Region__c;
                    }
                }
            }else{
                tempRegion = this.appSearch.stage.Region__c;
            }
            
            query += (regionToFieldNameMap.containsKey(tempRegion))?' OR ' + countryField + ' INCLUDES (\'' + regionToFieldNameMap.get(tempRegion) + '\')':'';
            if(!isEmpty(this.appSearch.stage.Country__c)){
                query += ' OR ' + countryField + ' INCLUDES (\'' + this.appSearch.stage.Country__c + '\')';
            }else{      
                for(MM_Country_Mapping__c cMapping : MM_Country_Mapping__c.getAll().values()){
                    if(cMapping.Region__c == tempRegion){
                        query += ' OR ' + countryField + ' INCLUDES (\'' + cMapping.Name + '\')';
                    }
                }    
            }       
            query += ')';*/
       // }

       // System.debug(LoggingLevel.ERROR, 'query:  ' + query);

        this.accountIdSet = new Set<Id>();
        Map<Id, CustomApplication> customAppMap = new Map<Id, CustomApplication>();
        //softwareAppMap = new Map<Id, Software_Applications__c>();
        /*for(sObject sa : Database.query(query)){
            //Software_Applications__c tempSa = (Software_Applications__c)sa;     
            if(this.appSearch.searchTerm.containsIgnoreCase('search') || 
               (tempSa.Name != null && tempSa.Name.containsIgnoreCase(this.appSearch.searchTerm)) || 
               (tempSa.Long_Description__c != null && tempSa.Long_Description__c.containsIgnoreCase(this.appSearch.searchTerm)) || 
               (tempSa.Supported_Peripherals__c != null && tempSa.Supported_Peripherals__c.containsIgnoreCase(this.appSearch.searchTerm)) || 
               (tempSa.Supported_Operating_Systems__c != null && tempSa.Supported_Operating_Systems__c.containsIgnoreCase(this.appSearch.searchTerm)) || 
               (tempSa.Short_Description__c != null && tempSa.Short_Description__c.containsIgnoreCase(this.appSearch.searchTerm)) || 
               tempSaIds.contains(tempSa.Id) || 
               (tempSa.Account_C__r.name != null && tempSa.Account_C__r.name.containsIgnoreCase(this.appSearch.searchTerm)) ||
               (tempSa.Account_C__r.NameLocal != null && tempSa.Account_C__r.NameLocal.containsIgnoreCase(this.appSearch.searchTerm)) ||
               (tempSa.Account_C__r.Partner_Account_Name__c!= null && tempSa.Account_C__r.Partner_Account_Name__c.containsIgnoreCase(this.appSearch.searchTerm))){
                //Modified by Sat for Mototrbo appFinder Enhancement- Included account name in search term
                softwareAppMap.put(tempSa.Id, tempSa);
                CustomApplication c = new CustomApplication();
                c.app = tempSa;
                c.app.Long_Description__c = '';
                customAppMap.put(c.app.Id, c);
                accountIdSet.add(c.app.Account_C__c);
            }
        }*/
        
        industrySolutionsMap = new Map<Id, Industries_Solutions__c>();
        /*for(Industries_Solutions__c is : [Select i.Vertical__c, i.SystemModstamp, i.Solutions__c, i.Software_Applications__c, i.Name, i.LastModifiedDate, i.LastModifiedById, i.IsDeleted, i.Industries__c, i.Id, i.Horizontal__c, i.CurrencyIsoCode, i.CreatedDate, i.CreatedById, i.ConnectionSentId, i.ConnectionReceivedId From Industries_Solutions__c i WHERE Software_Applications__c IN :softwareAppMap.keySet()]){
            industrySolutionsMap.put(is.Id, is);
            CustomApplication c = customAppMap.get(is.Software_Applications__c);
            c.industrySolutions.add(is);
            customAppMap.put(is.Software_Applications__c, c);
        }*/
        
        crossIndustriesMap = new Map<Id, Cross_Industries_Solutions__c>();
       /* for(Cross_Industries_Solutions__c is : [Select c.SystemModstamp, c.Cross_Industries__c, c.Solutions__c, c.Software_Applications__c, c.Name, c.LastModifiedDate, c.LastModifiedById, c.IsDeleted, c.Industries__c, c.Id, c.CurrencyIsoCode, c.Cross_Industry__c, c.CreatedDate, c.CreatedById, c.ConnectionSentId, c.ConnectionReceivedId From Cross_Industries_Solutions__c c WHERE Software_Applications__c IN :softwareAppMap.keySet()]){
            crossIndustriesMap.put(is.Id, is);  
            CustomApplication c = customAppMap.get(is.Software_Applications__c);
            c.crossIndustries.add(is);
            customAppMap.put(is.Software_Applications__c, c);
        }*/
        
       /* supportedProductsMap = new Map<Id, Supported_Products__c>();
        for(Supported_Products__c is : [Select s.Technology_Segment__c, s.SystemModstamp, s.Software_Applications__c, s.Name, s.Motorola_Support_Product_Tested__c, s.Model_Name__c, s.LastModifiedDate, s.LastModifiedById, s.IsDeleted, s.Id, s.CurrencyIsoCode, s.CreatedDate, s.CreatedById, s.ConnectionSentId, s.ConnectionReceivedId From Supported_Products__c s WHERE Software_Applications__c IN :softwareAppMap.keySet()]){
            supportedProductsMap.put(is.Id, is);    
            CustomApplication c = customAppMap.get(is.Software_Applications__c);
            c.supportedProducts.add(is);
            customAppMap.put(is.Software_Applications__c, c);
        }*/

        return processAppSearchData(industrySolutionsMap, crossIndustriesMap, customAppMap);
    }
    
    public PageReference processAppSearchData(Map<Id, Industries_Solutions__c> industrySolutionsMap, Map<Id, Cross_Industries_Solutions__c> crossIndustriesMap, Map<Id, CustomApplication> customAppMap){
        Set<Id> idsToReturn = new Set<Id>();
        if(isEmpty(this.appSearch.stage.Industry__c) && 
           isEmpty(this.appSearch.stage.Industry_Specialty__c) && 
           isEmpty(this.appSearch.stage.Business_Industry__c) && 
           isEmpty(this.appSearch.stage.Business__c) && 
           isEmpty(this.appSearch.stage.Business_Specialty__c) && 
           isEmpty(this.appSearch.stage.Technology__c)){
            System.debug(LoggingLevel.ERROR, 'return all');
            //System.debug(LoggingLevel.ERROR, 'softwareAppMap.keySet():  ' + softwareAppMap.keySet());
            //idsToReturn.addAll(softwareAppMap.keySet());    
        }else{
            Set<Id> industrySet = new Set<Id>();
            Set<Id> industrySpecSet = new Set<Id>();
            Set<Id> businessIndustrySet = new Set<Id>();
            Set<Id> businessSet = new Set<Id>();
            Set<Id> businessSpecSet = new Set<Id>();
            Set<Id> techSet = new Set<Id>();
            Set<Id> allIdSetTemp = new Set<Id>();
            
            
            if(!isEmpty(this.appSearch.stage.Industry__c)){
                for(Industries_Solutions__c is : industrySolutionsMap.values()){
                    if(is.Industries__c != null && is.Industries__c.containsIgnoreCase(this.appSearch.stage.Industry__c)){
                        //industrySet.add(is.Software_Applications__c);
                        //allIdSetTemp.add(is.Software_Applications__c);
                    }
                }
            }
            
            if(!isEmpty(this.appSearch.stage.Industry_Specialty__c)){
                for(Industries_Solutions__c is : industrySolutionsMap.values()){
                System.debug('***is.solutions'+is.Solutions__c+'***fromstagetable'+this.appSearch.stage.Industry_Specialty__c);
                    if(is.Solutions__c != null && is.Solutions__c.containsIgnoreCase(this.appSearch.stage.Industry_Specialty__c)){
                        //industrySpecSet.add(is.Software_Applications__c);
                       // allIdSetTemp.add(is.Software_Applications__c);
                    }
                }
            }
            
            if(!isEmpty(this.appSearch.stage.Business_Industry__c)){
                for(Cross_Industries_Solutions__c is : crossIndustriesMap.values()){
                    if(is.Industries__c != null && is.Industries__c.containsIgnoreCase(this.appSearch.stage.Business_Industry__c)){
                        //businessIndustrySet.add(is.Software_Applications__c);
                        //allIdSetTemp.add(is.Software_Applications__c);
                    }
                }
            }
            
            if(!isEmpty(this.appSearch.stage.Business__c)){
                for(Cross_Industries_Solutions__c is : crossIndustriesMap.values()){
                    if(is.Cross_Industry__c != null && is.Cross_Industry__c.containsIgnoreCase(this.appSearch.stage.Business__c)){
                       // businessSet.add(is.Software_Applications__c);
                       // allIdSetTemp.add(is.Software_Applications__c);
                    }
                }
            }
            
            if(!isEmpty(this.appSearch.stage.Business_Specialty__c)){
                for(Cross_Industries_Solutions__c is : crossIndustriesMap.values()){
                    if(is.Solutions__c != null && is.Solutions__c.containsIgnoreCase(this.appSearch.stage.Business_Specialty__c)){
                        //businessSpecSet.add(is.Software_Applications__c);
                        //allIdSetTemp.add(is.Software_Applications__c);
                    }
                    //Added by Sathish for Radio App Finder Enhancement
                    if(this.appSearch.stage.Business_Specialty__c.containsIgnoreCase('Life Safety')
                       &&  is.Solutions__c != null && is.Solutions__c.containsIgnoreCase('Life Safety') && is.Cross_Industry__c !=null 
                       && (is.Cross_Industry__c.containsIgnoreCase('Communications') || is.Cross_Industry__c.containsIgnoreCase('Safety and Security')) ){
                           //businessSet.add(is.Software_Applications__c); 
                    }
                    //Ends                    
                }
            }
            
            if(!isEmpty(this.appSearch.stage.Technology__c)){
                /*for(Supported_Products__c is : supportedProductsMap.values()){
                    if(is.Technology_Segment__c != null && is.Technology_Segment__c.containsIgnoreCase(this.appSearch.stage.Technology__c)){
                        techSet.add(is.Software_Applications__c);
                        allIdSetTemp.add(is.Software_Applications__c);
                    }
                }*/
            }
            
            for(Id tempId : allIdSetTemp){
                if(!isEmpty(this.appSearch.stage.Industry__c) && !industrySet.contains(tempId)){
                    continue;
                }
                if(!isEmpty(this.appSearch.stage.Industry_Specialty__c) && !industrySpecSet.contains(tempId)){
                    continue;
                }
                if(!isEmpty(this.appSearch.stage.Business_Industry__c) && !businessIndustrySet.contains(tempId)){
                    continue;
                }
                if(!isEmpty(this.appSearch.stage.Business__c) && !businessSet.contains(tempId)){
                    continue;
                }
                if(!isEmpty(this.appSearch.stage.Business_Specialty__c) && !businessSpecSet.contains(tempId)){
                    continue;
                }
                if(!isEmpty(this.appSearch.stage.Technology__c) && !techSet.contains(tempId)){
                    continue;
                }
                idsToReturn.add(tempId);
            }
        }
        
        List<Customer_References__c> crList = new List<Customer_References__c>();
        for(Customer_References__c cr : [Select Customer_Name__c FROM Customer_References__c ]){
            crList.add(cr);
        }
        
        Map<Id, Account> accountMap = new Map<Id, Account>();
        for(Account a : [Select Id, Name FROM Account WHERE Id IN :accountIdSet]){
            accountMap.put(a.Id, a);
        }
        
        this.appDataList = new List<ApplicationDataStripped>();
        this.appDataAllList = new List<List<ApplicationDataStripped>>();
        List<ApplicationDataStripped> tempAppDataList = new List<ApplicationDataStripped>();
        /*Commenting as part of SF-491 - Delete unused custom objects - Start
        Map<Id, Id> softwareToLogoMap = new Map<Id, Id>();
        for(Application_Logo__c al : [Select Id, Software_Applications__c,Logo_DocumentId__c, (Select Id, Name, ContentType From Attachments) From Application_Logo__c WHERE Software_Applications__c IN :idsToReturn]){
            Commented by Harish to make use of Logo DocumentId instead of attachment Id as a part of INC0188352
           for(Attachment att : al.Attachments){
                softwareToLogoMap.put(al.Software_Applications__c, att.Id);
            }
            
          softwareToLogoMap.put(al.Software_Applications__c, al.Logo_DocumentId__c);  // Modified by Harish as a part of INC0188352
        }
        Map<Id, List<Screenshot>> softwareToScreenshotMap = new Map<Id, List<Screenshot>>();
        for(Screenshots__c sc : [Select Id, ImageAttachmentId__c, ThumbnailPreviewImageID__c, Software_Applications__c From Screenshots__c WHERE Software_Applications__c IN :idsToReturn]){
            List<Screenshot> scList = new List<Screenshot>();
            if(softwareToScreenshotMap.containsKey(sc.Software_Applications__c)){
                scList = softwareToScreenshotMap.get(sc.Software_Applications__c);
            }
            scList.add(new Screenshot(sc.Id, sc.ThumbnailPreviewImageID__c, sc.ImageAttachmentId__c));
            softwareToScreenshotMap.put(sc.Software_Applications__c, scList);
            System.debug('************screenshots'+softwareToScreenshotMap);
        }
        Commenting as part of SF-491 - Delete unused custom objects - End*/
        System.debug('idsToReturn:  ' + idsToReturn);
        
        Map<Id, Id> acctIdToAppId = new Map<Id, Id>();
        Set<Id> acctIds = new Set<Id>();
        Map<Id, Decimal> acctIdToSortMap = new Map<Id, Decimal>();
        
        if(!isEmpty(this.appSearch.stage.Technology__c)){
           /* for(Software_Applications__c tempSa : softwareAppMap.values()){
                acctIdToAppId.put(tempSa.Account_C__c, tempSa.Id);
                acctIds.add(tempSa.Account_C__c);
            }*/
            
            for(Technology_Specialization__c tempTs : [Select Id, Account__c, MM_Sort_Order__c 
                                                       FROM Technology_Specialization__c
                                                       WHERE Community_Type__c = 'Application Partner'
                                                       AND Technology_Specialization_Level__c != 'OPEN'
                                                       AND Partner_Program__r.Status__c = 'Active'
                                                       AND Technology_Specialization__c = :this.appSearch.stage.Technology__c 
                                                       AND Account__c IN :acctIds]){
                if(!acctIdToSortMap.containsKey(tempTs.Account__c) || tempTs.MM_Sort_Order__c < acctIdToSortMap.get(tempTs.Account__c)){
                    acctIdToSortMap.put(tempTs.Account__c, tempTs.MM_Sort_Order__c);
                }   
            }
        }
        
        Set<Id> qlIds = this.getApplicationQLIds();
       /* for(Id appId : idsToReturn){
            ApplicationDataStripped ad = new ApplicationDataStripped();
            ad.hasTechnology = (isEmpty(this.appSearch.stage.Technology__c))?false:true;
            //ad.application = customAppMap.get(appId).app;
            ad.appId = appId;
            ad.isInQuickList = (qlIds.contains(appId))?true:false;*/

            /*if(!isEmpty(this.appSearch.stage.Technology__c) && acctIdToSortMap.containsKey(ad.application.Account_C__c)){
                ad.techSpecSort = acctIdToSortMap.get(ad.application.Account_C__c);
            }*/
            
           // ad.metalLevelSort = customAppMap.get(appId).app.Account_C__r.Metal_Level_Sort__c;
           // ad.motorolaTestSort = customAppMap.get(appId).app.MM_Motorola_Tested_Sort__c;
           // ad.motorolaTested = customAppMap.get(appId).app.Motorola_Tested__c;
              //Added by Sathish
           // for(Supported_Products__c device :customAppMap.get(appId).supportedProducts){
               //ad.supportedDevice.addAll(customAppMap.get(appId).supportedProducts);
            //}
            
            //System.debug('ad.application.name:  ' + ad.application.name);
            //System.debug('ad.motorolaTestSort:  ' + ad.motorolaTestSort);
            //System.debug('ad.techSpecSort:  ' + ad.techSpecSort);
            //System.debug('ad.metalLevelSort:  ' + ad.metalLevelSort);
            
            /*Commenting as part of SF-491 - Delete unused custom objects - Start
            if(softwareToLogoMap != null){
                ad.appIconUrl = (softwareToLogoMap.containsKey(appId))?'/servlet/servlet.FileDownload?file=' + softwareToLogoMap.get(appId):'';
            }
            Commenting as part of SF-491 - Delete unused custom objects - End*/
            //if(tempAppDataList.size() < 100){
               // tempAppDataList.add(ad);
            //}
        //}
        
        if(this.appSearch.stage.E_or_G__c !=null && this.appSearch.stage.E_or_G__c =='E'){
            enterpriseApplicationIds = findApplicationType(idsToReturn,customAppMap,subPageStateMap.get(State.ENTERPRISE_SOFTWARE));    
            //Commenting as part of SF-491 - Delete unused custom objects
            //tempAppDataList=categorizeAppFinderResults(enterpriseApplicationIds ,customAppMap,acctIdToSortMap,softwareToLogoMap);
            tempAppDataList=categorizeAppFinderResults(enterpriseApplicationIds ,customAppMap,acctIdToSortMap);
            numberOfResults = enterpriseApplicationIds.size() > 100? 100: enterpriseApplicationIds.size();
        }else{
             radioApplicationIds = findApplicationType(idsToReturn,customAppMap,subPageStateMap.get(State.RADIO_SOFTWARE));
             //Commenting as part of SF-491 - Delete unused custom objects - Start
             //tempAppDataList=categorizeAppFinderResults(radioApplicationIds ,customAppMap,acctIdToSortMap,softwareToLogoMap);
             tempAppDataList=categorizeAppFinderResults(radioApplicationIds ,customAppMap,acctIdToSortMap);
             numberOfResults = radioApplicationIds.size() > 100 ? 100 : radioApplicationIds.size();
        }
        
        /* this.numberOfEntApps = enterpriseApplicationIds.size() > 100 ? 100 : enterpriseApplicationIds.size();
        this.numberOfRadioApps = radioApplicationIds.size() > 100 ? 100 : radioApplicationIds.size();  
        
       /* populateAppFinderPageSubState(enterpriseApplicationIds ,radioApplicationIds ,this.appSearch.stage.Technology__c);  
        if(this.subPageState == subPageStateMap.get(State.RADIO_SOFTWARE) ){
            tempAppDataList=categorizeAppFinderResults(radioApplicationIds ,customAppMap,acctIdToSortMap,softwareToLogoMap);
        }else{
            tempAppDataList=categorizeAppFinderResults(enterpriseApplicationIds ,customAppMap,acctIdToSortMap,softwareToLogoMap);
        } */
        
        populateAppDataList(tempAppDataList);
        //this.numberOfResults = tempAppDataList.size();
        //System.debug(LoggingLevel.ERROR, 'this.numberOfResults:  ' + this.numberOfResults);
        this.populatePageState(State.RESULTS);
       // if(this.subPageState==null || (this.subPageState!=this.subPageStateMap.get(State.ENTERPRISE_SOFTWARE) || this.subPageState!=this.subPageStateMap.get(State.RADIO_SOFTWARE)))
          //if(this.subPageState==null) 
           // populateSubPageState(State.ENTERPRISE_SOFTWARE);
        return null;
    }
    
    public void populateAppDataList(){
        List<ApplicationDataStripped> tempAppData = new List<ApplicationDataStripped>();
        for(List<ApplicationDataStripped> ad : this.appDataAllList){
            tempAppData.addAll(ad);
        }
        populateAppDataList(tempAppData);
    }
    
    public void populateAppDataList(List<ApplicationDataStripped> tempAppDataList){
        tempAppDataList.sort();
        Integer pageSize = (this.showAllResults)?tempAppDataList.size():Integer.valueOf(System.Label.MM_PageSize);
        this.paginater = new Paginate(tempAppDataList.size(), pageSize);
        this.appDataAllList = new List<List<ApplicationDataStripped>>();
        this.appDataList = new List<ApplicationDataStripped>();
        Integer totalRecords = 0;
        if(tempAppDataList.size() > 0){
            List<ApplicationDataStripped> tempAd = new List<ApplicationDataStripped>();         
            Integer i = 0;
            for(ApplicationDataStripped ad : tempAppDataList){
                if(totalRecords < 100){
                    tempAd.add(ad);
                    i++;
                    if(i == pageSize){
                        this.appDataAllList.add(tempAd);
                        tempAd = new List<ApplicationDataStripped>();
                        i = 0;
                    }
                    totalRecords++;
                }else{
                    break;
                }
            }
            if(!tempAd.isEmpty()){
                this.appDataAllList.add(tempAd);
            }
            
            this.appDataList = this.appDataAllList.get(this.paginater.index);
        }
    }


    public void writeQuickLinksToCookie(){
        try{
            qlCookie = new Cookie('quickLinks', JSON.serialize(this.qlPanel), null, -1, false);
            ApexPages.currentPage().setCookies(new Cookie[]{qlCookie});
        }catch(Exception e){
            System.debug(LoggingLevel.ERROR, 'Exception when adding cookie:  ' + e);
        }
    }
    
    public PageReference addToQuickList(){
        // Start of Modified by Nimesh for MOTOTRBO Changes
        // For Enterprise Applications
        /* if(this.subPageState == subPageStateMap.get(State.ENTERPRISE_SOFTWARE)){
            Boolean shouldAddEnterpriseApp = true;
            for(QuickLink ql : this.qlPanel.enterpriseAppLinks){ 
                if(ql.id == this.idOfSelectedRecord){
                    shouldAddEnterpriseApp = false;
                }
            }
            if(shouldAddEnterpriseApp){
                this.qlPanel.enterpriseAppLinks.add(new QuickLink(this.idOfSelectedRecord, nameOfSelectedRecord, true, this.deepLink.allParams));
                for(ApplicationDataStripped ad : this.appDataList){
                    if(ad.appId == idOfSelectedRecord){
                        ad.isInQuickList = true;
                        break;
                    }
                }
                writeQuickLinksToCookie();
            }
        }
        
        // For Radio Applications
        if(this.subPageState == subPageStateMap.get(State.RADIO_SOFTWARE)){     
            Boolean shouldRadioApp = true;
            for(QuickLink ql : this.qlPanel.radioAppLinks){
                if(ql.id == this.idOfSelectedRecord){
                    shouldRadioApp = false;
                }
            }       
            if(shouldRadioApp){
                this.qlPanel.radioAppLinks.add(new QuickLink(this.idOfSelectedRecord, nameOfSelectedRecord, true, this.deepLink.allParams));
                for(ApplicationDataStripped ad : this.appDataList){
                    if(ad.appId == idOfSelectedRecord){
                        ad.isInQuickList = true;
                        break;
                    }
                }
                writeQuickLinksToCookie();
            }
        }
        if(appData !=null && appData.appId == idOfSelectedRecord){
            if(appData.ApplicationType.contains('ENTERPRISE')){
                this.qlPanel.enterpriseAppLinks.add(new QuickLink(this.idOfSelectedRecord, nameOfSelectedRecord, true, this.deepLink.allParams));
            }else if (appData.ApplicationType.contains('RADIO')){
                this.qlPanel.radioAppLinks.add(new QuickLink(this.idOfSelectedRecord, nameOfSelectedRecord, true, this.deepLink.allParams));
            }
            appData.isInQuickList = true;
            writeQuickLinksToCookie();          
        }*/
        // End of Modified by Nimesh for MOTOTRBO Changes
        
        Boolean shouldAdd = true;
        if(this.qlPanel.applicationLinks == null)
             this.qlPanel.applicationLinks = new List<QuickLink>();
        
        //if(this.qlPanel.applicationLinks !=null && this.qlPanel.applicationLinks.size()>0){
                for(QuickLink ql : this.qlPanel.applicationLinks){
                if(ql.id == this.idOfSelectedRecord){
                    shouldAdd = false;
                }
           // }
        
        }

        if(shouldAdd){
            this.qlPanel.applicationLinks.add(new QuickLink(this.idOfSelectedRecord, nameOfSelectedRecord, true, this.deepLink.allParams));
            for(ApplicationDataStripped ad : this.appDataList){
                if(ad.appId == idOfSelectedRecord){
                    ad.isInQuickList = true;
                    if(appData!=null && appData.appId == idOfSelectedRecord){
                        appData.isInQuickList = true;
                    }
                    break;
                }
            }
            writeQuickLinksToCookie();
        }
        return null;
    }
    
    public PageReference addToQuickListPartner(){
        Boolean shouldAdd = true;
        for(QuickLink ql : this.qlPanel.partnerLinks){
            if(ql.id == this.idOfSelectedRecord){
                shouldAdd = false;
            }
        }
        if(shouldAdd){
            for(PartnerData pd : this.partnerGenericList){
                if(pd.acctId == idOfSelectedRecord){
                    pd.isInQuickList = true;
                    break;
                }
            }
            if(this.partnerData != null && this.partnerData.acctId == idOfSelectedRecord){
                this.partnerData.isInQuickList = true;
            }
            
            this.qlPanel.partnerLinks.add(new QuickLink(this.idOfSelectedRecord, nameOfSelectedRecord, false, this.deepLink.allParams));
            writeQuickLinksToCookie();
            if(this.pageState == this.pageStateMap.get(State.MAP_VIEW)){
                this.updatePartnerQuickList(true);
            }
        }
        return null;
    }
    
    public PageReference emailQuickList(){
        Marketplace_Quick_List__c mql = new Marketplace_Quick_List__c();
        mql.Application_Quick_Links__c = '';
       // mql.Radio_Apps_Quick_Links__c = '';
        mql.Partner_Quick_Links__c = '';
        mql.Language__c = this.deepLink.loc;
        
        String siteDomain = '';
        for(MM_Url__c tempUrl : MM_Url__c.getAll().values()){
            siteDomain = (tempUrl.name == 'marketplace')?tempUrl.Url__c:'';
        }

/*      
        Set<Id> acctIdSet = new Set<Id>();
        Set<Id> softwareIdSet = new Set<Id>();
        for(QuickLink ql : this.qlPanel.applicationLinks){
            softwareIdSet.add(ql.Id);
        }
        for(QuickLink ql : this.qlPanel.partnerLinks){
            acctIdSet.add(ql.Id);
        }
        
        for(Software_Applications__c sa : [Select Id, Account_C__c FROM Software_Applications__c WHERE Id IN :softwareIdSet]){
            acctIdSet.add(sa.Account_C__c);
        }
        
        Map<Id, PartnerData> partnerDataMap = new Map<Id, PartnerData>();
        for(Account a : [Select Id, MM_Federal_Specialization_Sort__c, MM_Partner_Type_Sort__c, MM_Metal_Level_Sort__c, Partner_Region__c, MEGO_Order__c, Name, NameLocal, Partner_Account_Name__c, Value_Add__c, Company_Description__c, Socio_Economic_Status__c, Website_URL__c, Metal_Level__c, (Select Id, IsDeleted, Name, CurrencyIsoCode, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, ConnectionReceivedId, ConnectionSentId, Account__c, Account_Product__c, ProductKey__c, Product_Ext_Ref_Id__c, Product__c, Product_offering__c, Publish_Flag__c, Account_Unique_Id__c, Account__r.Partner_Region__c From Product_Offered__r), (Select Id, IsDeleted, Name, CurrencyIsoCode, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, LastActivityDate, ConnectionReceivedId, ConnectionSentId, Account_C__c, Customer__c, End_Date__c, Languages__c, Long_Description__c, Market_Ready_Offering__c, Account_C__r.Metal_Level_Sort__c, MM_Motorola_Tested_Sort__c, Motorola_Tested__c, Offer_Countries_End_User__c, Offer_Countries_Partner_to_Partner__c, Publish_on_Motorola_com__c, Request_Motorola_Validation__c, Short_Description__c, Status__c, Supported_Operating_Systems__c, Supported_Peripherals__c, Target_Customer_Size__c, Tested_Date__c, Type_of_Application_Build_Per_Client__c, Uses_a_MSI_Rho_Development_Framework__c, Version__c From Partner_Software_Apps_del__r), (Select UPL_CommunityMarketTerm__c, Type__c, Technology_Specialization__c, Technology_Specialization_Status__c, Technology_Specialization_Level__c, Tech_Specialization_Compliant_Status__c, SystemModstamp, Sort_Order__c, Program__c, Partner_Zone__c, Partner_Program__c, Partner_Category__c, Name, Market_Term__c, LastModifiedDate, LastModifiedById, LastActivityDate, IsDeleted, Id, CurrencyIsoCode, CreatedDate, CreatedById, ConnectionSentId, ConnectionReceivedId, Compliance_Review_Date__c, Community_Type__c, Authorized__c, Account__c, Account_Unique_Id__c, AccountPartnerRegion__c, Acc_Prgm_Track_Cmnty__c, Partner_Program__r.Status__c, MM_Distributor_Sort__c,Country__c FROM Technology_Specializations__r), (Select SystemModstamp, Name, Market_Specialization__c, Market_Specialization_Level__c, LastModifiedDate, LastModifiedById, LastActivityDate, IsDeleted, Id, CurrencyIsoCode, CreatedDate, CreatedById, ConnectionSentId, ConnectionReceivedId, Account__c FROM Market_Specializations__r), (Select street__c, SystemModstamp, State__c, State_Code__c, Postal_code__c, Phone__c, PartnerName__c, Name, Longitude__c, Location_Publish_Flag__c, Location_Key__c, Location_Ext_Ref_Id__c, Latitude__c, LastModifiedDate, LastModifiedById, Keyword__c, IsPrimary__c, IsDeleted, Id, Federal_Status__c, Fax__c, CurrencyIsoCode, CreatedDate, CreatedById, Country_Code__c, Country1__c, ConnectionSentId, ConnectionReceivedId, City__c, Address_Type__c, Address_Line3__c, Address_Line2__c, Address_Line1__c, Account__c, Account_Website_URL__c, Account_Name__c, Account_Location__c FROM Partner_Locations__r) FROM Account WHERE Id IN :acctIdSet]){
            partnerDataMap.put(a.Id, new PartnerData(a, this.partnerSearch, this.deepLink.allParams, QueryType.CHANNEL_PARTNER));
        }
*/
        /*for(QuickLink ql : this.qlPanel.enterpriseAppLinks){ // Modified by Nimesh for MOTOTRBO Changes
            System.debug('ql.url.url:  ' + ql.url.url);
            mql.Enterprise_Apps_Quick_Links__c += '<a href="' + siteDomain + '&appId=' + ql.Id + '&dest=Application&loc=' + this.deepLink.loc + '">' + ql.url.name + '</a><br/>';   
        }
        for(QuickLink ql : this.qlPanel.radioAppLinks){ // Modified by Nimesh for MOTOTRBO Changes
            System.debug('ql.url.url:  ' + ql.url.url);
            mql.Radio_Apps_Quick_Links__c += '<a href="' + siteDomain + '&appId=' + ql.Id + '&dest=Application&loc=' + this.deepLink.loc + '">' + ql.url.name + '</a><br/>';   
        }*/
        for(QuickLink ql : this.qlPanel.applicationLinks){
            System.debug('ql.url.url:  ' + ql.url.url);
            mql.Application_Quick_Links__c += '<a href="' + siteDomain + '&appId=' + ql.Id + '&dest=Application&loc=' + this.deepLink.loc + '">' + ql.url.name + '</a><br/>';   
        }       
        for(QuickLink ql : this.qlPanel.partnerLinks){
            mql.Partner_Quick_Links__c += '<a href="' + siteDomain + '&partnerId=' + ql.Id + '&dest=Channel&loc=' + this.deepLink.loc + '">' + ql.url.name + '</a><br/>';   
        }
        System.debug('qlPanel.emailAddress:  ' + this.emailAddress);
        Integer i = 1;
        if(!isEmpty(this.emailAddress)){
            for(String email : this.emailAddress.split(';')){
                if(i == 1){
                    mql.Email__c = email.trim();
                }else if(i == 2){
                    mql.Email2__c = email.trim();
                }else if(i == 3){
                    mql.Email3__c = email.trim();
                }else if(i == 4){
                    mql.Email4__c = email.trim();
                }else if(i == 5){
                    mql.Email5__c = email.trim();
                }
                i++;
            }
        }
        try{
            insert mql;
            this.emailAddress = '';
        }catch(Exception e){
            System.debug(e);
        }

        this.populateSubPageState(State.QL_SENT);
        
        return null;
    }
    
    public PageReference removeFromQuickListApplication(){
        // Modified by Nimesh for MOTOTRBO Changes  
        /*for(Integer i = 0; i < this.qlPanel.enterpriseAppLinks.size(); i++){
            if(this.qlPanel.enterpriseAppLinks.get(i).id == idOfSelectedRecord){
                this.qlPanel.enterpriseAppLinks.remove(i);
            }           
        }
        // Modified by Nimesh for MOTOTRBO Changes
        for(Integer i = 0; i < this.qlPanel.radioAppLinks.size(); i++){
            if(this.qlPanel.radioAppLinks.get(i).id == idOfSelectedRecord){
                this.qlPanel.radioAppLinks.remove(i);
            }           
        }       
        if(this.appDataList != null && !this.appDataList.isEmpty()){
            for(ApplicationDataStripped ad : this.appDataList){
                if(ad.appId == idOfSelectedRecord){
                    ad.isInQuickList = false;
                    break;
                }
            }
        }
        if(appData != null && appData.appId == idOfSelectedRecord){
                appData.isInQuickList = false;
        }
        writeQuickLinksToCookie(); */
       for(Integer i = 0; i < this.qlPanel.applicationLinks.size(); i++){
            if(this.qlPanel.applicationLinks.get(i).id == idOfSelectedRecord){
                this.qlPanel.applicationLinks.remove(i);
            }           
        }
        if(this.appDataList != null && !this.appDataList.isEmpty()){
            for(ApplicationDataStripped ad : this.appDataList){
                if(ad.appId == idOfSelectedRecord){
                    ad.isInQuickList = false;
                     break;
                    }
                   
                //}
            }
        }
        writeQuickLinksToCookie();
        
        return null;
    }
    
    public PageReference removeFromQuickListPartner(){
        for(Integer i = 0; i < this.qlPanel.partnerLinks.size(); i++){
            if(this.qlPanel.partnerLinks.get(i).id == idOfSelectedRecord){
                this.qlPanel.partnerLinks.remove(i);
            }           
        }
        for(PartnerData pd : this.partnerGenericList){
            if(pd.acctId == idOfSelectedRecord){
                pd.isInQuickList = false;
                break;
            }
        }
        if(this.partnerData != null && this.partnerData.acctId == idOfSelectedRecord){
            this.partnerData.isInQuickList = false;
        }
        
        if(this.pageState == this.pageStateMap.get(State.MAP_VIEW)){
            this.updatePartnerQuickList(false);
        }
        writeQuickLinksToCookie();
        return null;
    }
    
    public PageReference showAppDetail(){
        this.previousState = this.pageState;
        this.deepLink.appId = this.idOfSelectedRecord;
        populateTechTrackMap();
        this.doDetailAppProcess();        
        
        Boolean hasBeenFound = false;
        this.showNext = false;
        this.showPrevious = false;
        for(List<ApplicationDataStripped> tempList : this.appDataAllList){
            if(hasBeenFound){
                this.showNext = true;
                break;
            }
            for(ApplicationDataStripped ad : tempList){
                if(hasBeenFound){
                    this.showNext = true;
                    break;
                }
                if(ad.appId == this.idOfSelectedRecord){
                    //this.appData = ad;
                    hasBeenFound = true;
                }
                if(!hasBeenFound){
                    this.showPrevious = true;
                }
            }
        }
        this.populatePageState(State.DETAIL);
        return null;
    }
    
    public List<PartnerData> getTempPartnerDataList(){
        if(this.subPageState == subPageStateMap.get(State.CHANNEL_PARTNERS) && this.partnerChannelList != null){
            System.debug(LoggingLevel.ERROR, 'subPageState in getTemp:  ' + subPageState);
            return this.partnerChannelList; 
        }else if(this.subPageState == subPageStateMap.get(State.DISTRIBUTORS) && this.partnerDistributorList != null){
            System.debug(LoggingLevel.ERROR, 'subPageState in getTemp:  ' + subPageState);
            return this.partnerDistributorList;
        }else if(this.subPageState == subPageStateMap.get(State.SOFTWARE_VENDORS) && this.partnerSoftwareList != null){
            System.debug(LoggingLevel.ERROR, 'subPageState in getTemp:  ' + subPageState);
            return this.partnerSoftwareList;
        }else if(this.subPageState == subPageStateMap.get(State.CHANNEL_PARTNER_AND_SOFTWARE) && this.partnerChannelAndSoftwareList != null){
            System.debug(LoggingLevel.ERROR, 'subPageState in getTemp:  ' + subPageState);
            return this.partnerChannelAndSoftwareList;
        }
        return new List<PartnerData>();
    }
    
    public void updatePartnerQuickList(Boolean remove){
        if(this.subPageState == subPageStateMap.get(State.CHANNEL_PARTNERS) && this.partnerChannelList != null){
            this.partnerChannelList = setPartnerQuickList(remove, this.partnerChannelList); 
        }else if(this.subPageState == subPageStateMap.get(State.DISTRIBUTORS) && this.partnerDistributorList != null){
            this.partnerDistributorList = setPartnerQuickList(remove, this.partnerDistributorList); 
        }else if(this.subPageState == subPageStateMap.get(State.SOFTWARE_VENDORS) && this.partnerSoftwareList != null){
            this.partnerSoftwareList = setPartnerQuickList(remove, this.partnerSoftwareList); 
        }else if(this.subPageState == subPageStateMap.get(State.CHANNEL_PARTNER_AND_SOFTWARE) && this.partnerChannelAndSoftwareList != null){
            this.partnerChannelAndSoftwareList = setPartnerQuickList(remove, this.partnerChannelAndSoftwareList); 
        }
        populateGenericList();
    }
    
    public List<PartnerData> setPartnerQuickList(Boolean remove, List<PartnerData> pdList){
        for(PartnerData pd : pdList){
            if(pd.acctId == idOfSelectedRecord){
                pd.isInQuickList = remove;
            }
        }
        return pdList;
    }
    
    public PageReference showPartnerDetail(){
        this.previousState = this.pageState;
        List<PartnerData> tempPd = getTempPartnerDataList();
        this.showNext = false;
        this.showPrevious = false;
        Boolean hasBeenFound = false;
        for(PartnerData pd : tempPd){
            if(hasBeenFound){
                this.showNext = true;
                break;
            }
            if(pd.acctId == this.idOfSelectedRecord){
                this.partnerData = pd;
                this.populatePageState(State.DETAIL);
                hasBeenFound = true;
            }
            if(!hasBeenFound){
                this.showPrevious = true;
            }
        }
         /******Added by SaiHarish as a part of INC0387757 **********/
        this.partnerPrimaryLocationsJS = '[';
        Integer i = 1;
        if(!Test.isRunningTest()){
        if(this.partnerData.PrimaryLocationList.size()!=0){
        for(Location loc : this.partnerData.PrimaryLocationList){
            if(i < 11 && (!isEmpty(loc.latitude) && !isEmpty(loc.longitude))){
                this.partnerPrimaryLocationsJS += '[\'';
                this.partnerPrimaryLocationsJS += (isEmpty(loc.address1))?'':String.escapeSingleQuotes(loc.address1) + '<br/>';
                this.partnerPrimaryLocationsJS += (isEmpty(loc.address2))?'':String.escapeSingleQuotes(loc.address2) + '<br/>';
                this.partnerPrimaryLocationsJS += (isEmpty(loc.city))?'':String.escapeSingleQuotes(loc.city) + ', ';
                this.partnerPrimaryLocationsJS += (isEmpty(loc.state))?'':String.escapeSingleQuotes(loc.state) + ', ';
                this.partnerPrimaryLocationsJS += (isEmpty(loc.zip))?'':String.escapeSingleQuotes(loc.zip);
                this.partnerPrimaryLocationsJS = (this.partnerPrimaryLocationsJS.endsWith(','))?this.partnerPrimaryLocationsJS.substringBeforeLast(','):this.partnerPrimaryLocationsJS;
                this.partnerPrimaryLocationsJS += '<br/>';
                this.partnerPrimaryLocationsJS += loc.country;
                this.partnerPrimaryLocationsJS += '\', ';
                this.partnerPrimaryLocationsJS += loc.latitude + ', ' + loc.longitude;
                this.partnerPrimaryLocationsJS += ', ' + String.valueOf(i) + '],';
                i++;
            }
        }
        }
        this.partnerPrimaryLocationsJS += ']';
        this.partnerPrimaryLocationsJS = this.partnerPrimaryLocationsJS.replace('],]', ']]');
        }
        /******End by SaiHarish as a part of INC0387757 **********/
        return null;
    }
    
    public PageReference showQuickLinkEmailClicked(){
        this.populateSubPageState(State.QL_EMAIL);
        return null;
    }
    
    public PageReference showQuickLinkClicked(){
        this.previousPageState = this.pageState;
        this.previousSubState = this.subPageState;
        this.populatePageState(State.QUICK_LINK);
        this.populateSubPageState(State.QL_START);
        this.styleClass = '';
        return null;
    }
    
    public PageReference closeQuickLink(){
        this.pageState = this.previousPageState;
        this.subPageState = this.previousSubState;
        this.styleClass = 'active';
        return null;
    }
    
    public PageReference backFromDetail(){
        if(this.previousState == pageStateMap.get(State.DETAIL)){
            this.populatePageState(State.RESULTS);
        }else{
            this.pageState = previousState;
        }
        return null;
    }
    
    public PageReference backFromAdditionalLocations(){
        this.populatePageState(State.DETAIL);
        return null;
    }
    
    public PageReference newSearch(){
        this.populatePageState(State.START);
        //this.populateSubPageState(State.CHANNEL_PARTNERS);
        populateTechTrackMap();
        this.styleClass = 'active';
        this.displayDetailLinks = true;
        
        return this.clear();
    }
    
    public void populateGenericList(){
    System.debug('Ananth Entered populateGenericList()');
        System.debug(LoggingLevel.ERROR, 'this.subPageState:  ' + this.subPageState);
        List<PartnerData> tempPdList = getTempPartnerDataList();
        System.debug(LoggingLevel.ERROR, 'tempPdList.size():  ' + tempPdList.size());
        System.debug(LoggingLevel.ERROR, 'tempPdList:  ' + tempPdList);
        
        Integer pageSize = (this.showAllResults)?tempPdList.size():Integer.valueOf(System.Label.MM_PageSize);
        this.paginater = new Paginate(tempPdList.size(), pageSize);
        this.partnerAllGenericList = new List<List<PartnerData>>();
        this.partnerGenericList = new List<PartnerData>();
        if(tempPdList.size() > 0 && this.pageState != this.pageStateMap.get(State.MAP_VIEW)){
            List<PartnerData> tempPd = new List<PartnerData>();         
            Integer i = 0;
            for(PartnerData pd : tempPdList){
                tempPd.add(pd);
                i++;
                if(i == pageSize){
                    this.partnerAllGenericList.add(tempPd);
                    tempPd = new List<PartnerData>();
                    i = 0;
                }
            }
            if(!tempPd.isEmpty()){
                this.partnerAllGenericList.add(tempPd);
            }
            
            this.partnerGenericList = this.partnerAllGenericList.get(this.paginater.index);
        }else if(tempPdList.size() > 0 && this.pageState == this.pageStateMap.get(State.MAP_VIEW)){
            this.partnerDataLocationsCenter = '';
            this.partnerDataLocationsJS = '[';
            Integer i = 1;
            String srPath = getResourceURL('MM_Stylesheet2');
            
            // Modified the count of locations on Map from 30 to 50 by SaiHarish as a part of INC0387757
            for(PartnerData pd : tempPdList){
            System.Debug('Harish MapData***'+pd);
            System.Debug('Harish Latitude'+pd.primaryLocation.latitude+'Harish Longitude'+pd.primaryLocation.longitude);
                if(i < Integer.valueof(System.Label.MM_Number_of_Locations) && (!isEmpty(pd.primaryLocation.latitude) && !isEmpty(pd.primaryLocation.longitude))){
                    this.partnerDataLocationsCenter = (this.partnerDataLocationsCenter == '')?pd.primaryLocation.latitude + ', ' + pd.primaryLocation.longitude:this.partnerDataLocationsCenter;
                    this.partnerDataLocationsJS += '[\'<a href="javascript:;" onclick="showDetailRecord(\\\'' + pd.acctId + '\\\')">';
                    this.partnerDataLocationsJS += String.escapeSingleQuotes(pd.name);
                    this.partnerDataLocationsJS += '</a><br/>';
                    this.partnerDataLocationsJS += (isEmpty(pd.primaryLocation.city))?'':pd.primaryLocation.city + ', ';
                    this.partnerDataLocationsJS += (isEmpty(pd.primaryLocation.state))?'':pd.primaryLocation.state + ', ';
                    this.partnerDataLocationsJS += (isEmpty(pd.primaryLocation.zip))?'':pd.primaryLocation.zip;
                    this.partnerDataLocationsJS = (this.partnerDataLocationsJS.endsWith(','))?this.partnerDataLocationsJS.substringBeforeLast(','):this.partnerDataLocationsJS;
                    this.partnerDataLocationsJS += '<br/>';
                    this.partnerDataLocationsJS += String.escapeSingleQuotes(pd.primaryLocation.country);
                    if(pd.isInQuickList){
                        this.partnerDataLocationsJS += '<br/><a href="javascript:;" class="quickListRemoveClass" onclick="removeFromQuickList(\\\'' + pd.acctId + '\\\', \\\'' + String.escapeSingleQuotes(pd.name) + '\\\')"><img src="' + srPath + '/images/quick_list_icon_neg.jpg"/></a><br/>\', ';
                    }else{
                        this.partnerDataLocationsJS += '<br/><a href="javascript:;" class="quickListAddClass" onclick="addToQuickList(\\\'' + pd.acctId + '\\\', \\\'' + String.escapeSingleQuotes(pd.name) + '\\\')"><img src="' + srPath + '/images/quick_list_icon.jpg"/></a><br/>\', ';
                    }
                    this.partnerDataLocationsJS += pd.primaryLocation.latitude + ', ' + pd.primaryLocation.longitude;
                    this.partnerDataLocationsJS += ', ' + String.valueOf(i) + '],';
                    i++;
                }
            }
            
            this.partnerDataLocationsJS += ']';
            this.partnerDataLocationsJS = this.partnerDataLocationsJS.replace('],]', ']]');
        }
        System.debug('Ananth Exit populateGenericList()');
    }
    
    public static String getResourceURL(String resourceName){  
        for(StaticResource sr : [SELECT Name, NamespacePrefix, SystemModStamp FROM StaticResource WHERE Name = :resourceName]){
        System.Debug('Harish******'+'resource/' + sr.SystemModStamp.getTime() + '/' + resourceName);
           return 'resource/' + sr.SystemModStamp.getTime() + '/' + resourceName;   
        }  
        return '';  
    }      
    
    public PageReference commonGenericList(){
        populateGenericList();
        return null;
    }
    
    public PageReference checkPartnerInputs(){
        this.partnerSearch.stage.Partner_Technology_Industry__c = (this.partnerSearch.previousIndustryValue != this.partnerSearch.stage.Partner_Industry__c && !isEmpty(this.partnerSearch.stage.Partner_Industry__c))?this.partnerSearch.stage.Partner_Technology__c:this.partnerSearch.stage.Partner_Technology_Industry__c;
        this.partnerSearch.stage.Partner_Technology__c = (isEmpty(this.partnerSearch.stage.Partner_Industry__c))?this.partnerSearch.stage.Partner_Technology__c:this.partnerSearch.stage.Partner_Technology_Industry__c;
        this.partnerSearch.checkInputsForMego();
        this.partnerSearch.previousIndustryValue = this.partnerSearch.stage.Partner_Industry__c;
        return null;
    }

    public PageReference checkPartnerCounty(){
        return null;
    }

    public PageReference channelPartnerClicked(){
        this.populateSubPageState(State.CHANNEL_PARTNERS);
        return partnerSearch();
    }

    public PageReference additionalLocationsClicked(){
        this.partnerDataLocationsJS = '[';
        Integer i = 1;
        if(!Test.isRunningTest()){
        for(Location loc : this.partnerData.additionalLocations){
                if(i < Integer.valueof(System.Label.MM_Number_of_Locations) && (!isEmpty(loc.latitude) && !isEmpty(loc.longitude))){
               
                this.partnerDataLocationsCenter = (this.partnerDataLocationsCenter == '')?loc.latitude + ', ' + loc.longitude:this.partnerDataLocationsCenter;
                this.partnerDataLocationsJS += '[\'';
                this.partnerDataLocationsJS += (isEmpty(loc.address1))?'':String.escapeSingleQuotes(loc.address1) + '<br/>';
                this.partnerDataLocationsJS += (isEmpty(loc.address2))?'':String.escapeSingleQuotes(loc.address2) + '<br/>';
                this.partnerDataLocationsJS += (isEmpty(loc.city))?'':String.escapeSingleQuotes(loc.city) + ', ';
                this.partnerDataLocationsJS += (isEmpty(loc.state))?'':String.escapeSingleQuotes(loc.state) + ', ';
                this.partnerDataLocationsJS += (isEmpty(loc.zip))?'':String.escapeSingleQuotes(loc.zip);
                this.partnerDataLocationsJS = (this.partnerDataLocationsJS.endsWith(','))?this.partnerDataLocationsJS.substringBeforeLast(','):this.partnerDataLocationsJS;
                this.partnerDataLocationsJS += '<br/>';
                this.partnerDataLocationsJS += loc.country;
                this.partnerDataLocationsJS += '\', ';
                this.partnerDataLocationsJS += loc.latitude + ', ' + loc.longitude;
                this.partnerDataLocationsJS += ', ' + String.valueOf(i) + '],';
                i++;
            }
            
        }
        this.partnerDataLocationsJS += ']';
        this.partnerDataLocationsJS = this.partnerDataLocationsJS.replace('],]', ']]');
       
        this.populatePageState(State.ADDITIONAL_LOCATIONS);
        }
        return null;
    }
    public PageReference distributorsClicked(){
        this.populateSubPageState(State.DISTRIBUTORS);
        return partnerSearch();
    }

    public PageReference softwareVendorsClicked(){
        this.populateSubPageState(State.SOFTWARE_VENDORS);
        return partnerSearch();
    }

    public PageReference channelPartnerAndSoftwareClicked(){
        this.populateSubPageState(State.CHANNEL_PARTNER_AND_SOFTWARE);
        return partnerSearch();
    }

    public PageReference moreLocationsClicked(){
        this.populatePageState(State.MAP_VIEW);
        return null;
    }

    public PageReference partnerDetailClicked(){
        this.previousState = this.pageState;
        List<PartnerData> tempPd = getTempPartnerDataList();
        System.debug('this.idOfSelectedRecord:  ' + this.idOfSelectedRecord);
        this.showNext = false;
        this.showPrevious = false;
        Boolean hasBeenFound = false;
        for(PartnerData pd : tempPd){
            if(hasBeenFound){
                this.showNext = true;
                break;
            }
            if(pd.acctId == this.idOfSelectedRecord){
                this.partnerData = pd;
                this.populatePageState(State.DETAIL);
                hasBeenFound = true;
            }
            if(!hasBeenFound){
                this.showPrevious = true;
            }
        }
        /******Added by SaiHarish as a part of INC0387757 **********/
        this.partnerPrimaryLocationsJS = '[';
        Integer i = 1;
        if(!Test.isRunningTest()){
        if(this.partnerData.PrimaryLocationList.size()!=0){
        for(Location loc : this.partnerData.PrimaryLocationList){
            if(i < 11 && (!isEmpty(loc.latitude) && !isEmpty(loc.longitude))){
                this.partnerPrimaryLocationsJS += '[\'';
                this.partnerPrimaryLocationsJS += (isEmpty(loc.address1))?'':String.escapeSingleQuotes(loc.address1) + '<br/>';
                this.partnerPrimaryLocationsJS += (isEmpty(loc.address2))?'':String.escapeSingleQuotes(loc.address2) + '<br/>';
                this.partnerPrimaryLocationsJS += (isEmpty(loc.city))?'':String.escapeSingleQuotes(loc.city) + ', ';
                this.partnerPrimaryLocationsJS += (isEmpty(loc.state))?'':String.escapeSingleQuotes(loc.state) + ', ';
                this.partnerPrimaryLocationsJS += (isEmpty(loc.zip))?'':String.escapeSingleQuotes(loc.zip);
                this.partnerPrimaryLocationsJS = (this.partnerPrimaryLocationsJS.endsWith(','))?this.partnerPrimaryLocationsJS.substringBeforeLast(','):this.partnerPrimaryLocationsJS;
                this.partnerPrimaryLocationsJS += '<br/>';
                this.partnerPrimaryLocationsJS += loc.country;
                this.partnerPrimaryLocationsJS += '\', ';
                this.partnerPrimaryLocationsJS += loc.latitude + ', ' + loc.longitude;
                this.partnerPrimaryLocationsJS += ', ' + String.valueOf(i) + '],';
                i++;
            }
        }
        }
        this.partnerPrimaryLocationsJS += ']';
        this.partnerPrimaryLocationsJS = this.partnerPrimaryLocationsJS.replace('],]', ']]');
        }
        /******End by SaiHarish as a part of INC0387757 **********/

        return null;
    }
    
    public PageReference partnerMapClicked(){
        
        this.showAllResults = true;
        this.populatePageState(State.MAP_VIEW);
        return commonGenericList();
    }
    
    public PageReference partnerListClicked(){
        this.showAllResults = false;
        this.populatePageState(State.RESULTS);
        return commonGenericList();
    }
    
    public PageReference partnerShowTenClicked(){
        this.showAllResults = false;
        populateGenericList();
        return null;
    }

    public PageReference partnerShowAllClicked(){
        this.showAllResults = true;
        populateGenericList();
        return null;
    }

    public PageReference appShowTenClicked(){
        this.showAllResults = false;
        populateAppDataList();
        return null;
    }

    public PageReference appShowAllClicked(){
        this.showAllResults = true;
        populateAppDataList();
        return null;
    }

    
    public PageReference nextItem(){
        Integer i = 0;
        for(ApplicationDataStripped ad : this.appDataList){
            i++;
            if(ad.appId == this.idOfSelectedRecord){
                i = (i < (this.appDataList.size()))?i:0;
                this.idOfSelectedRecord = this.appDataList.get(i).appId;
                break;
            }
        }
        
        return this.showAppDetail();
    }
    
    public PageReference previousItem(){
        Integer i = 0;
        for(ApplicationDataStripped ad : this.appDataList){
            if(ad.appId == this.idOfSelectedRecord){
                i = (i > 0)?i-1:0;
                this.idOfSelectedRecord = this.appDataList.get(i).appId;
                break;
            }
            i++;
        }
        
        return this.showAppDetail();
    }
    
    public PageReference nextItemPartner(){
        List<PartnerData> tempPd = getTempPartnerDataList();
        Integer i = 0;
        for(PartnerData pd : tempPd){
            i++;
            if(pd.acctId == this.idOfSelectedRecord){
                i = (i < (tempPd.size()))?i:0;
                this.idOfSelectedRecord = tempPd.get(i).acctId;
                break;
            }
        }
        
        return this.showPartnerDetail();
    }
    
    public PageReference previousItemPartner(){
        List<PartnerData> tempPd = getTempPartnerDataList();
        Integer i = 0;
        for(PartnerData pd : tempPd){
            if(pd.acctId == this.idOfSelectedRecord){
                i = (i > 0)?i-1:0;
                this.idOfSelectedRecord = tempPd.get(i).acctId;
                break;
            }
            i++;
        }
        
        return this.showPartnerDetail();
    }
    
    public Boolean isEmpty(String s){
        return (s == null || s == '')?true:false;
    }
    
    public PageReference clear(){
        this.appSearch = new ApplicationSearch();
        this.appSearch.stage.Region__c = this.deepLink.region;
        this.appSearch.stage.Country__c = this.deepLink.country;
        this.partnerSearch = new PartnerSearch();
        this.partnerSearch.stage.Partner_Region__c = this.deepLink.region;
        this.partnerSearch.stage.Partner_Country__c = this.deeplink.country;
        /*
        this.appDataAllList = new List<List<ApplicationData>>();
        this.appDataList = new List<ApplicationData>();
        this.partnerAllGenericList = new List<List<PartnerData>>();
        this.partnerGenericList = new List<PartnerData>();
        */
        return null;
    }
    
    public PageReference clearName(){
        this.partnerSearch.searchTerm = '';
        this.appSearch.searchTerm = '';
        return null;
    }
    
    public PageReference optionChanged(){
        //System.debug('selectedOption:  ' + this.appSearch.selectedOption);
        MM_Staging__c tempStage = this.appSearch.stage.clone();
        this.appSearch.stage = new MM_Staging__c();

        this.appSearch.stage.Technology__c = tempStage.Technology__c;
        this.appSearch.stage.Supported_Language__c = tempStage.Supported_Language__c;
        this.appSearch.stage.Region__c = tempStage.Region__c;
        this.appSearch.stage.Country__c = tempStage.Country__c;
        System.debug(LoggingLevel.ERROR,'NIMESHS tempStage.Industry_Selector__c--> ' +tempStage.Industry_Selector__c); 
        System.debug(LoggingLevel.ERROR,'NIMESHS this.appSearch.stage.Industry_Selector__c--> ' +this.appSearch.stage.Industry_Selector__c); 
        System.debug('NIMESHS tempStage.Industry_Selector__c--> ' +tempStage.Industry_Selector__c); 
        System.debug('NIMESHS this.appSearch.stage.Industry_Selector__c--> ' +this.appSearch.stage.Industry_Selector__c); 
        
        this.appSearch.stage.Industry_Selector__c = tempStage.Industry_Selector__c;
        
        return null;
    }
    
    public PageReference partnerPreviousPage(){
        this.paginater.decrement();
        return changePartnerData();
    }
    
    public PageReference partnerNextPage(){
        this.paginater.increment();
        return changePartnerData();
    }
    
    public PageReference updatePartnerPage(){
        this.paginater.updateNumbers();
        return changePartnerData();
    }
    
    public PageReference changePartnerData(){
        this.partnerGenericList = this.partnerAllGenericList.get(this.paginater.index);
        this.pageState = pageStateMap.get(State.RESULTS);
        return null;
    }
    
    public PageReference appPreviousPage(){
        this.paginater.decrement();
        return changeAppData();
    }
    
    public PageReference appNextPage(){
        this.paginater.increment();
        return changeAppData();
    }
    
    public PageReference updateAppPage(){
        this.paginater.updateNumbers();
        return changeAppData();
    }
    
    public PageReference changeAppData(){
        this.appDataList = this.appDataAllList.get(this.paginater.index);
        this.pageState = pageStateMap.get(State.RESULTS);
        return null;
    }
    
    public PageReference partnerClickedFromAppDetail(){
       // this.deepLink.partnerId = this.appData.application.Account_C__c;
        this.deepLink.appId = this.appData.appId;
        return linkClicked('MM_PartnerFinderHome', this.appSearch.stage.Region__c, this.appSearch.stage.Country__c, this.appSearch.stage.Technology__c,this.appSearch.stage.E_or_G__c);
    }
    
    public PageReference partnerLinkClicked(){
        return linkClicked('MM_PartnerFinderHome', this.appSearch.stage.Region__c, this.appSearch.stage.Country__c, this.appSearch.stage.Technology__c,this.appSearch.stage.E_or_G__c);
    }

    public PageReference appLinkClicked(){
        this.deepLink.appId = '';
        this.deepLink.partnerId = '';
        return linkClicked('MM_appFinderHome', this.partnerSearch.stage.Partner_Region__c, this.partnerSearch.stage.Partner_Country__c, this.partnerSearch.stage.Partner_Technology__c,this.partnerSearch.stage.E_or_G__c);
    }
    
    public PageReference appLinkBackClicked(){
        this.deepLink.showActive = true;
        this.deepLink.partnerId = '';
        return linkClicked('MM_appFinderHome', this.partnerSearch.stage.Partner_Region__c, this.partnerSearch.stage.Partner_Country__c, this.partnerSearch.stage.Partner_Technology__c,this.partnerSearch.stage.E_or_G__c);
    }
    
    public PageReference linkClicked(String thePage, String region, String country, String technology,String business){
        PageReference tempPR = (thePage == 'MM_PartnerFinderHome')?Page.MM_PartnerFinderHome:Page.MM_appFinderHome; 
        tempPr.getParameters().put('region', region);
        tempPr.getParameters().put('loc', this.deepLink.loc);
        tempPr.getParameters().put('country', country);
        tempPr.getParameters().put('technology', technology);
        tempPr.getParameters().put('appx', String.valueOf(this.deepLink.isAppX));
        tempPr.getParameters().put('cameFromMarketPlacePage', 'yes');
        tempPr.getParameters().put('industry', this.deepLink.industry);
        tempPr.getParameters().put('showActive', String.valueOf(this.deepLink.showActive));
        
        //Addedd by Sathish for Day 1
        tempPr.getParameters().put('business',business );
        //Ends
        
        /*
        if(this.hasSearched){
            String dest = (thePage == 'MM_PartnerFinderHome')?'Channel':'Application';
            tempPr.getParameters().put('dest', dest);
        }else{
            tempPr.getParameters().put('dest', this.deepLink.dest);
        }
        */
        //if(thePage == 'MM_PartnerFinderHome'){
            tempPr.getParameters().put('partnerId', this.deepLink.partnerId);
        //}else{
            tempPr.getParameters().put('appId', this.deepLink.appId);
        //}
        tempPr.getParameters().put('languageCode', this.deepLink.languageCode);
        tempPR.setRedirect(true);
        return tempPR; 
    }
    
    public class CustomApplication{
        //public Software_Applications__c app {get;set;}
        public List<Industries_Solutions__c> industrySolutions {get;set;}
        public List<Cross_Industries_Solutions__c> crossIndustries {get;set;}
       // public List<Supported_Products__c> supportedProducts {get;set;}
        
        //public Map<String,String> techTrackMap {get;set;}
        public Set<String> appTypes {get;set;}
        
        public CustomApplication(){
            //this.app = new Software_Applications__c();
            this.industrySolutions = new List<Industries_Solutions__c>();
            this.crossIndustries = new List<Cross_Industries_Solutions__c>();
           // this.supportedProducts = new List<Supported_Products__c>();
            this.appTypes= new Set<String>();
        }
    }
    
    public class CustomPartnerType implements Comparable{ 
        public Partner_Type__c pt {get;set;}
        
        public CustomPartnerType(Partner_Type__c pt){
            this.pt = pt;
        }
        
        public Integer compareTo(Object compareTo) {
            CustomPartnerType tempPt = (CustomPartnerType)compareTo;
            String s = this.pt.Program__c + this.pt.Partner_Level__c;
            return s.compareTo(tempPt.pt.Program__c + tempPt.pt.Partner_Level__c);
        }
    }
    
    public class CustomTechSpec implements Comparable{
        public Technology_Specialization__c ts {get;set;}
        
        public CustomTechSpec(Technology_Specialization__c ts){
            this.ts = ts;
        }
        
        public Integer compareTo(Object compareTo) {
            CustomTechSpec tempTs = (CustomTechSpec)compareTo;
            String s = this.ts.Technology_Specialization__c + this.ts.Technology_Specialization_Level__c;
            return s.compareTo(tempTs.ts.Technology_Specialization__c + tempTs.ts.Technology_Specialization_Level__c);
        }
    }
    
    public class CustomCommunity implements Comparable{
        public Technology_Specialization__c ts {get;set;}
        
        public CustomCommunity(Technology_Specialization__c ts){
            this.ts = ts;
        }
        
        public Integer compareTo(Object compareTo) {
            CustomCommunity tempTs = (CustomCommunity)compareTo;
            return this.ts.UPL_CommunityMarketTerm__c.compareTo(tempTs.ts.UPL_CommunityMarketTerm__c);
        }
    }
    
    public class CustomMarketSpec implements Comparable{
        public Market_Specializations__c ms {get;set;}
        
        public CustomMarketSpec(Market_Specializations__c ms){
            this.ms = ms;
        }
        
        public Integer compareTo(Object compareTo) {
            CustomMarketSpec tempMs = (CustomMarketSpec)compareTo;
            String s = this.ms.Market_Specialization__c + ' ' + this.ms.Market_Specialization_Level__c;
            return s.compareTo(tempMs.ms.Market_Specialization__c + ' ' + tempMs.ms.Market_Specialization_Level__c);
        }
    }
    
    public class CustomAuthProd implements Comparable{
        public Technology_Specialization__c ts {get;set;}
        public Product_Offered__c po {get;set;}
        
        public CustomAuthProd(Technology_Specialization__c ts, Product_Offered__c po){
            this.ts = ts;
            this.po = po;
        }
        
        public Integer compareTo(Object compareTo) {
            CustomAuthProd tempAp = (CustomAuthProd)compareTo;
            String thisString = (this.ts.Technology_Specialization__c == '')?this.po.Product_offering__c:this.ts.Technology_Specialization__c;
            String otherString = (tempAp.ts.Technology_Specialization__c == '')?tempAp.po.Product_offering__c:tempAp.ts.Technology_Specialization__c;
            thisString = (thisString == null)?'':thisString;
            otherString = (otherString == null)?'':otherString;
            return thisString.compareTo(otherString);
        }
    }
        
    public class PartnerData implements Comparable {
        public Account limitedAccount {get;set;}
        public String acctId {get;set;}
        public String name {get;set;}
        public Location primaryLocation {get;set;}
        Public List<Location> PrimaryLocationList {get;set;}   // Added by SaiHarish as a part of INC0387757
        public String url {get;set;}
        public String programLevel {get;set;} //is picklist
        public String description {get;set;}
        public List<CustomPartnerType> levelTypeList {get;set;}//is picklist partnertrack + level on partner type not sure will translate...
        public String valueAdd {get;set;}
        public List<CustomTechSpec> techSpecList {get;set;}//is picklist techspec + level on techspec
        public List<CustomMarketSpec> industryList {get;set;}//is picklist marketspec on marketspec
        public List<CustomMarketSpec> marketSpecList {get;set;}//is picklist marketspec on marketspec
        public List<CustomCommunity> communityList {get;set;}//formula from picklists -- not sure will translate UPL_CommunityMarketTerm__c on techspec
        public List<CustomTechSpec> appSpecList {get;set;}//is picklist techspec + level on techspec
        public List<CustomAuthProd> authProdList {get;set;}//two picklists on two objects...
        //public List<Product_Offered__c> authProdList2 {get;set;}//two picklists on two objects...
        public List<URL> applicationList {get;set;}
        public List<Location> additionalLocations {get;set;}
        public Boolean isInQuickList {get;set;}
        private QueryType qt {get;set;}
        private PartnerSearch ps {get;set;}
        private Decimal fedSort = 100;
        private Decimal programLevelSort = 100;
        private Decimal partnerTypeSort = 100;
        private Decimal megoSort = 100;
        
        private Decimal fedSpecSort = 100;
        private Decimal appSpecSort = 100;
        private Decimal techSpecSort = 100;
        private Decimal mktSpecSort = 100;
        private Decimal distSpecSort = 100;
        
        
        public PartnerData(Account a, PartnerSearch ps, String params, QueryType qt, Set<Id> qlIds){
            Set<String> levelTypeSet = new Set<String>();
            Set<String> techSpecSet = new Set<String>();
            Set<String> industrySet = new Set<String>();
            Set<String> marketSpecSet = new Set<String>();
            Set<String> communitySet = new Set<String>();
            Set<String> appSpecSet = new Set<String>();
            Set<String> authProdSet = new Set<String>();
            String primaryLocationId = '';
            Set<String> primaryLocationIdSet = new Set<String>(); // Added by SaiHarish as a part of INC0387757
            this.limitedAccount = new Account(Metal_Level__c = a.Metal_Level__c);
            this.isInQuickList = (qlIds.contains(a.Id))?true:false;
            this.acctId = a.Id;
            this.name = (a.NameLocal == null)?a.Name:a.NameLocal;
            this.primaryLocation = new Location();
            this.PrimaryLocationList =  new List<Location>(); // Added by SaiHarish as a part of INC0387757
            this.url = a.Website_URL__c;
            this.description = a.Company_Description__c;
            this.valueAdd = a.Value_Add__c;
            this.levelTypeList = new List<CustomPartnerType>();
            this.programLevel = a.Metal_Level__c;
            this.fedSort = a.MM_Fed_Specialization_Sort__c;
            this.programLevelSort = a.MM_Metal_Level_Sort__c;
            this.partnerTypeSort = a.MM_Partner_Type_Sort__c;
            this.megoSort = a.MEGO_Order__c;
            this.qt = qt;
            this.ps = ps;
            this.additionalLocations = new List<Location>();
            this.techSpecList = new List<CustomTechSpec>();
            this.industryList = new List<CustomMarketSpec>();
            this.marketSpecList = new List<CustomMarketSpec>();
            this.communityList = new List<CustomCommunity>();
            this.appSpecList = new List<CustomTechSpec>();
            this.authProdList = new List<CustomAuthProd>();
            //this.authProdList2 = new List<Product_Offered__c>();
            this.applicationList = new List<URL>();

            if(a.Partner_Region__c == 'EMEA'){
                System.debug(LoggingLevel.ERROR, 'this.name:  ' + this.name + ' ' + this.acctId);
                for(Partner_Type__c pt : a.Partner_Types__r){
                    //String tempString = (pt.Partner_Track__c == 'RADIO')?'Radio Solutions':pt.Partner_Track__c;
                    //this.levelTypeList.add(tempString + ' ' + pt.Partner_Level__c);
                    System.debug(LoggingLevel.ERROR, 'pt.Program__c:  ' + pt.Program__c);
                    if(pt.Program__c != 'RADIO' && !levelTypeSet.contains(pt.Program__c + pt.Partner_Level__c)){
                        this.levelTypeList.add(new CustomPartnerType(pt));
                        levelTypeSet.add(pt.Program__c + pt.Partner_Level__c);
                    }
                }
            }
            this.levelTypeList.sort();
            
            for(Market_Specializations__c ms : a.Market_Specializations__r){
                if(ms.Market_Specialization_Level__c != null && ms.Market_Specialization_Level__c != '' && ms.Market_Specialization_Level__c != 'None'){
                    if(!industrySet.contains(ms.Market_Specialization__c)){
                        this.industryList.add(new CustomMarketSpec(new Market_Specializations__c(Market_Specialization__c = ms.Market_Specialization__c)));
                        industrySet.add(ms.Market_Specialization__c);
                    }
                    if(!marketSpecSet.contains(ms.Market_Specialization__c + ' ' + ms.Market_Specialization_Level__c)){
                        this.marketSpecList.add(new CustomMarketSpec(new Market_Specializations__c(Market_Specialization__c = ms.Market_Specialization__c, Market_Specialization_Level__c = ms.Market_Specialization_Level__c)));
                        marketSpecSet.add(ms.Market_Specialization__c + ' ' + ms.Market_Specialization_Level__c);
                    }
                }
                if(!isEmpty(ps.stage.Partner_Industry__c) && ms.MM_Sort_Order__c < this.mktSpecSort && ms.Market_Specialization__c == 'US Federal' && ms.Market_Specialization_Level__c != null && ms.Market_Specialization_Level__c != '' && ms.Market_Specialization_Level__c != 'None'){
                    this.mktSpecSort = ms.MM_Sort_Order__c;
                }
            }
            this.industryList.sort();
            this.marketSpecList.sort();
            
            //Modified by Srikanth V for EA_radio requirement 
            boolean EARADIO = false;
            if(a.Owner_Business_Group__c == 'Government' && a.Partner_Region__c == 'EMEA')
            {
                EARADIO = true;
            }
            else EARADIO = false;
            
            
            for(Technology_Specialization__c ts : a.Technology_Specializations__r){
                if(ts.Technology_Specialization_Level__c != 'OPEN' && (ts.Community_Type__c == 'Value Added Distributor' || ts.Community_Type__c == 'Sub-Distributor') && ts.Partner_Program__r.Status__c == 'Active' && (ts.Technology_Specialization__c == ps.stage.Partner_Technology__c || isEmpty(ps.stage.Partner_Technology__c)) && ts.MM_Distributor_Sort__c < this.distSpecSort){
                    this.distSpecSort = ts.MM_Distributor_Sort__c;
                }                   
                if(!isEmpty(ps.stage.Partner_Technology__c)){
                    //Commented by Brahma
                    /*if(ts.Technology_Specialization_Level__c != 'Open' && (ts.Community_Type__c == 'Value Added Reseller' || ts.Community_Type__c == 'eTailer' || ts.Community_Type__c == 'Direct Market Reseller' || ts.Community_Type__c == 'Carrier' || ts.Community_Type__c == 'Distributor' || ts.Community_Type__c == 'Sub-Distributor' || ts.Community_Type__c == 'Application Partner')){
                        if(ts.Technology_Specialization__c == ps.stage.Partner_Technology__c && ts.Partner_Program__r.Status__c == 'Active' && ts.Partner_Program__r.Federal_Specialization_Sort__c < this.fedSpecSort){
                            this.fedSpecSort = ts.Partner_Program__r.Federal_Specialization_Sort__c;
                        }
                    }*/
                    if(ts.Technology_Specialization_Level__c != 'OPEN' && ts.Community_Type__c == 'Application Partner'){
                        if(ts.Technology_Specialization__c == ps.stage.Partner_Technology__c && ts.Partner_Program__r.Status__c == 'Active' && ts.MM_Sort_Order__c < this.appSpecSort){
                            this.appSpecSort = ts.MM_Sort_Order__c;
                        }
                    }
                     //Modified By Chanu  for the ****Incident INC0139828  *******: Modified only the if Loop Condition
                     // Modified by Harish 
                    if(ts.Technology_Specialization_Level__c != 'Open' && ((ts.Community_Type__c == 'Systems Integrator' && ts.Program__c == 'Radio' && a.Partner_Region__c =='LACR' ) || ts.Community_Type__c == 'Value Added Reseller' || ts.Community_Type__c == 'eTailer' || ts.Community_Type__c == 'Direct Market Reseller' || ts.Community_Type__c == 'Carrier') && ts.Technology_Specialization__c == ps.stage.Partner_Technology__c && ts.Partner_Program__r.Status__c == 'Active' && ts.MM_Sort_Order__c < this.techSpecSort){
                        this.techSpecSort = ts.MM_Sort_Order__c;
                        System.debug('This.techSpecSort:  ' + this.techSpecSort);
                    }
                }// end of if loop
                  //Modified By Chanu  for the ****Incident INC0139828  *******: Modified only the if Loop Condition
                  //Modified by Harish to meet criteria only for Systems Integrator - LACR Radio
                if(ts.Technology_Specialization_Level__c != 'Open' && ((ts.Community_Type__c == 'Systems Integrator' && ts.Program__c == 'Radio' && a.Partner_Region__c =='LACR' ) ||ts.Community_Type__c == 'Value Added Reseller' || ts.Community_Type__c == 'eTailer' || ts.Community_Type__c == 'Direct Market Reseller' || ts.Community_Type__c == 'Carrier' || ts.Community_Type__c == 'Value Added Distributor' || ts.Community_Type__c == 'Sub-Distributor' || ts.Community_Type__c == 'Application Partner')){
                    //if(!techSpecSet.contains(ts.Technology_Specialization__c + ts.Technology_Specialization_Level__c) && ((a.Partner_Region__c == 'EMEA' && ts.Technology_Specialization__c != 'Industrial Mobile Computing') || a.Partner_Region__c != 'EMEA') && ts.Community_Type__c != 'Application Partner'){
                    //Psion for EMEA Code - Brahma
                    if(!techSpecSet.contains(ts.Technology_Specialization__c + ts.Technology_Specialization_Level__c) && ts.Community_Type__c != 'Application Partner'){
                        this.techSpecList.add(new CustomTechSpec(new Technology_Specialization__c(Technology_Specialization__c = ts.Technology_Specialization__c, Technology_Specialization_Level__c = ts.Technology_Specialization_Level__c)));
                        techSpecSet.add(ts.Technology_Specialization__c + ts.Technology_Specialization_Level__c);               
                    }
                    
                    //if(!authProdSet.contains(ts.Technology_Specialization__c) && ((a.Partner_Region__c == 'EMEA' && ts.Technology_Specialization__c != 'Industrial Mobile Computing') || a.Partner_Region__c != 'EMEA')){
                    //Psion for EMEA Code - Brahma
                   
                   //Modified by Srikanth V for EA_radio requirement 19JAn2015
                   if(!authProdSet.contains(ts.Technology_Specialization__c)){
                        If(EARADIO){
                            this.authProdList.add(new CustomAuthProd(new Technology_Specialization__c(Technology_Specialization__c = ts.Technology_Specialization__c,  Country__c =  ts.Country__c ), new Product_Offered__c()));
                        } else {
                            this.authProdList.add(new CustomAuthProd(new Technology_Specialization__c(Technology_Specialization__c = ts.Technology_Specialization__c), new Product_Offered__c()));
                        }
                        authProdSet.add(ts.Technology_Specialization__c);            
                    }
                }  // end of if loop 
                //if(((a.Partner_Region__c == 'EMEA' && ts.Technology_Specialization__c != 'Industrial Mobile Computing') || a.Partner_Region__c != 'EMEA') && ts.Technology_Specialization_Level__c != 'Open' && (ts.Community_Type__c == 'Value Added Reseller' || ts.Community_Type__c == 'eTailer' || ts.Community_Type__c == 'Direct Market Reseller' || ts.Community_Type__c == 'Carrier' || ts.Community_Type__c == 'Value Added Distributor' || ts.Community_Type__c == 'Sub-Distributor' || ts.Community_Type__c == 'Application Partner')){
                //Psion for EMEA Code - Brahma
                   //Modified By Chanu  for the ****Incident INC0139828  *******: Modified only the if Loop Condition
                   // Modified by Harish 
                if(ts.Technology_Specialization_Level__c != 'Open' && ((ts.Community_Type__c == 'Systems Integrator' && ts.Program__c == 'Radio' && a.Partner_Region__c =='LACR' ) || ts.Community_Type__c == 'Value Added Reseller' || ts.Community_Type__c == 'eTailer' || ts.Community_Type__c == 'Direct Market Reseller' || ts.Community_Type__c == 'Carrier' || ts.Community_Type__c == 'Value Added Distributor' || ts.Community_Type__c == 'Sub-Distributor' || ts.Community_Type__c == 'Application Partner')){
                    if(!communitySet.contains(ts.UPL_CommunityMarketTerm__c)){
                        this.communityList.add(new CustomCommunity(ts));
                        communitySet.add(ts.UPL_CommunityMarketTerm__c);
                    }
                }   // end of if loop                
                
                if(communitySet.contains('Carrier')){
                    this.limitedAccount.Metal_Level__c = '';
                }       
                
                if(ts.Technology_Specialization_Level__c != 'OPEN' && ts.Community_Type__c == 'Application Partner'){
                    //if(!appSpecSet.contains(ts.Technology_Specialization__c + ts.Technology_Specialization_Level__c) && ((a.Partner_Region__c == 'EMEA' && ts.Technology_Specialization__c != 'Industrial Mobile Computing') || a.Partner_Region__c != 'EMEA')){
                    //Psion for EMEA Code - Brahma
                    if(!appSpecSet.contains(ts.Technology_Specialization__c + ts.Technology_Specialization_Level__c)){
                        this.appSpecList.add(new CustomTechSpec(new Technology_Specialization__c(Technology_Specialization__c = ts.Technology_Specialization__c, Technology_Specialization_Level__c = ts.Technology_Specialization_Level__c)));
                        appSpecSet.add(ts.Technology_Specialization__c + ts.Technology_Specialization_Level__c);                
                    }
                    //this.appSpecList.add(ts.Technology_Specialization__c + ' ' + ts.Technology_Specialization_Level__c);
                }
            }//}
            this.appSpecList.sort();
            this.techSpecList.sort();
            this.communityList.sort();
            
            for(Product_Offered__c po : a.Product_Offered__r){
               // if(po.Publish_Flag__c && ps.stage.E_or_G__c != 'E' && (po.Product_offering__c == 'SCADA' || (po.Account__r.Partner_Region__c == 'EMEA' && (po.Product_offering__c == 'Radio Solutions' || po.Product_offering__c == 'Mission Critical Radio Systems' || po.Product_offering__c == 'Mission Critical Radio Systems')))){
                if(po.Publish_Flag__c && ps.stage.E_or_G__c != 'E' && (po.Product_offering__c == 'SCADA' )){
                    if(!authProdSet.contains(po.Product_offering__c)){
                        this.authProdList.add(new CustomAuthProd(new Technology_Specialization__c(), new Product_Offered__c(Product_Offering__c = po.Product_offering__c)));
                        authProdSet.add(po.Product_offering__c);               
                    }
                }
            }
            this.authProdList.sort();
            
            /*for(Software_Applications__c sa : a.Partner_Software_Apps_del__r){
                if(sa.Status__c == 'Active' && sa.Publish_on_Motorola_com__c == 'YES'){
                    this.applicationList.add(new URL('MM_appFinderHome?appId=' + sa.Id + '&' + params, sa.Name));
                }
            }*/
            
            Boolean hasFoundLocation = false;  
            Integer PastSetSize = 0;  // Added by SaiHarish as a part of INC0387757
            Integer CurrentSetSize;   // Added by SaiHarish as a part of INC0387757
            for(Integer i = 1; i < 7; i++)
            {           
                for(Partner_Location__c pl : a.Partner_Locations__r)
                {
                    System.Debug('**Harish**'+'pl.Country1__c'+pl.Country1__c+'ps.stage.Partner_Country__c'+ps.stage.Partner_Country__c);
                    Boolean isLocation = false;
                    if(i == 1 && pl.Location_Publish_Flag__c == true && pl.Country1__c == ps.stage.Partner_Country__c && (isEmpty(ps.stage.Partner_State__c) || pl.State__c == ps.stage.Partner_State__c) && pl.Address_Type__c != null && pl.Address_Type__c.containsIgnoreCase('Primary Location')){
                        isLocation = true;
                    }else if(i == 2 && pl.Location_Publish_Flag__c == true && pl.Country1__c == ps.stage.Partner_Country__c && (isEmpty(ps.stage.Partner_State__c) || pl.State__c == ps.stage.Partner_State__c) && pl.Address_Type__c != null && pl.Address_Type__c.containsIgnoreCase('HQ')){
                        isLocation = true;
                    }else if(i == 3 && pl.Location_Publish_Flag__c == true && pl.Country1__c == ps.stage.Partner_Country__c && (isEmpty(ps.stage.Partner_State__c) || pl.State__c == ps.stage.Partner_State__c)){
                        isLocation = true;
                    }else if(i == 4 && pl.Location_Publish_Flag__c == true && pl.Address_Type__c != null && pl.Address_Type__c.containsIgnoreCase('Primary Location')){
                        isLocation = true;
                    }else if(i == 5 && pl.Location_Publish_Flag__c == true && pl.Address_Type__c != null && pl.Address_Type__c.containsIgnoreCase('HQ')){
                        isLocation = true;
                    }else if(i == 6 && pl.Location_Publish_Flag__c == true){
                        isLocation = true;
                    }
                    if(isLocation){
                        primaryLocationId = pl.Id;
                        primaryLocationIdSet.add(primaryLocationId); //Added by SaiHarish as a part of INC0387757
                        CurrentSetSize=primaryLocationIdSet.size();
                        if(PastSetSize!=0 && (i==4 || i==5 || i==6) && (pl.Country1__c == 'United States' || pl.Country1__c == 'Canada'))
                        {
                        hasFoundLocation=true;
                        break;
                        }
                        
                        else
                        {
                            
                                if(PastSetSize != CurrentSetSize) 
                                {
                                    if(!(PastSetSize==1 && (ps.stage.Partner_State__c=='' || ps.stage.Partner_State__c==null)))
                                    hasFoundLocation = loadLocation(pl);
                                    else
                                    primaryLocationIdSet.remove(primaryLocationId);
                                PastSetSize = CurrentSetSize;
                                }
                                if((pl.Country1__c != 'United States' && pl.Country1__c != 'Canada') || (CurrentSetSize!=0 && (ps.stage.Partner_State__c=='' || ps.stage.Partner_State__c==null))) 
                                {
                                break;
                                }
                         }
                    }
                
                }
                if(hasFoundLocation){              
                  break;
                }
            } 
            
            for(Partner_Location__c pl : a.Partner_Locations__r){
            // Modified by SaiHarish as a part of INC0387757 - replaced primaryLocationId with primaryLocationIdSet
                if(pl.Latitude__c != 0 && pl.Longitude__c != 0 && pl.Location_Publish_Flag__c == true && primaryLocationIdSet.size() != 0 && !(primaryLocationIdSet.contains(pl.Id))){
                    Location l = new Location();
                    l.address1 = pl.Address_Line1__c;
                    l.address2 = pl.Address_Line2__c;
                    l.name = pl.Name;
                    l.city = pl.City__c;
                    l.state = pl.State__c;
                    l.zip = pl.Postal_Code__c;
                    l.phone = pl.Phone__c;
                    l.fax = pl.Fax__c;
                    l.country = pl.Country1__c;
                    l.latitude = String.valueOf(pl.Latitude__c);
                    l.longitude = String.valueOf(pl.Longitude__c);
                    this.additionalLocations.add(l);
                }
            }
        }
        // Commented by SaiHarish as a part of INC0387757
        /*public Boolean loadLocation(Partner_Location__c pl)
            this.primaryLocation.name = pl.Name;
            this.primaryLocation.address1 = pl.Address_Line1__c;
            this.primaryLocation.address2 = pl.Address_Line2__c;
            this.primaryLocation.city = pl.City__c;
            this.primaryLocation.state = pl.State__c;
            this.primaryLocation.zip = pl.Postal_Code__c;
            this.primaryLocation.phone = pl.Phone__c;
            this.primaryLocation.fax = pl.Fax__c;
            this.primaryLocation.country = pl.Country1__c;
            this.primaryLocation.latitude = (pl.Latitude__c != 0)?String.valueOf(pl.Latitude__c):'';
            this.primaryLocation.longitude = (pl.Longitude__c != 0)?String.valueOf(pl.Longitude__c):'';
            return true;
        */
        
        // Above block of Commented Code was rewritten by SaiHarish as a part of INC0387757 
        
        public Boolean loadLocation(Partner_Location__c pl){
                    
           Location l = new Location();
                    l.address1 = pl.Address_Line1__c;
                    l.address2 = pl.Address_Line2__c;
                    l.name = pl.Name;
                    l.city = pl.City__c;
                    l.state = pl.State__c;
                    l.zip = pl.Postal_Code__c;
                    l.phone = pl.Phone__c;
                    l.fax = pl.Fax__c;
                    l.country = pl.Country1__c;
                    l.latitude = (pl.Latitude__c != 0)?String.valueOf(pl.Latitude__c):'';
                    l.longitude = (pl.Longitude__c != 0)?String.valueOf(pl.Longitude__c):'';
                    this.PrimaryLocationList.add(l);
                    
                     this.primaryLocation.name = this.PrimaryLocationList[0].Name;
                    this.primaryLocation.address1 = this.PrimaryLocationList[0].address1;
                    this.primaryLocation.address2 = this.PrimaryLocationList[0].address2;
                    this.primaryLocation.city = this.PrimaryLocationList[0].city;
                    this.primaryLocation.state = this.PrimaryLocationList[0].state;
                    this.primaryLocation.zip = this.PrimaryLocationList[0].zip;
                    this.primaryLocation.phone = this.PrimaryLocationList[0].phone;
                    this.primaryLocation.fax = this.PrimaryLocationList[0].fax;
                    this.primaryLocation.country = this.PrimaryLocationList[0].country;
                    this.primaryLocation.latitude = (this.PrimaryLocationList[0].latitude != '')?String.valueOf(this.PrimaryLocationList[0].latitude):'';
                    this.primaryLocation.longitude = (this.PrimaryLocationList[0].longitude != '')?String.valueOf(this.PrimaryLocationList[0].longitude):'';
                    if(this.primarylocation.city!='')
                    {
                    if(this.primarylocation.city!=null)
                    this.primaryLocation.city=this.primaryLocation.city.remove('\'');
                    }
            if(pl.Country1__c == 'United States' || pl.Country1__c == 'Canada')            
            return false;
            else
             return true;
        }
        // End by SaiHarish as a part of INC0387757
        public Integer compareTo(Object compareTo) {
            System.debug(LoggingLevel.ERROR, 'this.qt:  ' + this.qt);
            System.Debug('Myself Checking CompareTo**'+compareTo);
            PartnerData tempPd = (PartnerData)compareTo;
                        System.Debug('Myself Checking PartnerData8**'+tempPd);
            
            if(this.qt == QueryType.CHANNEL_PARTNER){
                return channelPartnerSort(tempPd);
            }
            if(this.qt == QueryType.DISTRIBUTOR){
                return distributorSort(tempPd);
            }
            if(this.qt == QueryType.CHANNEL_APP){
                return channelAppSort(tempPd);
            }
            if(this.qt == QueryType.APP_PARTNER){
                return appPartnerSort(tempPd);
            }
            return randomSort();        
        }       
        
        public Integer randomSort(){
            return (Math.random() < Math.random())?1:-1;
        }       
        
        public Integer channelAppSort(PartnerData tempPd){
            System.debug(LoggingLevel.ERROR, 'this.appSpecSort:  ' + this.appSpecSort);
            System.debug(LoggingLevel.ERROR, 'this.programLevelSort:  ' + this.programLevelSort);
            if(regionMap.get(this.ps.stage.Partner_Region__c) == 'US Federal' || (regionMap.get(this.ps.stage.Partner_Region__c) != 'US Federal' && ps.stage.Partner_Industry__c == 'US Federal')){
                if(isEmpty(this.ps.stage.Partner_Technology__c)){
                    if(this.fedSort < tempPd.fedSort || (this.fedSort == tempPd.fedSort && this.programLevelSort < tempPd.programLevelSort)){
                        return -1;
                    }else if(this.fedSort != tempPd.fedSort || this.programLevelSort != tempPd.programLevelSort){
                        return 1;
                    }
                }else{
                    if(this.fedSort < tempPd.fedSort || (this.fedSort == tempPd.fedSort && this.appSpecSort < tempPd.appSpecSort) || (this.fedSort == tempPd.fedSort && this.appSpecSort == tempPd.appSpecSort && this.programLevelSort < tempPd.programLevelSort)){
                        return -1;
                    }else if(this.fedSort != tempPd.fedSort || this.appSpecSort != tempPd.appSpecSort || this.programLevelSort != tempPd.programLevelSort){
                        return 1;
                    }
                }
            }else if(regionMap.get(this.ps.stage.Partner_Region__c) == 'LACR' || regionMap.get(this.ps.stage.Partner_Region__c) == 'APAC' || regionMap.get(this.ps.stage.Partner_Region__c) == 'EMEA' || regionMap.get(this.ps.stage.Partner_Region__c) == 'NAMR'){
                if(isEmpty(ps.stage.Partner_Technology__c)){
                    if(this.programLevelSort < tempPd.programLevelSort){
                        return -1;
                    }else if(this.programLevelSort > tempPd.programLevelSort){
                        return 1;
                    }
                }else if(this.appSpecSort < tempPd.appSpecSort || (this.appSpecSort == tempPd.appSpecSort && this.programLevelSort < tempPd.programLevelSort)){
                    return -1;
                }else if(this.appSpecSort != tempPd.appSpecSort || this.programLevelSort != tempPd.programLevelSort){
                    return 1;
                }
            }
            return randomSort();        
        }
        
        public Integer channelPartnerSort(PartnerData tempPd){
        System.Debug('Myself Entered Sort Method-Step 1--- FIrst IF');
            if(regionMap.get(this.ps.stage.Partner_Region__c) == 'US Federal' || (regionMap.get(this.ps.stage.Partner_Region__c) != 'US Federal' && ps.stage.Partner_Industry__c == 'US Federal')){
            System.Debug('Myself Entered Sort Method-Step 2');
                if(isEmpty(this.ps.stage.Partner_Technology__c)){
                System.Debug('Myself Entered Sort Method-Step 3');
                    if(this.fedSort < tempPd.fedSort || (this.fedSort == tempPd.fedSort && this.programLevelSort < tempPd.programLevelSort)){
                    System.Debug('Myself Entered Sort Method-Step 4');
                        return -1;
                    }else if(this.fedSort != tempPd.fedSort || this.programLevelSort != tempPd.programLevelSort){
                    System.Debug('Myself Entered Sort Method-Step 5');
                        return 1;
                    }
                }else{
                System.Debug('Myself Entered Sort Method-Step 6');
                    if(this.mktSpecSort < tempPd.mktSpecSort || (this.mktSpecSort == tempPd.mktSpecSort && this.techSpecSort < tempPd.techSpecSort) || (this.mktSpecSort == tempPd.mktSpecSort && this.techSpecSort == tempPd.techSpecSort && this.programLevelSort < tempPd.programLevelSort)){
                    System.Debug('Myself Entered Sort Method-Step 7');
                        return -1;
                    }else if(this.mktSpecSort != tempPd.mktSpecSort || this.techSpecSort != tempPd.techSpecSort || this.programLevelSort != tempPd.programLevelSort){
                    System.Debug('Myself Entered Sort Method-Step 8');
                        return 1;
                    }
                }
            }else if((regionMap.get(this.ps.stage.Partner_Region__c) == 'NAMR' || regionMap.get(this.ps.stage.Partner_Region__c) == 'APAC' || regionMap.get(this.ps.stage.Partner_Region__c) == 'LACR' || regionMap.get(this.ps.stage.Partner_Region__c) == 'EMEA') && isEmpty(this.ps.stage.Partner_Technology__c) && this.ps.stage.Partner_Industry__c != 'US Federal'){
            System.Debug('Myself Entered Sort Method-Step 9 Second Elseif');
                System.debug(LoggingLevel.ERROR, 'this.programLevelSort:  ' + this.programLevelSort);
                if(this.programLevelSort < tempPd.programLevelSort){
                System.Debug('Myself Entered Sort Method-Step 10');
                    return -1;
                }else if(this.programLevelSort != tempPd.programLevelSort){
                System.Debug('Myself Entered Sort Method-Step 11');
                    return 1;
                }
            }else if(regionMap.get(this.ps.stage.Partner_Region__c) == 'APAC' && this.ps.stage.Partner_Technology__c != 'SCADA' && this.ps.stage.Partner_Industry__c != 'US Federal'){
            System.Debug('Myself Entered Sort Method-Step 12 THIRD ElseIf');
                if(this.techSpecSort < tempPd.techSpecSort || (this.techSpecSort == tempPd.techSpecSort && this.programLevelSort < tempPd.programLevelSort) || (this.techSpecSort == tempPd.techSpecSort && this.programLevelSort == tempPd.programLevelSort && this.megoSort < tempPd.megoSort)){
                System.Debug('Myself Entered Sort Method-Step 13');
                    return -1;
                }else if(this.techSpecSort != tempPd.techSpecSort || this.programLevelSort != tempPd.programLevelSort || this.megoSort != tempPd.megoSort){
                System.Debug('Myself Entered Sort Method-Step 14');
                    return 1;
                }
            }else if(regionMap.get(this.ps.stage.Partner_Region__c) == 'LACR' && this.ps.stage.Partner_Technology__c != 'SCADA' && this.ps.stage.Partner_Industry__c != 'US Federal'){
            System.Debug('Myself Entered Sort Method-Step 15 FOURTH ElseIf');
                if(this.techSpecSort < tempPd.techSpecSort || (this.techSpecSort == tempPd.techSpecSort && this.programLevelSort < tempPd.programLevelSort)){
                System.Debug('Myself Entered Sort Method-Step 16');
                    return -1;
                }else if(this.techSpecSort != tempPd.techSpecSort || this.programLevelSort != tempPd.programLevelSort){
                System.Debug('Myself Entered Sort Method-Step 17');
                    return 1;
                }
            }else if(regionMap.get(this.ps.stage.Partner_Region__c) == 'EMEA' && (this.ps.stage.Partner_Technology__c == 'Radio Solutions' || this.ps.stage.Partner_Technology__c == 'Mission Critical Radio Systems' || this.ps.stage.Partner_Technology__c == 'Mission Critical Radio Systems') && this.ps.stage.Partner_Industry__c != 'US Federal'){
            System.Debug('Myself Entered Sort Method-Step 18 FIFTH ElseIf');
                System.debug(LoggingLevel.ERROR, 'partnerTypeSort:  ' + this.partnerTypeSort);
                if(this.partnerTypeSort < tempPd.partnerTypeSort){
                System.Debug('Myself Entered Sort Method-Step 19');
                    return -1;
                }else if(this.partnerTypeSort != tempPd.partnerTypeSort){
                System.Debug('Myself Entered Sort Method-Step 20');
                    return 1;
                }
            }else if(regionMap.get(this.ps.stage.Partner_Region__c) == 'EMEA' && (this.ps.stage.Partner_Technology__c != 'Radio Solutions' && this.ps.stage.Partner_Technology__c != 'Mission Critical Radio Systems' && this.ps.stage.Partner_Technology__c != 'Mission Critical Radio Systems' && this.ps.stage.Partner_Technology__c != 'Professional and Commercial Radio' && this.ps.stage.Partner_Technology__c != 'Professional and Commercial Radio' && this.ps.stage.Partner_Technology__c != 'Business Radio' && this.ps.stage.Partner_Technology__c != 'SCADA') && this.ps.stage.Partner_Industry__c != 'US Federal'){
            System.Debug('Myself Entered Sort Method-Step 21 SIXTH ElseIf');
                if(this.techSpecSort < tempPd.techSpecSort || (this.techSpecSort == tempPd.techSpecSort && this.programLevelSort < tempPd.programLevelSort)){
                System.Debug('Myself Entered Sort Method-Step 22');
                    return -1;
                }else if(this.techSpecSort != tempPd.techSpecSort || this.programLevelSort != tempPd.programLevelSort){
                System.Debug('Myself Entered Sort Method-Step 23');
                    return 1;
                }
            //else if(regionMap.get(this.ps.stage.Partner_Region__c) == 'NAMR' && (!isEmpty(this.ps.stage.Partner_Technology__c) && this.ps.stage.Partner_Technology__c != 'Radio Solutions' && this.ps.stage.Partner_Technology__c != 'Mission Critical Radio Systems' && this.ps.stage.Partner_Technology__c != 'Mission Critical Radio Systems' && this.ps.stage.Partner_Technology__c != 'Professional and Commercial Radio' && this.ps.stage.Partner_Technology__c != 'Professional and Commercial Radio' && this.ps.stage.Partner_Technology__c != 'Business Radio' && this.ps.stage.Partner_Technology__c != 'SCADA') && this.ps.stage.Partner_Industry__c != 'US Federal')
            }else if(regionMap.get(this.ps.stage.Partner_Region__c) == 'NAMR' && (!isEmpty(this.ps.stage.Partner_Technology__c) && this.ps.stage.Partner_Technology__c != 'Radio Solutions' && this.ps.stage.Partner_Technology__c != 'Mission Critical Radio Systems' && this.ps.stage.Partner_Technology__c != 'Mission Critical Radio Systems' && this.ps.stage.Partner_Technology__c != 'Business Radio' && this.ps.stage.Partner_Technology__c != 'SCADA') && this.ps.stage.Partner_Industry__c != 'US Federal'){
            System.Debug('Myself Entered Sort Method-Step 24 SEVENTH ElseIf');
                if(this.techSpecSort < tempPd.techSpecSort || (this.techSpecSort == tempPd.techSpecSort && this.programLevelSort < tempPd.programLevelSort)){
                System.Debug('Myself Entered Sort Method-Step 25');
                    return -1;
                }else if(this.techSpecSort != tempPd.techSpecSort || this.programLevelSort != tempPd.programLevelSort){
                System.Debug('Myself Entered Sort Method-Step 26');
                    return 1;
                }
            }
            System.Debug('Myself Entered Sort Method-Step 27-- END of IF ELSE LADDER');
            System.debug('this.techSpecSort:  ' + this.techSpecSort);
            System.debug('tempPd.techSpecSort:  ' + tempPd.techSpecSort);
            return randomSort();        
        }
        
        public Integer distributorSort(PartnerData tempPd){
            if(regionMap.get(this.ps.stage.Partner_Region__c) == 'US Federal' || (regionMap.get(this.ps.stage.Partner_Region__c) != 'US Federal' && ps.stage.Partner_Industry__c == 'US Federal')){
                if(isEmpty(this.ps.stage.Partner_Technology__c)){
                    if(this.fedSort < tempPd.fedSort || (this.fedSort == tempPd.fedSort && this.programLevelSort < tempPd.programLevelSort)){
                        return -1;
                    }else if(this.fedSort != tempPd.fedSort || this.programLevelSort != tempPd.programLevelSort){
                        return 1;
                    }
                }
            }
            if(this.distSpecSort < tempPd.distSpecSort){
                return -1;
            }else if(this.distSpecSort > tempPd.distSpecSort){
                return 1;
            }
            return randomSort();        
        }
        
        public Integer appPartnerSort(PartnerData tempPd){
            if(regionMap.get(this.ps.stage.Partner_Region__c) == 'US Federal' || (regionMap.get(this.ps.stage.Partner_Region__c) != 'US Federal' && ps.stage.Partner_Industry__c == 'US Federal')){
                if(isEmpty(this.ps.stage.Partner_Technology__c)){
                    if(this.fedSort < tempPd.fedSort || (this.fedSort == tempPd.fedSort && this.programLevelSort < tempPd.programLevelSort)){
                        return -1;
                    }else if(this.fedSort != tempPd.fedSort || this.programLevelSort != tempPd.programLevelSort){
                        return 1;
                    }
                }else{
                    if(this.fedSort < tempPd.fedSort || (this.fedSort == tempPd.fedSort && this.appSpecSort < tempPd.appSpecSort) || (this.fedSort == tempPd.fedSort && this.appSpecSort == tempPd.appSpecSort && this.programLevelSort < tempPd.programLevelSort)){
                        return -1;
                    }else if(this.fedSort != tempPd.fedSort || this.appSpecSort != tempPd.appSpecSort || this.programLevelSort != tempPd.programLevelSort){
                        return 1;
                    }
                }
            }else if(regionMap.get(this.ps.stage.Partner_Region__c) == 'LACR' || regionMap.get(this.ps.stage.Partner_Region__c) == 'APAC' || regionMap.get(this.ps.stage.Partner_Region__c) == 'EMEA' || regionMap.get(this.ps.stage.Partner_Region__c) == 'NAMR'){
                if(isEmpty(ps.stage.Partner_Technology__c)){
                    if(this.programLevelSort < tempPd.programLevelSort){
                        return -1;
                    }else if(this.programLevelSort > tempPd.programLevelSort){
                        return 1;
                    }
                }else{
                    if(this.appSpecSort < tempPd.appSpecSort || (this.appSpecSort == tempPd.appSpecSort && this.programLevelSort < tempPd.programLevelSort)){
                        return -1;
                    }else if(this.appSpecSort != tempPd.appSpecSort || this.programLevelSort != tempPd.programLevelSort){
                        return 1;
                    }
                }
            }
            return randomSort();        
        }
        
        public Boolean isEmpty(String s){
            return (s == null || s == '')?true:false;
        }
    }
    
    public class Location{
        public String latitude {get;set;}
        public String longitude {get;set;}
        public String name {get;set;}
        public String address1 {get;set;}
        public String address2 {get;set;}
        public String city {get;set;}
        public String state {get;set;}
        public String zip {get;set;}
        public String country {get;set;}
        public String phone {get;set;}
        public String fax {get;set;}
        public Location()
        {
        }
        
    }
    
    public class URL{
        public String url {get;set;}
        public String name {get;set;}
        
        public URL(String url, String name){
            this.url = url;
            this.name = name;
        }
    }

    public class ApplicationData{
       // public Software_Applications__c application {get;set;}
        public ApplicationSearch aSearch = new ApplicationSearch();
        public String appId {get;set;}
        public String Name {get;set;}
        public String Version {get;set;}
        public String appIconUrl {get;set;}
        public String appLevelUrl {get;set;}
        public String motorolaTested {get;set;}
        public Boolean isInQuickList {get;set;}
        public Decimal metalLevelSort = 100;
        public Decimal motorolaTestSort = 100;
          
        public List<Screenshot> screenshots {get;set;}
        
        public List<Industries_Solutions__c> industrySolutions {get;set;}
        public List<Cross_Industries_Solutions__c> crossIndustrySolutions {get;set;}
       // public List<Supported_Products__c> supportedProducts {get;set;}
       // public List<Supported_Products__c> modelNames {get;set;}
        public Set<String> Customer_Name {get;set;}
        public Set<String> Technology_Segment {get;set;}
        public Set<String> ApplicationType {get;set;}
        public Integer customerNameSize;
        public Integer crossIndustriesSize;
        
        public ApplicationData(){
            this.appId = '';
            this.Name = '';
            this.Version = '';
            this.industrySolutions = new List<Industries_Solutions__c>();
            this.crossIndustrySolutions = new List<Cross_Industries_Solutions__c>();
           // this.supportedProducts = new List<Supported_Products__c>();
            //this.modelNames = new List<Supported_Products__c>();
            //this.application = new Software_Applications__c();
            this.ApplicationType = new Set<String>();
            this.isInQuickList = false;
            this.Customer_Name = new Set<String>();
            this.screenshots = new List<Screenshot>();
            this.appIconUrl = '';
            this.appLevelUrl = '';
        }
        
        public Integer getCustomerNameSize(){
            return this.Customer_Name.size();
        }
    }
    
    public class ApplicationDataStripped implements Comparable{
        public String appId {get;set;}
        //public Software_Applications__c application {get;set;}
        public String motorolaTested {get;set;}
        public String appIconUrl {get;set;}
        public Boolean isInQuickList {get;set;}
        public Decimal motorolaTestSort = 100;
        public Decimal metalLevelSort = 100;
        public Decimal techSpecSort = 100;
        public Boolean hasTechnology = false;
        //Added by Sathish for MOTOTRBO AppFinder Enhancement
        //public List<Supported_Products__c> supportedDevice {get;set;}
        public Set<String> supportedProducts {get;set;}
        
        public ApplicationDataStripped(){
            this.appId = '';
            this.isInQuickList = false;
            this.appIconUrl = '';
            this.motorolaTested = '';
            //this.supportedDevice = new List<Supported_Products__c>();
            this.supportedProducts = new Set<String>();
        }
        
        public Integer compareTo(Object compareTo) {
            ApplicationDataStripped tempAd = (ApplicationDataStripped)compareTo;
            System.debug(LoggingLevel.ERROR, 'this.Name:  ' + ', motorolaTestSort:  ' + this.motorolaTestSort + ', techSpecSort:  ' + this.techSpecSort + ', metalLevelSort:  ' + this.metalLevelSort);
            System.debug(LoggingLevel.ERROR, 'tempAd.Name:  ' + ', motorolaTestSort:  ' + tempAd.motorolaTestSort + ', techSpecSort:  ' + tempAd.techSpecSort + ', metalLevelSort:  ' + tempAd.metalLevelSort);
            if(this.hasTechnology){
                if(this.motorolaTestSort < tempAd.motorolaTestSort || (this.motorolaTestSort == tempAd.motorolaTestSort && this.techSpecSort < tempAd.techSpecSort) || (this.motorolaTestSort == tempAd.motorolaTestSort && this.techSpecSort == tempAd.techSpecSort && this.metalLevelSort < tempAd.metalLevelSort)){
                    return -1;
                }else if(this.motorolaTestSort != tempAd.motorolaTestSort || this.techSpecSort != tempAd.techSpecSort || this.metalLevelSort != tempAd.metalLevelSort){
                    return 1;
                }
            }else{
                if(this.motorolaTestSort < tempAd.motorolaTestSort || (this.motorolaTestSort == tempAd.motorolaTestSort && this.metalLevelSort < tempAd.metalLevelSort)){
                    return -1;
                }else if(this.motorolaTestSort != tempAd.motorolaTestSort || this.metalLevelSort != tempAd.metalLevelSort){
                    return 1;
                }
            }
            return (Math.random() < Math.random())?1:-1;        
        }       

        public Boolean isEmpty(String s){
            return (s == null || s == '')?true:false;
        }
    }
    

    public class Screenshot{
        public String scId {get;set;}
        public String thumbnailId {get;set;}
        public String fullImageId {get;set;}
        
        public Screenshot(String scId, String thumbnailId, String fullImageId){
            this.scId = scId;
            this.thumbnailId = thumbnailId;
            this.fullImageId = fullImageId;
        }
    }
    
    public class ApplicationSearch{
        public String searchTerm {get;set;}
        //public List<SelectOption> typeList {get;set;}
        //public String selectedOption {get;set;}
        public MM_Staging__c stage {get;set;}
        public String recordTypeId {get;set;}

        public ApplicationSearch(DeepLinking dl){
            this.stage = new MM_Staging__c();
            this.stage.Country__c = dl.country;
            this.stage.E_or_G__c='E'; //Added by Ananth as part of INC0671758 
            System.debug(LoggingLevel.ERROR, 'deep link tech in app search = ' + dl.technology);
            this.stage.Technology__c = dl.technology;
            this.stage.Industry__c = dl.industry;
            this.stage.Region__c = dl.region;
            this.stage.Supported_Operating_Systems__c = dl.os;
            this.stage.Product__c = dl.model;
            commonOps();
            
            //Commented by Ananth as part of INC0671758 
           /* if(dl.business !=null && dl.business == 'E'){
                this.stage.E_or_G__c='E';
            }else{
                this.stage.E_or_G__c='G';
            } */
            //Ended by Ananth as part of INC0671758
        }
        

      
      //Added by Sat for Mototrbo Appfinder enhacement Starts  
       public List<SelectOption> SystemTypeOptions{
                get {
                  return this.genOptions(MM_Staging__c.System_Type__c.getDescribe().getPicklistValues());
                } 
                private set;
            }
            
             public String[] SystemTypes{ 
                get {
                  String[] selected = new List<String>();
                  List<SelectOption> sos = this.SystemTypeOptions;
                  
                  for(SelectOption s : sos) {
                    if (stage.System_Type__c!= null && stage.System_Type__c.contains(s.getValue()))
                    selected.add(s.getValue());
                  }
                  return selected;
                } 
            
                public set {
                  String selectedProgram = '';
                  
                  for(String s : value) {
                    if (selectedProgram== '') selectedProgram += s;
                    else selectedProgram+= ';' + s;
                  }
                  
                  stage.System_Type__c= selectedProgram;
                }
            } 
            
            //System.debug();    
        //Added by Sat for Mototrbo Appfinder enhacement Ends

        private List<SelectOption> genOptions(List<Schema.PicklistEntry> ple) {
            List<SelectOption> options = new List<SelectOption>();
            for(Schema.PicklistEntry f : ple) {
                    options.add(new SelectOption(f.getValue(), f.getLabel()));
            }
            return options;
        }
        
        
        
        public ApplicationSearch(){
            this.stage = new MM_Staging__c();
            commonOps();
        }
        
        public void commonOps(){
            this.searchTerm = '';
            //this.selectedOption = System.Label.MM_Industry_Specific_Application;
            this.recordTypeId = [Select Id From RecordType WHERE SobjectType = 'Account' AND Name = 'Partner' LIMIT 1].Id;
            this.stage.Industry_Selector__c = 'Industry Specific Application';
            
            System.debug(LoggingLevel.ERROR, 'this.stage:  ' + this.stage);
            
            /*
            typeList = new List<SelectOption>();
            typeList.add(new SelectOption(System.Label.MM_Industry_Specific_Application, System.Label.MM_Industry_Specific_Application));
            typeList.add(new SelectOption(System.Label.MM_General_Business_Application, System.Label.MM_General_Business_Application));
            */
        }
    }

    public class PartnerSearch{
        public String searchTerm {get;set;}
        public MM_Staging__c stage {get;set;}
        public String recordTypeId {get;set;}
        public List<PartnerQuery> partnerQueries {get;set;}
        public Boolean renderMego {get;set;}
        public Map<String, String> rm = MM_Class_SearchController.regionMap;
        public List<SelectOption> countyList;
        public String county {get;set;}
        public String previousIndustryValue {get;set;}
        public Boolean showCounty;
        public Boolean showState;
        
        public List<SelectOption> technologyOptions{get;set;}
        public List<SelectOption> govTechnologyOptions{get;set;}
        public List<SelectOption> entTechnologyOptions{get;set;}
        
        public PartnerSearch(DeepLinking dl){
            this.stage = new MM_Staging__c();
            this.stage.Partner_Country__c = dl.country;
            this.stage.Partner_Technology__c = dl.technology;
            this.stage.Partner_Industry__c = dl.industry;
            this.stage.Partner_Technology_Industry__c = (dl.industry == '')?'':this.stage.Partner_Technology__c;
                        
            this.stage.Partner_Region__c = dl.region;
            //Added by Sathish for Day 1 Starts
            if(dl.business !=null && dl.business == 'E'){
                this.stage.E_or_G__c='E';
            }else{
                this.stage.E_or_G__c='G';
            }
            
            commonOps();
        }    
        public PageReference refreshTechnology(){
              
              system.debug(' Entering refreshTechnologyTesting.. Region   :: '+this.stage.Partner_Region__c);
              system.debug(' Entering refreshTechnologyTesting.. Business :: '+this.stage.E_or_G__c);
              this.govTechnologyOptions = getTechnologyOptionsList('G');
              this.entTechnologyOptions = getTechnologyOptionsList('E');
              //this.stage.Partner_Technology__c ='';
              return null ;
        }
        
        public List<SelectOption> getTechnologyOptionsList(String businessSelected){
          Schema.DescribeFieldResult techPicklist = MM_Staging__c.Partner_Technology__c.getDescribe();
          List<Schema.PicklistEntry> techLOVs = techPicklist.getPicklistValues();
          List<SelectOption> technologyOptions = new List<SelectOption>();
          technologyOptions.add(new SelectOption('', ''));
          
          if(businessSelected == 'E'){
              for(MM_Region_To_Technology_Enterprise__c tech : [select Technology__c from MM_Region_To_Technology_Enterprise__c where Region__c = :this.stage.Partner_Region__c]){
                  for(Schema.PicklistEntry entry:techLOVs ){
                      if(entry.getValue()==tech.Technology__c){
                           technologyOptions.add(new SelectOption(entry.getValue(), entry.getLabel()));
                     }
                  }
              }
          }
          if(businessSelected == 'G'){
              for(MM_Region_To_Technology_Government__c tech : [select Technology__c from MM_Region_To_Technology_Government__c where Region__c = :this.stage.Partner_Region__c]){
                  for(Schema.PicklistEntry entry:techLOVs ){
                      if(entry.getValue()==tech.Technology__c){
                           technologyOptions.add(new SelectOption(entry.getValue(), entry.getLabel()));
                      }
                  }
              }
          } 
          technologyOptions.sort();         
          return technologyOptions;
        } 

        public PartnerSearch(){
            this.stage = new MM_Staging__c();
            commonOps();
        }
        
        public void commonOps(){
            this.county = '';
            this.partnerQueries = new List<PartnerQuery>();
            this.searchTerm = '';
            this.previousIndustryValue = '';
            this.renderMego = false;
            this.recordTypeId = [Select Id From RecordType WHERE SobjectType = 'Account' AND Name = 'Partner' LIMIT 1].Id;
            this.govTechnologyOptions = getTechnologyOptionsList('G');
            this.entTechnologyOptions = getTechnologyOptionsList('E');        
        }
        //Added by Sathish for Day 1 Ends
        
        public Boolean getShowCounty(){
            System.debug(LoggingLevel.ERROR, 'this.countyList:  ' + this.countyList);
            return (this.countyList != null && this.countyList.size() > 1)?true:false;
        }
        
        public Boolean getShowState(){
            System.debug(LoggingLevel.ERROR, 'this.stage.Partner_Region__c:  ' + this.stage.Partner_Region__c);
            return (this.stage.Partner_Region__c != null && this.stage.Partner_Region__c == 'North America')?true:false;
        }
        
        public List<SelectOption> getCountyList(){
            List<SelectOption> soList = new List<SelectOption>();
            soList.add(new SelectOption('', '--None--'));
            System.debug(LoggingLevel.ERROR, 'this.stage.Partner_Region__c:  ' + this.stage.Partner_Region__c);
            if(this.stage.Partner_Region__c == 'North America' && (this.stage.Partner_Technology__c == 'Professional and Commercial Radio' || this.stage.Partner_Technology__c == 'Professional and Commercial Radio' || this.stage.Partner_Technology__c == 'Business Radio')){
                System.debug(LoggingLevel.ERROR, 'this.stage.Partner_State__c:  ' + this.stage.Partner_State__c);
               // Commented as a part of INC0376524 by Harish
               /*for(MM_County_To_State__c ms : [Select County__c, State__c FROM MM_County_To_State__c WHERE State__c = :this.stage.Partner_State__c ORDER BY County__c ASC])
                    System.debug(LoggingLevel.ERROR, 'ms.County__c:  ' + ms.County__c);
                    soList.add(new SelectOption(ms.County__c, ms.County__c)); */

                for(Territory_Master__c ms : [Select State_Code__c, Sales_County__c from Territory_Master__c WHERE State_Code__c = :this.stage.Partner_State__c and Sales_County__c!='' ORDER BY Sales_County__c ASC])
                {
                    System.debug(LoggingLevel.ERROR, 'ms.Sales_County__c:  ' + ms.Sales_County__c);
                    soList.add(new SelectOption(ms.Sales_County__c, ms.Sales_County__c));
                }
            }
            return soList;
        }
        
        public void checkInputsForMego(){
            if(regionMap.get(this.stage.Partner_Region__c) == 'APAC' && 
               (this.stage.Partner_Technology__c == 'Business Radio' ||
               this.stage.Partner_Technology__c == 'Professional and Commercial Radio' ||
               this.stage.Partner_Technology__c == 'Mission Critical Radio Systems' ||
               this.stage.Partner_Technology__c == 'Professional and Commercial Radio' ||
               this.stage.Partner_Technology__c == 'Mission Critical Radio Systems') &&
               this.stage.Partner_Country__c != 'Australia' &&
               this.stage.Partner_Country__c != 'New Zealand' &&
               this.stage.Partner_Industry__c != 'US Federal'){
                this.renderMego = true;
            }else{
                this.renderMego = false;
            }
            this.countyList = this.getCountyList();
            this.showState = this.getShowState();
            this.showCounty = this.getShowCounty();
        }
        
        public void createQueries(){
            System.debug(LoggingLevel.ERROR, 'regionMap.get(this.stage.Partner_Region__c):  ' + regionMap.get(this.stage.Partner_Region__c));
            System.debug(LoggingLevel.ERROR, 'this.stage.Partner_Industry__c:  ' + this.stage.Partner_Industry__c);
            System.debug(LoggingLevel.ERROR, 'this.stage.Partner_Technology__c:  ' + this.stage.Partner_Technology__c);

           // String allTechnology = getAllTechnology(this.stage.E_or_G__c);
           String searchTrack = this.stage.E_or_G__c == 'E' ? '(\''+'WNS'+'\',\''+'Mobility'+'\')' : '(\''+'RADIO'+ '\',\''+'SCADA'+'\')';
           system.debug(' The enabled Tracks : '+searchTrack);
            
            String holdQuery = '';
            String territoryCode = '';
            if(!isEmpty(this.county) || !isEmpty(this.stage.Partner_State__c)){
                String tempQuery = 'Select Territory_Code__c FROM Territory_Master__c where Id != null';
                tempQuery += (isEmpty(this.stage.Partner_Country__c))?'':' AND Country__c = \'' + this.stage.Partner_Country__c + '\''; 
                tempQuery += (isEmpty(this.stage.Partner_State__c))?'':' AND State_Code__c = \'' + this.stage.Partner_State__c + '\''; 
                tempQuery += (isEmpty(this.county))?'':' AND Sales_County__c = \'' + this.county + '\''; 
                System.debug(LoggingLevel.ERROR, 'tempQuery:  ' + tempQuery);
                for(sObject sa : Database.query(tempQuery)){
                    Territory_Master__c tm = (Territory_Master__c)sa;
                    territoryCode += (territoryCode == '')?' AND (Territory_Code__c = \'' + tm.Territory_Code__c + '\'':' OR Territory_Code__c = \'' + tm.Territory_Code__c + '\'';
                }
                territoryCode += (territoryCode == '')?'':')';
            }
            
            
            if(regionMap.get(this.stage.Partner_Region__c) == 'US Federal'){
                holdQuery = 'Select Id'; 
                holdQuery += (isEmpty(this.stage.Partner_Industry__c))?'':', (Select Id FROM Market_Specializations__r WHERE Market_Specialization__c = \'' + this.stage.Partner_Industry__c + '\' AND Market_Specialization_Level__c != null AND Market_Specialization_Level__c != \'None\' LIMIT 1)';
                holdQuery += ' FROM Account a WHERE Id IN (Select Account__c From Technology_Specialization__c where Technology_Specialization_Level__c != \'Open\' AND Community_Type__c = \'Application Partner\' AND Partner_Program__r.Status__c = \'Active\' AND Partner_Program__r.US_Federal__c = true';
                holdQuery += (isEmpty(this.stage.Partner_Technology__c))?'':' AND Technology_Specialization__c = \'' + this.stage.Partner_Technology__c + '\'';
                // Added By Sathish for Separation Day 1
                holdQuery += (isEmpty(this.stage.Partner_Technology__c))?' AND Program__c IN '+searchTrack : ''; 
                //Ends  
                holdQuery += ') AND Id In (Select Account__c FROM Partner_Location__c WHERE Location_Publish_Flag__c = true AND (Federal_Status__c = \'Federal Only Location\' OR Federal_Status__c = \'Federal and Non-Federal Location\')';
                holdQuery += (isEmpty(this.stage.Partner_Country__c))?'':' AND Country1__c = \'' + this.stage.Partner_Country__c + '\'';
                holdQuery += (isEmpty(this.stage.Partner_State__c))?'':' AND State__c = \'' + this.stage.Partner_State__c + '\'';
                holdQuery += ') AND RecordTypeId = \'' + this.recordTypeId + '\' AND Partner_Locator_Status__c = \'Active\' AND (Hierarchy_Placement__c = \'Global Account\' OR Hierarchy_Placement__c = \'Regional Account\' OR Hierarchy_Placement__c = \'Regional Subsidiary Account\')';
                this.partnerQueries.add(new PartnerQuery(QueryType.APP_PARTNER, holdQuery));

                holdQuery = 'Select Id'; 
                holdQuery += (isEmpty(this.stage.Partner_Industry__c))?'':', (Select Id FROM Market_Specializations__r WHERE Market_Specialization__c = \'' + this.stage.Partner_Industry__c + '\' AND Market_Specialization_Level__c != null AND Market_Specialization_Level__c != \'None\' LIMIT 1)';
                holdQuery += ' FROM Account a WHERE Id IN (Select Account__c From Technology_Specialization__c where Technology_Specialization_Level__c != \'Open\' AND (Community_Type__c = \'Value Added Reseller\' OR Community_Type__c = \'eTailer\' OR Community_Type__c = \'Direct Market Reseller\' OR Community_Type__c = \'Carrier\') AND Partner_Program__r.Status__c = \'Active\' AND Partner_Program__r.US_Federal__c = true';
                holdQuery += (isEmpty(this.stage.Partner_Technology__c))?'':' AND Technology_Specialization__c = \'' + this.stage.Partner_Technology__c + '\'';
                // Added By Sathish for Separation Day 1
                holdQuery += (isEmpty(this.stage.Partner_Technology__c))?' AND Program__c IN '+searchTrack : ''; 
                //Ends  
                holdQuery += ') AND Id IN (Select Account__c FROM Partner_Location__c WHERE Location_Publish_Flag__c = true AND (Federal_Status__c = \'Federal Only Location\' OR Federal_Status__c = \'Federal and Non-Federal Location\')';
                holdQuery += (isEmpty(this.stage.Partner_Country__c))?'':' AND Country1__c = \'' + this.stage.Partner_Country__c + '\'';
                holdQuery += (isEmpty(this.stage.Partner_State__c))?'':' AND State__c = \'' + this.stage.Partner_State__c + '\'';
                holdQuery += ') AND RecordTypeId = \'' + this.recordTypeId + '\' AND Partner_Locator_Status__c = \'Active\' AND (Hierarchy_Placement__c = \'Global Account\' OR Hierarchy_Placement__c = \'Regional Account\' OR Hierarchy_Placement__c = \'Regional Subsidiary Account\')';
                this.partnerQueries.add(new PartnerQuery(QueryType.CHANNEL_APP, holdQuery));

                holdQuery = 'Select Id'; 
                holdQuery += (isEmpty(this.stage.Partner_Industry__c))?'':', (Select Id FROM Market_Specializations__r WHERE Market_Specialization__c = \'' + this.stage.Partner_Industry__c + '\' AND Market_Specialization_Level__c != null AND Market_Specialization_Level__c != \'None\' LIMIT 1)';
                holdQuery += ' FROM Account a WHERE Id IN (Select Account__c From Technology_Specialization__c where Technology_Specialization_Level__c != \'Open\' AND (Community_Type__c = \'Application Partner\') AND Partner_Program__r.Status__c = \'Active\' AND Partner_Program__r.US_Federal__c = true';
                holdQuery += (isEmpty(this.stage.Partner_Technology__c))?'':' AND Technology_Specialization__c = \'' + this.stage.Partner_Technology__c + '\'';
                // Added By Sathish for Separation Day 1
                holdQuery += (isEmpty(this.stage.Partner_Technology__c))?' AND Program__c IN '+searchTrack : ''; 
                //Ends  
                holdQuery += ') AND Id IN (Select Account__c FROM Partner_Location__c WHERE Location_Publish_Flag__c = true AND (Federal_Status__c = \'Federal Only Location\' OR Federal_Status__c = \'Federal and Non-Federal Location\')';
                holdQuery += (isEmpty(this.stage.Partner_Country__c))?'':' AND Country1__c = \'' + this.stage.Partner_Country__c + '\'';
                holdQuery += (isEmpty(this.stage.Partner_State__c))?'':' AND State__c = \'' + this.stage.Partner_State__c + '\'';
                holdQuery += ') AND RecordTypeId = \'' + this.recordTypeId + '\' AND Partner_Locator_Status__c = \'Active\' AND (Hierarchy_Placement__c = \'Global Account\' OR Hierarchy_Placement__c = \'Regional Account\' OR Hierarchy_Placement__c = \'Regional Subsidiary Account\')';
                this.partnerQueries.add(new PartnerQuery(QueryType.CHANNEL_APP2, holdQuery));

                if(isEmpty(this.stage.Partner_Technology__c)){
                    holdQuery = 'Select Id';
                    holdQuery += (isEmpty(this.stage.Partner_Industry__c))?'':', (Select Id FROM Market_Specializations__r WHERE Market_Specialization__c = \'' + this.stage.Partner_Industry__c + '\' AND Market_Specialization_Level__c != null AND Market_Specialization_Level__c != \'None\' LIMIT 1)';
                    holdQuery += ' FROM Account a WHERE Id IN (Select Account__c From Technology_Specialization__c where Technology_Specialization_Level__c != \'Open\' AND (Community_Type__c = \'Value Added Reseller\' OR Community_Type__c = \'eTailer\' OR Community_Type__c = \'Direct Market Reseller\' OR Community_Type__c = \'Carrier\')'; 
                    // Added By Sathish for Separation Day 1
                    holdQuery += (isEmpty(this.stage.Partner_Technology__c)) ?' AND Program__c IN '+searchTrack : '';
                    holdQuery +=  ' AND Partner_Program__r.Status__c = \'Active\' AND Partner_Program__r.US_Federal__c = true) AND Id IN (Select Account__c FROM Partner_Location__c WHERE Location_Publish_Flag__c = true AND (Federal_Status__c = \'Federal Only Location\' OR Federal_Status__c = \'Federal and Non-Federal Location\')';
                    // ENDS
                    holdQuery += (isEmpty(this.stage.Partner_Country__c))?'':' AND Country1__c = \'' + this.stage.Partner_Country__c + '\'';
                    holdQuery += (isEmpty(this.stage.Partner_State__c))?'':' AND State__c = \'' + this.stage.Partner_State__c + '\'';
                    holdQuery += ') AND RecordTypeId = \'' + this.recordTypeId + '\' AND Partner_Locator_Status__c = \'Active\' AND (Hierarchy_Placement__c = \'Global Account\' OR Hierarchy_Placement__c = \'Regional Account\' OR Hierarchy_Placement__c = \'Regional Subsidiary Account\')';
                    this.partnerQueries.add(new PartnerQuery(QueryType.CHANNEL_PARTNER, holdQuery));
                    
                    holdQuery = 'Select Id'; 
                    holdQuery += (isEmpty(this.stage.Partner_Industry__c))?'':', (Select Id FROM Market_Specializations__r WHERE Market_Specialization__c = \'' + this.stage.Partner_Industry__c + '\' AND Market_Specialization_Level__c != null AND Market_Specialization_Level__c != \'None\' LIMIT 1)';
                    holdQuery += ' FROM Account a WHERE Id IN (Select Account__c From Technology_Specialization__c where Technology_Specialization_Level__c != \'Open\' AND (Community_Type__c = \'Value Added Distributor\' OR Community_Type__c = \'Sub-Distributor\')' ;
                    // Added By Sathish for Separation Day 1
                    holdQuery += (isEmpty(this.stage.Partner_Technology__c)) ? ' AND Program__c IN '+searchTrack : '';
                    holdQuery +=' AND Partner_Program__r.Status__c = \'Active\' AND Partner_Program__r.US_Federal__c = true) AND Id IN (Select Account__c FROM Partner_Location__c WHERE Location_Publish_Flag__c = true';
                    //Ends
                    holdQuery += (isEmpty(this.stage.Partner_Country__c))?'':' AND Country1__c = \'' + this.stage.Partner_Country__c + '\'';
                    holdQuery += (isEmpty(this.stage.Partner_State__c))?'':' AND State__c = \'' + this.stage.Partner_State__c + '\'';
                    holdQuery += ' AND (Federal_Status__c = \'Federal Only Location\' OR Federal_Status__c = \'Federal and Non-Federal Location\')) AND RecordTypeId = \'' + this.recordTypeId + '\' AND Partner_Locator_Status__c = \'Active\' AND (Hierarchy_Placement__c = \'Global Account\' OR Hierarchy_Placement__c = \'Regional Account\' OR Hierarchy_Placement__c = \'Regional Subsidiary Account\')';
                    this.partnerQueries.add(new PartnerQuery(QueryType.DISTRIBUTOR, holdQuery));
                }
                if(!isEmpty(this.stage.Partner_Technology__c)){
                    holdQuery = 'Select Id';
                    holdQuery += (isEmpty(this.stage.Partner_Industry__c))?'':', (Select Id FROM Market_Specializations__r WHERE Market_Specialization__c = \'' + this.stage.Partner_Industry__c + '\' AND MM_Sort_Order__c = 1 AND Market_Specialization_Level__c != null AND Market_Specialization_Level__c != \'None\' LIMIT 1)';
                    holdQuery += ' FROM Account a WHERE Id IN (Select Account__c From Technology_Specialization__c where Technology_Specialization_Level__c != \'Open\' AND (Community_Type__c = \'Value Added Reseller\' OR Community_Type__c = \'eTailer\' OR Community_Type__c = \'Direct Market Reseller\' OR Community_Type__c = \'Carrier\') AND Partner_Program__r.Status__c = \'Active\' AND Partner_Program__r.US_Federal__c = true';
                    holdQuery += ' AND Technology_Specialization__c = \'' + this.stage.Partner_Technology__c + '\'';
                    holdQuery += ') AND Id IN (Select Account__c FROM Partner_Location__c WHERE Location_Publish_Flag__c = true AND (Federal_Status__c = \'Federal Only Location\' OR Federal_Status__c = \'Federal and Non-Federal Location\')';
                    holdQuery += (isEmpty(this.stage.Partner_Country__c))?'':' AND Country1__c = \'' + this.stage.Partner_Country__c + '\'';
                    holdQuery += (isEmpty(this.stage.Partner_State__c))?'':' AND State__c = \'' + this.stage.Partner_State__c + '\'';
                    holdQuery += ') AND RecordTypeId = \'' + this.recordTypeId + '\' AND Partner_Locator_Status__c = \'Active\' AND (Hierarchy_Placement__c = \'Global Account\' OR Hierarchy_Placement__c = \'Regional Account\' OR Hierarchy_Placement__c = \'Regional Subsidiary Account\')';
                    this.partnerQueries.add(new PartnerQuery(QueryType.CHANNEL_PARTNER, holdQuery));

                    holdQuery = 'Select Id';
                    holdQuery += (isEmpty(this.stage.Partner_Industry__c))?'':', (Select Id FROM Market_Specializations__r WHERE Market_Specialization__c = \'' + this.stage.Partner_Industry__c + '\' AND MM_Sort_Order__c = 2 AND Market_Specialization_Level__c != null AND Market_Specialization_Level__c != \'None\' LIMIT 1)';
                    holdQuery += ' FROM Account a WHERE Id IN (Select Account__c From Technology_Specialization__c where Technology_Specialization_Level__c != \'Open\' AND (Community_Type__c = \'Value Added Reseller\' OR Community_Type__c = \'eTailer\' OR Community_Type__c = \'Direct Market Reseller\' OR Community_Type__c = \'Carrier\') AND Partner_Program__r.Status__c = \'Active\' AND Partner_Program__r.US_Federal__c = true';
                    holdQuery += ' AND Technology_Specialization__c = \'' + this.stage.Partner_Technology__c + '\'';
                    holdQuery += ') AND Id IN (Select Account__c FROM Partner_Location__c WHERE Location_Publish_Flag__c = true AND (Federal_Status__c = \'Federal Only Location\' OR Federal_Status__c = \'Federal and Non-Federal Location\')';
                    holdQuery += (isEmpty(this.stage.Partner_Country__c))?'':' AND Country1__c = \'' + this.stage.Partner_Country__c + '\'';
                    holdQuery += (isEmpty(this.stage.Partner_State__c))?'':' AND State__c = \'' + this.stage.Partner_State__c + '\'';
                    holdQuery += ') AND RecordTypeId = \'' + this.recordTypeId + '\' AND Partner_Locator_Status__c = \'Active\' AND (Hierarchy_Placement__c = \'Global Account\' OR Hierarchy_Placement__c = \'Regional Account\' OR Hierarchy_Placement__c = \'Regional Subsidiary Account\')';
                    this.partnerQueries.add(new PartnerQuery(QueryType.CHANNEL_PARTNER, holdQuery));

                    holdQuery = 'Select Id';
                    holdQuery += (isEmpty(this.stage.Partner_Industry__c))?'':', (Select Id FROM Market_Specializations__r WHERE Market_Specialization__c = \'' + this.stage.Partner_Industry__c + '\' AND MM_Sort_Order__c != 1 AND MM_Sort_Order__c != 2 AND Market_Specialization_Level__c != null AND Market_Specialization_Level__c != \'None\' LIMIT 1)';
                    holdQuery += ' FROM Account a WHERE Id IN (Select Account__c From Technology_Specialization__c where Technology_Specialization_Level__c != \'Open\' AND (Community_Type__c = \'Value Added Reseller\' OR Community_Type__c = \'eTailer\' OR Community_Type__c = \'Direct Market Reseller\' OR Community_Type__c = \'Carrier\') AND Partner_Program__r.Status__c = \'Active\' AND Partner_Program__r.US_Federal__c = true';
                    holdQuery += ' AND Technology_Specialization__c = \'' + this.stage.Partner_Technology__c + '\'';
                    holdQuery += ') AND Id IN (Select Account__c FROM Partner_Location__c WHERE Location_Publish_Flag__c = true AND (Federal_Status__c = \'Federal Only Location\' OR Federal_Status__c = \'Federal and Non-Federal Location\')';
                    holdQuery += (isEmpty(this.stage.Partner_Country__c))?'':' AND Country1__c = \'' + this.stage.Partner_Country__c + '\'';
                    holdQuery += (isEmpty(this.stage.Partner_State__c))?'':' AND State__c = \'' + this.stage.Partner_State__c + '\'';
                    holdQuery += ') AND RecordTypeId = \'' + this.recordTypeId + '\' AND Partner_Locator_Status__c = \'Active\' AND (Hierarchy_Placement__c = \'Global Account\' OR Hierarchy_Placement__c = \'Regional Account\' OR Hierarchy_Placement__c = \'Regional Subsidiary Account\')';
                    this.partnerQueries.add(new PartnerQuery(QueryType.CHANNEL_PARTNER2, holdQuery));

                    holdQuery = 'Select Id';
                    holdQuery += (isEmpty(this.stage.Partner_Industry__c))?'':', (Select Id FROM Market_Specializations__r WHERE Market_Specialization__c = \'' + this.stage.Partner_Industry__c + '\' AND Market_Specialization_Level__c != null AND Market_Specialization_Level__c != \'None\' LIMIT 1)';
                    holdQuery += ' FROM Account a WHERE Id IN (Select Account__c From Technology_Specialization__c where Technology_Specialization_Level__c != \'Open\' AND Partner_Program__r.US_Federal__c = true AND (Community_Type__c = \'Value Added Distributor\' OR Community_Type__c = \'Sub-Distributor\') AND Partner_Program__r.Status__c = \'Active\'';
                    holdQuery += ' AND Technology_Specialization__c = \'' + this.stage.Partner_Technology__c + '\'';
                    holdQuery += ') AND Id IN (Select Account__c FROM Partner_Location__c WHERE Location_Publish_Flag__c = true';
                    holdQuery += (isEmpty(this.stage.Partner_Country__c))?'':' AND Country1__c = \'' + this.stage.Partner_Country__c + '\'';
                    holdQuery += (isEmpty(this.stage.Partner_State__c))?'':' AND State__c = \'' + this.stage.Partner_State__c + '\'';
                    holdQuery += ' AND (Federal_Status__c = \'Federal Only Location\' OR Federal_Status__c = \'Federal and Non-Federal Location\')) AND RecordTypeId = \'' + this.recordTypeId + '\' AND Partner_Locator_Status__c = \'Active\' AND (Hierarchy_Placement__c = \'Global Account\' OR Hierarchy_Placement__c = \'Regional Account\' OR Hierarchy_Placement__c = \'Regional Subsidiary Account\')';
                    this.partnerQueries.add(new PartnerQuery(QueryType.DISTRIBUTOR, holdQuery));
                }
            }
                
            if((regionMap.get(this.stage.Partner_Region__c) == 'EMEA') && this.stage.Partner_Industry__c != 'US Federal'){
                holdQuery = 'Select Id';
                holdQuery += (!this.stage.Partner_Authorized_Service_Center__c)?'':', (Select Id FROM Partner_Types__r WHERE Authorized_Service_Center__c = true LIMIT 1)';
                holdQuery += (isEmpty(this.stage.Partner_Industry__c))?'':', (Select Id FROM Market_Specializations__r WHERE Market_Specialization__c = \'' + this.stage.Partner_Industry__c + '\' AND Market_Specialization_Level__c != null AND Market_Specialization_Level__c != \'None\' LIMIT 1)';
                //holdQuery += ' FROM Account a WHERE Id IN (Select Account__c From Technology_Specialization__c where Technology_Specialization__c != \'Industrial Mobile Computing\' AND Technology_Specialization_Level__c != \'Open\' AND Community_Type__c = \'Application Partner\' AND Partner_Program__r.Status__c = \'Active\'';
                //Psion for EMEA Code - Brahma
                holdQuery += ' FROM Account a WHERE Id IN (Select Account__c From Technology_Specialization__c where Technology_Specialization_Level__c != \'Open\' AND Community_Type__c = \'Application Partner\' AND Partner_Program__r.Status__c = \'Active\'';
                holdQuery += (isEmpty(this.stage.Partner_Technology__c))?'':' AND Technology_Specialization__c = \'' + this.stage.Partner_Technology__c + '\'';
                // Added By Sathish for Separation Day 1
                holdQuery += (isEmpty(this.stage.Partner_Technology__c))?' AND Program__c IN '+searchTrack : ''; 
                //Ends  
                holdQuery += ') AND Id IN (Select Account__c FROM Partner_Location__c WHERE Location_Publish_Flag__c = true AND (Federal_Status__c != \'Federal Only Location\')';
                holdQuery += (isEmpty(this.stage.Partner_Region__c))?'':' AND Account__r.Partner_Region__c = \'' + regionMap.get(this.stage.Partner_Region__c) + '\'';
                holdQuery += (isEmpty(this.stage.Partner_Country__c))?'':' AND Country1__c = \'' + this.stage.Partner_Country__c + '\'';
                holdQuery += (isEmpty(this.stage.Partner_State__c))?'':' AND State__c = \'' + this.stage.Partner_State__c + '\'';
                holdQuery += ') AND RecordTypeId = \'' + this.recordTypeId + '\' AND Partner_Locator_Status__c = \'Active\' AND (Hierarchy_Placement__c = \'Global Account\' OR Hierarchy_Placement__c = \'Regional Account\' OR Hierarchy_Placement__c = \'Regional Subsidiary Account\'';
                holdQuery += (!this.stage.Partner_Mego__c)?')':') AND MEGO_Status__c != null';
                this.partnerQueries.add(new PartnerQuery(QueryType.APP_PARTNER, holdQuery));

                holdQuery = 'Select Id';
                holdQuery += (!this.stage.Partner_Authorized_Service_Center__c)?'':', (Select Id FROM Partner_Types__r WHERE Authorized_Service_Center__c = true LIMIT 1)';
                holdQuery += (isEmpty(this.stage.Partner_Industry__c))?'':', (Select Id FROM Market_Specializations__r WHERE Market_Specialization__c = \'' + this.stage.Partner_Industry__c + '\' AND Market_Specialization_Level__c != null AND Market_Specialization_Level__c != \'None\' LIMIT 1)';
                //holdQuery += ' FROM Account a WHERE Id IN (Select Account__c From Technology_Specialization__c where Technology_Specialization__c != \'Industrial Mobile Computing\' AND Technology_Specialization_Level__c != \'Open\' AND (Community_Type__c = \'Value Added Reseller\' OR Community_Type__c = \'eTailer\' OR Community_Type__c = \'Direct Market Reseller\' OR Community_Type__c = \'Carrier\') AND Partner_Program__r.Status__c = \'Active\'';
                //Psion for EMEA Code - Brahma
                holdQuery += ' FROM Account a WHERE Id IN (Select Account__c From Technology_Specialization__c where Technology_Specialization_Level__c != \'Open\' AND (Community_Type__c = \'Value Added Reseller\' OR Community_Type__c = \'eTailer\' OR Community_Type__c = \'Direct Market Reseller\' OR Community_Type__c = \'Carrier\') AND Partner_Program__r.Status__c = \'Active\'';
                holdQuery += (isEmpty(this.stage.Partner_Technology__c))?'':' AND Technology_Specialization__c = \'' + this.stage.Partner_Technology__c + '\'';
                // Added By Sathish for Separation Day 1
                holdQuery += (isEmpty(this.stage.Partner_Technology__c))?' AND Program__c IN '+searchTrack : ''; 
                //Ends 
                holdQuery += ') AND Id IN (Select Account__c FROM Partner_Location__c WHERE Location_Publish_Flag__c = true AND (Federal_Status__c != \'Federal Only Location\')';
                holdQuery += (isEmpty(this.stage.Partner_Region__c))?'':' AND Account__r.Partner_Region__c = \'' + regionMap.get(this.stage.Partner_Region__c) + '\'';
                holdQuery += (isEmpty(this.stage.Partner_Country__c))?'':' AND Country1__c = \'' + this.stage.Partner_Country__c + '\'';
                holdQuery += (isEmpty(this.stage.Partner_State__c))?'':' AND State__c = \'' + this.stage.Partner_State__c + '\'';
                holdQuery += ') AND RecordTypeId = \'' + this.recordTypeId + '\' AND Partner_Locator_Status__c = \'Active\' AND (Hierarchy_Placement__c = \'Global Account\' OR Hierarchy_Placement__c = \'Regional Account\' OR Hierarchy_Placement__c = \'Regional Subsidiary Account\'';
                holdQuery += (!this.stage.Partner_Mego__c)?')':') AND MEGO_Status__c != null';
                this.partnerQueries.add(new PartnerQuery(QueryType.CHANNEL_APP, holdQuery));

                holdQuery = 'Select Id';
                holdQuery += (!this.stage.Partner_Authorized_Service_Center__c)?'':', (Select Id FROM Partner_Types__r WHERE Authorized_Service_Center__c = true LIMIT 1)';
                holdQuery += (isEmpty(this.stage.Partner_Industry__c))?'':', (Select Id FROM Market_Specializations__r WHERE Market_Specialization__c = \'' + this.stage.Partner_Industry__c + '\' AND Market_Specialization_Level__c != null AND Market_Specialization_Level__c != \'None\' LIMIT 1)';
                //holdQuery += ' FROM Account a WHERE Id IN (Select Account__c From Technology_Specialization__c where Technology_Specialization__c != \'Industrial Mobile Computing\' AND Technology_Specialization_Level__c != \'Open\' AND (Community_Type__c = \'Application Partner\') AND Partner_Program__r.Status__c = \'Active\'';
                //Psion for EMEA Code - Brahma
                holdQuery += ' FROM Account a WHERE Id IN (Select Account__c From Technology_Specialization__c where Technology_Specialization_Level__c != \'Open\' AND (Community_Type__c = \'Application Partner\') AND Partner_Program__r.Status__c = \'Active\'';
                holdQuery += (isEmpty(this.stage.Partner_Technology__c))?'':' AND Technology_Specialization__c = \'' + this.stage.Partner_Technology__c + '\'';
                // Added By Sathish for Separation Day 1
                holdQuery += (isEmpty(this.stage.Partner_Technology__c))?' AND Program__c IN '+searchTrack : ''; 
                //Ends 
                holdQuery += ') AND Id IN (Select Account__c FROM Partner_Location__c WHERE Location_Publish_Flag__c = true AND (Federal_Status__c != \'Federal Only Location\')';
                holdQuery += (isEmpty(this.stage.Partner_Region__c))?'':' AND Account__r.Partner_Region__c = \'' + regionMap.get(this.stage.Partner_Region__c) + '\'';
                holdQuery += (isEmpty(this.stage.Partner_Country__c))?'':' AND Country1__c = \'' + this.stage.Partner_Country__c + '\'';
                holdQuery += (isEmpty(this.stage.Partner_State__c))?'':' AND State__c = \'' + this.stage.Partner_State__c + '\'';
                holdQuery += ') AND RecordTypeId = \'' + this.recordTypeId + '\' AND Partner_Locator_Status__c = \'Active\' AND (Hierarchy_Placement__c = \'Global Account\' OR Hierarchy_Placement__c = \'Regional Account\' OR Hierarchy_Placement__c = \'Regional Subsidiary Account\'';
                holdQuery += (!this.stage.Partner_Mego__c)?')':') AND MEGO_Status__c != null';
                this.partnerQueries.add(new PartnerQuery(QueryType.CHANNEL_APP2, holdQuery));
            }
            
            if((regionMap.get(this.stage.Partner_Region__c) == 'APAC' || regionMap.get(this.stage.Partner_Region__c) == 'NAMR') && this.stage.Partner_Industry__c != 'US Federal'){
                holdQuery = 'Select Id';
                holdQuery += (!this.stage.Partner_Authorized_Service_Center__c)?'':', (Select Id FROM Partner_Types__r WHERE Authorized_Service_Center__c = true LIMIT 1)';
                holdQuery += (isEmpty(this.stage.Partner_Industry__c))?'':', (Select Id FROM Market_Specializations__r WHERE Market_Specialization__c = \'' + this.stage.Partner_Industry__c + '\' AND Market_Specialization_Level__c != null AND Market_Specialization_Level__c != \'None\' LIMIT 1)';
                holdQuery += ' FROM Account a WHERE Id IN (Select Account__c From Technology_Specialization__c where Technology_Specialization_Level__c != \'Open\' AND Community_Type__c = \'Application Partner\' AND Partner_Program__r.Status__c = \'Active\'';
                holdQuery += (isEmpty(this.stage.Partner_Technology__c))?'':' AND Technology_Specialization__c = \'' + this.stage.Partner_Technology__c + '\'';
                holdQuery += (isEmpty(this.stage.Partner_Technology__c))?' AND Program__c IN '+searchTrack : ''; // Added By Sathish for Separation Day 1
                holdQuery += ') AND Id IN (Select Account__c FROM Partner_Location__c WHERE Location_Publish_Flag__c = true AND (Federal_Status__c != \'Federal Only Location\')';
                holdQuery += (isEmpty(this.stage.Partner_Region__c))?'':' AND Account__r.Partner_Region__c = \'' + regionMap.get(this.stage.Partner_Region__c) + '\'';
                holdQuery += (isEmpty(this.stage.Partner_Country__c))?'':' AND Country1__c = \'' + this.stage.Partner_Country__c + '\'';
                holdQuery += (isEmpty(this.stage.Partner_State__c))?'':' AND State__c = \'' + this.stage.Partner_State__c + '\'';
                holdQuery += ') AND RecordTypeId = \'' + this.recordTypeId + '\' AND Partner_Locator_Status__c = \'Active\' AND (Hierarchy_Placement__c = \'Global Account\' OR Hierarchy_Placement__c = \'Regional Account\' OR Hierarchy_Placement__c = \'Regional Subsidiary Account\'';
                holdQuery += (!this.stage.Partner_Mego__c)?')':') AND MEGO_Status__c != null';
                this.partnerQueries.add(new PartnerQuery(QueryType.APP_PARTNER, holdQuery));

                holdQuery = 'Select Id';
                holdQuery += (!this.stage.Partner_Authorized_Service_Center__c)?'':', (Select Id FROM Partner_Types__r WHERE Authorized_Service_Center__c = true LIMIT 1)';
                holdQuery += (isEmpty(this.stage.Partner_Industry__c))?'':', (Select Id FROM Market_Specializations__r WHERE Market_Specialization__c = \'' + this.stage.Partner_Industry__c + '\' AND Market_Specialization_Level__c != null AND Market_Specialization_Level__c != \'None\' LIMIT 1)';
                holdQuery += ' FROM Account a WHERE Id IN (Select Account__c From Technology_Specialization__c where Technology_Specialization_Level__c != \'Open\' AND (Community_Type__c = \'Value Added Reseller\' OR Community_Type__c = \'eTailer\' OR Community_Type__c = \'Direct Market Reseller\' OR Community_Type__c = \'Carrier\') AND Partner_Program__r.Status__c = \'Active\'';
                holdQuery += (isEmpty(this.stage.Partner_Technology__c))?'':' AND Technology_Specialization__c = \'' + this.stage.Partner_Technology__c + '\'';
                holdQuery += (isEmpty(this.stage.Partner_Technology__c))?' AND Program__c IN '+searchTrack : ''; // Added By Sathish for Separation Day 1
                holdQuery += ') AND Id IN (Select Account__c FROM Partner_Location__c WHERE Location_Publish_Flag__c = true AND (Federal_Status__c != \'Federal Only Location\')';
                holdQuery += (isEmpty(this.stage.Partner_Region__c))?'':' AND Account__r.Partner_Region__c = \'' + regionMap.get(this.stage.Partner_Region__c) + '\'';
                holdQuery += (isEmpty(this.stage.Partner_Country__c))?'':' AND Country1__c = \'' + this.stage.Partner_Country__c + '\'';
                holdQuery += (isEmpty(this.stage.Partner_State__c))?'':' AND State__c = \'' + this.stage.Partner_State__c + '\'';
                holdQuery += ') AND RecordTypeId = \'' + this.recordTypeId + '\' AND Partner_Locator_Status__c = \'Active\' AND (Hierarchy_Placement__c = \'Global Account\' OR Hierarchy_Placement__c = \'Regional Account\' OR Hierarchy_Placement__c = \'Regional Subsidiary Account\'';
                holdQuery += (!this.stage.Partner_Mego__c)?')':') AND MEGO_Status__c != null';
                this.partnerQueries.add(new PartnerQuery(QueryType.CHANNEL_APP, holdQuery));

                holdQuery = 'Select Id';
                holdQuery += (!this.stage.Partner_Authorized_Service_Center__c)?'':', (Select Id FROM Partner_Types__r WHERE Authorized_Service_Center__c = true LIMIT 1)';
                holdQuery += (isEmpty(this.stage.Partner_Industry__c))?'':', (Select Id FROM Market_Specializations__r WHERE Market_Specialization__c = \'' + this.stage.Partner_Industry__c + '\' AND Market_Specialization_Level__c != null AND Market_Specialization_Level__c != \'None\' LIMIT 1)';
                holdQuery += ' FROM Account a WHERE Id IN (Select Account__c From Technology_Specialization__c where Technology_Specialization_Level__c != \'Open\' AND (Community_Type__c = \'Application Partner\') AND Partner_Program__r.Status__c = \'Active\'';
                holdQuery += (isEmpty(this.stage.Partner_Technology__c))?'':' AND Technology_Specialization__c = \'' + this.stage.Partner_Technology__c + '\'';                
                holdQuery += (isEmpty(this.stage.Partner_Technology__c))? ' AND Program__c IN '+searchTrack : ''; // Added By Sathish for Separation Day 1
                holdQuery += ') AND Id IN (Select Account__c FROM Partner_Location__c WHERE Location_Publish_Flag__c = true AND (Federal_Status__c != \'Federal Only Location\')';
                holdQuery += (isEmpty(this.stage.Partner_Region__c))?'':' AND Account__r.Partner_Region__c = \'' + regionMap.get(this.stage.Partner_Region__c) + '\'';
                holdQuery += (isEmpty(this.stage.Partner_Country__c))?'':' AND Country1__c = \'' + this.stage.Partner_Country__c + '\'';
                holdQuery += (isEmpty(this.stage.Partner_State__c))?'':' AND State__c = \'' + this.stage.Partner_State__c + '\'';
                holdQuery += ') AND RecordTypeId = \'' + this.recordTypeId + '\' AND Partner_Locator_Status__c = \'Active\' AND (Hierarchy_Placement__c = \'Global Account\' OR Hierarchy_Placement__c = \'Regional Account\' OR Hierarchy_Placement__c = \'Regional Subsidiary Account\'';
                holdQuery += (!this.stage.Partner_Mego__c)?')':') AND MEGO_Status__c != null';
                this.partnerQueries.add(new PartnerQuery(QueryType.CHANNEL_APP2, holdQuery));
            }
            
            if(regionMap.get(this.stage.Partner_Region__c) != 'US Federal' && this.stage.Partner_Industry__c == 'US Federal'){
                holdQuery = 'Select Id';
                holdQuery += (isEmpty(this.stage.Partner_Industry__c))?'':', (Select Id FROM Market_Specializations__r WHERE Market_Specialization__c = \'' + this.stage.Partner_Industry__c + '\' AND Market_Specialization_Level__c != null AND Market_Specialization_Level__c != \'None\' LIMIT 1)';
                holdQuery += ' FROM Account a WHERE Id IN (Select Account__c From Technology_Specialization__c where Technology_Specialization_Level__c != \'Open\' AND Community_Type__c = \'Application Partner\' AND Partner_Program__r.Status__c = \'Active\' AND Partner_Program__r.US_Federal__c = true';
                holdQuery += (isEmpty(this.stage.Partner_Technology__c))?'':' AND Technology_Specialization__c = \'' + this.stage.Partner_Technology__c + '\'';
                // Added By Sathish for Separation Day 1
                holdQuery += (isEmpty(this.stage.Partner_Technology__c))?' AND Program__c IN '+searchTrack : ''; 
                //Ends  
                holdQuery += ') AND Id IN (Select Account__c FROM Partner_Location__c WHERE Location_Publish_Flag__c = true AND (Federal_Status__c = \'Federal Only Location\' OR Federal_Status__c = \'Federal and Non-Federal Location\')';
                holdQuery += (isEmpty(this.stage.Partner_Region__c))?'':' AND Account__r.Partner_Region__c = \'' + regionMap.get(this.stage.Partner_Region__c) + '\'';
                holdQuery += (isEmpty(this.stage.Partner_Country__c))?'':' AND Country1__c = \'' + this.stage.Partner_Country__c + '\'';
                holdQuery += (isEmpty(this.stage.Partner_State__c))?'':' AND State__c = \'' + this.stage.Partner_State__c + '\'';
                holdQuery += ') AND RecordTypeId = \'' + this.recordTypeId + '\' AND Partner_Locator_Status__c = \'Active\' AND (Hierarchy_Placement__c = \'Global Account\' OR Hierarchy_Placement__c = \'Regional Account\' OR Hierarchy_Placement__c = \'Regional Subsidiary Account\')';
                this.partnerQueries.add(new PartnerQuery(QueryType.APP_PARTNER, holdQuery));

                holdQuery = 'Select Id';
                holdQuery += (isEmpty(this.stage.Partner_Industry__c))?'':', (Select Id FROM Market_Specializations__r WHERE Market_Specialization__c = \'' + this.stage.Partner_Industry__c + '\' AND Market_Specialization_Level__c != null AND Market_Specialization_Level__c != \'None\' LIMIT 1)';
                holdQuery += ' FROM Account a WHERE Id IN (Select Account__c From Technology_Specialization__c where Technology_Specialization_Level__c != \'Open\' AND (Community_Type__c = \'Value Added Reseller\' OR Community_Type__c = \'eTailer\' OR Community_Type__c = \'Direct Market Reseller\' OR Community_Type__c = \'Carrier\') AND Partner_Program__r.Status__c = \'Active\' AND Partner_Program__r.US_Federal__c = true';
                holdQuery += (isEmpty(this.stage.Partner_Technology__c))?'':' AND Technology_Specialization__c = \'' + this.stage.Partner_Technology__c + '\'';
                // Added By Sathish for Separation Day 1
                holdQuery += (isEmpty(this.stage.Partner_Technology__c))?' AND Program__c IN '+searchTrack : ''; 
                //Ends  
                holdQuery += ') AND Id IN (Select Account__c FROM Partner_Location__c WHERE Location_Publish_Flag__c = true AND (Federal_Status__c = \'Federal Only Location\' OR Federal_Status__c = \'Federal and Non-Federal Location\')';
                holdQuery += (isEmpty(this.stage.Partner_Region__c))?'':' AND Account__r.Partner_Region__c = \'' + regionMap.get(this.stage.Partner_Region__c) + '\'';
                holdQuery += (isEmpty(this.stage.Partner_Country__c))?'':' AND Country1__c = \'' + this.stage.Partner_Country__c + '\'';
                holdQuery += (isEmpty(this.stage.Partner_State__c))?'':' AND State__c = \'' + this.stage.Partner_State__c + '\'';
                holdQuery += ') AND RecordTypeId = \'' + this.recordTypeId + '\' AND Partner_Locator_Status__c = \'Active\' AND (Hierarchy_Placement__c = \'Global Account\' OR Hierarchy_Placement__c = \'Regional Account\' OR Hierarchy_Placement__c = \'Regional Subsidiary Account\')';
                this.partnerQueries.add(new PartnerQuery(QueryType.CHANNEL_APP, holdQuery));
                
                holdQuery = 'Select Id';
                holdQuery += (isEmpty(this.stage.Partner_Industry__c))?'':', (Select Id FROM Market_Specializations__r WHERE Market_Specialization__c = \'' + this.stage.Partner_Industry__c + '\' AND Market_Specialization_Level__c != null AND Market_Specialization_Level__c != \'None\' LIMIT 1)';
                holdQuery += ' FROM Account a WHERE Id IN (Select Account__c From Technology_Specialization__c where Technology_Specialization_Level__c != \'Open\' AND (Community_Type__c = \'Application Partner\') AND Partner_Program__r.Status__c = \'Active\' AND Partner_Program__r.US_Federal__c = true';
                holdQuery += (isEmpty(this.stage.Partner_Technology__c))?'':' AND Technology_Specialization__c = \'' + this.stage.Partner_Technology__c + '\'';
                // Added By Sathish for Separation Day 1
                holdQuery += (isEmpty(this.stage.Partner_Technology__c))?' AND Program__c IN '+searchTrack : ''; 
                //Ends  
                holdQuery += ') AND Id IN (Select Account__c FROM Partner_Location__c WHERE Location_Publish_Flag__c = true AND (Federal_Status__c = \'Federal Only Location\' OR Federal_Status__c = \'Federal and Non-Federal Location\')';
                holdQuery += (isEmpty(this.stage.Partner_Region__c))?'':' AND Account__r.Partner_Region__c = \'' + regionMap.get(this.stage.Partner_Region__c) + '\'';
                holdQuery += (isEmpty(this.stage.Partner_Country__c))?'':' AND Country1__c = \'' + this.stage.Partner_Country__c + '\'';
                holdQuery += (isEmpty(this.stage.Partner_State__c))?'':' AND State__c = \'' + this.stage.Partner_State__c + '\'';
                holdQuery += ') AND RecordTypeId = \'' + this.recordTypeId + '\' AND Partner_Locator_Status__c = \'Active\' AND (Hierarchy_Placement__c = \'Global Account\' OR Hierarchy_Placement__c = \'Regional Account\' OR Hierarchy_Placement__c = \'Regional Subsidiary Account\')';
                this.partnerQueries.add(new PartnerQuery(QueryType.CHANNEL_APP2, holdQuery));
                
                holdQuery = 'Select Id';
                holdQuery += (isEmpty(this.stage.Partner_Industry__c))?'':', (Select Id FROM Market_Specializations__r WHERE Market_Specialization__c = \'' + this.stage.Partner_Industry__c + '\' AND Market_Specialization_Level__c != null AND Market_Specialization_Level__c != \'None\' LIMIT 1)';
                holdQuery += ' FROM Account a WHERE Id IN (Select Account__c From Technology_Specialization__c where Technology_Specialization_Level__c != \'Open\' AND Partner_Program__r.US_Federal__c = true AND (Community_Type__c = \'Value Added Distributor\' OR Community_Type__c = \'Sub-Distributor\') AND Partner_Program__r.Status__c = \'Active\'';
                // Added By Sathish for Separation Day 1
                holdQuery += (isEmpty(this.stage.Partner_Technology__c))?' AND Program__c IN '+searchTrack : ''; 
                //Ends  
                holdQuery += ') AND Id IN (Select Account__c FROM Partner_Location__c WHERE Location_Publish_Flag__c = true';
                holdQuery += (isEmpty(this.stage.Partner_Region__c))?'':' AND Account__r.Partner_Region__c = \'' + regionMap.get(this.stage.Partner_Region__c) + '\'';
                holdQuery += (isEmpty(this.stage.Partner_Country__c))?'':' AND Country1__c = \'' + this.stage.Partner_Country__c + '\'';
                holdQuery += (isEmpty(this.stage.Partner_State__c))?'':' AND State__c = \'' + this.stage.Partner_State__c + '\'';
                holdQuery += ' AND (Federal_Status__c = \'Federal Only Location\' OR Federal_Status__c = \'Federal and Non-Federal Location\')) AND RecordTypeId = \'' + this.recordTypeId + '\' AND Partner_Locator_Status__c = \'Active\' AND (Hierarchy_Placement__c = \'Global Account\' OR Hierarchy_Placement__c = \'Regional Account\' OR Hierarchy_Placement__c = \'Regional Subsidiary Account\')';
                this.partnerQueries.add(new PartnerQuery(QueryType.DISTRIBUTOR, holdQuery));
                
                if(isEmpty(this.stage.Partner_Technology__c)){
                    holdQuery = 'Select Id';
                    holdQuery += (isEmpty(this.stage.Partner_Industry__c))?'':', (Select Id FROM Market_Specializations__r WHERE Market_Specialization__c = \'' + this.stage.Partner_Industry__c + '\' AND Market_Specialization_Level__c != null AND Market_Specialization_Level__c != \'None\' LIMIT 1)';
                    holdQuery += ' FROM Account a WHERE Id IN (Select Account__c From Technology_Specialization__c where Technology_Specialization_Level__c != \'Open\' AND (Community_Type__c = \'Value Added Reseller\' OR Community_Type__c = \'eTailer\' OR Community_Type__c = \'Direct Market Reseller\' OR Community_Type__c = \'Carrier\') AND Partner_Program__r.Status__c = \'Active\' AND Partner_Program__r.US_Federal__c = true';
                    // Added By Sathish for Separation Day 1
                    holdQuery += (isEmpty(this.stage.Partner_Technology__c))?' AND Program__c IN '+searchTrack : ''; 
                    //Ends  
                    holdQuery += ') AND Id IN (Select Account__c FROM Partner_Location__c WHERE Location_Publish_Flag__c = true AND (Federal_Status__c = \'Federal Only Location\' OR Federal_Status__c = \'Federal and Non-Federal Location\')';
                    holdQuery += (isEmpty(this.stage.Partner_Country__c))?'':' AND Country1__c = \'' + this.stage.Partner_Country__c + '\'';
                    holdQuery += (isEmpty(this.stage.Partner_State__c))?'':' AND State__c = \'' + this.stage.Partner_State__c + '\'';
                    holdQuery += ') AND RecordTypeId = \'' + this.recordTypeId + '\' AND Partner_Locator_Status__c = \'Active\' AND (Hierarchy_Placement__c = \'Global Account\' OR Hierarchy_Placement__c = \'Regional Account\' OR Hierarchy_Placement__c = \'Regional Subsidiary Account\')';
                    this.partnerQueries.add(new PartnerQuery(QueryType.CHANNEL_PARTNER, holdQuery));
                }
            }           
            if(!isEmpty(this.stage.Partner_Technology__c) && this.stage.Partner_Industry__c == 'US Federal'){
                holdQuery = 'Select Id';
                holdQuery += (isEmpty(this.stage.Partner_Industry__c))?'':', (Select Id FROM Market_Specializations__r WHERE Market_Specialization__c = \'' + this.stage.Partner_Industry__c + '\' AND MM_Sort_Order__c = 1 AND Market_Specialization_Level__c != null AND Market_Specialization_Level__c != \'None\' LIMIT 1)';
                holdQuery += ' FROM Account a WHERE Id IN (Select Account__c From Technology_Specialization__c where Technology_Specialization_Level__c != \'Open\' AND (Community_Type__c = \'Value Added Reseller\' OR Community_Type__c = \'eTailer\' OR Community_Type__c = \'Direct Market Reseller\' OR Community_Type__c = \'Carrier\') AND Partner_Program__r.Status__c = \'Active\' AND Partner_Program__r.US_Federal__c = true';
                holdQuery += ' AND Technology_Specialization__c = \'' + this.stage.Partner_Technology__c + '\'';
                holdQuery += ') AND Id IN (Select Account__c FROM Partner_Location__c WHERE Location_Publish_Flag__c = true AND (Federal_Status__c = \'Federal Only Location\' OR Federal_Status__c = \'Federal and Non-Federal Location\')';
                holdQuery += (isEmpty(this.stage.Partner_Country__c))?'':' AND Country1__c = \'' + this.stage.Partner_Country__c + '\'';
                holdQuery += (isEmpty(this.stage.Partner_State__c))?'':' AND State__c = \'' + this.stage.Partner_State__c + '\'';
                holdQuery += ' AND Account__r.Partner_Region__c = \'' + regionMap.get(this.stage.Partner_Region__c) + '\'';
                holdQuery += ') AND RecordTypeId = \'' + this.recordTypeId + '\' AND Partner_Locator_Status__c = \'Active\' AND (Hierarchy_Placement__c = \'Global Account\' OR Hierarchy_Placement__c = \'Regional Account\' OR Hierarchy_Placement__c = \'Regional Subsidiary Account\')';
                this.partnerQueries.add(new PartnerQuery(QueryType.CHANNEL_PARTNER, holdQuery));

                holdQuery = 'Select Id';
                holdQuery += (isEmpty(this.stage.Partner_Industry__c))?'':', (Select Id FROM Market_Specializations__r WHERE Market_Specialization__c = \'' + this.stage.Partner_Industry__c + '\' AND MM_Sort_Order__c = 2 AND Market_Specialization_Level__c != null AND Market_Specialization_Level__c != \'None\' LIMIT 1)';
                holdQuery += ' FROM Account a WHERE Id IN (Select Account__c From Technology_Specialization__c where Technology_Specialization_Level__c != \'Open\' AND (Community_Type__c = \'Value Added Reseller\' OR Community_Type__c = \'eTailer\' OR Community_Type__c = \'Direct Market Reseller\' OR Community_Type__c = \'Carrier\') AND Partner_Program__r.Status__c = \'Active\' AND Partner_Program__r.US_Federal__c = true';
                holdQuery += ' AND Technology_Specialization__c = \'' + this.stage.Partner_Technology__c + '\'';
                holdQuery += ') AND Id IN (Select Account__c FROM Partner_Location__c WHERE Location_Publish_Flag__c = true AND (Federal_Status__c = \'Federal Only Location\' OR Federal_Status__c = \'Federal and Non-Federal Location\')';
                holdQuery += (isEmpty(this.stage.Partner_Country__c))?'':' AND Country1__c = \'' + this.stage.Partner_Country__c + '\'';
                holdQuery += (isEmpty(this.stage.Partner_State__c))?'':' AND State__c = \'' + this.stage.Partner_State__c + '\'';
                holdQuery += ' AND Account__r.Partner_Region__c = \'' + regionMap.get(this.stage.Partner_Region__c) + '\'';
                holdQuery += ') AND RecordTypeId = \'' + this.recordTypeId + '\' AND Partner_Locator_Status__c = \'Active\' AND (Hierarchy_Placement__c = \'Global Account\' OR Hierarchy_Placement__c = \'Regional Account\' OR Hierarchy_Placement__c = \'Regional Subsidiary Account\')';
                this.partnerQueries.add(new PartnerQuery(QueryType.CHANNEL_PARTNER, holdQuery));

                holdQuery = 'Select Id';
                holdQuery += (isEmpty(this.stage.Partner_Industry__c))?'':', (Select Id FROM Market_Specializations__r WHERE Market_Specialization__c = \'' + this.stage.Partner_Industry__c + '\' AND MM_Sort_Order__c != 1 AND MM_Sort_Order__c != 2 AND Market_Specialization_Level__c != null AND Market_Specialization_Level__c != \'None\' LIMIT 1)';
                holdQuery += ' FROM Account a WHERE Id IN (Select Account__c From Technology_Specialization__c where Technology_Specialization_Level__c != \'Open\' AND (Community_Type__c = \'Value Added Reseller\' OR Community_Type__c = \'eTailer\' OR Community_Type__c = \'Direct Market Reseller\' OR Community_Type__c = \'Carrier\') AND Partner_Program__r.Status__c = \'Active\' AND Partner_Program__r.US_Federal__c = true';
                holdQuery += ' AND Technology_Specialization__c = \'' + this.stage.Partner_Technology__c + '\'';
                holdQuery += ') AND Id IN (Select Account__c FROM Partner_Location__c WHERE Location_Publish_Flag__c = true AND (Federal_Status__c = \'Federal Only Location\' OR Federal_Status__c = \'Federal and Non-Federal Location\')';
                holdQuery += (isEmpty(this.stage.Partner_Country__c))?'':' AND Country1__c = \'' + this.stage.Partner_Country__c + '\'';
                holdQuery += (isEmpty(this.stage.Partner_State__c))?'':' AND State__c = \'' + this.stage.Partner_State__c + '\'';
                holdQuery += ' AND Account__r.Partner_Region__c = \'' + regionMap.get(this.stage.Partner_Region__c) + '\'';
                holdQuery += ') AND RecordTypeId = \'' + this.recordTypeId + '\' AND Partner_Locator_Status__c = \'Active\' AND (Hierarchy_Placement__c = \'Global Account\' OR Hierarchy_Placement__c = \'Regional Account\' OR Hierarchy_Placement__c = \'Regional Subsidiary Account\')';
                this.partnerQueries.add(new PartnerQuery(QueryType.CHANNEL_PARTNER2, holdQuery));

                holdQuery = 'Select Id';
                holdQuery += (isEmpty(this.stage.Partner_Industry__c))?'':', (Select Id FROM Market_Specializations__r WHERE Market_Specialization__c = \'' + this.stage.Partner_Industry__c + '\' AND Market_Specialization_Level__c != null AND Market_Specialization_Level__c != \'None\' LIMIT 1)';
                holdQuery += ' FROM Account a WHERE Id IN (Select Account__c From Technology_Specialization__c where Technology_Specialization_Level__c != \'Open\' AND Partner_Program__r.US_Federal__c = true AND (Community_Type__c = \'Value Added Distributor\' OR Community_Type__c = \'Sub-Distributor\') AND Partner_Program__r.Status__c = \'Active\' AND Partner_Program__r.US_Federal__c = true';
                holdQuery += ' AND Technology_Specialization__c = \'' + this.stage.Partner_Technology__c + '\'';
                holdQuery += ') AND Id IN (Select Account__c FROM Partner_Location__c WHERE Location_Publish_Flag__c = true AND (Federal_Status__c = \'Federal Only Location\' OR Federal_Status__c = \'Federal and Non-Federal Location\')';
                holdQuery += (isEmpty(this.stage.Partner_Country__c))?'':' AND Country1__c = \'' + this.stage.Partner_Country__c + '\'';
                holdQuery += (isEmpty(this.stage.Partner_State__c))?'':' AND State__c = \'' + this.stage.Partner_State__c + '\'';
                holdQuery += ' AND Account__r.Partner_Region__c = \'' + regionMap.get(this.stage.Partner_Region__c) + '\'';
                holdQuery += ' AND (Federal_Status__c = \'Federal Only Location\' OR Federal_Status__c = \'Federal and Non-Federal Location\')) AND RecordTypeId = \'' + this.recordTypeId + '\' AND Partner_Locator_Status__c = \'Active\' AND (Hierarchy_Placement__c = \'Global Account\' OR Hierarchy_Placement__c = \'Regional Account\' OR Hierarchy_Placement__c = \'Regional Subsidiary Account\')';
                this.partnerQueries.add(new PartnerQuery(QueryType.DISTRIBUTOR, holdQuery));
            }
            if(regionMap.get(this.stage.Partner_Region__c) == 'APAC' && this.stage.Partner_Industry__c != 'US Federal'){
                if(isEmpty(this.stage.Partner_Technology__c)){
                    if(this.stage.E_or_G__c != 'E'){ // Added by Sathish
                        holdQuery = 'Select Id, (Select Id FROM Product_Offered__r WHERE Product_Offering__c = \'SCADA\' AND Publish_Flag__c = true)';
                        holdQuery += (isEmpty(this.stage.Partner_Industry__c))?'':', (Select Id FROM Market_Specializations__r WHERE Market_Specialization__c = \'' + this.stage.Partner_Industry__c + '\' AND Market_Specialization_Level__c != null AND Market_Specialization_Level__c != \'None\' LIMIT 1)';
                        holdQuery += ' FROM Account a WHERE Id IN (Select Account__c From Partner_Type__c where Program__c = \'SCADA\' AND Status__c = \'Active\' AND Partner_Level__c != \'Distributor\') AND Id IN (Select Account__c FROM Partner_Location__c WHERE Location_Publish_Flag__c = true AND Federal_Status__c != \'Federal Only Location\'';
                        holdQuery += (isEmpty(this.stage.Partner_Country__c))?'':' AND Country1__c = \'' + this.stage.Partner_Country__c + '\'';
                        holdQuery += ' AND Account__r.Partner_Region__c = \'' + regionMap.get(this.stage.Partner_Region__c) + '\'';
                        holdQuery += ') AND RecordTypeId = \'' + this.recordTypeId + '\' AND Partner_Locator_Status__c = \'Active\' AND (Hierarchy_Placement__c = \'Global Account\' OR Hierarchy_Placement__c = \'Regional Account\' OR Hierarchy_Placement__c = \'Regional Subsidiary Account\')';
                        this.partnerQueries.add(new PartnerQuery(QueryType.CHANNEL_PARTNER, holdQuery));
                    }
                    
                    holdQuery = 'Select Id';
                    holdQuery += (!this.stage.Partner_Authorized_Service_Center__c)?'':', (Select Id FROM Partner_Types__r WHERE Authorized_Service_Center__c = true LIMIT 1)';
                    holdQuery += (isEmpty(this.stage.Partner_Industry__c))?'':', (Select Id FROM Market_Specializations__r WHERE Market_Specialization__c = \'' + this.stage.Partner_Industry__c + '\' AND Market_Specialization_Level__c != null AND Market_Specialization_Level__c != \'None\' LIMIT 1)';
                    holdQuery += ' FROM Account a WHERE Id IN (Select Account__c From Technology_Specialization__c where Technology_Specialization_Level__c != \'Open\' AND (Community_Type__c = \'Value Added Reseller\' OR Community_Type__c = \'eTailer\' OR Community_Type__c = \'Direct Market Reseller\' OR Community_Type__c = \'Carrier\') AND Partner_Program__r.Status__c = \'Active\'';
                    // Added By Sathish for Separation Day 1
                    holdQuery += (isEmpty(this.stage.Partner_Technology__c))?' AND Program__c IN '+searchTrack : ''; 
                    //Ends  
                    holdQuery += ') AND Id IN (Select Account__c FROM Partner_Location__c WHERE Location_Publish_Flag__c = true AND Federal_Status__c != \'Federal Only Location\'';
                    holdQuery += ' AND Account__r.Partner_Region__c = \'' + regionMap.get(this.stage.Partner_Region__c) + '\'';
                    holdQuery += (isEmpty(this.stage.Partner_Country__c))?'':' AND Country1__c = \'' + this.stage.Partner_Country__c + '\'';
                    holdQuery += ') AND RecordTypeId = \'' + this.recordTypeId + '\' AND Partner_Locator_Status__c = \'Active\' AND (Hierarchy_Placement__c = \'Global Account\' OR Hierarchy_Placement__c = \'Regional Account\' OR Hierarchy_Placement__c = \'Regional Subsidiary Account\'';
                    holdQuery += (!this.stage.Partner_Mego__c)?')':') AND MEGO_Status__c != null';
                    this.partnerQueries.add(new PartnerQuery(QueryType.CHANNEL_PARTNER, holdQuery));
                    
                    if(this.stage.E_or_G__c != 'E'){ // Added by Sathish 
                        holdQuery = 'Select Id, (Select Id FROM Product_Offered__r WHERE Product_Offering__c = \'SCADA\' AND Publish_Flag__c = true LIMIT 1)';
                        holdQuery += (isEmpty(this.stage.Partner_Industry__c))?'':', (Select Id FROM Market_Specializations__r WHERE Market_Specialization__c = \'' + this.stage.Partner_Industry__c + '\' AND Market_Specialization_Level__c != null AND Market_Specialization_Level__c != \'None\' LIMIT 1)';
                        holdQuery += ' FROM Account a WHERE Id IN (Select Account__c From Partner_Type__c where Program__c = \'SCADA\' AND Status__c = \'Active\' AND Partner_Level__c = \'Distributor\') AND Id IN (Select Account__c FROM Partner_Location__c WHERE Location_Publish_Flag__c = true AND Federal_Status__c != \'Federal Only Location\'';
                        holdQuery += (isEmpty(this.stage.Partner_Country__c))?'':' AND Country1__c = \'' + this.stage.Partner_Country__c + '\'';
                        holdQuery += ' AND Account__r.Partner_Region__c = \'' + regionMap.get(this.stage.Partner_Region__c) + '\'';
                        holdQuery += ') AND RecordTypeId = \'' + this.recordTypeId + '\' AND Partner_Locator_Status__c = \'Active\' AND (Hierarchy_Placement__c = \'Global Account\' OR Hierarchy_Placement__c = \'Regional Account\' OR Hierarchy_Placement__c = \'Regional Subsidiary Account\')';
                        this.partnerQueries.add(new PartnerQuery(QueryType.DISTRIBUTOR, holdQuery));
                    }

                    holdQuery = 'Select Id';
                    holdQuery += (!this.stage.Partner_Authorized_Service_Center__c)?'':', (Select Id FROM Partner_Types__r WHERE Authorized_Service_Center__c = true LIMIT 1)';
                    holdQuery += (isEmpty(this.stage.Partner_Industry__c))?'':', (Select Id FROM Market_Specializations__r WHERE Market_Specialization__c = \'' + this.stage.Partner_Industry__c + '\' AND Market_Specialization_Level__c != null AND Market_Specialization_Level__c != \'None\' LIMIT 1)';
                    holdQuery += ' FROM Account a WHERE Id IN (Select Account__c From Technology_Specialization__c where Technology_Specialization_Level__c != \'Open\' AND (Community_Type__c = \'Value Added Distributor\' OR Community_Type__c = \'Sub-Distributor\') AND Partner_Program__r.Status__c = \'Active\'';
                    // Added By Sathish for Separation Day 1
                    holdQuery += (isEmpty(this.stage.Partner_Technology__c))?' AND Program__c IN '+searchTrack : ''; 
                    //Ends  
                    holdQuery += ') AND Id IN (Select Account__c FROM Partner_Location__c WHERE Location_Publish_Flag__c = true AND Federal_Status__c != \'Federal Only Location\'';
                    holdQuery += ' AND Account__r.Partner_Region__c = \'' + regionMap.get(this.stage.Partner_Region__c) + '\'';
                    holdQuery += (isEmpty(this.stage.Partner_Country__c))?'':' AND Country1__c = \'' + this.stage.Partner_Country__c + '\'';
                    holdQuery += ') AND RecordTypeId = \'' + this.recordTypeId + '\' AND Partner_Locator_Status__c = \'Active\' AND (Hierarchy_Placement__c = \'Global Account\' OR Hierarchy_Placement__c = \'Regional Account\' OR Hierarchy_Placement__c = \'Regional Subsidiary Account\'';
                    holdQuery += (!this.stage.Partner_Mego__c)?')':') AND MEGO_Status__c != null';
                    this.partnerQueries.add(new PartnerQuery(QueryType.DISTRIBUTOR, holdQuery));
                }else{
                    if(this.stage.Partner_Technology__c == 'SCADA'){
                        holdQuery = 'Select Id, (Select Id FROM Product_Offered__r WHERE Product_Offering__c = \'SCADA\' AND Publish_Flag__c = true LIMIT 1)';
                        holdQuery += (isEmpty(this.stage.Partner_Industry__c))?'':', (Select Id FROM Market_Specializations__r WHERE Market_Specialization__c = \'' + this.stage.Partner_Industry__c + '\' AND Market_Specialization_Level__c != null AND Market_Specialization_Level__c != \'None\' LIMIT 1)';
                        holdQuery += ' FROM Account a WHERE Id IN (Select Account__c From Partner_Type__c where Program__c = \'SCADA\' AND Status__c = \'Active\' AND Partner_Level__c != \'Distributor\') AND Id IN (Select Account__c FROM Partner_Location__c WHERE Location_Publish_Flag__c = true AND Federal_Status__c != \'Federal Only Location\'';
                        holdQuery += (isEmpty(this.stage.Partner_Country__c))?'':' AND Country1__c = \'' + this.stage.Partner_Country__c + '\'';
                        holdQuery += ' AND Account__r.Partner_Region__c = \'' + regionMap.get(this.stage.Partner_Region__c) + '\'';
                        holdQuery += ') AND RecordTypeId = \'' + this.recordTypeId + '\' AND Partner_Locator_Status__c = \'Active\' AND (Hierarchy_Placement__c = \'Global Account\' OR Hierarchy_Placement__c = \'Regional Account\' OR Hierarchy_Placement__c = \'Regional Subsidiary Account\')';
                        this.partnerQueries.add(new PartnerQuery(QueryType.CHANNEL_PARTNER, holdQuery));

                        holdQuery = 'Select Id, (Select Id FROM Product_Offered__r WHERE Product_Offering__c = \'SCADA\' AND Publish_Flag__c = true LIMIT 1)';
                        holdQuery += (isEmpty(this.stage.Partner_Industry__c))?'':', (Select Id FROM Market_Specializations__r WHERE Market_Specialization__c = \'' + this.stage.Partner_Industry__c + '\' AND Market_Specialization_Level__c != null AND Market_Specialization_Level__c != \'None\' LIMIT 1)';
                        holdQuery += ' FROM Account a WHERE Id IN (Select Account__c From Partner_Type__c where Program__c = \'SCADA\' AND Status__c = \'Active\' AND Partner_Level__c = \'Distributor\') AND Id IN (Select Account__c FROM Partner_Location__c WHERE Location_Publish_Flag__c = true AND Federal_Status__c != \'Federal Only Location\'';
                        holdQuery += (isEmpty(this.stage.Partner_Country__c))?'':' AND Country1__c = \'' + this.stage.Partner_Country__c + '\'';
                        holdQuery += ' AND Account__r.Partner_Region__c = \'' + regionMap.get(this.stage.Partner_Region__c) + '\'';
                        holdQuery += ') AND RecordTypeId = \'' + this.recordTypeId + '\' AND Partner_Locator_Status__c = \'Active\' AND (Hierarchy_Placement__c = \'Global Account\' OR Hierarchy_Placement__c = \'Regional Account\' OR Hierarchy_Placement__c = \'Regional Subsidiary Account\')';
                        this.partnerQueries.add(new PartnerQuery(QueryType.DISTRIBUTOR, holdQuery));
                    }else{
                        holdQuery = 'Select Id';
                        holdQuery += (!this.stage.Partner_Authorized_Service_Center__c)?'':', (Select Id FROM Partner_Types__r WHERE Authorized_Service_Center__c = true LIMIT 1)';
                        holdQuery += (isEmpty(this.stage.Partner_Industry__c))?'':', (Select Id FROM Market_Specializations__r WHERE Market_Specialization__c = \'' + this.stage.Partner_Industry__c + '\' AND Market_Specialization_Level__c != null AND Market_Specialization_Level__c != \'None\' LIMIT 1)';
                        holdQuery += ' FROM Account a WHERE Id IN (Select Account__c From Technology_Specialization__c where Technology_Specialization_Level__c != \'Open\' AND (Community_Type__c = \'Value Added Reseller\' OR Community_Type__c = \'eTailer\' OR Community_Type__c = \'Direct Market Reseller\' OR Community_Type__c = \'Carrier\') AND Partner_Program__r.Status__c = \'Active\'';
                        holdQuery += (isEmpty(this.stage.Partner_Technology__c))?'':' AND Technology_Specialization__c = \'' + this.stage.Partner_Technology__c + '\' AND MM_Sort_Order__C = 1';
                        holdQuery += ') AND Id IN (Select Account__c FROM Partner_Location__c WHERE Location_Publish_Flag__c = true AND Federal_Status__c != \'Federal Only Location\'';
                        holdQuery += ' AND Account__r.Partner_Region__c = \'' + regionMap.get(this.stage.Partner_Region__c) + '\'';
                        holdQuery += (isEmpty(this.stage.Partner_Country__c))?'':' AND Country1__c = \'' + this.stage.Partner_Country__c + '\'';
                        holdQuery += ') AND RecordTypeId = \'' + this.recordTypeId + '\' AND Partner_Locator_Status__c = \'Active\' AND (Hierarchy_Placement__c = \'Global Account\' OR Hierarchy_Placement__c = \'Regional Account\' OR Hierarchy_Placement__c = \'Regional Subsidiary Account\'';
                        holdQuery += (!this.stage.Partner_Mego__c)?')':') AND MEGO_Status__c != null';
                        this.partnerQueries.add(new PartnerQuery(QueryType.CHANNEL_PARTNER, holdQuery));

                        holdQuery = 'Select Id';
                        holdQuery += (!this.stage.Partner_Authorized_Service_Center__c)?'':', (Select Id FROM Partner_Types__r WHERE Authorized_Service_Center__c = true LIMIT 1)';
                        holdQuery += (isEmpty(this.stage.Partner_Industry__c))?'':', (Select Id FROM Market_Specializations__r WHERE Market_Specialization__c = \'' + this.stage.Partner_Industry__c + '\' AND Market_Specialization_Level__c != null AND Market_Specialization_Level__c != \'None\' LIMIT 1)';
                        holdQuery += ' FROM Account a WHERE Id IN (Select Account__c From Technology_Specialization__c where Technology_Specialization_Level__c != \'Open\' AND (Community_Type__c = \'Value Added Reseller\' OR Community_Type__c = \'eTailer\' OR Community_Type__c = \'Direct Market Reseller\' OR Community_Type__c = \'Carrier\') AND Partner_Program__r.Status__c = \'Active\'';
                        holdQuery += (isEmpty(this.stage.Partner_Technology__c))?'':' AND Technology_Specialization__c = \'' + this.stage.Partner_Technology__c + '\' AND MM_Sort_Order__C = 2';
                        holdQuery += ') AND Id IN (Select Account__c FROM Partner_Location__c WHERE Location_Publish_Flag__c = true AND Federal_Status__c != \'Federal Only Location\'';
                        holdQuery += ' AND Account__r.Partner_Region__c = \'' + regionMap.get(this.stage.Partner_Region__c) + '\'';
                        holdQuery += (isEmpty(this.stage.Partner_Country__c))?'':' AND Country1__c = \'' + this.stage.Partner_Country__c + '\'';
                        holdQuery += ') AND RecordTypeId = \'' + this.recordTypeId + '\' AND Partner_Locator_Status__c = \'Active\' AND (Hierarchy_Placement__c = \'Global Account\' OR Hierarchy_Placement__c = \'Regional Account\' OR Hierarchy_Placement__c = \'Regional Subsidiary Account\'';
                        holdQuery += (!this.stage.Partner_Mego__c)?')':') AND MEGO_Status__c != null';
                        this.partnerQueries.add(new PartnerQuery(QueryType.CHANNEL_PARTNER, holdQuery));

                        holdQuery = 'Select Id';
                        holdQuery += (!this.stage.Partner_Authorized_Service_Center__c)?'':', (Select Id FROM Partner_Types__r WHERE Authorized_Service_Center__c = true LIMIT 1)';
                        holdQuery += (isEmpty(this.stage.Partner_Industry__c))?'':', (Select Id FROM Market_Specializations__r WHERE Market_Specialization__c = \'' + this.stage.Partner_Industry__c + '\' AND Market_Specialization_Level__c != null AND Market_Specialization_Level__c != \'None\' LIMIT 1)';
                        holdQuery += ' FROM Account a WHERE Id IN (Select Account__c From Technology_Specialization__c where Technology_Specialization_Level__c != \'Open\' AND (Community_Type__c = \'Value Added Reseller\' OR Community_Type__c = \'eTailer\' OR Community_Type__c = \'Direct Market Reseller\' OR Community_Type__c = \'Carrier\') AND Partner_Program__r.Status__c = \'Active\'';
                        holdQuery += (isEmpty(this.stage.Partner_Technology__c))?'':' AND Technology_Specialization__c = \'' + this.stage.Partner_Technology__c + '\' AND MM_Sort_Order__C != 1 AND MM_Sort_Order__C != 2';
                        holdQuery += ') AND Id IN (Select Account__c FROM Partner_Location__c WHERE Location_Publish_Flag__c = true AND Federal_Status__c != \'Federal Only Location\'';
                        holdQuery += ' AND Account__r.Partner_Region__c = \'' + regionMap.get(this.stage.Partner_Region__c) + '\'';
                        holdQuery += (isEmpty(this.stage.Partner_Country__c))?'':' AND Country1__c = \'' + this.stage.Partner_Country__c + '\'';
                        holdQuery += ') AND RecordTypeId = \'' + this.recordTypeId + '\' AND Partner_Locator_Status__c = \'Active\' AND (Hierarchy_Placement__c = \'Global Account\' OR Hierarchy_Placement__c = \'Regional Account\' OR Hierarchy_Placement__c = \'Regional Subsidiary Account\'';
                        holdQuery += (!this.stage.Partner_Mego__c)?')':') AND MEGO_Status__c != null';
                        this.partnerQueries.add(new PartnerQuery(QueryType.CHANNEL_PARTNER2, holdQuery));

                        holdQuery = 'Select Id';
                        holdQuery += (!this.stage.Partner_Authorized_Service_Center__c)?'':', (Select Id FROM Partner_Types__r WHERE Authorized_Service_Center__c = true LIMIT 1)';
                        holdQuery += (isEmpty(this.stage.Partner_Industry__c))?'':', (Select Id FROM Market_Specializations__r WHERE Market_Specialization__c = \'' + this.stage.Partner_Industry__c + '\' AND Market_Specialization_Level__c != null AND Market_Specialization_Level__c != \'None\' LIMIT 1)';
                        holdQuery += ' FROM Account a WHERE Id IN (Select Account__c From Technology_Specialization__c where Technology_Specialization_Level__c != \'Open\' AND (Community_Type__c = \'Value Added Distributor\' OR Community_Type__c = \'Sub-Distributor\') AND Partner_Program__r.Status__c = \'Active\'';
                        holdQuery += (isEmpty(this.stage.Partner_Technology__c))?'':' AND Technology_Specialization__c = \'' + this.stage.Partner_Technology__c + '\'';
                        holdQuery += ') AND Id IN (Select Account__c FROM Partner_Location__c WHERE Location_Publish_Flag__c = true AND Federal_Status__c != \'Federal Only Location\'';
                        holdQuery += ' AND Account__r.Partner_Region__c = \'' + regionMap.get(this.stage.Partner_Region__c) + '\'';
                        holdQuery += (isEmpty(this.stage.Partner_Country__c))?'':' AND Country1__c = \'' + this.stage.Partner_Country__c + '\'';
                        holdQuery += ') AND RecordTypeId = \'' + this.recordTypeId + '\' AND Partner_Locator_Status__c = \'Active\' AND (Hierarchy_Placement__c = \'Global Account\' OR Hierarchy_Placement__c = \'Regional Account\' OR Hierarchy_Placement__c = \'Regional Subsidiary Account\'';
                        holdQuery += (!this.stage.Partner_Mego__c)?')':') AND MEGO_Status__c != null';
                        this.partnerQueries.add(new PartnerQuery(QueryType.DISTRIBUTOR, holdQuery));
                    }
                }
            }
            if(regionMap.get(this.stage.Partner_Region__c) == 'LACR' && this.stage.Partner_Industry__c != 'US Federal'){
                holdQuery = 'Select Id';
                holdQuery += (isEmpty(this.stage.Partner_Industry__c))?'':', (Select Id FROM Market_Specializations__r WHERE Market_Specialization__c = \'' + this.stage.Partner_Industry__c + '\' AND Market_Specialization_Level__c != null AND Market_Specialization_Level__c != \'None\' LIMIT 1)';
                holdQuery += ' FROM Account a WHERE Id IN (Select Account__c From Technology_Specialization__c where Technology_Specialization_Level__c != \'Open\' AND Community_Type__c = \'Application Partner\' AND Partner_Program__r.Status__c = \'Active\'';
                holdQuery += (isEmpty(this.stage.Partner_Technology__c))?'':' AND Technology_Specialization__c = \'' + this.stage.Partner_Technology__c + '\'';
                // Added By Sathish for Separation Day 1
                holdQuery += (isEmpty(this.stage.Partner_Technology__c))?' AND Program__c IN '+searchTrack : ''; 
                //Ends  
                holdQuery += (isEmpty(this.stage.Partner_Region__c))?'':' AND Region__c = \'' + regionMap.get(this.stage.Partner_Region__c) + '\'';
                holdQuery += (isEmpty(this.stage.Partner_Country__c))?'':' AND Country__c INCLUDES (\'' + this.stage.Partner_Country__c + '\')';
                holdQuery += ') AND Id IN (Select Account__c FROM Partner_Location__c WHERE Location_Publish_Flag__c = true AND Federal_Status__c != \'Federal Only Location\'';
                holdQuery += ') AND RecordTypeId = \'' + this.recordTypeId + '\' AND Partner_Locator_Status__c = \'Active\' AND (Hierarchy_Placement__c = \'Global Account\' OR Hierarchy_Placement__c = \'Regional Account\' OR Hierarchy_Placement__c = \'Regional Subsidiary Account\')';
                this.partnerQueries.add(new PartnerQuery(QueryType.APP_PARTNER, holdQuery));
                
                holdQuery = 'Select Id, (Select Id from Sales_Territory__r WHERE Country__c INCLUDES (\'All LACR Countries\'))';
                holdQuery += (isEmpty(this.stage.Partner_Industry__c))?'':', (Select Id FROM Market_Specializations__r WHERE Market_Specialization__c = \'' + this.stage.Partner_Industry__c + '\' AND Market_Specialization_Level__c != null AND Market_Specialization_Level__c != \'None\' LIMIT 1)';
                holdQuery += ' FROM Account a WHERE Id IN (Select Account__c From Technology_Specialization__c where Technology_Specialization_Level__c != \'Open\' AND Community_Type__c = \'Application Partner\' AND Partner_Program__r.Status__c = \'Active\'';
                // Added By Sathish for Separation Day 1
                holdQuery += (isEmpty(this.stage.Partner_Technology__c))?' AND Program__c IN '+searchTrack : ''; 
                //Ends  
                holdQuery += (isEmpty(this.stage.Partner_Technology__c))?'':' AND Technology_Specialization__c = \'' + this.stage.Partner_Technology__c + '\'';
                holdQuery += (isEmpty(this.stage.Partner_Region__c))?'':' AND Region__c = \'' + regionMap.get(this.stage.Partner_Region__c) + '\'';
                holdQuery += ') AND Id IN (Select Account__c FROM Partner_Location__c WHERE Location_Publish_Flag__c = true AND Federal_Status__c != \'Federal Only Location\'';
                holdQuery += ') AND RecordTypeId = \'' + this.recordTypeId + '\' AND Partner_Locator_Status__c = \'Active\' AND (Hierarchy_Placement__c = \'Global Account\' OR Hierarchy_Placement__c = \'Regional Account\' OR Hierarchy_Placement__c = \'Regional Subsidiary Account\')';
                this.partnerQueries.add(new PartnerQuery(QueryType.APP_PARTNER, holdQuery));
                
                holdQuery = 'Select Id';
                holdQuery += (isEmpty(this.stage.Partner_Industry__c))?'':', (Select Id FROM Market_Specializations__r WHERE Market_Specialization__c = \'' + this.stage.Partner_Industry__c + '\' AND Market_Specialization_Level__c != null AND Market_Specialization_Level__c != \'None\' LIMIT 1)';
                holdQuery += ' FROM Account a WHERE Id IN (Select Account__c From Technology_Specialization__c where Technology_Specialization_Level__c != \'Open\' AND (Community_Type__c = \'Value Added Reseller\' OR Community_Type__c = \'eTailer\' OR Community_Type__c = \'Direct Market Reseller\' OR Community_Type__c = \'Carrier\')';
                holdQuery += (isEmpty(this.stage.Partner_Region__c))?'':' AND Region__c = \'' + regionMap.get(this.stage.Partner_Region__c) + '\'';
                holdQuery += (isEmpty(this.stage.Partner_Country__c))?'':' AND (Country__c INCLUDES (\'All LACR Countries\') OR Country__c INCLUDES (\'' + this.stage.Partner_Country__c + '\'))';
                holdQuery += ' AND Partner_Program__r.Status__c = \'Active\'';
                holdQuery += (isEmpty(this.stage.Partner_Technology__c))?'':' AND Technology_Specialization__c = \'' + this.stage.Partner_Technology__c + '\'';
                // Added By Sathish for Separation Day 1
                holdQuery += (isEmpty(this.stage.Partner_Technology__c))?' AND Program__c IN '+searchTrack : ''; 
                //Ends  
                holdQuery += ') AND Id IN (Select Account__c FROM Partner_Location__c WHERE Location_Publish_Flag__c = true AND Federal_Status__c != \'Federal Only Location\'';
                holdQuery += ') AND RecordTypeId = \'' + this.recordTypeId + '\' AND Partner_Locator_Status__c = \'Active\' AND (Hierarchy_Placement__c = \'Global Account\' OR Hierarchy_Placement__c = \'Regional Account\' OR Hierarchy_Placement__c = \'Regional Subsidiary Account\')';
                this.partnerQueries.add(new PartnerQuery(QueryType.CHANNEL_APP, holdQuery));
                
                holdQuery = 'Select Id';
                holdQuery += (isEmpty(this.stage.Partner_Industry__c))?'':', (Select Id FROM Market_Specializations__r WHERE Market_Specialization__c = \'' + this.stage.Partner_Industry__c + '\' AND Market_Specialization_Level__c != null AND Market_Specialization_Level__c != \'None\' LIMIT 1)';
                holdQuery += ' FROM Account a WHERE Id IN (Select Account__c From Technology_Specialization__c where Technology_Specialization_Level__c != \'Open\' AND Community_Type__c = \'Application Partner\'';
                holdQuery += (isEmpty(this.stage.Partner_Region__c))?'':' AND Region__c = \'' + regionMap.get(this.stage.Partner_Region__c) + '\'';
                holdQuery += (isEmpty(this.stage.Partner_Country__c))?'':' AND (Country__c INCLUDES (\'All LACR Countries\') OR Country__c INCLUDES (\'' + this.stage.Partner_Country__c + '\'))';
                holdQuery += ' AND (Community_Type__c = \'Application Partner\') AND Partner_Program__r.Status__c = \'Active\'';
                holdQuery += (isEmpty(this.stage.Partner_Technology__c))?'':' AND Technology_Specialization__c = \'' + this.stage.Partner_Technology__c + '\'';
                // Added By Sathish for Separation Day 1
                holdQuery += (isEmpty(this.stage.Partner_Technology__c))?' AND Program__c IN '+searchTrack : ''; 
                //Ends  
                holdQuery += ') AND Id IN (Select Account__c FROM Partner_Location__c WHERE Location_Publish_Flag__c = true AND Federal_Status__c != \'Federal Only Location\'';
                holdQuery += ') AND RecordTypeId = \'' + this.recordTypeId + '\' AND Partner_Locator_Status__c = \'Active\' AND (Hierarchy_Placement__c = \'Global Account\' OR Hierarchy_Placement__c = \'Regional Account\' OR Hierarchy_Placement__c = \'Regional Subsidiary Account\')';
                this.partnerQueries.add(new PartnerQuery(QueryType.CHANNEL_APP2, holdQuery));
                
                if(isEmpty(this.stage.Partner_Technology__c)){
                    if(this.stage.E_or_G__c != 'E'){ // Added by Sathish 
                        holdQuery = 'Select Id, (Select Id FROM Product_Offered__r WHERE Product_Offering__c = \'SCADA\' AND Publish_Flag__c = true LIMIT 1), (Select Id From Partner_Types__r where Program__c = \'SCADA\' AND Status__c = \'Active\' AND Partner_Level__c != \'Distributor\' LIMIT 1)';
                        holdQuery += (isEmpty(this.stage.Partner_Industry__c))?'':', (Select Id FROM Market_Specializations__r WHERE Market_Specialization__c = \'' + this.stage.Partner_Industry__c + '\' AND Market_Specialization_Level__c != null AND Market_Specialization_Level__c != \'None\' LIMIT 1)';
                        holdQuery += ' FROM Account a WHERE Id IN (Select Account__c FROM Partner_Location__c WHERE Location_Publish_Flag__c = true AND Federal_Status__c != \'Federal Only Location\'';
                        holdQuery += ') AND Id IN (Select Account__c FROM Sales_Territory__c WHERE Region__c = \'LACR\'';
                        holdQuery += (isEmpty(this.stage.Partner_Country__c))?'':' AND (Country__c INCLUDES (\'All LACR Countries\') OR Country__c INCLUDES (\'' + this.stage.Partner_Country__c + '\'))';
                        holdQuery += ') AND RecordTypeId = \'' + this.recordTypeId + '\' AND Partner_Locator_Status__c = \'Active\' AND (Hierarchy_Placement__c = \'Global Account\' OR Hierarchy_Placement__c = \'Regional Account\' OR Hierarchy_Placement__c = \'Regional Subsidiary Account\')';
                        this.partnerQueries.add(new PartnerQuery(QueryType.CHANNEL_PARTNER, holdQuery));
                    }
                 
                 //Added  By Chanu  for the ****Incident INC0139828  // added for LACR Radio System Integrator *******
                     if(this.stage.E_or_G__c != 'E'){
                    holdQuery = 'Select Id';
                    holdQuery += (isEmpty(this.stage.Partner_Industry__c))?'':', (Select Id FROM Market_Specializations__r WHERE Market_Specialization__c = \'' + this.stage.Partner_Industry__c + '\' AND Market_Specialization_Level__c != null AND Market_Specialization_Level__c != \'None\' LIMIT 1)';
                    holdQuery += ' FROM Account a WHERE Id IN (Select Account__c From Technology_Specialization__c where Technology_Specialization_Level__c != \'Open\' AND (Community_Type__c = \'Systems Integrator\' OR Community_Type__c = \'Value Added Reseller\' OR Community_Type__c = \'eTailer\' OR Community_Type__c = \'Direct Market Reseller\' OR Community_Type__c = \'Carrier\') AND Partner_Program__r.Status__c = \'Active\'';
                    holdQuery += (isEmpty(this.stage.Partner_Technology__c))?' AND Program__c IN '+searchTrack : ''; 
                    holdQuery += (isEmpty(this.stage.Partner_Region__c))?'':' AND Region__c = \'' + regionMap.get(this.stage.Partner_Region__c) + '\'';
                    holdQuery += (isEmpty(this.stage.Partner_Country__c))?'':' AND Country__c INCLUDES (\'' + this.stage.Partner_Country__c + '\')';
                    holdQuery += ') AND Id IN (Select Account__c FROM Partner_Location__c WHERE Location_Publish_Flag__c = true AND Federal_Status__c != \'Federal Only Location\'';
                    holdQuery += ') AND RecordTypeId = \'' + this.recordTypeId + '\' AND Partner_Locator_Status__c = \'Active\' AND (Hierarchy_Placement__c = \'Global Account\' OR Hierarchy_Placement__c = \'Regional Account\' OR Hierarchy_Placement__c = \'Regional Subsidiary Account\')';
                    this.partnerQueries.add(new PartnerQuery(QueryType.CHANNEL_PARTNER, holdQuery));
                    
                    
                    holdQuery = 'Select Id, (Select Id from Sales_Territory__r WHERE Country__c INCLUDES (\'All LACR Countries\') LIMIT 1)';
                    holdQuery += (isEmpty(this.stage.Partner_Industry__c))?'':', (Select Id FROM Market_Specializations__r WHERE Market_Specialization__c = \'' + this.stage.Partner_Industry__c + '\' AND Market_Specialization_Level__c != null AND Market_Specialization_Level__c != \'None\' LIMIT 1)';
                    holdQuery += ' FROM Account a WHERE Id IN (Select Account__c From Technology_Specialization__c where Technology_Specialization_Level__c != \'Open\' AND (Community_Type__c = \'Systems Integrator\' OR Community_Type__c = \'Value Added Reseller\' OR Community_Type__c = \'eTailer\' OR Community_Type__c = \'Direct Market Reseller\' OR Community_Type__c = \'Carrier\') AND Partner_Program__r.Status__c = \'Active\'';
                    holdQuery += (isEmpty(this.stage.Partner_Region__c))?'':' AND Region__c = \'' + regionMap.get(this.stage.Partner_Region__c) + '\'';
                    holdQuery += (isEmpty(this.stage.Partner_Technology__c))?' AND Program__c IN '+searchTrack : ''; 
                    holdQuery += ') AND Id IN (Select Account__c FROM Partner_Location__c WHERE Location_Publish_Flag__c = true AND Federal_Status__c != \'Federal Only Location\'';
                    holdQuery += ') AND RecordTypeId = \'' + this.recordTypeId + '\' AND Partner_Locator_Status__c = \'Active\' AND (Hierarchy_Placement__c = \'Global Account\' OR Hierarchy_Placement__c = \'Regional Account\' OR Hierarchy_Placement__c = \'Regional Subsidiary Account\')';
                    this.partnerQueries.add(new PartnerQuery(QueryType.CHANNEL_PARTNER, holdQuery));
                    
                    }// End of Additions
                        
                    
                    holdQuery = 'Select Id';
                    holdQuery += (isEmpty(this.stage.Partner_Industry__c))?'':', (Select Id FROM Market_Specializations__r WHERE Market_Specialization__c = \'' + this.stage.Partner_Industry__c + '\' AND Market_Specialization_Level__c != null AND Market_Specialization_Level__c != \'None\' LIMIT 1)';
                    holdQuery += ' FROM Account a WHERE Id IN (Select Account__c From Technology_Specialization__c where Technology_Specialization_Level__c != \'Open\' AND (Community_Type__c = \'Value Added Reseller\' OR Community_Type__c = \'eTailer\' OR Community_Type__c = \'Direct Market Reseller\' OR Community_Type__c = \'Carrier\') AND Partner_Program__r.Status__c = \'Active\'';
                    // Added By Sathish for Separation Day 1
                    holdQuery += (isEmpty(this.stage.Partner_Technology__c))?' AND Program__c IN '+searchTrack : ''; 
                    //Ends  
                    holdQuery += (isEmpty(this.stage.Partner_Region__c))?'':' AND Region__c = \'' + regionMap.get(this.stage.Partner_Region__c) + '\'';
                    holdQuery += (isEmpty(this.stage.Partner_Country__c))?'':' AND Country__c INCLUDES (\'' + this.stage.Partner_Country__c + '\')';
                    holdQuery += ') AND Id IN (Select Account__c FROM Partner_Location__c WHERE Location_Publish_Flag__c = true AND Federal_Status__c != \'Federal Only Location\'';
                    holdQuery += ') AND RecordTypeId = \'' + this.recordTypeId + '\' AND Partner_Locator_Status__c = \'Active\' AND (Hierarchy_Placement__c = \'Global Account\' OR Hierarchy_Placement__c = \'Regional Account\' OR Hierarchy_Placement__c = \'Regional Subsidiary Account\')';
                    this.partnerQueries.add(new PartnerQuery(QueryType.CHANNEL_PARTNER, holdQuery));

                    holdQuery = 'Select Id, (Select Id from Sales_Territory__r WHERE Country__c INCLUDES (\'All LACR Countries\') LIMIT 1)';
                    holdQuery += (isEmpty(this.stage.Partner_Industry__c))?'':', (Select Id FROM Market_Specializations__r WHERE Market_Specialization__c = \'' + this.stage.Partner_Industry__c + '\' AND Market_Specialization_Level__c != null AND Market_Specialization_Level__c != \'None\' LIMIT 1)';
                    holdQuery += ' FROM Account a WHERE Id IN (Select Account__c From Technology_Specialization__c where Technology_Specialization_Level__c != \'Open\' AND (Community_Type__c = \'Value Added Reseller\' OR Community_Type__c = \'eTailer\' OR Community_Type__c = \'Direct Market Reseller\' OR Community_Type__c = \'Carrier\') AND Partner_Program__r.Status__c = \'Active\'';
                    holdQuery += (isEmpty(this.stage.Partner_Region__c))?'':' AND Region__c = \'' + regionMap.get(this.stage.Partner_Region__c) + '\'';
                    // Added By Sathish for Separation Day 1
                    holdQuery += (isEmpty(this.stage.Partner_Technology__c))?' AND Program__c IN '+searchTrack : ''; 
                    //Ends  
                    holdQuery += ') AND Id IN (Select Account__c FROM Partner_Location__c WHERE Location_Publish_Flag__c = true AND Federal_Status__c != \'Federal Only Location\'';
                    holdQuery += ') AND RecordTypeId = \'' + this.recordTypeId + '\' AND Partner_Locator_Status__c = \'Active\' AND (Hierarchy_Placement__c = \'Global Account\' OR Hierarchy_Placement__c = \'Regional Account\' OR Hierarchy_Placement__c = \'Regional Subsidiary Account\')';
                    this.partnerQueries.add(new PartnerQuery(QueryType.CHANNEL_PARTNER, holdQuery));
                    
                    if(this.stage.E_or_G__c != 'E'){ // Added by Sathish 
                        holdQuery = 'Select Id, (Select Id From Partner_Types__r where Program__c = \'SCADA\' AND Status__c = \'Active\' AND Partner_Level__c = \'Distributor\' LIMIT 1), (Select Id FROM Product_Offered__r WHERE Product_Offering__c = \'SCADA\' AND Publish_Flag__c = true LIMIT 1)';
                        holdQuery += (isEmpty(this.stage.Partner_Industry__c))?'':', (Select Id FROM Market_Specializations__r WHERE Market_Specialization__c = \'' + this.stage.Partner_Industry__c + '\' AND Market_Specialization_Level__c != null AND Market_Specialization_Level__c != \'None\' LIMIT 1)';
                        holdQuery += ' FROM Account a WHERE Id IN (Select Account__c FROM Partner_Location__c WHERE Location_Publish_Flag__c = true AND Federal_Status__c != \'Federal Only Location\'';
                        holdQuery += ') AND Id IN (Select Account__c FROM Sales_Territory__c WHERE Region__c = \'LACR\' AND Technology_Segment__c INCLUDES (\'SCADA\')';
                        holdQuery += (isEmpty(this.stage.Partner_Country__c))?'':' AND Country__c INCLUDES (\'' + this.stage.Partner_Country__c + '\')';
                        holdQuery += ') AND RecordTypeId = \'' + this.recordTypeId + '\' AND Partner_Locator_Status__c = \'Active\' AND (Hierarchy_Placement__c = \'Global Account\' OR Hierarchy_Placement__c = \'Regional Account\' OR Hierarchy_Placement__c = \'Regional Subsidiary Account\')';
                        this.partnerQueries.add(new PartnerQuery(QueryType.DISTRIBUTOR, holdQuery));
                    }
                    
                    holdQuery = 'Select Id';
                    holdQuery += (isEmpty(this.stage.Partner_Industry__c))?'':', (Select Id FROM Market_Specializations__r WHERE Market_Specialization__c = \'' + this.stage.Partner_Industry__c + '\' AND Market_Specialization_Level__c != null AND Market_Specialization_Level__c != \'None\' LIMIT 1)';
                    holdQuery += ' FROM Account a WHERE Id IN (Select Account__c From Technology_Specialization__c where Technology_Specialization_Level__c != \'Open\' AND (Community_Type__c = \'Value Added Distributor\' OR Community_Type__c = \'Sub-Distributor\') AND Partner_Program__r.Status__c = \'Active\'';
                    holdQuery += (isEmpty(this.stage.Partner_Region__c))?'':' AND Region__c = \'' + regionMap.get(this.stage.Partner_Region__c) + '\'';
                    holdQuery += (isEmpty(this.stage.Partner_Country__c))?'':' AND Country__c INCLUDES (\'' + this.stage.Partner_Country__c + '\')';
                    // Added By Sathish for Separation Day 1
                    holdQuery += (isEmpty(this.stage.Partner_Technology__c))?' AND Program__c IN '+searchTrack : ''; 
                    //Ends  
                    holdQuery += ') AND Id IN (Select Account__c FROM Partner_Location__c WHERE Location_Publish_Flag__c = true AND Federal_Status__c != \'Federal Only Location\'';
                    holdQuery += ') AND RecordTypeId = \'' + this.recordTypeId + '\' AND Partner_Locator_Status__c = \'Active\' AND (Hierarchy_Placement__c = \'Global Account\' OR Hierarchy_Placement__c = \'Regional Account\' OR Hierarchy_Placement__c = \'Regional Subsidiary Account\')';
                    this.partnerQueries.add(new PartnerQuery(QueryType.DISTRIBUTOR, holdQuery));
                }else{
                    if(this.stage.Partner_Technology__c == 'SCADA'){
                        holdQuery = 'Select Id, (Select Id From Partner_Types__r where Program__c = \'SCADA\' AND Status__c = \'Active\' AND Partner_Level__c != \'Distributor\' LIMIT 1), (Select Id FROM Product_Offered__r WHERE Product_Offering__c = \'SCADA\' AND Publish_Flag__c = true LIMIT 1)';
                        holdQuery += (isEmpty(this.stage.Partner_Industry__c))?'':', (Select Id FROM Market_Specializations__r WHERE Market_Specialization__c = \'' + this.stage.Partner_Industry__c + '\' AND Market_Specialization_Level__c != null AND Market_Specialization_Level__c != \'None\' LIMIT 1)';
                        holdQuery += ' FROM Account a WHERE Id IN (Select Account__c FROM Partner_Location__c WHERE Location_Publish_Flag__c = true AND Federal_Status__c != \'Federal Only Location\'';
                        holdQuery += ') AND Id IN (Select Account__c FROM Sales_Territory__c WHERE Region__c = \'LACR\'';
                        holdQuery += (isEmpty(this.stage.Partner_Technology__c))?'':' AND Technology_Segment__c INCLUDES (\'' + this.stage.Partner_Technology__c + '\')';
                        holdQuery += (isEmpty(this.stage.Partner_Country__c))?'':' AND (Country__c INCLUDES (\'All LACR Countries\') OR Country__c INCLUDES (\'' + this.stage.Partner_Country__c + '\'))';
                        holdQuery += ') AND RecordTypeId = \'' + this.recordTypeId + '\' AND Partner_Locator_Status__c = \'Active\' AND (Hierarchy_Placement__c = \'Global Account\' OR Hierarchy_Placement__c = \'Regional Account\' OR Hierarchy_Placement__c = \'Regional Subsidiary Account\')';
                        this.partnerQueries.add(new PartnerQuery(QueryType.CHANNEL_PARTNER, holdQuery));

                        holdQuery = 'Select Id, (Select Id From Partner_Types__r where Program__c = \'SCADA\' AND Status__c = \'Active\' AND Partner_Level__c = \'Distributor\' LIMIT 1), (Select Id FROM Product_Offered__r WHERE Product_Offering__c = \'SCADA\' AND Publish_Flag__c = true LIMIT 1)';
                        holdQuery += (isEmpty(this.stage.Partner_Industry__c))?'':', (Select Id FROM Market_Specializations__r WHERE Market_Specialization__c = \'' + this.stage.Partner_Industry__c + '\' AND Market_Specialization_Level__c != null AND Market_Specialization_Level__c != \'None\' LIMIT 1)';
                        holdQuery += ' FROM Account a WHERE Id IN (Select Account__c FROM Partner_Location__c WHERE Location_Publish_Flag__c = true AND Federal_Status__c != \'Federal Only Location\'';
                        holdQuery += ') AND Id IN (Select Account__c FROM Sales_Territory__c WHERE Region__c = \'LACR\'';
                        holdQuery += (isEmpty(this.stage.Partner_Technology__c))?'':' AND Technology_Segment__c INCLUDES (\'' + this.stage.Partner_Technology__c + '\')';
                        holdQuery += (isEmpty(this.stage.Partner_Country__c))?'':' AND (Country__c INCLUDES (\'All LACR Countries\') OR Country__c INCLUDES (\'' + this.stage.Partner_Country__c + '\'))';
                        holdQuery += ') AND RecordTypeId = \'' + this.recordTypeId + '\' AND Partner_Locator_Status__c = \'Active\' AND (Hierarchy_Placement__c = \'Global Account\' OR Hierarchy_Placement__c = \'Regional Account\' OR Hierarchy_Placement__c = \'Regional Subsidiary Account\')';
                        this.partnerQueries.add(new PartnerQuery(QueryType.DISTRIBUTOR, holdQuery));
                    }else{
                     
                          //Added  By Chanu  for the ****Incident INC0139828  // added for LACR Radio System Integrator ******* : Code added for all technology 
                        if(this.stage.E_or_G__c != 'E'){
                        holdQuery = 'Select Id';
                        holdQuery += (isEmpty(this.stage.Partner_Industry__c))?'':', (Select Id FROM Market_Specializations__r WHERE Market_Specialization__c = \'' + this.stage.Partner_Industry__c + '\' AND Market_Specialization_Level__c != null AND Market_Specialization_Level__c != \'None\' LIMIT 1)';
                        holdQuery += ' FROM Account a WHERE Id IN (Select Account__c From Technology_Specialization__c where Technology_Specialization_Level__c != \'Open\' AND ( Community_Type__c = \'Systems Integrator\' OR Community_Type__c = \'Value Added Reseller\' OR Community_Type__c = \'eTailer\' OR Community_Type__c = \'Direct Market Reseller\' OR Community_Type__c = \'Carrier\') AND Partner_Program__r.Status__c = \'Active\'';
                        holdQuery += (isEmpty(this.stage.Partner_Technology__c))?'':' AND Technology_Specialization__c = \'' + this.stage.Partner_Technology__c + '\' AND MM_Sort_Order__C = 1';
                        holdQuery += (isEmpty(this.stage.Partner_Region__c))?'':' AND Region__c = \'' + regionMap.get(this.stage.Partner_Region__c) + '\'';
                        holdQuery += (isEmpty(this.stage.Partner_Country__c))?'':' AND Country__c INCLUDES (\'' + this.stage.Partner_Country__c + '\')';
                        holdQuery += ') AND Id IN (Select Account__c FROM Partner_Location__c WHERE Location_Publish_Flag__c = true AND Federal_Status__c != \'Federal Only Location\'';
                        holdQuery += ') AND RecordTypeId = \'' + this.recordTypeId + '\' AND Partner_Locator_Status__c = \'Active\' AND (Hierarchy_Placement__c = \'Global Account\' OR Hierarchy_Placement__c = \'Regional Account\' OR Hierarchy_Placement__c = \'Regional Subsidiary Account\')';
                        this.partnerQueries.add(new PartnerQuery(QueryType.CHANNEL_PARTNER, holdQuery));

                        holdQuery = 'Select Id';
                        holdQuery += (isEmpty(this.stage.Partner_Industry__c))?'':', (Select Id FROM Market_Specializations__r WHERE Market_Specialization__c = \'' + this.stage.Partner_Industry__c + '\' AND Market_Specialization_Level__c != null AND Market_Specialization_Level__c != \'None\' LIMIT 1)';
                        holdQuery += ' FROM Account a WHERE Id IN (Select Account__c From Technology_Specialization__c where Technology_Specialization_Level__c != \'Open\' AND (Community_Type__c = \'Systems Integrator\' OR Community_Type__c = \'Value Added Reseller\' OR Community_Type__c = \'eTailer\' OR Community_Type__c = \'Direct Market Reseller\' OR Community_Type__c = \'Carrier\') AND Partner_Program__r.Status__c = \'Active\'';
                        holdQuery += (isEmpty(this.stage.Partner_Technology__c))?'':' AND Technology_Specialization__c = \'' + this.stage.Partner_Technology__c + '\' AND MM_Sort_Order__C = 2';
                        holdQuery += (isEmpty(this.stage.Partner_Region__c))?'':' AND Region__c = \'' + regionMap.get(this.stage.Partner_Region__c) + '\'';
                        holdQuery += (isEmpty(this.stage.Partner_Country__c))?'':' AND Country__c INCLUDES (\'' + this.stage.Partner_Country__c + '\')';
                        holdQuery += ') AND Id IN (Select Account__c FROM Partner_Location__c WHERE Location_Publish_Flag__c = true AND Federal_Status__c != \'Federal Only Location\'';
                        holdQuery += ') AND RecordTypeId = \'' + this.recordTypeId + '\' AND Partner_Locator_Status__c = \'Active\' AND (Hierarchy_Placement__c = \'Global Account\' OR Hierarchy_Placement__c = \'Regional Account\' OR Hierarchy_Placement__c = \'Regional Subsidiary Account\')';
                        this.partnerQueries.add(new PartnerQuery(QueryType.CHANNEL_PARTNER, holdQuery));
                       
                        holdQuery = 'Select Id';
                        holdQuery += (isEmpty(this.stage.Partner_Industry__c))?'':', (Select Id FROM Market_Specializations__r WHERE Market_Specialization__c = \'' + this.stage.Partner_Industry__c + '\' AND Market_Specialization_Level__c != null AND Market_Specialization_Level__c != \'None\' LIMIT 1)';
                        holdQuery += ' FROM Account a WHERE Id IN (Select Account__c From Technology_Specialization__c where Technology_Specialization_Level__c != \'Open\' AND (Community_Type__c = \'Systems Integrator\'OR Community_Type__c = \'Value Added Reseller\' OR Community_Type__c = \'eTailer\' OR Community_Type__c = \'Direct Market Reseller\' OR Community_Type__c = \'Carrier\') AND Partner_Program__r.Status__c = \'Active\'';
                        holdQuery += (isEmpty(this.stage.Partner_Technology__c))?'':' AND Technology_Specialization__c = \'' + this.stage.Partner_Technology__c + '\' AND MM_Sort_Order__C != 1 AND MM_Sort_Order__C != 2';
                        holdQuery += (isEmpty(this.stage.Partner_Region__c))?'':' AND Region__c = \'' + regionMap.get(this.stage.Partner_Region__c) + '\'';
                        holdQuery += (isEmpty(this.stage.Partner_Country__c))?'':' AND Country__c INCLUDES (\'' + this.stage.Partner_Country__c + '\')';
                        holdQuery += ') AND Id IN (Select Account__c FROM Partner_Location__c WHERE Location_Publish_Flag__c = true AND Federal_Status__c != \'Federal Only Location\'';
                        holdQuery += ') AND RecordTypeId = \'' + this.recordTypeId + '\' AND Partner_Locator_Status__c = \'Active\' AND (Hierarchy_Placement__c = \'Global Account\' OR Hierarchy_Placement__c = \'Regional Account\' OR Hierarchy_Placement__c = \'Regional Subsidiary Account\')';
                        this.partnerQueries.add(new PartnerQuery(QueryType.CHANNEL_PARTNER2, holdQuery));
                       
                        //***********Code added when Sort Order = Elite
                       
                        holdQuery = 'Select Id, (Select Id from Sales_Territory__r WHERE Country__c INCLUDES (\'All LACR Countries\') LIMIT 1)';
                        holdQuery += (isEmpty(this.stage.Partner_Industry__c))?'':', (Select Id FROM Market_Specializations__r WHERE Market_Specialization__c = \'' + this.stage.Partner_Industry__c + '\' AND Market_Specialization_Level__c != null AND Market_Specialization_Level__c != \'None\' LIMIT 1)';
                        holdQuery += ' FROM Account a WHERE Id IN (Select Account__c From Technology_Specialization__c where Technology_Specialization_Level__c != \'Open\' AND (Community_Type__c = \'Systems Integrator\'OR Community_Type__c = \'Value Added Reseller\' OR Community_Type__c = \'eTailer\' OR Community_Type__c = \'Direct Market Reseller\' OR Community_Type__c = \'Carrier\') AND Partner_Program__r.Status__c = \'Active\'';
                        holdQuery += (isEmpty(this.stage.Partner_Technology__c))?'':' AND Technology_Specialization__c = \'' + this.stage.Partner_Technology__c + '\' AND MM_Sort_Order__C = 1';
                        holdQuery += (isEmpty(this.stage.Partner_Region__c))?'':' AND Region__c = \'' + regionMap.get(this.stage.Partner_Region__c) + '\'';
                        holdQuery += ') AND Id IN (Select Account__c FROM Partner_Location__c WHERE Location_Publish_Flag__c = true AND Federal_Status__c != \'Federal Only Location\'';
                        holdQuery += ') AND RecordTypeId = \'' + this.recordTypeId + '\' AND Partner_Locator_Status__c = \'Active\' AND (Hierarchy_Placement__c = \'Global Account\' OR Hierarchy_Placement__c = \'Regional Account\' OR Hierarchy_Placement__c = \'Regional Subsidiary Account\')';
                        this.partnerQueries.add(new PartnerQuery(QueryType.CHANNEL_PARTNER, holdQuery));

                        holdQuery = 'Select Id, (Select Id from Sales_Territory__r WHERE Country__c INCLUDES (\'All LACR Countries\') LIMIT 1)';
                        holdQuery += (isEmpty(this.stage.Partner_Industry__c))?'':', (Select Id FROM Market_Specializations__r WHERE Market_Specialization__c = \'' + this.stage.Partner_Industry__c + '\' AND Market_Specialization_Level__c != null AND Market_Specialization_Level__c != \'None\' LIMIT 1)';
                        holdQuery += ' FROM Account a WHERE Id IN (Select Account__c From Technology_Specialization__c where Technology_Specialization_Level__c != \'Open\' AND (Community_Type__c = \'Systems Integrator\' OR Community_Type__c = \'Value Added Reseller\' OR Community_Type__c = \'eTailer\' OR Community_Type__c = \'Direct Market Reseller\' OR Community_Type__c = \'Carrier\') AND Partner_Program__r.Status__c = \'Active\'';
                        holdQuery += (isEmpty(this.stage.Partner_Technology__c))?'':' AND Technology_Specialization__c = \'' + this.stage.Partner_Technology__c + '\' AND MM_Sort_Order__C != 1';
                        holdQuery += (isEmpty(this.stage.Partner_Region__c))?'':' AND Region__c = \'' + regionMap.get(this.stage.Partner_Region__c) + '\'';
                        holdQuery += ') AND Id IN (Select Account__c FROM Partner_Location__c WHERE Location_Publish_Flag__c = true AND Federal_Status__c != \'Federal Only Location\'';
                        holdQuery += ') AND RecordTypeId = \'' + this.recordTypeId + '\' AND Partner_Locator_Status__c = \'Active\' AND (Hierarchy_Placement__c = \'Global Account\' OR Hierarchy_Placement__c = \'Regional Account\' OR Hierarchy_Placement__c = \'Regional Subsidiary Account\')';
                        this.partnerQueries.add(new PartnerQuery(QueryType.CHANNEL_PARTNER2, holdQuery));
                           
                        }// End of Addition
                     
                        holdQuery = 'Select Id';
                        holdQuery += (isEmpty(this.stage.Partner_Industry__c))?'':', (Select Id FROM Market_Specializations__r WHERE Market_Specialization__c = \'' + this.stage.Partner_Industry__c + '\' AND Market_Specialization_Level__c != null AND Market_Specialization_Level__c != \'None\' LIMIT 1)';
                        holdQuery += ' FROM Account a WHERE Id IN (Select Account__c From Technology_Specialization__c where Technology_Specialization_Level__c != \'Open\' AND (Community_Type__c = \'Value Added Reseller\' OR Community_Type__c = \'eTailer\' OR Community_Type__c = \'Direct Market Reseller\' OR Community_Type__c = \'Carrier\') AND Partner_Program__r.Status__c = \'Active\'';
                        holdQuery += (isEmpty(this.stage.Partner_Technology__c))?'':' AND Technology_Specialization__c = \'' + this.stage.Partner_Technology__c + '\' AND MM_Sort_Order__C = 1';
                        holdQuery += (isEmpty(this.stage.Partner_Region__c))?'':' AND Region__c = \'' + regionMap.get(this.stage.Partner_Region__c) + '\'';
                        holdQuery += (isEmpty(this.stage.Partner_Country__c))?'':' AND Country__c INCLUDES (\'' + this.stage.Partner_Country__c + '\')';
                        holdQuery += ') AND Id IN (Select Account__c FROM Partner_Location__c WHERE Location_Publish_Flag__c = true AND Federal_Status__c != \'Federal Only Location\'';
                        holdQuery += ') AND RecordTypeId = \'' + this.recordTypeId + '\' AND Partner_Locator_Status__c = \'Active\' AND (Hierarchy_Placement__c = \'Global Account\' OR Hierarchy_Placement__c = \'Regional Account\' OR Hierarchy_Placement__c = \'Regional Subsidiary Account\')';
                        this.partnerQueries.add(new PartnerQuery(QueryType.CHANNEL_PARTNER, holdQuery));

                        holdQuery = 'Select Id';
                        holdQuery += (isEmpty(this.stage.Partner_Industry__c))?'':', (Select Id FROM Market_Specializations__r WHERE Market_Specialization__c = \'' + this.stage.Partner_Industry__c + '\' AND Market_Specialization_Level__c != null AND Market_Specialization_Level__c != \'None\' LIMIT 1)';
                        holdQuery += ' FROM Account a WHERE Id IN (Select Account__c From Technology_Specialization__c where Technology_Specialization_Level__c != \'Open\' AND (Community_Type__c = \'Value Added Reseller\' OR Community_Type__c = \'eTailer\' OR Community_Type__c = \'Direct Market Reseller\' OR Community_Type__c = \'Carrier\') AND Partner_Program__r.Status__c = \'Active\'';
                        holdQuery += (isEmpty(this.stage.Partner_Technology__c))?'':' AND Technology_Specialization__c = \'' + this.stage.Partner_Technology__c + '\' AND MM_Sort_Order__C = 2';
                        holdQuery += (isEmpty(this.stage.Partner_Region__c))?'':' AND Region__c = \'' + regionMap.get(this.stage.Partner_Region__c) + '\'';
                        holdQuery += (isEmpty(this.stage.Partner_Country__c))?'':' AND Country__c INCLUDES (\'' + this.stage.Partner_Country__c + '\')';
                        holdQuery += ') AND Id IN (Select Account__c FROM Partner_Location__c WHERE Location_Publish_Flag__c = true AND Federal_Status__c != \'Federal Only Location\'';
                        holdQuery += ') AND RecordTypeId = \'' + this.recordTypeId + '\' AND Partner_Locator_Status__c = \'Active\' AND (Hierarchy_Placement__c = \'Global Account\' OR Hierarchy_Placement__c = \'Regional Account\' OR Hierarchy_Placement__c = \'Regional Subsidiary Account\')';
                        this.partnerQueries.add(new PartnerQuery(QueryType.CHANNEL_PARTNER, holdQuery));

                        holdQuery = 'Select Id';
                        holdQuery += (isEmpty(this.stage.Partner_Industry__c))?'':', (Select Id FROM Market_Specializations__r WHERE Market_Specialization__c = \'' + this.stage.Partner_Industry__c + '\' AND Market_Specialization_Level__c != null AND Market_Specialization_Level__c != \'None\' LIMIT 1)';
                        holdQuery += ' FROM Account a WHERE Id IN (Select Account__c From Technology_Specialization__c where Technology_Specialization_Level__c != \'Open\' AND (Community_Type__c = \'Value Added Reseller\' OR Community_Type__c = \'eTailer\' OR Community_Type__c = \'Direct Market Reseller\' OR Community_Type__c = \'Carrier\') AND Partner_Program__r.Status__c = \'Active\'';
                        holdQuery += (isEmpty(this.stage.Partner_Technology__c))?'':' AND Technology_Specialization__c = \'' + this.stage.Partner_Technology__c + '\' AND MM_Sort_Order__C != 1 AND MM_Sort_Order__C != 2';
                        holdQuery += (isEmpty(this.stage.Partner_Region__c))?'':' AND Region__c = \'' + regionMap.get(this.stage.Partner_Region__c) + '\'';
                        holdQuery += (isEmpty(this.stage.Partner_Country__c))?'':' AND Country__c INCLUDES (\'' + this.stage.Partner_Country__c + '\')';
                        holdQuery += ') AND Id IN (Select Account__c FROM Partner_Location__c WHERE Location_Publish_Flag__c = true AND Federal_Status__c != \'Federal Only Location\'';
                        holdQuery += ') AND RecordTypeId = \'' + this.recordTypeId + '\' AND Partner_Locator_Status__c = \'Active\' AND (Hierarchy_Placement__c = \'Global Account\' OR Hierarchy_Placement__c = \'Regional Account\' OR Hierarchy_Placement__c = \'Regional Subsidiary Account\')';
                        this.partnerQueries.add(new PartnerQuery(QueryType.CHANNEL_PARTNER2, holdQuery));

                        holdQuery = 'Select Id, (Select Id from Sales_Territory__r WHERE Country__c INCLUDES (\'All LACR Countries\') LIMIT 1)';
                        holdQuery += (isEmpty(this.stage.Partner_Industry__c))?'':', (Select Id FROM Market_Specializations__r WHERE Market_Specialization__c = \'' + this.stage.Partner_Industry__c + '\' AND Market_Specialization_Level__c != null AND Market_Specialization_Level__c != \'None\' LIMIT 1)';
                        holdQuery += ' FROM Account a WHERE Id IN (Select Account__c From Technology_Specialization__c where Technology_Specialization_Level__c != \'Open\' AND (Community_Type__c = \'Value Added Reseller\' OR Community_Type__c = \'eTailer\' OR Community_Type__c = \'Direct Market Reseller\' OR Community_Type__c = \'Carrier\') AND Partner_Program__r.Status__c = \'Active\'';
                        holdQuery += (isEmpty(this.stage.Partner_Technology__c))?'':' AND Technology_Specialization__c = \'' + this.stage.Partner_Technology__c + '\' AND MM_Sort_Order__C = 1';
                        holdQuery += (isEmpty(this.stage.Partner_Region__c))?'':' AND Region__c = \'' + regionMap.get(this.stage.Partner_Region__c) + '\'';
                        holdQuery += ') AND Id IN (Select Account__c FROM Partner_Location__c WHERE Location_Publish_Flag__c = true AND Federal_Status__c != \'Federal Only Location\'';
                        holdQuery += ') AND RecordTypeId = \'' + this.recordTypeId + '\' AND Partner_Locator_Status__c = \'Active\' AND (Hierarchy_Placement__c = \'Global Account\' OR Hierarchy_Placement__c = \'Regional Account\' OR Hierarchy_Placement__c = \'Regional Subsidiary Account\')';
                        this.partnerQueries.add(new PartnerQuery(QueryType.CHANNEL_PARTNER, holdQuery));

                        holdQuery = 'Select Id, (Select Id from Sales_Territory__r WHERE Country__c INCLUDES (\'All LACR Countries\') LIMIT 1)';
                        holdQuery += (isEmpty(this.stage.Partner_Industry__c))?'':', (Select Id FROM Market_Specializations__r WHERE Market_Specialization__c = \'' + this.stage.Partner_Industry__c + '\' AND Market_Specialization_Level__c != null AND Market_Specialization_Level__c != \'None\' LIMIT 1)';
                        holdQuery += ' FROM Account a WHERE Id IN (Select Account__c From Technology_Specialization__c where Technology_Specialization_Level__c != \'Open\' AND (Community_Type__c = \'Value Added Reseller\' OR Community_Type__c = \'eTailer\' OR Community_Type__c = \'Direct Market Reseller\' OR Community_Type__c = \'Carrier\') AND Partner_Program__r.Status__c = \'Active\'';
                        holdQuery += (isEmpty(this.stage.Partner_Technology__c))?'':' AND Technology_Specialization__c = \'' + this.stage.Partner_Technology__c + '\' AND MM_Sort_Order__C != 1';
                        holdQuery += (isEmpty(this.stage.Partner_Region__c))?'':' AND Region__c = \'' + regionMap.get(this.stage.Partner_Region__c) + '\'';
                        holdQuery += ') AND Id IN (Select Account__c FROM Partner_Location__c WHERE Location_Publish_Flag__c = true AND Federal_Status__c != \'Federal Only Location\'';
                        holdQuery += ') AND RecordTypeId = \'' + this.recordTypeId + '\' AND Partner_Locator_Status__c = \'Active\' AND (Hierarchy_Placement__c = \'Global Account\' OR Hierarchy_Placement__c = \'Regional Account\' OR Hierarchy_Placement__c = \'Regional Subsidiary Account\')';
                        this.partnerQueries.add(new PartnerQuery(QueryType.CHANNEL_PARTNER2, holdQuery));

                        holdQuery = 'Select Id';
                        holdQuery += (isEmpty(this.stage.Partner_Industry__c))?'':', (Select Id FROM Market_Specializations__r WHERE Market_Specialization__c = \'' + this.stage.Partner_Industry__c + '\' AND Market_Specialization_Level__c != null AND Market_Specialization_Level__c != \'None\' LIMIT 1)';
                        holdQuery += ' FROM Account a WHERE Id IN (Select Account__c From Technology_Specialization__c where Technology_Specialization_Level__c != \'Open\' AND (Community_Type__c = \'Value Added Distributor\' OR Community_Type__c = \'Sub-Distributor\') AND Partner_Program__r.Status__c = \'Active\'';
                        holdQuery += (isEmpty(this.stage.Partner_Technology__c))?'':' AND Technology_Specialization__c = \'' + this.stage.Partner_Technology__c + '\'';
                        holdQuery += (isEmpty(this.stage.Partner_Region__c))?'':' AND Region__c = \'' + regionMap.get(this.stage.Partner_Region__c) + '\'';
                        holdQuery += (isEmpty(this.stage.Partner_Country__c))?'':' AND (Country__c INCLUDES (\'All LACR Countries\') OR Country__c INCLUDES (\'' + this.stage.Partner_Country__c + '\'))';
                        holdQuery += ') AND Id IN (Select Account__c FROM Partner_Location__c WHERE Location_Publish_Flag__c = true AND Federal_Status__c != \'Federal Only Location\'';
                        holdQuery += ') AND RecordTypeId = \'' + this.recordTypeId + '\' AND Partner_Locator_Status__c = \'Active\' AND (Hierarchy_Placement__c = \'Global Account\' OR Hierarchy_Placement__c = \'Regional Account\' OR Hierarchy_Placement__c = \'Regional Subsidiary Account\')';
                        this.partnerQueries.add(new PartnerQuery(QueryType.DISTRIBUTOR, holdQuery));

                        holdQuery = 'Select Id, (Select Id from Sales_Territory__r WHERE Country__c INCLUDES (\'All LACR Countries\') LIMIT 1)';
                        holdQuery += (isEmpty(this.stage.Partner_Industry__c))?'':', (Select Id FROM Market_Specializations__r WHERE Market_Specialization__c = \'' + this.stage.Partner_Industry__c + '\' AND Market_Specialization_Level__c != null AND Market_Specialization_Level__c != \'None\' LIMIT 1)';
                        holdQuery += ' FROM Account a WHERE Id IN (Select Account__c From Technology_Specialization__c where Technology_Specialization_Level__c != \'Open\' AND (Community_Type__c = \'Value Added Distributor\' OR Community_Type__c = \'Sub-Distributor\') AND Partner_Program__r.Status__c = \'Active\'';
                        holdQuery += (isEmpty(this.stage.Partner_Technology__c))?'':' AND Technology_Specialization__c = \'' + this.stage.Partner_Technology__c + '\'';
                        holdQuery += (isEmpty(this.stage.Partner_Region__c))?'':' AND Region__c = \'' + regionMap.get(this.stage.Partner_Region__c) + '\'';
                        holdQuery += ') AND Id IN (Select Account__c FROM Partner_Location__c WHERE Location_Publish_Flag__c = true AND Federal_Status__c != \'Federal Only Location\'';
                        holdQuery += ') AND RecordTypeId = \'' + this.recordTypeId + '\' AND Partner_Locator_Status__c = \'Active\' AND (Hierarchy_Placement__c = \'Global Account\' OR Hierarchy_Placement__c = \'Regional Account\' OR Hierarchy_Placement__c = \'Regional Subsidiary Account\')';
                        this.partnerQueries.add(new PartnerQuery(QueryType.DISTRIBUTOR, holdQuery));
                    }  // end of else loop
                } // end of else loop              
            }  // end of Loop when region == LACR 
            
            if(regionMap.get(this.stage.Partner_Region__c) == 'EMEA' && this.stage.Partner_Industry__c != 'US Federal'){
                if(isEmpty(this.stage.Partner_Technology__c)){
                    holdQuery = 'Select Id';
                    holdQuery += (isEmpty(this.stage.Partner_Industry__c))?'':', (Select Id FROM Market_Specializations__r WHERE Market_Specialization__c = \'' + this.stage.Partner_Industry__c + '\' AND Market_Specialization_Level__c != null AND Market_Specialization_Level__c != \'None\' LIMIT 1)';
                    //holdQuery += ' FROM Account a WHERE Id IN (Select Account__c From Technology_Specialization__c where Technology_Specialization__c != \'Industrial Mobile Computing\' AND Technology_Specialization_Level__c != \'Open\' AND (Community_Type__c = \'Value Added Reseller\' OR Community_Type__c = \'eTailer\' OR Community_Type__c = \'Direct Market Reseller\' OR Community_Type__c = \'Carrier\') AND Partner_Program__r.Status__c = \'Active\'';
                    //Psion for EMEA Code - Brahma
                    holdQuery += ' FROM Account a WHERE Id IN (Select Account__c From Technology_Specialization__c where Technology_Specialization_Level__c != \'Open\' AND (Community_Type__c = \'Value Added Reseller\' OR Community_Type__c = \'eTailer\' OR Community_Type__c = \'Direct Market Reseller\' OR Community_Type__c = \'Carrier\') AND Partner_Program__r.Status__c = \'Active\'';
                    // Added By Sathish for Separation Day 1
                    holdQuery += (isEmpty(this.stage.Partner_Technology__c))?' AND Program__c IN '+searchTrack : ''; 
                     //Ends 
                    holdQuery += ') AND Id IN (Select Account__c FROM Partner_Location__c WHERE Location_Publish_Flag__c = true AND Federal_Status__c != \'Federal Only Location\'';
                    holdQuery += (isEmpty(this.stage.Partner_Region__c))?'':'AND Account__r.Partner_Region__c = \'' + regionMap.get(this.stage.Partner_Region__c) + '\'';
                    holdQuery += (isEmpty(this.stage.Partner_Country__c))?'':'AND Country1__c = \'' + this.stage.Partner_Country__c + '\'';
                    holdQuery += ') AND RecordTypeId = \'' + this.recordTypeId + '\' AND Partner_Locator_Status__c = \'Active\' AND (Hierarchy_Placement__c = \'Global Account\' OR Hierarchy_Placement__c = \'Regional Account\' OR Hierarchy_Placement__c = \'Regional Subsidiary Account\')';
                    this.partnerQueries.add(new PartnerQuery(QueryType.CHANNEL_PARTNER, holdQuery));
                    
                    if(this.stage.E_or_G__c != 'E'){ // Added by Sathish for EMEA-E-Distributor Search Issue Starts
                       //Code change for EA Radio
                        /*
                        holdQuery = 'Select Id, (Select Id From Partner_Types__r where Program__c = \'RADIO\' AND Status__c = \'Active\' AND Partner_Level__c != \'Distributor\' LIMIT 1), (Select Id FROM Product_Offered__r WHERE (Product_Offering__c = \'Radio Solutions\' OR Product_Offering__c = \'Mission Critical Radio Systems\' OR Product_Offering__c = \'Mission Critical Radio Systems\') AND Publish_Flag__c = true LIMIT 1)';
                        holdQuery += (isEmpty(this.stage.Partner_Industry__c))?'':', (Select Id FROM Market_Specializations__r WHERE Market_Specialization__c = \'' + this.stage.Partner_Industry__c + '\' AND Market_Specialization_Level__c != null AND Market_Specialization_Level__c != \'None\' LIMIT 1)';
                        holdQuery += ' FROM Account a WHERE Id IN (Select Account__c FROM Partner_Location__c WHERE Location_Publish_Flag__c = true AND Federal_Status__c != \'Federal Only Location\'';
                        holdQuery += ') AND Id IN (Select Account__c FROM Sales_Territory__c WHERE Region__c = \'EMEA\' AND (Technology_Segment__c INCLUDES (\'Radio Solutions\') OR Technology_Segment__c INCLUDES (\'Mission Critical Radio Systems\') OR Technology_Segment__c INCLUDES (\'Mission Critical Radio Systems\'))';
                        holdQuery += (isEmpty(this.stage.Partner_Country__c))?'':' AND (Country__c INCLUDES (\'All EMEA Countries\') OR Country__c INCLUDES (\'' + this.stage.Partner_Country__c + '\'))';
                        holdQuery += ') AND RecordTypeId = \'' + this.recordTypeId + '\' AND Partner_Locator_Status__c = \'Active\' AND (Hierarchy_Placement__c = \'Global Account\' OR Hierarchy_Placement__c = \'Regional Account\' OR Hierarchy_Placement__c = \'Regional Subsidiary Account\')';
                        this.partnerQueries.add(new PartnerQuery(QueryType.CHANNEL_PARTNER, holdQuery));
              */ //Commented by Brahma
              //Starts - Code added by Brahma
              holdQuery = 'Select Id';
                      holdQuery += (isEmpty(this.stage.Partner_Industry__c))?'':', (Select Id FROM Market_Specializations__r WHERE Market_Specialization__c = \'' + this.stage.Partner_Industry__c + '\' AND Market_Specialization_Level__c != null AND Market_Specialization_Level__c != \'None\' LIMIT 1)';
                      holdQuery += ' FROM Account a WHERE Id IN (Select Account__c From Technology_Specialization__c where Technology_Specialization_Level__c != \'Open\' AND (Community_Type__c = \'Value Added Reseller\' OR Community_Type__c = \'eTailer\' OR Community_Type__c = \'Direct Market Reseller\' OR Community_Type__c = \'Carrier\') AND Partner_Program__r.Status__c = \'Active\'';
                      // Added By Sathish for Separation Day 1
                      holdQuery += (isEmpty(this.stage.Partner_Technology__c))?' AND Program__c IN '+searchTrack : ''; 
                      //Ends  
                      holdQuery += (isEmpty(this.stage.Partner_Region__c))?'':' AND Region__c = \'' + regionMap.get(this.stage.Partner_Region__c) + '\'';
                      holdQuery += (isEmpty(this.stage.Partner_Country__c))?'':' AND (Country__c INCLUDES(\'All EMEA Countries\') OR Country__c INCLUDES (\'' + this.stage.Partner_Country__c + '\'))';
                      holdQuery += ') AND Id IN (Select Account__c FROM Partner_Location__c WHERE Location_Publish_Flag__c = true AND Federal_Status__c != \'Federal Only Location\'';
                      holdQuery += ') AND RecordTypeId = \'' + this.recordTypeId + '\' AND Partner_Locator_Status__c = \'Active\' AND (Hierarchy_Placement__c = \'Global Account\' OR Hierarchy_Placement__c = \'Regional Account\' OR Hierarchy_Placement__c = \'Regional Subsidiary Account\')';
                      this.partnerQueries.add(new PartnerQuery(QueryType.CHANNEL_PARTNER, holdQuery));
  
                      holdQuery = 'Select Id, (Select Id from Sales_Territory__r WHERE Country__c INCLUDES (\'All EMEA Countries\') LIMIT 1)';
                      holdQuery += (isEmpty(this.stage.Partner_Industry__c))?'':', (Select Id FROM Market_Specializations__r WHERE Market_Specialization__c = \'' + this.stage.Partner_Industry__c + '\' AND Market_Specialization_Level__c != null AND Market_Specialization_Level__c != \'None\' LIMIT 1)';
                      holdQuery += ' FROM Account a WHERE Id IN (Select Account__c From Technology_Specialization__c where Technology_Specialization_Level__c != \'Open\' AND (Community_Type__c = \'Value Added Reseller\' OR Community_Type__c = \'eTailer\' OR Community_Type__c = \'Direct Market Reseller\' OR Community_Type__c = \'Carrier\') AND Partner_Program__r.Status__c = \'Active\'';
                      holdQuery += (isEmpty(this.stage.Partner_Region__c))?'':' AND Region__c = \'' + regionMap.get(this.stage.Partner_Region__c) + '\'';
                      // Added By Sathish for Separation Day 1
                      holdQuery += (isEmpty(this.stage.Partner_Technology__c))?' AND Program__c IN '+searchTrack : ''; 
                      //Ends  
                      holdQuery += ') AND Id IN (Select Account__c FROM Partner_Location__c WHERE Location_Publish_Flag__c = true AND Federal_Status__c != \'Federal Only Location\'';
                      holdQuery += ') AND RecordTypeId = \'' + this.recordTypeId + '\' AND Partner_Locator_Status__c = \'Active\' AND (Hierarchy_Placement__c = \'Global Account\' OR Hierarchy_Placement__c = \'Regional Account\' OR Hierarchy_Placement__c = \'Regional Subsidiary Account\')';
                      this.partnerQueries.add(new PartnerQuery(QueryType.CHANNEL_PARTNER, holdQuery));
              //Ends - Code added by Brahma
              
                        holdQuery = 'Select Id, (Select Id FROM Product_Offered__r WHERE Product_Offering__c = \'SCADA\' AND Publish_Flag__c = true LIMIT 1)';
                        holdQuery += (isEmpty(this.stage.Partner_Industry__c))?'':', (Select Id FROM Market_Specializations__r WHERE Market_Specialization__c = \'' + this.stage.Partner_Industry__c + '\' AND Market_Specialization_Level__c != null AND Market_Specialization_Level__c != \'None\' LIMIT 1)';
                        holdQuery += ' FROM Account a WHERE Id IN (Select Account__c FROM Partner_Location__c WHERE Location_Publish_Flag__c = true AND Federal_Status__c != \'Federal Only Location\'';
                        holdQuery += ' AND Account__r.Partner_Region__c = \'EMEA\'';
                        holdQuery += (isEmpty(this.stage.Partner_Country__c))?'':' AND Country1__c = \'' + this.stage.Partner_Country__c + '\'';
                        holdQuery += ') AND Id IN (Select Account__c From Partner_Type__c where Program__c = \'SCADA\' AND Status__c = \'Active\' AND Partner_Level__c != \'Distributor\') AND RecordTypeId = \'' + this.recordTypeId + '\' AND Partner_Locator_Status__c = \'Active\' AND (Hierarchy_Placement__c = \'Global Account\' OR Hierarchy_Placement__c = \'Regional Account\' OR Hierarchy_Placement__c = \'Regional Subsidiary Account\')';
                        this.partnerQueries.add(new PartnerQuery(QueryType.CHANNEL_PARTNER, holdQuery));
                        
                        holdQuery = 'Select Id, (Select Id From Partner_Types__r where Program__c = \'SCADA\' AND Status__c = \'Active\' AND Partner_Level__c = \'Distributor\' LIMIT 1), (Select Id FROM Product_Offered__r WHERE Product_Offering__c = \'SCADA\' AND Publish_Flag__c = true LIMIT 1)';                
                        holdQuery += (isEmpty(this.stage.Partner_Industry__c))?'':', (Select Id FROM Market_Specializations__r WHERE Market_Specialization__c = \'' + this.stage.Partner_Industry__c + '\' AND Market_Specialization_Level__c != null AND Market_Specialization_Level__c != \'None\' LIMIT 1)';
                        holdQuery += ' FROM Account a WHERE Id IN (Select Account__c FROM Partner_Location__c WHERE Location_Publish_Flag__c = true AND Federal_Status__c != \'Federal Only Location\'';
                        holdQuery += ') AND Id IN (Select Account__c FROM Sales_Territory__c WHERE Region__c = \'EMEA\' AND Technology_Segment__c INCLUDES (\'SCADA\')';
                        holdQuery += (isEmpty(this.stage.Partner_Country__c))?'':' AND (Country__c INCLUDES (\'All EMEA Countries\') OR Country__c INCLUDES (\'' + this.stage.Partner_Country__c + '\'))';
                        holdQuery += ') AND RecordTypeId = \'' + this.recordTypeId + '\' AND Partner_Locator_Status__c = \'Active\' AND (Hierarchy_Placement__c = \'Global Account\' OR Hierarchy_Placement__c = \'Regional Account\' OR Hierarchy_Placement__c = \'Regional Subsidiary Account\')';
                        this.partnerQueries.add(new PartnerQuery(QueryType.DISTRIBUTOR, holdQuery));
                        //Code change for EA Radio
                        /*
                        holdQuery = 'Select Id, (Select Id From Partner_Types__r where Program__c = \'RADIO\' AND Status__c = \'Active\' AND Partner_Level__c = \'Distributor\' LIMIT 1), (Select Id FROM Product_Offered__r WHERE (Product_Offering__c = \'Radio Solutions\' OR Product_Offering__c = \'Mission Critical Radio Systems\' OR Product_Offering__c = \'TERA Systems\') AND Publish_Flag__c = true LIMIT 1)';
                        holdQuery += (isEmpty(this.stage.Partner_Industry__c))?'':', (Select Id FROM Market_Specializations__r WHERE Market_Specialization__c = \'' + this.stage.Partner_Industry__c + '\' AND Market_Specialization_Level__c != null AND Market_Specialization_Level__c != \'None\' LIMIT 1)';
                        holdQuery += ' FROM Account a WHERE Id IN (Select Account__c FROM Partner_Location__c WHERE Location_Publish_Flag__c = true AND Federal_Status__c != \'Federal Only Location\'';
                        holdQuery += ') AND Id IN (Select Account__c FROM Sales_Territory__c WHERE Region__c = \'EMEA\' AND (Technology_Segment__c INCLUDES (\'Radio Solutions\') OR Technology_Segment__c INCLUDES (\'Mission Critical Radio Systems\') OR Technology_Segment__c INCLUDES (\'Mission Critical Radio Systems\'))';
                        holdQuery += (isEmpty(this.stage.Partner_Country__c))?'':' AND (Country__c INCLUDES (\'All EMEA Countries\') OR Country__c INCLUDES (\'' + this.stage.Partner_Country__c + '\'))';
                        holdQuery += ') AND RecordTypeId = \'' + this.recordTypeId + '\' AND Partner_Locator_Status__c = \'Active\' AND (Hierarchy_Placement__c = \'Global Account\' OR Hierarchy_Placement__c = \'Regional Account\' OR Hierarchy_Placement__c = \'Regional Subsidiary Account\')';
                        this.partnerQueries.add(new PartnerQuery(QueryType.DISTRIBUTOR, holdQuery));
                      */ //Commented by Brahma
              //Starts - Code added by Brahma                      
                      holdQuery = 'Select Id';
                      holdQuery += (isEmpty(this.stage.Partner_Industry__c))?'':', (Select Id FROM Market_Specializations__r WHERE Market_Specialization__c = \'' + this.stage.Partner_Industry__c + '\' AND Market_Specialization_Level__c != null AND Market_Specialization_Level__c != \'None\' LIMIT 1)';
                      holdQuery += ' FROM Account a WHERE Id IN (Select Account__c From Technology_Specialization__c where Technology_Specialization_Level__c != \'Open\' AND (Community_Type__c = \'Value Added Distributor\' OR Community_Type__c = \'Sub-Distributor\') AND Partner_Program__r.Status__c = \'Active\'';
                      holdQuery += (isEmpty(this.stage.Partner_Region__c))?'':' AND Region__c = \'' + regionMap.get(this.stage.Partner_Region__c) + '\'';
                      holdQuery += (isEmpty(this.stage.Partner_Country__c))?'':' AND (Country__c INCLUDES(\'All EMEA Countries\') OR Country__c INCLUDES (\'' + this.stage.Partner_Country__c + '\'))';
                      // Added By Sathish for Separation Day 1
                      holdQuery += (isEmpty(this.stage.Partner_Technology__c))?' AND Program__c IN '+searchTrack : ''; 
                      //Ends  
                      holdQuery += ') AND Id IN (Select Account__c FROM Partner_Location__c WHERE Location_Publish_Flag__c = true AND Federal_Status__c != \'Federal Only Location\'';
                      holdQuery += ') AND RecordTypeId = \'' + this.recordTypeId + '\' AND Partner_Locator_Status__c = \'Active\' AND (Hierarchy_Placement__c = \'Global Account\' OR Hierarchy_Placement__c = \'Regional Account\' OR Hierarchy_Placement__c = \'Regional Subsidiary Account\')';
                      this.partnerQueries.add(new PartnerQuery(QueryType.DISTRIBUTOR, holdQuery));
                      //Ends - Code added by Brahma
                    }

                    holdQuery = 'Select Id';
                    holdQuery += (isEmpty(this.stage.Partner_Industry__c))?'':', (Select Id FROM Market_Specializations__r WHERE Market_Specialization__c = \'' + this.stage.Partner_Industry__c + '\' AND Market_Specialization_Level__c != null AND Market_Specialization_Level__c != \'None\' LIMIT 1)';
                    //holdQuery += ' FROM Account a WHERE Id IN (Select Account__c From Technology_Specialization__c where Technology_Specialization_Level__c != \'Open\' AND (Community_Type__c = \'Value Added Distributor\' OR Community_Type__c = \'Sub-Distributor\') AND Partner_Program__r.Status__c = \'Active\' AND Technology_Specialization__c != \'Industrial Mobile Computing\'';
                    //Psion for EMEA Code - Brahma
                    holdQuery += ' FROM Account a WHERE Id IN (Select Account__c From Technology_Specialization__c where Technology_Specialization_Level__c != \'Open\' AND (Community_Type__c = \'Value Added Distributor\' OR Community_Type__c = \'Sub-Distributor\') AND Partner_Program__r.Status__c = \'Active\'';
                    // Added By Sathish for Separation Day 1
                    holdQuery += (isEmpty(this.stage.Partner_Technology__c))?' AND Program__c IN '+searchTrack : ''; 
                    //Ends 
                    holdQuery += (isEmpty(this.stage.Partner_Region__c))?'':'AND Region__c = \'' + regionMap.get(this.stage.Partner_Region__c) + '\'';
                    holdQuery += (isEmpty(this.stage.Partner_Country__c))?'':'AND (Country__c INCLUDES(\'All EMEA Countries\') OR Country__c INCLUDES (\'' + this.stage.Partner_Country__c + '\'))';
                    holdQuery += ') AND Id IN (Select Account__c FROM Partner_Location__c WHERE Location_Publish_Flag__c = true AND Federal_Status__c != \'Federal Only Location\'';
                    holdQuery += ') AND RecordTypeId = \'' + this.recordTypeId + '\' AND Partner_Locator_Status__c = \'Active\' AND (Hierarchy_Placement__c = \'Global Account\' OR Hierarchy_Placement__c = \'Regional Account\' OR Hierarchy_Placement__c = \'Regional Subsidiary Account\')';
                    this.partnerQueries.add(new PartnerQuery(QueryType.DISTRIBUTOR, holdQuery));

                    holdQuery = 'Select Id, (Select Id from Sales_Territory__r WHERE Country__c INCLUDES (\'All EMEA Countries\') LIMIT 1)';
                    holdQuery += (isEmpty(this.stage.Partner_Industry__c))?'':', (Select Id FROM Market_Specializations__r WHERE Market_Specialization__c = \'' + this.stage.Partner_Industry__c + '\' AND Market_Specialization_Level__c != null AND Market_Specialization_Level__c != \'None\' LIMIT 1)';
                    //holdQuery += ' FROM Account a WHERE Id IN (Select Account__c From Technology_Specialization__c where Technology_Specialization_Level__c != \'Open\' AND (Community_Type__c = \'Value Added Distributor\' OR Community_Type__c = \'Sub-Distributor\') AND Partner_Program__r.Status__c = \'Active\' AND Technology_Specialization__c != \'Industrial Mobile Computing\'';
                    //Psion for EMEA Code - Brahma
                    holdQuery += ' FROM Account a WHERE Id IN (Select Account__c From Technology_Specialization__c where Technology_Specialization_Level__c != \'Open\' AND (Community_Type__c = \'Value Added Distributor\' OR Community_Type__c = \'Sub-Distributor\') AND Partner_Program__r.Status__c = \'Active\'';
                    // Added By Sathish for Separation Day 1
                    holdQuery += (isEmpty(this.stage.Partner_Technology__c))?' AND Program__c IN '+searchTrack : ''; 
                    //Ends 
                    holdQuery += (isEmpty(this.stage.Partner_Region__c))?'':'AND Region__c = \'' + regionMap.get(this.stage.Partner_Region__c) + '\'';
                    holdQuery += ') AND Id IN (Select Account__c FROM Partner_Location__c WHERE Location_Publish_Flag__c = true AND Federal_Status__c != \'Federal Only Location\'';
                    holdQuery += ') AND RecordTypeId = \'' + this.recordTypeId + '\' AND Partner_Locator_Status__c = \'Active\' AND (Hierarchy_Placement__c = \'Global Account\' OR Hierarchy_Placement__c = \'Regional Account\' OR Hierarchy_Placement__c = \'Regional Subsidiary Account\')';
                    this.partnerQueries.add(new PartnerQuery(QueryType.DISTRIBUTOR, holdQuery));
                }else{
                    if(this.stage.Partner_Technology__c == 'SCADA'){
                        holdQuery = 'Select Id, (Select Id FROM Product_Offered__r WHERE Product_Offering__c = \'SCADA\' AND Publish_Flag__c = true LIMIT 1)';
                        holdQuery += (isEmpty(this.stage.Partner_Industry__c))?'':', (Select Id FROM Market_Specializations__r WHERE Market_Specialization__c = \'' + this.stage.Partner_Industry__c + '\' AND Market_Specialization_Level__c != null AND Market_Specialization_Level__c != \'None\' LIMIT 1)';
                        holdQuery += ' FROM Account a WHERE Id IN (Select Account__c FROM Partner_Location__c WHERE Location_Publish_Flag__c = true AND Federal_Status__c != \'Federal Only Location\'';
                        holdQuery += ' AND Account__r.Partner_Region__c = \'EMEA\'';
                        holdQuery += (isEmpty(this.stage.Partner_Country__c))?'':' AND Country1__c = \'' + this.stage.Partner_Country__c + '\'';
                        holdQuery += ') AND Id IN (Select Account__c From Partner_Type__c where Program__c = \'SCADA\' AND Status__c = \'Active\' AND Partner_Level__c != \'Distributor\') AND RecordTypeId = \'' + this.recordTypeId + '\' AND Partner_Locator_Status__c = \'Active\' AND (Hierarchy_Placement__c = \'Global Account\' OR Hierarchy_Placement__c = \'Regional Account\' OR Hierarchy_Placement__c = \'Regional Subsidiary Account\')';
                        this.partnerQueries.add(new PartnerQuery(QueryType.CHANNEL_PARTNER, holdQuery));

                        holdQuery = 'Select Id, (Select Id FROM Product_Offered__r WHERE Product_Offering__c = \'SCADA\' AND Publish_Flag__c = true LIMIT 1), (Select Id FROM Sales_Territory__r WHERE Technology_Segment__c INCLUDES (\'SCADA\')';
                        holdQuery += (isEmpty(this.stage.Partner_Region__c))?'':'AND Region__c = \'' + regionMap.get(this.stage.Partner_Region__c) + '\'';
                        holdQuery += (isEmpty(this.stage.Partner_Country__c))?'':' AND (Country__c INCLUDES (\'All EMEA Countries\') OR Country__c INCLUDES (\'' + this.stage.Partner_Country__c + '\'))';
                        holdQuery += ' LIMIT 1)';
                        holdQuery += (isEmpty(this.stage.Partner_Industry__c))?'':', (Select Id FROM Market_Specializations__r WHERE Market_Specialization__c = \'' + this.stage.Partner_Industry__c + '\' AND Market_Specialization_Level__c != null AND Market_Specialization_Level__c != \'None\' LIMIT 1)';
                        holdQuery += ' FROM Account a WHERE Id IN (Select Account__c FROM Partner_Location__c WHERE Location_Publish_Flag__c = true AND Federal_Status__c != \'Federal Only Location\'';
                        holdQuery += ') AND Id IN (Select Account__c From Partner_Type__c where Program__c = \'SCADA\' AND Status__c = \'Active\' AND Partner_Level__c = \'Distributor\') AND RecordTypeId = \'' + this.recordTypeId + '\' AND Partner_Locator_Status__c = \'Active\' AND (Hierarchy_Placement__c = \'Global Account\' OR Hierarchy_Placement__c = \'Regional Account\' OR Hierarchy_Placement__c = \'Regional Subsidiary Account\')';
                        this.partnerQueries.add(new PartnerQuery(QueryType.DISTRIBUTOR, holdQuery));
                    }else{ //Code change for EA Radio
                        /*
                        if(this.stage.Partner_Technology__c == 'Radio Solutions' || this.stage.Partner_Technology__c == 'Mission Critical Radio Systems' || this.stage.Partner_Technology__c == 'Mission Critical Radio Systems'){
                            holdQuery = 'Select Id, (Select Id From Partner_Types__r where Program__c = \'RADIO\' AND Status__c = \'Active\' AND Partner_Level__c != \'Distributor\' LIMIT 1), (Select Id FROM Product_Offered__r WHERE Product_Offering__c = \'' + this.stage.Partner_Technology__c + '\' AND Publish_Flag__c = true LIMIT 1)'; 
                            holdQuery += (isEmpty(this.stage.Partner_Industry__c))?'':', (Select Id FROM Market_Specializations__r WHERE Market_Specialization__c = \'' + this.stage.Partner_Industry__c + '\' AND Market_Specialization_Level__c != null AND Market_Specialization_Level__c != \'None\' LIMIT 1)';
                            holdQuery += ' FROM Account a WHERE Id IN (Select Account__c FROM Partner_Location__c WHERE Location_Publish_Flag__c = true AND Federal_Status__c != \'Federal Only Location\'';
                            holdQuery += ') AND Id IN (Select Account__c FROM Sales_Territory__c WHERE Region__c = \'EMEA\'';
                            holdQuery += (isEmpty(this.stage.Partner_Technology__c))?'':' AND Technology_Segment__c INCLUDES (\'' + this.stage.Partner_Technology__c + '\')';
                            holdQuery += (isEmpty(this.stage.Partner_Country__c))?'':' AND (Country__c INCLUDES (\'All EMEA Countries\') OR Country__c INCLUDES (\'' + this.stage.Partner_Country__c + '\'))';
                            holdQuery += ') AND RecordTypeId = \'' + this.recordTypeId + '\' AND Partner_Locator_Status__c = \'Active\' AND (Hierarchy_Placement__c = \'Global Account\' OR Hierarchy_Placement__c = \'Regional Account\' OR Hierarchy_Placement__c = \'Regional Subsidiary Account\')';
                            this.partnerQueries.add(new PartnerQuery(QueryType.CHANNEL_PARTNER, holdQuery));
                        }*/ // Commented by Brahma
                        if(this.stage.Partner_Technology__c != 'Radio Solutions' && this.stage.Partner_Technology__c != 'Mission Critical Radio Systems' && this.stage.Partner_Technology__c != 'Mission Critical Radio Systems' && this.stage.Partner_Technology__c != 'Professional and Commercial Radio' && this.stage.Partner_Technology__c != 'Professional and Commercial Radio' && this.stage.Partner_Technology__c != 'Business Radio' && this.stage.Partner_Technology__c != 'SCADA'){
                            holdQuery = 'Select Id';
                            holdQuery += (isEmpty(this.stage.Partner_Industry__c))?'':', (Select Id FROM Market_Specializations__r WHERE Market_Specialization__c = \'' + this.stage.Partner_Industry__c + '\' AND Market_Specialization_Level__c != null AND Market_Specialization_Level__c != \'None\' LIMIT 1)';
                            holdQuery += ' FROM Account a WHERE Id IN (Select Account__c From Technology_Specialization__c where Technology_Specialization_Level__c != \'Open\' AND (Community_Type__c = \'Value Added Reseller\' OR Community_Type__c = \'eTailer\' OR Community_Type__c = \'Direct Market Reseller\' OR Community_Type__c = \'Carrier\') AND Partner_Program__r.Status__c = \'Active\'';
                            holdQuery += (isEmpty(this.stage.Partner_Technology__c))?'':' AND Technology_Specialization__c = \'' + this.stage.Partner_Technology__c + '\' AND MM_Sort_Order__C = 1';
                            holdQuery += ') AND Id IN (Select Account__c FROM Partner_Location__c WHERE Location_Publish_Flag__c = true AND Federal_Status__c != \'Federal Only Location\'';
                            holdQuery += (isEmpty(this.stage.Partner_Region__c))?'':'AND Account__r.Partner_Region__c = \'' + regionMap.get(this.stage.Partner_Region__c) + '\'';
                            holdQuery += (isEmpty(this.stage.Partner_Country__c))?'':'AND Country1__c = \'' + this.stage.Partner_Country__c + '\'';
                            holdQuery += ') AND RecordTypeId = \'' + this.recordTypeId + '\' AND Partner_Locator_Status__c = \'Active\' AND (Hierarchy_Placement__c = \'Global Account\' OR Hierarchy_Placement__c = \'Regional Account\' OR Hierarchy_Placement__c = \'Regional Subsidiary Account\')';
                            this.partnerQueries.add(new PartnerQuery(QueryType.CHANNEL_PARTNER, holdQuery));

                            holdQuery = 'Select Id';
                            holdQuery += (isEmpty(this.stage.Partner_Industry__c))?'':', (Select Id FROM Market_Specializations__r WHERE Market_Specialization__c = \'' + this.stage.Partner_Industry__c + '\' AND Market_Specialization_Level__c != null AND Market_Specialization_Level__c != \'None\' LIMIT 1)';
                            holdQuery += ' FROM Account a WHERE Id IN (Select Account__c From Technology_Specialization__c where Technology_Specialization_Level__c != \'Open\' AND (Community_Type__c = \'Value Added Reseller\' OR Community_Type__c = \'eTailer\' OR Community_Type__c = \'Direct Market Reseller\' OR Community_Type__c = \'Carrier\') AND Partner_Program__r.Status__c = \'Active\'';
                            holdQuery += (isEmpty(this.stage.Partner_Technology__c))?'':' AND Technology_Specialization__c = \'' + this.stage.Partner_Technology__c + '\' AND MM_Sort_Order__C = 2';
                            holdQuery += ') AND Id IN (Select Account__c FROM Partner_Location__c WHERE Location_Publish_Flag__c = true AND Federal_Status__c != \'Federal Only Location\'';
                            holdQuery += (isEmpty(this.stage.Partner_Region__c))?'':'AND Account__r.Partner_Region__c = \'' + regionMap.get(this.stage.Partner_Region__c) + '\'';
                            holdQuery += (isEmpty(this.stage.Partner_Country__c))?'':'AND Country1__c = \'' + this.stage.Partner_Country__c + '\'';
                            holdQuery += ') AND RecordTypeId = \'' + this.recordTypeId + '\' AND Partner_Locator_Status__c = \'Active\' AND (Hierarchy_Placement__c = \'Global Account\' OR Hierarchy_Placement__c = \'Regional Account\' OR Hierarchy_Placement__c = \'Regional Subsidiary Account\')';
                            this.partnerQueries.add(new PartnerQuery(QueryType.CHANNEL_PARTNER, holdQuery));
                        } 
                        if(this.stage.Partner_Technology__c != 'Radio Solutions' && this.stage.Partner_Technology__c != 'Mission Critical Radio Systems' && this.stage.Partner_Technology__c != 'Mission Critical Radio Systems' && this.stage.Partner_Technology__c != 'Professional and Commercial Radio' && this.stage.Partner_Technology__c != 'Professional and Commercial Radio' && this.stage.Partner_Technology__c != 'Business Radio' && this.stage.Partner_Technology__c != 'SCADA'){
                            holdQuery = 'Select Id';
                            holdQuery += (isEmpty(this.stage.Partner_Industry__c))?'':', (Select Id FROM Market_Specializations__r WHERE Market_Specialization__c = \'' + this.stage.Partner_Industry__c + '\' AND Market_Specialization_Level__c != null AND Market_Specialization_Level__c != \'None\' LIMIT 1)';
                            holdQuery += ' FROM Account a WHERE Id IN (Select Account__c From Technology_Specialization__c where Technology_Specialization_Level__c != \'Open\' AND (Community_Type__c = \'Value Added Reseller\' OR Community_Type__c = \'eTailer\' OR Community_Type__c = \'Direct Market Reseller\' OR Community_Type__c = \'Carrier\') AND Partner_Program__r.Status__c = \'Active\'';
                            holdQuery += (isEmpty(this.stage.Partner_Technology__c))?'':' AND Technology_Specialization__c = \'' + this.stage.Partner_Technology__c + '\' AND MM_Sort_Order__C != 1 AND MM_Sort_Order__C != 2';
                            holdQuery += ') AND Id IN (Select Account__c FROM Partner_Location__c WHERE Location_Publish_Flag__c = true AND Federal_Status__c != \'Federal Only Location\'';
                            holdQuery += (isEmpty(this.stage.Partner_Region__c))?'':'AND Account__r.Partner_Region__c = \'' + regionMap.get(this.stage.Partner_Region__c) + '\'';
                            holdQuery += (isEmpty(this.stage.Partner_Country__c))?'':'AND Country1__c = \'' + this.stage.Partner_Country__c + '\'';
                            holdQuery += ') AND RecordTypeId = \'' + this.recordTypeId + '\' AND Partner_Locator_Status__c = \'Active\' AND (Hierarchy_Placement__c = \'Global Account\' OR Hierarchy_Placement__c = \'Regional Account\' OR Hierarchy_Placement__c = \'Regional Subsidiary Account\')';
                            this.partnerQueries.add(new PartnerQuery(QueryType.CHANNEL_PARTNER2, holdQuery));
                        } //Code change for EA Radio
                        if((this.stage.Partner_Technology__c == 'Radio Solutions' || this.stage.Partner_Technology__c == 'Mission Critical Radio Systems' || this.stage.Partner_Technology__c == 'Professional and Commercial Radio' || this.stage.Partner_Technology__c == 'Business Radio') && this.stage.Partner_Technology__c != 'SCADA'){
                            /*
                            holdQuery = 'Select Id, (Select Id From Partner_Types__r where Program__c = \'RADIO\' AND Status__c = \'Active\' AND Partner_Level__c = \'Distributor\' LIMIT 1), (Select Id FROM Product_Offered__r WHERE Product_Offering__c = \'' + this.stage.Partner_Technology__c + '\' AND Publish_Flag__c = true LIMIT 1)';
                            holdQuery += (isEmpty(this.stage.Partner_Industry__c))?'':', (Select Id FROM Market_Specializations__r WHERE Market_Specialization__c = \'' + this.stage.Partner_Industry__c + '\' AND Market_Specialization_Level__c != null AND Market_Specialization_Level__c != \'None\' LIMIT 1)';
                            holdQuery += ' FROM Account a WHERE Id IN (Select Account__c FROM Partner_Location__c WHERE Location_Publish_Flag__c = true AND Federal_Status__c != \'Federal Only Location\'';
                            holdQuery += ') AND Id IN (Select Account__c FROM Sales_Territory__c WHERE Region__c = \'EMEA\'';
                            holdQuery += (isEmpty(this.stage.Partner_Country__c))?'':'AND (Country__c INCLUDES(\'All EMEA Countries\') OR Country__c INCLUDES (\'' + this.stage.Partner_Country__c + '\'))';
                            holdQuery += (isEmpty(this.stage.Partner_Technology__c))?'':' AND Technology_Segment__c INCLUDES (\'' + this.stage.Partner_Technology__c + '\')';
                            holdQuery += ') AND RecordTypeId = \'' + this.recordTypeId + '\' AND Partner_Locator_Status__c = \'Active\' AND (Hierarchy_Placement__c = \'Global Account\' OR Hierarchy_Placement__c = \'Regional Account\' OR Hierarchy_Placement__c = \'Regional Subsidiary Account\')';
                            this.partnerQueries.add(new PartnerQuery(QueryType.DISTRIBUTOR, holdQuery));
                            */ // Commented by Brahma
                            //Starts - Code added by Brahma
                            holdQuery = 'Select Id';
                          holdQuery += (isEmpty(this.stage.Partner_Industry__c))?'':', (Select Id FROM Market_Specializations__r WHERE Market_Specialization__c = \'' + this.stage.Partner_Industry__c + '\' AND Market_Specialization_Level__c != null AND Market_Specialization_Level__c != \'None\' LIMIT 1)';
                          holdQuery += ' FROM Account a WHERE Id IN (Select Account__c From Technology_Specialization__c where Technology_Specialization_Level__c != \'Open\' AND (Community_Type__c = \'Value Added Reseller\' OR Community_Type__c = \'eTailer\' OR Community_Type__c = \'Direct Market Reseller\' OR Community_Type__c = \'Carrier\') AND Partner_Program__r.Status__c = \'Active\'';
                          holdQuery += (isEmpty(this.stage.Partner_Technology__c))?'':' AND Technology_Specialization__c = \'' + this.stage.Partner_Technology__c + '\' AND MM_Sort_Order__C = 1';
                          holdQuery += (isEmpty(this.stage.Partner_Region__c))?'':' AND Region__c = \'' + regionMap.get(this.stage.Partner_Region__c) + '\'';
                          holdQuery += (isEmpty(this.stage.Partner_Country__c))?'':' AND (Country__c INCLUDES(\'All EMEA Countries\') OR Country__c INCLUDES (\'' + this.stage.Partner_Country__c + '\'))';
                          holdQuery += ') AND Id IN (Select Account__c FROM Partner_Location__c WHERE Location_Publish_Flag__c = true AND Federal_Status__c != \'Federal Only Location\'';
                          holdQuery += ') AND RecordTypeId = \'' + this.recordTypeId + '\' AND Partner_Locator_Status__c = \'Active\' AND (Hierarchy_Placement__c = \'Global Account\' OR Hierarchy_Placement__c = \'Regional Account\' OR Hierarchy_Placement__c = \'Regional Subsidiary Account\')';
                          this.partnerQueries.add(new PartnerQuery(QueryType.CHANNEL_PARTNER, holdQuery));
  
                          holdQuery = 'Select Id';
                          holdQuery += (isEmpty(this.stage.Partner_Industry__c))?'':', (Select Id FROM Market_Specializations__r WHERE Market_Specialization__c = \'' + this.stage.Partner_Industry__c + '\' AND Market_Specialization_Level__c != null AND Market_Specialization_Level__c != \'None\' LIMIT 1)';
                          holdQuery += ' FROM Account a WHERE Id IN (Select Account__c From Technology_Specialization__c where Technology_Specialization_Level__c != \'Open\' AND (Community_Type__c = \'Value Added Reseller\' OR Community_Type__c = \'eTailer\' OR Community_Type__c = \'Direct Market Reseller\' OR Community_Type__c = \'Carrier\') AND Partner_Program__r.Status__c = \'Active\'';
                          holdQuery += (isEmpty(this.stage.Partner_Technology__c))?'':' AND Technology_Specialization__c = \'' + this.stage.Partner_Technology__c + '\' AND MM_Sort_Order__C = 2';
                          holdQuery += (isEmpty(this.stage.Partner_Region__c))?'':' AND Region__c = \'' + regionMap.get(this.stage.Partner_Region__c) + '\'';
                          holdQuery += (isEmpty(this.stage.Partner_Country__c))?'':' AND (Country__c INCLUDES(\'All EMEA Countries\') OR Country__c INCLUDES (\'' + this.stage.Partner_Country__c + '\'))';
                          holdQuery += ') AND Id IN (Select Account__c FROM Partner_Location__c WHERE Location_Publish_Flag__c = true AND Federal_Status__c != \'Federal Only Location\'';
                          holdQuery += ') AND RecordTypeId = \'' + this.recordTypeId + '\' AND Partner_Locator_Status__c = \'Active\' AND (Hierarchy_Placement__c = \'Global Account\' OR Hierarchy_Placement__c = \'Regional Account\' OR Hierarchy_Placement__c = \'Regional Subsidiary Account\')';
                          this.partnerQueries.add(new PartnerQuery(QueryType.CHANNEL_PARTNER, holdQuery));
  
                          holdQuery = 'Select Id';
                          holdQuery += (isEmpty(this.stage.Partner_Industry__c))?'':', (Select Id FROM Market_Specializations__r WHERE Market_Specialization__c = \'' + this.stage.Partner_Industry__c + '\' AND Market_Specialization_Level__c != null AND Market_Specialization_Level__c != \'None\' LIMIT 1)';
                          holdQuery += ' FROM Account a WHERE Id IN (Select Account__c From Technology_Specialization__c where Technology_Specialization_Level__c != \'Open\' AND (Community_Type__c = \'Value Added Reseller\' OR Community_Type__c = \'eTailer\' OR Community_Type__c = \'Direct Market Reseller\' OR Community_Type__c = \'Carrier\') AND Partner_Program__r.Status__c = \'Active\'';
                          holdQuery += (isEmpty(this.stage.Partner_Technology__c))?'':' AND Technology_Specialization__c = \'' + this.stage.Partner_Technology__c + '\' AND MM_Sort_Order__C != 1 AND MM_Sort_Order__C != 2';
                          holdQuery += (isEmpty(this.stage.Partner_Region__c))?'':' AND Region__c = \'' + regionMap.get(this.stage.Partner_Region__c) + '\'';
                          holdQuery += (isEmpty(this.stage.Partner_Country__c))?'':' AND (Country__c INCLUDES(\'All EMEA Countries\') OR Country__c INCLUDES (\'' + this.stage.Partner_Country__c + '\'))';
                          holdQuery += ') AND Id IN (Select Account__c FROM Partner_Location__c WHERE Location_Publish_Flag__c = true AND Federal_Status__c != \'Federal Only Location\'';
                          holdQuery += ') AND RecordTypeId = \'' + this.recordTypeId + '\' AND Partner_Locator_Status__c = \'Active\' AND (Hierarchy_Placement__c = \'Global Account\' OR Hierarchy_Placement__c = \'Regional Account\' OR Hierarchy_Placement__c = \'Regional Subsidiary Account\')';
                          this.partnerQueries.add(new PartnerQuery(QueryType.CHANNEL_PARTNER2, holdQuery));
  
                          holdQuery = 'Select Id, (Select Id from Sales_Territory__r WHERE Country__c INCLUDES (\'All EMEA Countries\') LIMIT 1)';
                          holdQuery += (isEmpty(this.stage.Partner_Industry__c))?'':', (Select Id FROM Market_Specializations__r WHERE Market_Specialization__c = \'' + this.stage.Partner_Industry__c + '\' AND Market_Specialization_Level__c != null AND Market_Specialization_Level__c != \'None\' LIMIT 1)';
                          holdQuery += ' FROM Account a WHERE Id IN (Select Account__c From Technology_Specialization__c where Technology_Specialization_Level__c != \'Open\' AND (Community_Type__c = \'Value Added Reseller\' OR Community_Type__c = \'eTailer\' OR Community_Type__c = \'Direct Market Reseller\' OR Community_Type__c = \'Carrier\') AND Partner_Program__r.Status__c = \'Active\'';
                          holdQuery += (isEmpty(this.stage.Partner_Technology__c))?'':' AND Technology_Specialization__c = \'' + this.stage.Partner_Technology__c + '\' AND MM_Sort_Order__C = 1';
                          holdQuery += (isEmpty(this.stage.Partner_Region__c))?'':' AND Region__c = \'' + regionMap.get(this.stage.Partner_Region__c) + '\'';
                          holdQuery += ') AND Id IN (Select Account__c FROM Partner_Location__c WHERE Location_Publish_Flag__c = true AND Federal_Status__c != \'Federal Only Location\'';
                          holdQuery += ') AND RecordTypeId = \'' + this.recordTypeId + '\' AND Partner_Locator_Status__c = \'Active\' AND (Hierarchy_Placement__c = \'Global Account\' OR Hierarchy_Placement__c = \'Regional Account\' OR Hierarchy_Placement__c = \'Regional Subsidiary Account\')';
                          this.partnerQueries.add(new PartnerQuery(QueryType.CHANNEL_PARTNER, holdQuery));
  
                          holdQuery = 'Select Id, (Select Id from Sales_Territory__r WHERE Country__c INCLUDES (\'All EMEA Countries\') LIMIT 1)';
                          holdQuery += (isEmpty(this.stage.Partner_Industry__c))?'':', (Select Id FROM Market_Specializations__r WHERE Market_Specialization__c = \'' + this.stage.Partner_Industry__c + '\' AND Market_Specialization_Level__c != null AND Market_Specialization_Level__c != \'None\' LIMIT 1)';
                          holdQuery += ' FROM Account a WHERE Id IN (Select Account__c From Technology_Specialization__c where Technology_Specialization_Level__c != \'Open\' AND (Community_Type__c = \'Value Added Reseller\' OR Community_Type__c = \'eTailer\' OR Community_Type__c = \'Direct Market Reseller\' OR Community_Type__c = \'Carrier\') AND Partner_Program__r.Status__c = \'Active\'';
                          holdQuery += (isEmpty(this.stage.Partner_Technology__c))?'':' AND Technology_Specialization__c = \'' + this.stage.Partner_Technology__c + '\' AND MM_Sort_Order__C != 1';
                          holdQuery += (isEmpty(this.stage.Partner_Region__c))?'':' AND Region__c = \'' + regionMap.get(this.stage.Partner_Region__c) + '\'';
                          holdQuery += ') AND Id IN (Select Account__c FROM Partner_Location__c WHERE Location_Publish_Flag__c = true AND Federal_Status__c != \'Federal Only Location\'';
                          holdQuery += ') AND RecordTypeId = \'' + this.recordTypeId + '\' AND Partner_Locator_Status__c = \'Active\' AND (Hierarchy_Placement__c = \'Global Account\' OR Hierarchy_Placement__c = \'Regional Account\' OR Hierarchy_Placement__c = \'Regional Subsidiary Account\')';
                          this.partnerQueries.add(new PartnerQuery(QueryType.CHANNEL_PARTNER2, holdQuery));
  
                          holdQuery = 'Select Id';
                          holdQuery += (isEmpty(this.stage.Partner_Industry__c))?'':', (Select Id FROM Market_Specializations__r WHERE Market_Specialization__c = \'' + this.stage.Partner_Industry__c + '\' AND Market_Specialization_Level__c != null AND Market_Specialization_Level__c != \'None\' LIMIT 1)';
                          holdQuery += ' FROM Account a WHERE Id IN (Select Account__c From Technology_Specialization__c where Technology_Specialization_Level__c != \'Open\' AND (Community_Type__c = \'Value Added Distributor\' OR Community_Type__c = \'Sub-Distributor\') AND Partner_Program__r.Status__c = \'Active\'';
                          holdQuery += (isEmpty(this.stage.Partner_Technology__c))?'':' AND Technology_Specialization__c = \'' + this.stage.Partner_Technology__c + '\'';
                          holdQuery += (isEmpty(this.stage.Partner_Region__c))?'':' AND Region__c = \'' + regionMap.get(this.stage.Partner_Region__c) + '\'';
                          holdQuery += (isEmpty(this.stage.Partner_Country__c))?'':' AND (Country__c INCLUDES (\'All EMEA Countries\') OR Country__c INCLUDES (\'' + this.stage.Partner_Country__c + '\'))';
                          holdQuery += ') AND Id IN (Select Account__c FROM Partner_Location__c WHERE Location_Publish_Flag__c = true AND Federal_Status__c != \'Federal Only Location\'';
                          holdQuery += ') AND RecordTypeId = \'' + this.recordTypeId + '\' AND Partner_Locator_Status__c = \'Active\' AND (Hierarchy_Placement__c = \'Global Account\' OR Hierarchy_Placement__c = \'Regional Account\' OR Hierarchy_Placement__c = \'Regional Subsidiary Account\')';
                          this.partnerQueries.add(new PartnerQuery(QueryType.DISTRIBUTOR, holdQuery));
  
                          holdQuery = 'Select Id, (Select Id from Sales_Territory__r WHERE Country__c INCLUDES (\'All EMEA Countries\') LIMIT 1)';
                          holdQuery += (isEmpty(this.stage.Partner_Industry__c))?'':', (Select Id FROM Market_Specializations__r WHERE Market_Specialization__c = \'' + this.stage.Partner_Industry__c + '\' AND Market_Specialization_Level__c != null AND Market_Specialization_Level__c != \'None\' LIMIT 1)';
                          holdQuery += ' FROM Account a WHERE Id IN (Select Account__c From Technology_Specialization__c where Technology_Specialization_Level__c != \'Open\' AND (Community_Type__c = \'Value Added Distributor\' OR Community_Type__c = \'Sub-Distributor\') AND Partner_Program__r.Status__c = \'Active\'';
                          holdQuery += (isEmpty(this.stage.Partner_Technology__c))?'':' AND Technology_Specialization__c = \'' + this.stage.Partner_Technology__c + '\'';
                          holdQuery += (isEmpty(this.stage.Partner_Region__c))?'':' AND Region__c = \'' + regionMap.get(this.stage.Partner_Region__c) + '\'';
                          holdQuery += ') AND Id IN (Select Account__c FROM Partner_Location__c WHERE Location_Publish_Flag__c = true AND Federal_Status__c != \'Federal Only Location\'';
                          holdQuery += ') AND RecordTypeId = \'' + this.recordTypeId + '\' AND Partner_Locator_Status__c = \'Active\' AND (Hierarchy_Placement__c = \'Global Account\' OR Hierarchy_Placement__c = \'Regional Account\' OR Hierarchy_Placement__c = \'Regional Subsidiary Account\')';
                          this.partnerQueries.add(new PartnerQuery(QueryType.DISTRIBUTOR, holdQuery));
                          //Ends - Code added by Brahma
                        }else{
                            holdQuery = 'Select Id';
                            holdQuery += (isEmpty(this.stage.Partner_Industry__c))?'':', (Select Id FROM Market_Specializations__r WHERE Market_Specialization__c = \'' + this.stage.Partner_Industry__c + '\' AND Market_Specialization_Level__c != null AND Market_Specialization_Level__c != \'None\' LIMIT 1)';
                            holdQuery += ' FROM Account a WHERE Id IN (Select Account__c From Technology_Specialization__c where Technology_Specialization_Level__c != \'Open\' AND (Community_Type__c = \'Value Added Distributor\' OR Community_Type__c = \'Sub-Distributor\') AND Partner_Program__r.Status__c = \'Active\'';
                            holdQuery += (isEmpty(this.stage.Partner_Technology__c))?'':' AND Technology_Specialization__c = \'' + this.stage.Partner_Technology__c + '\'';
                            holdQuery += (isEmpty(this.stage.Partner_Region__c))?'':'AND Region__c = \'' + regionMap.get(this.stage.Partner_Region__c) + '\'';
                            holdQuery += (isEmpty(this.stage.Partner_Country__c))?'':'AND (Country__c INCLUDES(\'All EMEA Countries\') OR Country__c INCLUDES (\'' + this.stage.Partner_Country__c + '\'))';
                            holdQuery += ') AND Id IN (Select Account__c FROM Partner_Location__c WHERE Location_Publish_Flag__c = true AND Federal_Status__c != \'Federal Only Location\'';
                            holdQuery += ') AND RecordTypeId = \'' + this.recordTypeId + '\' AND Partner_Locator_Status__c = \'Active\' AND (Hierarchy_Placement__c = \'Global Account\' OR Hierarchy_Placement__c = \'Regional Account\' OR Hierarchy_Placement__c = \'Regional Subsidiary Account\')';
                            this.partnerQueries.add(new PartnerQuery(QueryType.DISTRIBUTOR, holdQuery));
                        }                       
                    }
                }               
            }
            if(regionMap.get(this.stage.Partner_Region__c) == 'NAMR' && this.stage.Partner_Industry__c != 'US Federal'){
                if(isEmpty(this.stage.Partner_Technology__c)){
                    if(this.stage.E_or_G__c != 'E'){ // Added by Sathish 
                        holdQuery = 'Select Id, (Select Id FROM Product_Offered__r WHERE Product_Offering__c = \'SCADA\' AND Publish_Flag__c = true LIMIT 1)';
                        holdQuery += (isEmpty(this.stage.Partner_Industry__c))?'':', (Select Id FROM Market_Specializations__r WHERE Market_Specialization__c = \'' + this.stage.Partner_Industry__c + '\' AND Market_Specialization_Level__c != null AND Market_Specialization_Level__c != \'None\' LIMIT 1)';
                        holdQuery += ' FROM Account a WHERE Id IN (Select Account__c FROM Partner_Location__c WHERE Location_Publish_Flag__c = true AND Federal_Status__c != \'Federal Only Location\'';
                        holdQuery += ' AND Account__r.Partner_Region__c = \'NAMR\'';
                        holdQuery += (isEmpty(this.stage.Partner_Country__c))?'':' AND Country1__c = \'' + this.stage.Partner_Country__c + '\'';
                        holdQuery += (isEmpty(this.stage.Partner_State__c))?'':' AND State__c = \'' + this.stage.Partner_State__c + '\'';
                        holdQuery += ') AND Id IN (Select Account__c From Partner_Type__c where Program__c = \'SCADA\' AND Status__c = \'Active\' AND Partner_Level__c != \'Distributor\') AND RecordTypeId = \'' + this.recordTypeId + '\' AND Partner_Locator_Status__c = \'Active\' AND (Hierarchy_Placement__c = \'Global Account\' OR Hierarchy_Placement__c = \'Regional Account\' OR Hierarchy_Placement__c = \'Regional Subsidiary Account\')';
                        this.partnerQueries.add(new PartnerQuery(QueryType.CHANNEL_PARTNER, holdQuery));
                    }

                    holdQuery = 'Select Id, (Select Id FROM Partner_Locations__r WHERE Location_Publish_Flag__c = true AND Federal_Status__c != \'Federal Only Location\' LIMIT 1)';
                    holdQuery += (isEmpty(this.stage.Partner_Industry__c))?'':', (Select Id FROM Market_Specializations__r WHERE Market_Specialization__c = \'' + this.stage.Partner_Industry__c + '\' AND Market_Specialization_Level__c != null AND Market_Specialization_Level__c != \'None\' LIMIT 1)';
                    holdQuery += ' FROM Account a WHERE Id IN (Select Account__c From Technology_Specialization__c where (Technology_Specialization__c = \'Professional and Commercial Radio\' OR Technology_Specialization__c = \'Professional and Commercial Radio\' OR Technology_Specialization__c = \'Business Radio\') AND Technology_Specialization_Level__c != \'Open\' AND (Community_Type__c = \'Value Added Reseller\' OR Community_Type__c = \'eTailer\' OR Community_Type__c = \'Direct Market Reseller\' OR Community_Type__c = \'Carrier\') AND Partner_Program__r.Status__c = \'Active\'';
                    // Added By Sathish for Separation Day 1
                    holdQuery += (isEmpty(this.stage.Partner_Technology__c))?' AND Program__c IN '+searchTrack : ''; 
                    //Ends  
                    holdQuery += ') AND Id IN (Select Account__c FROM Sales_Territory__c WHERE (Technology_Segment__c INCLUDES (\'Professional and Commercial Radio\') OR Technology_Segment__c INCLUDES (\'Professional and Commercial Radio\') OR Technology_Segment__c INCLUDES (\'Business Radio\')) ';
                    holdQuery += (isEmpty(this.stage.Partner_Region__c))?'':' AND Region__c = \'' + regionMap.get(this.stage.Partner_Region__c) + '\'';
                    holdQuery += (isEmpty(this.stage.Partner_Country__c))?'':' AND (Country__c INCLUDES (\'All NAMR Countries\') OR Country__c INCLUDES (\'' + this.stage.Partner_Country__c + '\'))';
                     /*********Added by Chanu for the  Incident -------INC0338296 ************/
                    holdQuery += (isEmpty(this.stage.Partner_State__c))?'':'AND State_Province__c = \'' + this.stage.Partner_State__c + '\'';
                    holdQuery += (isEmpty(territoryCode))?'':territoryCode;
                    holdQuery += ')'; 
                    holdQuery += ' AND RecordTypeId = \'' + this.recordTypeId + '\' AND Partner_Locator_Status__c = \'Active\' AND (Hierarchy_Placement__c = \'Global Account\' OR Hierarchy_Placement__c = \'Regional Account\' OR Hierarchy_Placement__c = \'Regional Subsidiary Account\')';
                    this.partnerQueries.add(new PartnerQuery(QueryType.CHANNEL_PARTNER, holdQuery));

                    holdQuery = 'Select Id';
                    holdQuery += (isEmpty(this.stage.Partner_Industry__c))?'':', (Select Id FROM Market_Specializations__r WHERE Market_Specialization__c = \'' + this.stage.Partner_Industry__c + '\' AND Market_Specialization_Level__c != null AND Market_Specialization_Level__c != \'None\' LIMIT 1)';
                    holdQuery += ' FROM Account a WHERE Id IN (Select Account__c From Technology_Specialization__c where Program__c = \'Mobility\' AND Technology_Specialization_Level__c != \'Open\' AND (Community_Type__c = \'Value Added Reseller\' OR Community_Type__c = \'eTailer\' OR Community_Type__c = \'Direct Market Reseller\' OR Community_Type__c = \'Carrier\') AND Partner_Program__r.Status__c = \'Active\'';
                    // Added By Sathish for Separation Day 1
                    holdQuery += (isEmpty(this.stage.Partner_Technology__c))?' AND Program__c IN '+searchTrack : ''; 
                    //Ends  
                    holdQuery += ') AND Id IN (Select Account__c FROM Partner_Location__c WHERE Location_Publish_Flag__c = true AND Federal_Status__c != \'Federal Only Location\'';
                    holdQuery += (isEmpty(this.stage.Partner_Region__c))?'':'AND Account__r.Partner_Region__c = \'' + regionMap.get(this.stage.Partner_Region__c) + '\'';
                    holdQuery += (isEmpty(this.stage.Partner_Country__c))?'':'AND Country1__c = \'' + this.stage.Partner_Country__c + '\'';
                    holdQuery += (isEmpty(this.stage.Partner_State__c))?'':'AND State__c = \'' + this.stage.Partner_State__c + '\'';
                    holdQuery += ') AND RecordTypeId = \'' + this.recordTypeId + '\' AND Partner_Locator_Status__c = \'Active\' AND (Hierarchy_Placement__c = \'Global Account\' OR Hierarchy_Placement__c = \'Regional Account\' OR Hierarchy_Placement__c = \'Regional Subsidiary Account\')';
                    this.partnerQueries.add(new PartnerQuery(QueryType.CHANNEL_PARTNER, holdQuery));
                    
                    // Nimsi test for WNS NAMR issue raised by L2
                    holdQuery = 'Select Id';
                    holdQuery += (isEmpty(this.stage.Partner_Industry__c))?'':', (Select Id FROM Market_Specializations__r WHERE Market_Specialization__c = \'' + this.stage.Partner_Industry__c + '\' AND Market_Specialization_Level__c != null AND Market_Specialization_Level__c != \'None\' LIMIT 1)';
                    holdQuery += ' FROM Account a WHERE Id IN (Select Account__c From Technology_Specialization__c where Technology_Specialization_Level__c != \'Open\' AND (Community_Type__c = \'Value Added Reseller\' OR Community_Type__c = \'eTailer\' OR Community_Type__c = \'Direct Market Reseller\' OR Community_Type__c = \'Carrier\') AND Partner_Program__r.Status__c = \'Active\'';
                    holdQuery += (isEmpty(this.stage.Partner_Technology__c))?'':' AND Technology_Specialization__c = \'' + this.stage.Partner_Technology__c + '\' AND MM_Sort_Order__c != 1 AND MM_Sort_Order__c != 2';
                    // Added By Sathish for Separation Day 1
                    holdQuery += (isEmpty(this.stage.Partner_Technology__c))?' AND Program__c IN '+searchTrack : ''; 
                    //Ends  
                    holdQuery += ') AND Id IN (Select Account__c FROM Partner_Location__c WHERE Location_Publish_Flag__c = true AND Federal_Status__c != \'Federal Only Location\'';
                    holdQuery += (isEmpty(this.stage.Partner_Region__c))?'':'AND Account__r.Partner_Region__c = \'' + regionMap.get(this.stage.Partner_Region__c) + '\'';
                    holdQuery += (isEmpty(this.stage.Partner_Country__c))?'':'AND Country1__c = \'' + this.stage.Partner_Country__c + '\'';
                     /*********Added by Chanu for the  Incident -------INC0338296 ************/
                    holdQuery += (isEmpty(this.stage.Partner_State__c))?'':'AND State__c = \'' + this.stage.Partner_State__c + '\'';
                    holdQuery += ') AND RecordTypeId = \'' + this.recordTypeId + '\' AND Partner_Locator_Status__c = \'Active\' AND (Hierarchy_Placement__c = \'Global Account\' OR Hierarchy_Placement__c = \'Regional Account\' OR Hierarchy_Placement__c = \'Regional Subsidiary Account\')';
                    this.partnerQueries.add(new PartnerQuery(QueryType.CHANNEL_PARTNER2, holdQuery));   
                                    
                    if(this.stage.E_or_G__c != 'E'){ // Added by Sathish 
                        holdQuery = 'Select Id, (Select Id From Partner_Types__r where Program__c = \'SCADA\' AND Status__c = \'Active\' AND Partner_Level__c = \'Distributor\' LIMIT 1), (Select Id FROM Product_Offered__r WHERE Product_Offering__c = \'SCADA\' AND Publish_Flag__c = true LIMIT 1)';                
                        holdQuery += (isEmpty(this.stage.Partner_Industry__c))?'':', (Select Id FROM Market_Specializations__r WHERE Market_Specialization__c = \'' + this.stage.Partner_Industry__c + '\' AND Market_Specialization_Level__c != null AND Market_Specialization_Level__c != \'None\' LIMIT 1)';
                        holdQuery += ' FROM Account a WHERE Id IN (Select Account__c FROM Partner_Location__c WHERE Location_Publish_Flag__c = true AND Federal_Status__c != \'Federal Only Location\'';
                        holdQuery += (isEmpty(this.stage.Partner_Region__c))?'':'AND Account__r.Partner_Region__c = \'' + regionMap.get(this.stage.Partner_Region__c) + '\'';
                        holdQuery += (isEmpty(this.stage.Partner_Country__c))?'':'AND Country1__c = \'' + this.stage.Partner_Country__c + '\'';
                        holdQuery += (isEmpty(this.stage.Partner_State__c))?'':'AND State__c = \'' + this.stage.Partner_State__c + '\'';
                        holdQuery += ') AND RecordTypeId = \'' + this.recordTypeId + '\' AND Partner_Locator_Status__c = \'Active\' AND (Hierarchy_Placement__c = \'Global Account\' OR Hierarchy_Placement__c = \'Regional Account\' OR Hierarchy_Placement__c = \'Regional Subsidiary Account\')';
                        this.partnerQueries.add(new PartnerQuery(QueryType.DISTRIBUTOR, holdQuery));
                    }
                    
                    holdQuery = 'Select Id';
                    holdQuery += (isEmpty(this.stage.Partner_Industry__c))?'':', (Select Id FROM Market_Specializations__r WHERE Market_Specialization__c = \'' + this.stage.Partner_Industry__c + '\' AND Market_Specialization_Level__c != null AND Market_Specialization_Level__c != \'None\' LIMIT 1)';
                    holdQuery += ' FROM Account a WHERE Id IN (Select Account__c From Technology_Specialization__c where Technology_Specialization_Level__c != \'Open\' AND (Community_Type__c = \'Value Added Distributor\' OR Community_Type__c = \'Sub-Distributor\') AND Partner_Program__r.Status__c = \'Active\' AND (Technology_Specialization__c = \'Professional and Commercial Radio\' OR Technology_Specialization__c = \'Professional and Commercial Radio\' OR Technology_Specialization__c = \'Business Radio\')';
                    holdQuery += (isEmpty(this.stage.Partner_Region__c))?'':' AND Region__c = \'' + regionMap.get(this.stage.Partner_Region__c) + '\'';
                    holdQuery += (isEmpty(this.stage.Partner_Country__c))?'':' AND Country__c INCLUDES (\'' + this.stage.Partner_Country__c + '\')';
                    holdQuery += (isEmpty(this.stage.Partner_State__c))?'':' AND State_Province__c = \'' + this.stage.Partner_State__c + '\'';
                    // Added By Sathish for Separation Day 1
                    holdQuery += (isEmpty(this.stage.Partner_Technology__c))?' AND Program__c IN '+searchTrack : ''; 
                    //Ends  
                    holdQuery += ') AND Id IN (Select Account__c FROM Partner_Location__c WHERE Location_Publish_Flag__c = true AND Federal_Status__c != \'Federal Only Location\')';
                    holdQuery += ' AND RecordTypeId = \'' + this.recordTypeId + '\' AND Partner_Locator_Status__c = \'Active\' AND (Hierarchy_Placement__c = \'Global Account\' OR Hierarchy_Placement__c = \'Regional Account\' OR Hierarchy_Placement__c = \'Regional Subsidiary Account\')';
                    this.partnerQueries.add(new PartnerQuery(QueryType.DISTRIBUTOR, holdQuery));

                    holdQuery = 'Select Id, (Select Id from Sales_Territory__r WHERE Country__c INCLUDES (\'All NAMR Countries\') LIMIT 1)';
                    holdQuery += (isEmpty(this.stage.Partner_Industry__c))?'':', (Select Id FROM Market_Specializations__r WHERE Market_Specialization__c = \'' + this.stage.Partner_Industry__c + '\' AND Market_Specialization_Level__c != null AND Market_Specialization_Level__c != \'None\' LIMIT 1)';
                    holdQuery += ' FROM Account a WHERE Id IN (Select Account__c From Technology_Specialization__c where Technology_Specialization_Level__c != \'Open\' AND (Community_Type__c = \'Value Added Distributor\' OR Community_Type__c = \'Sub-Distributor\') AND Partner_Program__r.Status__c = \'Active\' AND (Technology_Specialization__c = \'Professional and Commercial Radio\' OR Technology_Specialization__c = \'Professional and Commercial Radio\' OR Technology_Specialization__c = \'Business Radio\')';
                    holdQuery += (isEmpty(this.stage.Partner_Region__c))?'':' AND Region__c = \'' + regionMap.get(this.stage.Partner_Region__c) + '\'';
                    // Added By Sathish for Separation Day 1
                    holdQuery += (isEmpty(this.stage.Partner_Technology__c))?' AND Program__c IN '+searchTrack : ''; 
                    //Ends  
                    holdQuery += ') AND Id IN (Select Account__c FROM Partner_Location__c WHERE Location_Publish_Flag__c = true AND Federal_Status__c != \'Federal Only Location\')';
                    holdQuery += ' AND RecordTypeId = \'' + this.recordTypeId + '\' AND Partner_Locator_Status__c = \'Active\' AND (Hierarchy_Placement__c = \'Global Account\' OR Hierarchy_Placement__c = \'Regional Account\' OR Hierarchy_Placement__c = \'Regional Subsidiary Account\')';
                    this.partnerQueries.add(new PartnerQuery(QueryType.DISTRIBUTOR, holdQuery));

                    holdQuery = 'Select Id';
                    holdQuery += (isEmpty(this.stage.Partner_Industry__c))?'':', (Select Id FROM Market_Specializations__r WHERE Market_Specialization__c = \'' + this.stage.Partner_Industry__c + '\' AND Market_Specialization_Level__c != null AND Market_Specialization_Level__c != \'None\' LIMIT 1)';
                    holdQuery += ' FROM Account a WHERE Id IN (Select Account__c From Technology_Specialization__c where Technology_Specialization_Level__c != \'Open\' AND (Community_Type__c = \'Value Added Distributor\' OR Community_Type__c = \'Sub-Distributor\') AND Partner_Program__r.Status__c = \'Active\' AND Program__c = \'Mobility\'';
                    // Added By Sathish for Separation Day 1
                    holdQuery += (isEmpty(this.stage.Partner_Technology__c))?' AND Program__c IN '+searchTrack : ''; 
                    //Ends  
                    holdQuery += ') AND Id IN (Select Account__c FROM Partner_Location__c WHERE Location_Publish_Flag__c = true AND Federal_Status__c != \'Federal Only Location\'';
                    holdQuery += (isEmpty(this.stage.Partner_Region__c))?'':'AND Account__r.Partner_Region__c = \'' + regionMap.get(this.stage.Partner_Region__c) + '\'';
                    holdQuery += (isEmpty(this.stage.Partner_Country__c))?'':'AND Country1__c = \'' + this.stage.Partner_Country__c + '\'';
                    holdQuery += (isEmpty(this.stage.Partner_State__c))?'':'AND State__c = \'' + this.stage.Partner_State__c + '\'';
                    holdQuery += ') AND RecordTypeId = \'' + this.recordTypeId + '\' AND Partner_Locator_Status__c = \'Active\' AND (Hierarchy_Placement__c = \'Global Account\' OR Hierarchy_Placement__c = \'Regional Account\' OR Hierarchy_Placement__c = \'Regional Subsidiary Account\')';
                    this.partnerQueries.add(new PartnerQuery(QueryType.DISTRIBUTOR, holdQuery));
                    
                    // Nimsi test for WNS NAMR issue raised by L2 DISTRIBUTOR
                    holdQuery = 'Select Id';
                    holdQuery += (isEmpty(this.stage.Partner_Industry__c))?'':', (Select Id FROM Market_Specializations__r WHERE Market_Specialization__c = \'' + this.stage.Partner_Industry__c + '\' AND Market_Specialization_Level__c != null AND Market_Specialization_Level__c != \'None\' LIMIT 1)';
                    holdQuery += ' FROM Account a WHERE Id IN (Select Account__c From Technology_Specialization__c where Technology_Specialization_Level__c != \'Open\' AND (Community_Type__c = \'Value Added Distributor\' OR Community_Type__c = \'Sub-Distributor\') AND Partner_Program__r.Status__c = \'Active\' AND Program__c = \'WNS\'';
                    // Added By Sathish for Separation Day 1
                    holdQuery += (isEmpty(this.stage.Partner_Technology__c))?' AND Program__c IN '+searchTrack : ''; 
                    //Ends  
                    holdQuery += ') AND Id IN (Select Account__c FROM Partner_Location__c WHERE Location_Publish_Flag__c = true AND Federal_Status__c != \'Federal Only Location\'';
                    holdQuery += (isEmpty(this.stage.Partner_Region__c))?'':'AND Account__r.Partner_Region__c = \'' + regionMap.get(this.stage.Partner_Region__c) + '\'';
                    holdQuery += (isEmpty(this.stage.Partner_Country__c))?'':'AND Country1__c = \'' + this.stage.Partner_Country__c + '\'';
                    holdQuery += (isEmpty(this.stage.Partner_State__c))?'':'AND State__c = \'' + this.stage.Partner_State__c + '\'';
                    holdQuery += ') AND RecordTypeId = \'' + this.recordTypeId + '\' AND Partner_Locator_Status__c = \'Active\' AND (Hierarchy_Placement__c = \'Global Account\' OR Hierarchy_Placement__c = \'Regional Account\' OR Hierarchy_Placement__c = \'Regional Subsidiary Account\')';
                    this.partnerQueries.add(new PartnerQuery(QueryType.DISTRIBUTOR, holdQuery));
                    // Nimsi test for WNS NAMR issue raised by L2 DISTRIBUTOR                   
                }else{
                    if(this.stage.Partner_Technology__c == 'SCADA'){
                        holdQuery = 'Select Id, (Select Id FROM Product_Offered__r WHERE Product_Offering__c = \'SCADA\' AND Publish_Flag__c = true LIMIT 1)';
                        holdQuery += (isEmpty(this.stage.Partner_Industry__c))?'':', (Select Id FROM Market_Specializations__r WHERE Market_Specialization__c = \'' + this.stage.Partner_Industry__c + '\' AND Market_Specialization_Level__c != null AND Market_Specialization_Level__c != \'None\' LIMIT 1)';
                        holdQuery += ' FROM Account a WHERE Id IN (Select Account__c FROM Partner_Location__c WHERE Location_Publish_Flag__c = true AND Federal_Status__c != \'Federal Only Location\'';
                        holdQuery += ' AND Account__r.Partner_Region__c = \'NAMR\'';
                        holdQuery += (isEmpty(this.stage.Partner_Country__c))?'':' AND Country1__c = \'' + this.stage.Partner_Country__c + '\'';
                        holdQuery += (isEmpty(this.stage.Partner_State__c))?'':' AND State__c = \'' + this.stage.Partner_State__c + '\'';
                        holdQuery += ') AND Id IN (Select Account__c From Partner_Type__c where Program__c = \'SCADA\' AND Status__c = \'Active\' AND Partner_Level__c != \'Distributor\') AND RecordTypeId = \'' + this.recordTypeId + '\' AND Partner_Locator_Status__c = \'Active\' AND (Hierarchy_Placement__c = \'Global Account\' OR Hierarchy_Placement__c = \'Regional Account\' OR Hierarchy_Placement__c = \'Regional Subsidiary Account\')';
                        this.partnerQueries.add(new PartnerQuery(QueryType.CHANNEL_PARTNER, holdQuery));

                        holdQuery = 'Select Id, (Select Id FROM Product_Offered__r WHERE Product_Offering__c = \'SCADA\' AND Publish_Flag__c = true LIMIT 1)';
                        holdQuery += (isEmpty(this.stage.Partner_Industry__c))?'':', (Select Id FROM Market_Specializations__r WHERE Market_Specialization__c = \'' + this.stage.Partner_Industry__c + '\' AND Market_Specialization_Level__c != null AND Market_Specialization_Level__c != \'None\' LIMIT 1)';
                        holdQuery += ' FROM Account a WHERE Id IN (Select Account__c FROM Partner_Location__c WHERE Location_Publish_Flag__c = true AND Federal_Status__c != \'Federal Only Location\'';
                        holdQuery += ' AND Account__r.Partner_Region__c = \'NAMR\'';
                        holdQuery += (isEmpty(this.stage.Partner_Country__c))?'':' AND Country1__c = \'' + this.stage.Partner_Country__c + '\'';
                        holdQuery += (isEmpty(this.stage.Partner_State__c))?'':' AND State__c = \'' + this.stage.Partner_State__c + '\'';
                        holdQuery += ') AND Id IN (Select Account__c From Partner_Type__c where Program__c = \'SCADA\' AND Status__c = \'Active\' AND Partner_Level__c = \'Distributor\') AND RecordTypeId = \'' + this.recordTypeId + '\' AND Partner_Locator_Status__c = \'Active\' AND (Hierarchy_Placement__c = \'Global Account\' OR Hierarchy_Placement__c = \'Regional Account\' OR Hierarchy_Placement__c = \'Regional Subsidiary Account\')';
                        this.partnerQueries.add(new PartnerQuery(QueryType.DISTRIBUTOR, holdQuery));

                        holdQuery = 'Select Id, (Select Id from Sales_Territory__r WHERE Country__c INCLUDES (\'All NAMR Countries\') LIMIT 1), (Select Id FROM Product_Offered__r WHERE Product_Offering__c = \'SCADA\' AND Publish_Flag__c = true LIMIT 1)';
                        holdQuery += (isEmpty(this.stage.Partner_Industry__c))?'':', (Select Id FROM Market_Specializations__r WHERE Market_Specialization__c = \'' + this.stage.Partner_Industry__c + '\' AND Market_Specialization_Level__c != null AND Market_Specialization_Level__c != \'None\' LIMIT 1)';
                        holdQuery += ' FROM Account a WHERE Id IN (Select Account__c FROM Partner_Location__c WHERE Location_Publish_Flag__c = true AND Federal_Status__c != \'Federal Only Location\'';
                        holdQuery += ' AND Account__r.Partner_Region__c = \'NAMR\'';
                        holdQuery += ') AND Id IN (Select Account__c From Partner_Type__c where Program__c = \'SCADA\' AND Status__c = \'Active\' AND Partner_Level__c = \'Distributor\') AND RecordTypeId = \'' + this.recordTypeId + '\' AND Partner_Locator_Status__c = \'Active\' AND (Hierarchy_Placement__c = \'Global Account\' OR Hierarchy_Placement__c = \'Regional Account\' OR Hierarchy_Placement__c = \'Regional Subsidiary Account\')';
                        this.partnerQueries.add(new PartnerQuery(QueryType.DISTRIBUTOR, holdQuery));
                    }else{
                        if(this.stage.Partner_Technology__c == 'Professional and Commercial Radio' || this.stage.Partner_Technology__c == 'Professional and Commercial Radio' || this.stage.Partner_Technology__c == 'Business Radio'){
                            holdQuery = 'Select Id, (Select Id FROM Partner_Locations__r WHERE Location_Publish_Flag__c = true AND Federal_Status__c != \'Federal Only Location\' LIMIT 1)';
                            holdQuery += (isEmpty(this.stage.Partner_Industry__c))?'':', (Select Id FROM Market_Specializations__r WHERE Market_Specialization__c = \'' + this.stage.Partner_Industry__c + '\' AND Market_Specialization_Level__c != null AND Market_Specialization_Level__c != \'None\' LIMIT 1)';
                            holdQuery += ' FROM Account a WHERE Id IN (Select Account__c FROM Sales_Territory__c WHERE Id != null ';
                            holdQuery += (isEmpty(this.stage.Partner_Technology__c))?'':'AND Technology_Segment__c  INCLUDES (\'' + this.stage.Partner_Technology__c + '\')';
                            holdQuery += (isEmpty(this.stage.Partner_Region__c))?'':'AND Region__c = \'' + regionMap.get(this.stage.Partner_Region__c) + '\'';
                            holdQuery += (isEmpty(this.stage.Partner_Country__c))?'':' AND (Country__c INCLUDES (\'All NAMR Countries\') OR Country__c INCLUDES (\'' + this.stage.Partner_Country__c + '\'))';
                           
                            holdQuery += (isEmpty(territoryCode))?'':territoryCode;
                            holdQuery += ') AND Id IN (Select Account__c From Technology_Specialization__c where MM_Sort_Order__c = 1 AND Technology_Specialization_Level__c != \'Open\' AND (Community_Type__c = \'Value Added Reseller\' OR Community_Type__c = \'eTailer\' OR Community_Type__c = \'Direct Market Reseller\' OR Community_Type__c = \'Carrier\') AND Partner_Program__r.Status__c = \'Active\'';
                            holdQuery += (isEmpty(this.stage.Partner_Technology__c))?'':' AND Technology_Specialization__c LIKE \'%' + this.stage.Partner_Technology__c + '%\'';
                            holdQuery += ')';
                            holdQuery += ' AND RecordTypeId = \'' + this.recordTypeId + '\' AND Partner_Locator_Status__c = \'Active\' AND (Hierarchy_Placement__c = \'Global Account\' OR Hierarchy_Placement__c = \'Regional Account\' OR Hierarchy_Placement__c = \'Regional Subsidiary Account\')';
                            this.partnerQueries.add(new PartnerQuery(QueryType.CHANNEL_PARTNER, holdQuery));

                            holdQuery = 'Select Id, (Select Id FROM Partner_Locations__r WHERE Location_Publish_Flag__c = true AND Federal_Status__c != \'Federal Only Location\' LIMIT 1)';
                            holdQuery += (isEmpty(this.stage.Partner_Industry__c))?'':', (Select Id FROM Market_Specializations__r WHERE Market_Specialization__c = \'' + this.stage.Partner_Industry__c + '\' AND Market_Specialization_Level__c != null AND Market_Specialization_Level__c != \'None\' LIMIT 1)';
                            holdQuery += ' FROM Account a WHERE Id IN (Select Account__c FROM Sales_Territory__c WHERE Id != null ';
                            holdQuery += (isEmpty(this.stage.Partner_Technology__c))?'':'AND Technology_Segment__c  INCLUDES (\'' + this.stage.Partner_Technology__c + '\')';
                            holdQuery += (isEmpty(this.stage.Partner_Region__c))?'':'AND Region__c = \'' + regionMap.get(this.stage.Partner_Region__c) + '\'';
                            holdQuery += (isEmpty(this.stage.Partner_Country__c))?'':' AND (Country__c INCLUDES (\'All NAMR Countries\') OR Country__c INCLUDES (\'' + this.stage.Partner_Country__c + '\'))';
                           
                            holdQuery += (isEmpty(territoryCode))?'':territoryCode;
                            holdQuery += ') AND Id IN (Select Account__c From Technology_Specialization__c where MM_Sort_Order__c = 2 AND Technology_Specialization_Level__c != \'Open\' AND (Community_Type__c = \'Value Added Reseller\' OR Community_Type__c = \'eTailer\' OR Community_Type__c = \'Direct Market Reseller\' OR Community_Type__c = \'Carrier\') AND Partner_Program__r.Status__c = \'Active\'';
                            holdQuery += (isEmpty(this.stage.Partner_Technology__c))?'':' AND Technology_Specialization__c LIKE \'%' + this.stage.Partner_Technology__c + '%\'';
                            holdQuery += ')';
                            holdQuery += ' AND RecordTypeId = \'' + this.recordTypeId + '\' AND Partner_Locator_Status__c = \'Active\' AND (Hierarchy_Placement__c = \'Global Account\' OR Hierarchy_Placement__c = \'Regional Account\' OR Hierarchy_Placement__c = \'Regional Subsidiary Account\')';
                            this.partnerQueries.add(new PartnerQuery(QueryType.CHANNEL_PARTNER, holdQuery));
                            
                            holdQuery = 'Select Id, (Select Id FROM Partner_Locations__r WHERE Location_Publish_Flag__c = true AND Federal_Status__c != \'Federal Only Location\' LIMIT 1)';
                            holdQuery += (isEmpty(this.stage.Partner_Industry__c))?'':', (Select Id FROM Market_Specializations__r WHERE Market_Specialization__c = \'' + this.stage.Partner_Industry__c + '\' AND Market_Specialization_Level__c != null AND Market_Specialization_Level__c != \'None\' LIMIT 1)';
                            holdQuery += ' FROM Account a WHERE Id IN (Select Account__c FROM Sales_Territory__c WHERE Id != null ';
                            holdQuery += (isEmpty(this.stage.Partner_Technology__c))?'':'AND Technology_Segment__c  INCLUDES (\'' + this.stage.Partner_Technology__c + '\')';
                            holdQuery += (isEmpty(this.stage.Partner_Region__c))?'':'AND Region__c = \'' + regionMap.get(this.stage.Partner_Region__c) + '\'';
                            holdQuery += (isEmpty(this.stage.Partner_Country__c))?'':' AND (Country__c INCLUDES (\'All NAMR Countries\') OR Country__c INCLUDES (\'' + this.stage.Partner_Country__c + '\'))';
                            
                            holdQuery += (isEmpty(territoryCode))?'':territoryCode;
                            holdQuery += ') AND Id IN (Select Account__c From Technology_Specialization__c where MM_Sort_Order__c != 1 AND MM_Sort_Order__c != 2 AND Technology_Specialization_Level__c != \'Open\' AND (Community_Type__c = \'Value Added Reseller\' OR Community_Type__c = \'eTailer\' OR Community_Type__c = \'Direct Market Reseller\' OR Community_Type__c = \'Carrier\') AND Partner_Program__r.Status__c = \'Active\'';
                            holdQuery += (isEmpty(this.stage.Partner_Technology__c))?'':' AND Technology_Specialization__c LIKE \'%' + this.stage.Partner_Technology__c + '%\'';
                            holdQuery += ')';
                            holdQuery += ' AND RecordTypeId = \'' + this.recordTypeId + '\' AND Partner_Locator_Status__c = \'Active\' AND (Hierarchy_Placement__c = \'Global Account\' OR Hierarchy_Placement__c = \'Regional Account\' OR Hierarchy_Placement__c = \'Regional Subsidiary Account\')';
                            this.partnerQueries.add(new PartnerQuery(QueryType.CHANNEL_PARTNER, holdQuery));

                            holdQuery = 'Select Id';
                            holdQuery += (isEmpty(this.stage.Partner_Industry__c))?'':', (Select Id FROM Market_Specializations__r WHERE Market_Specialization__c = \'' + this.stage.Partner_Industry__c + '\' AND Market_Specialization_Level__c != null AND Market_Specialization_Level__c != \'None\' LIMIT 1)';
                            holdQuery += ' FROM Account a WHERE Id IN (Select Account__c From Technology_Specialization__c where Technology_Specialization_Level__c != \'Open\' AND (Community_Type__c = \'Value Added Distributor\' OR Community_Type__c = \'Sub-Distributor\') AND Partner_Program__r.Status__c = \'Active\'';
                            holdQuery += (isEmpty(this.stage.Partner_Technology__c))?'':' AND Technology_Specialization__c LIKE \'%' + this.stage.Partner_Technology__c + '%\'';
                            holdQuery += (isEmpty(this.stage.Partner_Region__c))?'':'AND Region__c = \'' + regionMap.get(this.stage.Partner_Region__c) + '\'';
                            holdQuery += (isEmpty(this.stage.Partner_Country__c))?'':'AND Country__c INCLUDES (\'' + this.stage.Partner_Country__c + '\')';
                            holdQuery += (isEmpty(this.stage.Partner_State__c))?'':'AND State_Province__c = \'' + this.stage.Partner_State__c + '\'';
                            holdQuery += ') AND Id IN (Select Account__c FROM Partner_Location__c WHERE Location_Publish_Flag__c = true AND Federal_Status__c != \'Federal Only Location\') AND RecordTypeId = \'' + this.recordTypeId + '\' AND Partner_Locator_Status__c = \'Active\' AND (Hierarchy_Placement__c = \'Global Account\' OR Hierarchy_Placement__c = \'Regional Account\' OR Hierarchy_Placement__c = \'Regional Subsidiary Account\')';
                            this.partnerQueries.add(new PartnerQuery(QueryType.DISTRIBUTOR, holdQuery));
                        }
                        if(this.stage.Partner_Technology__c != 'Radio Solutions' && this.stage.Partner_Technology__c != 'Mission Critical Radio Systems' && this.stage.Partner_Technology__c != 'Mission Critical Radio Systems' && this.stage.Partner_Technology__c != 'Professional and Commercial Radio' && this.stage.Partner_Technology__c != 'Professional and Commercial Radio' && this.stage.Partner_Technology__c != 'Business Radio' && this.stage.Partner_Technology__c != 'SCADA'){
                            holdQuery = 'Select Id';
                            holdQuery += (isEmpty(this.stage.Partner_Industry__c))?'':', (Select Id FROM Market_Specializations__r WHERE Market_Specialization__c = \'' + this.stage.Partner_Industry__c + '\' AND Market_Specialization_Level__c != null AND Market_Specialization_Level__c != \'None\' LIMIT 1)';
                            holdQuery += ' FROM Account a WHERE Id IN (Select Account__c From Technology_Specialization__c where Technology_Specialization_Level__c != \'Open\' AND (Community_Type__c = \'Value Added Reseller\' OR Community_Type__c = \'eTailer\' OR Community_Type__c = \'Direct Market Reseller\' OR Community_Type__c = \'Carrier\') AND Partner_Program__r.Status__c = \'Active\'';
                            holdQuery += (isEmpty(this.stage.Partner_Technology__c))?'':' AND Technology_Specialization__c = \'' + this.stage.Partner_Technology__c + '\' AND MM_Sort_Order__c = 1';
                            // Added By Sathish for Separation Day 1
                            holdQuery += (isEmpty(this.stage.Partner_Technology__c))?' AND Program__c IN ' +searchTrack : ''; 
                            //ENDS
                            holdQuery += ') AND Id IN (Select Account__c FROM Partner_Location__c WHERE Location_Publish_Flag__c = true AND Federal_Status__c != \'Federal Only Location\'';
                            holdQuery += (isEmpty(this.stage.Partner_Region__c))?'':'AND Account__r.Partner_Region__c = \'' + regionMap.get(this.stage.Partner_Region__c) + '\'';
                            holdQuery += (isEmpty(this.stage.Partner_Country__c))?'':'AND Country1__c = \'' + this.stage.Partner_Country__c + '\'';
                            holdQuery += (isEmpty(this.stage.Partner_State__c))?'':'AND State__c = \'' + this.stage.Partner_State__c + '\'';
                            holdQuery += ') AND RecordTypeId = \'' + this.recordTypeId + '\' AND Partner_Locator_Status__c = \'Active\' AND (Hierarchy_Placement__c = \'Global Account\' OR Hierarchy_Placement__c = \'Regional Account\' OR Hierarchy_Placement__c = \'Regional Subsidiary Account\')';
                            this.partnerQueries.add(new PartnerQuery(QueryType.CHANNEL_PARTNER, holdQuery));

                            holdQuery = 'Select Id';
                            holdQuery += (isEmpty(this.stage.Partner_Industry__c))?'':', (Select Id FROM Market_Specializations__r WHERE Market_Specialization__c = \'' + this.stage.Partner_Industry__c + '\' AND Market_Specialization_Level__c != null AND Market_Specialization_Level__c != \'None\' LIMIT 1)';
                            holdQuery += ' FROM Account a WHERE Id IN (Select Account__c From Technology_Specialization__c where Technology_Specialization_Level__c != \'Open\' AND (Community_Type__c = \'Value Added Reseller\' OR Community_Type__c = \'eTailer\' OR Community_Type__c = \'Direct Market Reseller\' OR Community_Type__c = \'Carrier\') AND Partner_Program__r.Status__c = \'Active\'';
                            holdQuery += (isEmpty(this.stage.Partner_Technology__c))?'':' AND Technology_Specialization__c = \'' + this.stage.Partner_Technology__c + '\' AND MM_Sort_Order__c = 2';
                            // Added By Sathish for Separation Day 1
                            holdQuery += (isEmpty(this.stage.Partner_Technology__c))?' AND Program__c IN ' +searchTrack : ''; 
                            //Ends  
                            holdQuery += ') AND Id IN (Select Account__c FROM Partner_Location__c WHERE Location_Publish_Flag__c = true AND Federal_Status__c != \'Federal Only Location\'';
                            holdQuery += (isEmpty(this.stage.Partner_Region__c))?'':'AND Account__r.Partner_Region__c = \'' + regionMap.get(this.stage.Partner_Region__c) + '\'';
                            holdQuery += (isEmpty(this.stage.Partner_Country__c))?'':'AND Country1__c = \'' + this.stage.Partner_Country__c + '\'';
                            holdQuery += (isEmpty(this.stage.Partner_State__c))?'':'AND State__c = \'' + this.stage.Partner_State__c + '\'';
                            holdQuery += ') AND RecordTypeId = \'' + this.recordTypeId + '\' AND Partner_Locator_Status__c = \'Active\' AND (Hierarchy_Placement__c = \'Global Account\' OR Hierarchy_Placement__c = \'Regional Account\' OR Hierarchy_Placement__c = \'Regional Subsidiary Account\')';
                            this.partnerQueries.add(new PartnerQuery(QueryType.CHANNEL_PARTNER, holdQuery));

                            holdQuery = 'Select Id';
                            holdQuery += (isEmpty(this.stage.Partner_Industry__c))?'':', (Select Id FROM Market_Specializations__r WHERE Market_Specialization__c = \'' + this.stage.Partner_Industry__c + '\' AND Market_Specialization_Level__c != null AND Market_Specialization_Level__c != \'None\' LIMIT 1)';
                            holdQuery += ' FROM Account a WHERE Id IN (Select Account__c From Technology_Specialization__c where Technology_Specialization_Level__c != \'Open\' AND (Community_Type__c = \'Value Added Reseller\' OR Community_Type__c = \'eTailer\' OR Community_Type__c = \'Direct Market Reseller\' OR Community_Type__c = \'Carrier\') AND Partner_Program__r.Status__c = \'Active\'';
                            holdQuery += (isEmpty(this.stage.Partner_Technology__c))?'':' AND Technology_Specialization__c = \'' + this.stage.Partner_Technology__c + '\' AND MM_Sort_Order__c != 1 AND MM_Sort_Order__c != 2';
                            // Added By Sathish for Separation Day 1
                            holdQuery += (isEmpty(this.stage.Partner_Technology__c))?' AND Program__c IN '+searchTrack : ''; 
                            //Ends  
                            holdQuery += ') AND Id IN (Select Account__c FROM Partner_Location__c WHERE Location_Publish_Flag__c = true AND Federal_Status__c != \'Federal Only Location\'';
                            holdQuery += (isEmpty(this.stage.Partner_Region__c))?'':'AND Account__r.Partner_Region__c = \'' + regionMap.get(this.stage.Partner_Region__c) + '\'';
                            holdQuery += (isEmpty(this.stage.Partner_Country__c))?'':'AND Country1__c = \'' + this.stage.Partner_Country__c + '\'';
                            holdQuery += (isEmpty(this.stage.Partner_State__c))?'':'AND State__c = \'' + this.stage.Partner_State__c + '\'';
                            holdQuery += ') AND RecordTypeId = \'' + this.recordTypeId + '\' AND Partner_Locator_Status__c = \'Active\' AND (Hierarchy_Placement__c = \'Global Account\' OR Hierarchy_Placement__c = \'Regional Account\' OR Hierarchy_Placement__c = \'Regional Subsidiary Account\')';
                            this.partnerQueries.add(new PartnerQuery(QueryType.CHANNEL_PARTNER2, holdQuery));

                            holdQuery = 'Select Id';
                            holdQuery += (isEmpty(this.stage.Partner_Industry__c))?'':', (Select Id FROM Market_Specializations__r WHERE Market_Specialization__c = \'' + this.stage.Partner_Industry__c + '\' AND Market_Specialization_Level__c != null AND Market_Specialization_Level__c != \'None\' LIMIT 1)';
                            holdQuery += ' FROM Account a WHERE Id IN (Select Account__c From Technology_Specialization__c where Technology_Specialization_Level__c != \'Open\' AND (Community_Type__c = \'Value Added Distributor\' OR Community_Type__c = \'Sub-Distributor\') AND Partner_Program__r.Status__c = \'Active\'';
                            holdQuery += (isEmpty(this.stage.Partner_Technology__c))?'':' AND Technology_Specialization__c = \'' + this.stage.Partner_Technology__c + '\'';
                            // Added By Sathish for Separation Day 1
                            holdQuery += (isEmpty(this.stage.Partner_Technology__c))?' AND Program__c IN '+searchTrack : ''; 
                            //Ends  
                            holdQuery += ') AND Id IN (Select Account__c FROM Partner_Location__c WHERE Location_Publish_Flag__c = true AND Federal_Status__c != \'Federal Only Location\'';
                            holdQuery += (isEmpty(this.stage.Partner_Region__c))?'':'AND Account__r.Partner_Region__c = \'' + regionMap.get(this.stage.Partner_Region__c) + '\'';
                            holdQuery += (isEmpty(this.stage.Partner_Country__c))?'':'AND Country1__c = \'' + this.stage.Partner_Country__c + '\'';
                            holdQuery += (isEmpty(this.stage.Partner_State__c))?'':'AND State__c = \'' + this.stage.Partner_State__c + '\'';
                            holdQuery += ') AND RecordTypeId = \'' + this.recordTypeId + '\' AND Partner_Locator_Status__c = \'Active\' AND (Hierarchy_Placement__c = \'Global Account\' OR Hierarchy_Placement__c = \'Regional Account\' OR Hierarchy_Placement__c = \'Regional Subsidiary Account\')';
                            this.partnerQueries.add(new PartnerQuery(QueryType.DISTRIBUTOR, holdQuery));
                        }                                       
                    }
                }           
            }
            
            for(PartnerQuery pq : this.partnerQueries){
                if(pq.query.containsIgnoreCase('FROM Technology_Specializations__r')){
                    pq.objTypeSet.add(Obj.TECH_SPEC);
                }
                if(pq.query.containsIgnoreCase('FROM Market_Specializations__r')){
                    pq.objTypeSet.add(Obj.MARKET_SPEC);
                }
                if(pq.query.containsIgnoreCase('FROM Partner_Types__r')){
                    pq.objTypeSet.add(Obj.PARTNER_TYPE);
                }
                if(pq.query.containsIgnoreCase('FROM Partner_Locations__r')){
                    pq.objTypeSet.add(Obj.PARTNER_LOCATION);
                }
                if(pq.query.containsIgnoreCase('FROM Product_Offered__r')){
                    pq.objTypeSet.add(Obj.PRODUCT_OFFERED);
                }
                if(pq.query.containsIgnoreCase('FROM Sales_Territory__r')){
                    pq.objTypeSet.add(Obj.SALES_TERRITORY);
                }
            }
        }

        public Boolean isEmpty(String s){
            return (s == null || s == '')?true:false;
        }
    }
    
    public enum Obj {TECH_SPEC, MARKET_SPEC, PARTNER_TYPE, PARTNER_LOCATION, PRODUCT_OFFERED, SALES_TERRITORY}
    public enum QueryType {CHANNEL_PARTNER, CHANNEL_PARTNER2, DISTRIBUTOR, APP_PARTNER, CHANNEL_APP, CHANNEL_APP2}
    
    public class PartnerQuery{
        public Set<Obj> objTypeSet {get;set;}
        public QueryType queryType {get;set;}
        public String query {get;set;}
        
        public PartnerQuery(QueryType queryType, String query){
            this.objTypeSet = new Set<Obj>();
            this.queryType = queryType;
            this.query = query;
        }
    }
    
    public class DeepLinking{
        public String loc {get;set;}
        public String countryCode {get;set;}
        public String technology {get;set;}
        public String industry {get;set;}
        public String dest {get;set;}
        public String appId {get;set;}
        public String partnerId {get;set;}
        public String country {get;set;}
        public String languageCode {get;set;}
        public String defaultCountry {get;set;}
        public String region {get;set;}
        public String os {get;set;}
        public String model {get;set;}
        public Boolean hasAccessToApplication {get;set;}
        public Boolean shouldRunSearch {get;set;}
        public Boolean isAppX {get;set;}
        public Boolean showActive {get;set;}
        public String business {get;set;}


        public String currentPage {get;set;}
        public String allParams {get;set;}
        
        public DeepLinking(){
            this.languageCode = 'en';
            this.hasAccessToApplication = true;
            this.region = 'North America';
            this.country = 'United States';
            this.defaultCountry = 'United States';
            this.allParams = '';
            
            Boolean cameFromMarketPlacePage = (getP('cameFromMarketPlacePage') == '')?false:true;
            if(validateStringForXSS(getP('loc'))){
                this.loc = getP('loc');
                this.loc = (this.loc == '')?'US-EN':this.loc;
                this.loc = this.loc.toUpperCase();
            }else{
                this.loc = 'US-EN';
            }
            
            if(validateStringForXSS(getP('region')))
                this.region = getP('region');
            
            if(validateStringForXSS(getP('country')))
                this.countryCode = getP('country');
            
            if(validateStringForXSS(getP('country')))
                this.country = getP('country');
            
            if(validateStringForXSS(getP('technology')))
                this.technology = getP('technology');
            
            if(validateStringForXSS(getP('industry')))
                this.industry = getP('industry');
            
            if(validateStringForXSS(getP('dest')))
                this.dest = getP('dest');
            
            if(validateStringForXSS(getP('appId')))
                this.appId = getP('appId');
            
            if(validateStringForXSS(getP('partnerId')))
                this.partnerId = getP('partnerId');
            
            if(validateStringForXSS(getP('languageCode')))
                this.languageCode = getP('languageCode');
            
            if(validateStringForXSS(getP('os')))
                this.os =getP('os');
            
            if(validateStringForXSS(getP('model')))
            this.model = getP('model');
            
            if(validateStringForXSS(getP('appx')))
                this.isAppX = (getP('appx') == '' || getP('appx') == 'false')?false:true;
            
            if(validateStringForXSS(getP('showActive')))
                this.showActive = (getP('showActive') == '' || getP('showActive') == 'false')?false:true;
            
            if(validateStringForXSS(getP('business')))
            {
               //this.business = getP('business') == '' ? 'G':getP('business');
               this.business = (getP('business') == '') || (getP('business') == 'E')? 'G':getP('business'); // Added by Ananth as a part of INC0671758 
             }   
            if(!cameFromMarketPlacePage){
                for(MM_Country_Mapping__c cm : MM_Country_Mapping__c.getall().values()){
                    if(cm.Code__c.equalsIgnoreCase(this.countryCode)){
                        this.country = cm.name;
                        break;
                    }               
                }
            
                for(MM_Locale_Mapping__c lm : MM_Locale_Mapping__c.getall().values()){
                    if(lm.name == this.loc){
                        if(this.country == ''){
                            this.country = lm.Default_Country__c;
                            this.defaultCountry = lm.Default_Country__c;
                        }
                        this.languageCode = lm.Language_Code__c;
                        this.region = lm.Region__c;
                        break;
                    }
                }
            }
            
            for(MM_Region_To_App_Map__c ram : MM_Region_To_App_Map__c.getall().values()){
                if(ram.name == this.region){
                    this.hasAccessToApplication = ram.Has_Access__c;
                    break;
                }
            }
            
            String fullURL = (ApexPages.currentPage().getUrl() == null)?'MM_PartnerFinderHome':ApexPages.currentPage().getUrl();
            
            System.debug('fullURL:  ' + fullURL);
            this.currentPage = (fullUrl == null || fullURL.containsIgnoreCase('MM_PartnerFinderHome'))?'partner':'application';
            
            String[] splitString = fullURL.split('\\?');
            if(splitString.size() > 1){
                this.allParams = splitString[1];
            }
            
            
            if(this.currentPage == 'partner' && (this.dest == 'Channel' || this.dest == 'Distributor' || this.dest == 'AppPartner' || this.dest == 'Channel Application')){
                this.shouldRunSearch = true;
            }else{
                this.shouldRunSearch = false;
            }
        }
        
        public String getP(String s){
            return (ApexPages.currentPage().getParameters().get(s) == null)?'':ApexPages.currentPage().getParameters().get(s);
        }
        
        private boolean validateStringForXSS(String inputString){
            boolean isValid=true;
            String xssString = '(<)|((<)[^\n]+(>)|(>))';
            Pattern xssPattern = Pattern.compile(xssString);
            Matcher matchInputString = xssPattern.matcher(inputString.toUpperCase());
            if(matchInputString.find()){
                System.Debug('*** XSS matches & returns False');
                return false;
            }
            return isValid; 
        }
    }
    
    public class QuickLinkPanel{
        public Integer totalLinks;
        public List<QuickLink> partnerLinks {get;set;}
        public List<QuickLink> enterpriseAppLinks {get;set;} // Modified by Nimesh for MOTOTRBO Changes
        public List<QuickLink> radioAppLinks {get;set;} // Modified by Nimesh for MOTOTRBO Changes
        public List<QuickLink> applicationLinks {get;set;} // Added by Sathish For Day 1

        
        public QuickLinkPanel(){
            this.partnerLinks = new List<QuickLink>();
            this.applicationLinks = new List<QuickLink>();
           // this.enterpriseAppLinks = new List<QuickLink>(); // Modified by Nimesh for MOTOTRBO Changes
           // this.radioAppLinks = new List<QuickLink>(); // Modified by Nimesh for MOTOTRBO Changes
            
            
        }
        
        public Integer getTotalLinks(){
            // Modified by Nimesh for MOTOTRBO Changes
            return (this.partnerLinks.size() + this.applicationLinks.size());
        }
    }
    
    public class QuickLink{
        public String id {get;set;}
        public URL url {get;set;}
        
        public QuickLink(String id, String name, Boolean isApplication, String allParams){
            this.id = id;
            String tempUrl = (isApplication)?'MM_appFinderHome?appId=':'MM_PartnerFinderHome?partnerId=';
            tempUrl += this.id + '&' + allParams;
            this.url = new URL(tempUrl, name);
        }
    }
    
    public class Paginate{
        public Integer index {get;set;}
        public Integer pageNum {get;set;}
        public Integer totalPage {get;set;}
        public Integer totalResults {get;set;}
        public List<Pager> pageList {get;set;}
        public Boolean showPrevious {get;set;}
        public Boolean showNext {get;set;}
        public Boolean isAll {get;set;}
        
        public Paginate(Integer listSize, Integer pageSize){
            this.totalResults = listSize;
            pageSize = (pageSize > 0)?pageSize:Integer.valueOf(System.Label.MM_PageSize);
            this.totalPage = (Integer)Math.ceil((Double)listSize / (Double)pageSize);
            // Start of Added by Nimesh for List out of bounds exception - the number of results we show are limited to 100
            if(totalPage > Integer.valueOf(System.Label.MM_PageSize)){
              totalPage = Integer.valueOf(System.Label.MM_PageSize);
            }
            // End of Added by Nimesh for List out of bounds exception - the number of results we show are limited to 100
            this.pageNum = 1;
            this.index = 0;
            this.isAll = (listSize == pageSize)?true:false;
            updateNumbers();
        }
        
        public void updateNumbers(){
            this.pageList = new List<Pager>();
            for(Integer i = 1; i < (this.totalPage + 1); i++){
                Boolean b = (i == pageNum)?true:false;
                this.pageList.add(new Pager(i, b));
            }
            this.showPrevious = (this.pageNum == 1)?false:true;
            this.showNext = (this.pageNum == this.totalPage)?false:true;
            this.index = this.pageNum - 1;
        }
        
        public void decrement(){
            this.pageNum = this.pageNum - 1;
            updateNumbers();
        }

        public void increment(){
            this.pageNum++;
            updateNumbers();
        }
    }
    
    public class Pager{
        public Integer pageNum {get;set;}
        public Boolean isActive {get;set;}
        
        public Pager(Integer num, Boolean active){
            this.pageNum = num;
            this.isActive = active;
        }
    }
    
    // Added by Sathish for MOTOTRBO AP Enhancement STARTS
    /*public PageReference enterpriseClicked(){
        this.selectedAppSubPageState=this.subPageStateMap.get(State.ENTERPRISE_SOFTWARE); 
        //this.populateSubPageState(State.ENTERPRISE_SOFTWARE);
        return appSearch();
    }
    
    public PageReference radioClicked(){
        this.selectedAppSubPageState=this.subPageStateMap.get(State.RADIO_SOFTWARE); 
        //this.populateSubPageState(State.RADIO_SOFTWARE);
        return appSearch();
    }*/
    
    //Added by Sathish
    public void populateTechTrackMap(){
      
        Map<String,String> techTrackMap = new Map<String,String>();
        Map<String, MM_Technology_Track_Map__c> techTrackSettings= MM_Technology_Track_Map__c.getAll();
        if(techTrackSettings!=null && !techTrackSettings.isEmpty()){
            for(String tech:techTrackSettings.keyset()){
                techTrackMap.put(tech,techTrackSettings.get(tech).Track__c);
            }
        } 
        this.technologyToTrackMap.putAll(techTrackMap);
       
    }
    
    /*Commenting as part of SF-491 - Delete unused custom objects - Start
    public List<ApplicationDataStripped> categorizeAppFinderResults(Set<ID> idsToReturn, Map<Id, CustomApplication> customAppMap,Map<Id, Decimal> acctIdToSortMap,Map<Id, Id> softwareToLogoMap){ End*/
    public List<ApplicationDataStripped> categorizeAppFinderResults(Set<ID> idsToReturn, Map<Id, CustomApplication> customAppMap,Map<Id, Decimal> acctIdToSortMap){
    
        List<ApplicationDataStripped> finalList = new List<ApplicationDataStripped>();
        Set<Id> qlIds = this.getApplicationQLIds();
        
        for(Id appId : idsToReturn){
            ApplicationDataStripped ad = new ApplicationDataStripped();
            ad.hasTechnology = (isEmpty(this.appSearch.stage.Technology__c))?false:true;
            //ad.application = customAppMap.get(appId).app;
            ad.appId = appId;
            ad.isInQuickList = (qlIds.contains(appId))? true:false;

            /*if(!isEmpty(this.appSearch.stage.Technology__c) && acctIdToSortMap.containsKey(ad.application.Account_C__c)){
                ad.techSpecSort = acctIdToSortMap.get(ad.application.Account_C__c);
            }*/
            
            //ad.metalLevelSort = customAppMap.get(appId).app.Account_C__r.Metal_Level_Sort__c;
            //ad.motorolaTestSort = customAppMap.get(appId).app.MM_Motorola_Tested_Sort__c;
            //ad.motorolaTested = customAppMap.get(appId).app.Motorola_Tested__c;
              //Added by Sathish
           /*for(Supported_Products__c device :customAppMap.get(appId).supportedProducts){
               //ad.supportedProducts.add(device.Technology_Segment__c);
               
                   if(ad.supportedProducts.add(device.Technology_Segment__c)){
                       //Modified by Sathish for Day 1 Starts
                       if((this.technologyToTrackMap.get(device.Technology_Segment__c) == 'RADIO' && this.appSearch.stage.E_or_G__c == 'G' )
                        || ((this.technologyToTrackMap.get(device.Technology_Segment__c) == 'WNS' || this.technologyToTrackMap.get(device.Technology_Segment__c) == 'Mobility' ) && this.appSearch.stage.E_or_G__c == 'E') ){
                            ad.supportedDevice.add(device);
                       
                     }
                     //Modified by Sathish for Day 1 Ends
                  }   
            }*/
            
            //System.debug(LoggingLevel.ERROR,'ad.supportedProducts:  ' + ad.supportedProducts);
            //System.debug(LoggingLevel.ERROR,'ad.supportedDevice:  ' + ad.supportedDevice);
            
            //System.debug(LoggingLevel.ERROR,'ad.application.name:  ' + ad.application.name);
           // System.debug(LoggingLevel.ERROR,'ad.motorolaTestSort:  ' + ad.motorolaTestSort);
           // System.debug('ad.metalLevelSort:  ' + ad.metalLevelSort);
            
            /*Commenting as part of SF-491 - Delete unused custom objects - Start
            if(softwareToLogoMap != null){
                ad.appIconUrl = (softwareToLogoMap.containsKey(appId))?'/servlet/servlet.FileDownload?file=' + softwareToLogoMap.get(appId):'';
            }
            Commenting as part of SF-491 - Delete unused custom objects - End*/           
            finalList.add(ad);
        }    
        return finalList;
    }
    
     public Set<ID> findApplicationType(Set<ID> idsToReturn,Map<Id, CustomApplication> customAppMap,String appType){
        Set<ID> result = new Set<ID>();
        
         Map<String,String> appTypeMap=getAppTypes();
        for(ID appId : idsToReturn){
            // Display s/w w/o products - Removed after discussing with business Sathish
           /* if(appType == this.subPageStateMap.get(State.ENTERPRISE_SOFTWARE) && (customAppMap.get(appId).supportedProducts == null || customAppMap.get(appId).supportedProducts.size()==0 )){
                 result.add(appId);
            }*/
            /*for(Supported_Products__c sp : customAppMap.get(appId).supportedProducts){
                if(appTypeMap.get(sp.Technology_Segment__c) == appType ){
                    result.add(appId);
                 }   
                    // Start of Added by Nimesh for List out of bounds exception - the number of results we show are limited to 100
                   // if(result.size() < 100){
                      //result.add(appId);
                  // }
                    // End of Added by Nimesh for List out of bounds exception - the number of results we show are limited to 100
            }*/
            
        }
       // System.debug(LoggingLevel.ERROR,'findApplicationType result SIZE :  ' + result.size());

        return result;
    }
    
    public Map<String,String> getAppTypes(){
       Map<String,String> appTypeMap= new Map<String,String>();
        System.debug(LoggingLevel.ERROR,'getAppTypesresult technologyToTrackMap :  ' + this.technologyToTrackMap); 
        for(String technology : this.technologyToTrackMap.keySet()){
            if(this.technologyToTrackMap.get(technology) == 'WNS' || this.technologyToTrackMap.get(technology) == 'Mobility'){
                appTypeMap.put(technology,this.subPageStateMap.get(State.ENTERPRISE_SOFTWARE));
            }
            if(this.technologyToTrackMap.get(technology) == 'RADIO' ){
                appTypeMap.put(technology,this.subPageStateMap.get(State.RADIO_SOFTWARE));
            }
        }
        return appTypeMap;
    }
    
    // Added by Ananth as part of INC0671758 
     public List<SelectOption> AppBusinessGrp{
    get {
        return this.GENAppBusinessGrp();
          } 
    private set;
    }
    Public List<SelectOption> GENAppBusinessGrp()
    {
        List<SelectOption> AppBG = new List<SelectOption>();
        Schema.DescribeFieldResult techPicklist = MM_Staging__c.E_or_G__c.getDescribe();
          List<Schema.PicklistEntry> techLOVs = techPicklist.getPicklistValues();
        
                  for(Schema.PicklistEntry entry:techLOVs ){
                      if(entry.getValue()=='Mobile and Wireless Network' || entry.getValue()=='E'){
                           AppBG.add(new SelectOption(entry.getValue(), Label.MM_Enterprise_Group ));
                     }
                  }
              
       
        return AppBG;
    }
    
    // Ended by Ananth as part of INC0671758 
    
    /*public void populateAppFinderPageSubState(Set<ID> entperiseAppIds,Set<ID> radioAppIds,String selectedTechnology){
        Map<String,String> appTypeMap=getAppTypes();
       
        if(this.selectedAppSubPageState!=null){
            this.subPageState = this.selectedAppSubPageState;
            return;
        }
        if(appTypeMap.get(selectedTechnology)== null && entperiseAppIds!=null && entperiseAppIds.size()>0){
             this.populateSubPageState(State.ENTERPRISE_SOFTWARE);
        }else if(appTypeMap.get(selectedTechnology)== null && radioAppIds!=null && radioAppIds.size()>0){
             this.populateSubPageState(State.RADIO_SOFTWARE);
        }else if (appTypeMap.get(selectedTechnology)!= null){
            this.subPageState = appTypeMap.get(selectedTechnology);
        }
    }
    public PageReference appSearchAll(){
        //this.selectedAppSubPageState=null;
        return appSearch();
    }*/
   /* 
   public String getAllTechnology(String businessGroup){
   
       List<String> entTechnologyList=new List<String>();
       List<String> govTechnologyList=new List<String>();

       String result='';
       
       for(String technology : this.technologyToTrackMap.keySet()){
       
            if(this.technologyToTrackMap.get(technology) == 'WNS' || this.technologyToTrackMap.get(technology) == 'Mobility'){
                entTechnologyList.add(technology);
            }
            else if(this.technologyToTrackMap.get(technology) == 'RADIO' ){
                govTechnologyList.add(technology);                  
            }
            
            if(businessGroup == 'E'){
                for(Integer i=0;i<entTechnologyList.size();i++){
                    if(i==0){
                        result=result+'(';
                    }
                    result=result+'\''+result+'\'';
                    
                    if(i== (entTechnologyList.size()-1)){
                        result=result+')';
                    }else{
                        result=result+',';
                    }

                }
            }else{
                for(Integer i=0;i<govTechnologyList.size();i++){
                    if(i==0){
                        result=result+'('+'\'';
                    }
                    result=result+'\''+result+'\'';
                    
                    if(i== (govTechnologyList.size()-1)){
                        result=result+')';
                    }else{
                        result=result+',';
                    }
                    
                }           
            }
      
       }
       return result ;
   }*/
    
    // Added by Sathish for MOTOTRBO AP Enhancement ENDS
}