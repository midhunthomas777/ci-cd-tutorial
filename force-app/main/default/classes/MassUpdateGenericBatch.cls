global class MassUpdateGenericBatch implements Database.Batchable<sobject>{
    
    public Map<Id,List<OpportunityFieldHistory>> fieldHistoryMap = new Map<Id,List<OpportunityFieldHistory>>();
    public Map<Id,List<PreSales__c>> oppwithPreSaleMap = new Map<Id,List<PreSales__c>>();
    public List<Opportunity> opportunitiesForUpdates = new List<Opportunity>();
    Public Set<Opportunity> newOpportunitiesSet = new Set<Opportunity>();
    Public List<CompetitiveDB__c> competitorsForInsert = new List<CompetitiveDB__c>();
    Public List<CompetitiveDB__c> competitorsForUpdate = new List<CompetitiveDB__c>();
    public String finalQuery;
    public String batchClassName;
    public Boolean dmlPerform = false;
    
    global MassUpdateGenericBatch(String query,String batchName,Boolean dmlExecute){
        finalQuery = query; 
        batchClassName = batchName;
        dmlPerform = dmlExecute;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(finalQuery);
    }
    global void execute(Database.BatchableContext BC, List<sobject> scope) {
        if(batchClassName == 'CloseDateCounterBatch'){
            List<OpportunityFieldHistory> oppFieldList = new List<OpportunityFieldHistory>();
            if(scope != null) oppFieldList = (List<OpportunityFieldHistory>) scope;
            for(OpportunityFieldHistory fieldHistory : oppFieldList)
            {
                if(fieldHistoryMap.containsKey(fieldHistory.OpportunityId)){
                    List<OpportunityFieldHistory> historyList = fieldHistoryMap.get(fieldHistory.OpportunityId);
                    historyList.add(fieldHistory);
                    fieldHistoryMap.PUT(fieldHistory.OpportunityId,historyList);    
                }else{
                    fieldHistoryMap.PUT(fieldHistory.OpportunityId,new List<OpportunityFieldHistory>{fieldHistory});    
                }
            }
            
            if(!fieldHistoryMap.isEmpty()){
                for(Id oppId : fieldHistoryMap.keyset()){
                    Integer closeDateCount = 0;
                    for(OpportunityFieldHistory historyRecord : fieldHistoryMap.get(oppId)){
                        if(Date.valueOf(historyRecord.NewValue) > Date.valueOf(historyRecord.OldValue)){
                            closeDateCount++;
                        }
                    }
                    opportunitiesForUpdates.add(new Opportunity(Id = oppId,Close_Date_Push_Counter__c = closeDateCount));
                }
            }
            
            // 122 opportunitiesForUpdates records for update in UAT
            System.debug('opportunitiesForUpdates = '+opportunitiesForUpdates.size());
            if(!opportunitiesForUpdates.isEmpty() && dmlPerform){
                update opportunitiesForUpdates;
            }
        }
        // VESTA_SPILLMAN_INT-270 : Used to update the existing Opportunity records Days in Stage Field.
        // Query : SELECT Field, CreatedDate,  OpportunityId , newvalue, oldvalue FROM OpportunityFieldHistory  where Field = 'StageName' order By CreatedDate DESC
        else if(batchClassName == 'DaysInStageBatch'){
            List<OpportunityFieldHistory> oppFieldList = new List<OpportunityFieldHistory>();
            if(scope != null) oppFieldList = (List<OpportunityFieldHistory>) scope;
            for(OpportunityFieldHistory fieldHistory : oppFieldList)
            {
                if(fieldHistoryMap.containsKey(fieldHistory.OpportunityId)){
                    List<OpportunityFieldHistory> historyList = fieldHistoryMap.get(fieldHistory.OpportunityId);
                    historyList.add(fieldHistory);
                    fieldHistoryMap.PUT(fieldHistory.OpportunityId,historyList);    
                }else{
                    fieldHistoryMap.PUT(fieldHistory.OpportunityId,new List<OpportunityFieldHistory>{fieldHistory});    
                }
            }
            
            if(!fieldHistoryMap.isEmpty())
            {
                for(Id oppId : fieldHistoryMap.keyset()){
                    DateTime dateChagedTo;
                    dateChagedTo = fieldHistoryMap.get(oppId)[0].CreatedDate;
                    system.debug('dateChagedTo>>>'+dateChagedTo);
                    opportunitiesForUpdates.add(new Opportunity(Id = oppId,Date_Changed_to_Current_Stage__c = dateChagedTo));
                }
            }
            
            //UAT: 242000 opportunitiesForUpdates records for update in UAT
            System.debug('opportunitiesForUpdates = '+opportunitiesForUpdates.size());
            if(!opportunitiesForUpdates.isEmpty() && dmlPerform){
                update opportunitiesForUpdates;
            }        
        }        
        else if(batchClassName == 'ProposalDueDateBatch'){
            List<PreSales__c> presalesList = new List<PreSales__c>();
            if(scope != null) presalesList = (List<PreSales__c>) scope;
            for(PreSales__c preSale : presalesList)
            {
                if(oppwithPreSaleMap.containsKey(preSale.Opportunity__c)){
                    List<PreSales__c> preSaleData = oppwithPreSaleMap.get(preSale.Opportunity__c);
                    preSaleData.add(preSale);
                    oppwithPreSaleMap.put(preSale.Opportunity__c,preSaleData);
                }else{
                    List<PreSales__c> preSaleData =  new List<PreSales__c>();
                    preSaleData.add(preSale);
                    oppwithPreSaleMap.put(preSale.Opportunity__c,preSaleData);
                }    
            }
            
            if(!oppwithPreSaleMap.isEmpty()){
                for(Id oppId : oppwithPreSaleMap.keySet()){
                    Integer revisionNumber;
                    Integer count = 0;
                    Date propsalDate;
                    for(PreSales__c preSale : oppwithPreSaleMap.get(oppId)){
                        if(count != 0){
                            System.debug('inside if...'+count + '&&'+ preSale.Revision_Number__c);
                            if(preSale.Revision_Number__c > revisionNumber){
                                revisionNumber = Integer.valueOf(preSale.Revision_Number__c);
                                propsalDate = preSale.RFx_Proposal_Due_Date__c;
                            }
                        }else{
                            System.debug('inside else...'+count + '&&'+ revisionNumber);
                            revisionNumber = Integer.valueOf(preSale.Revision_Number__c);
                            propsalDate = preSale.RFx_Proposal_Due_Date__c;
                        }
                        count++;
                    }
                    System.debug('final value..'+propsalDate);
                    opportunitiesForUpdates.add(new Opportunity(Id=oppId,RFx_Proposal_Due_Date__c=propsalDate));
                }
                //25145 opportunitiesForUpdates records in UAT
                System.debug('opportunitiesForUpdates size = '+opportunitiesForUpdates.size());
                System.debug('dmlPerform == '+dmlPerform);
                if(!opportunitiesForUpdates.isEmpty() && dmlPerform){
                    update opportunitiesForUpdates;
                }    
            }
        }
        else if(batchClassName == 'IncumbentCompetitorBatch'){
            List<Opportunity> opportunityList = new List<Opportunity>();
            if(scope != null) opportunityList = (List<Opportunity>) scope;
            Set<Id> competitorVendorSet;
            
            for(Opportunity opp : opportunityList){
                competitorVendorSet = new Set<Id>();
                if(opp.Competitive_DB_Records__r.isEmpty()){
                    CompetitiveDB__c compt = new CompetitiveDB__c();
                    compt.Competitive_Vendor__c = opp.Incumbent_Lookup__c;
                    compt.Related_Opportunity__c = opp.Id;
                    competitorsForInsert.add(compt);
                }else {
                    for(CompetitiveDB__c eachCompetitor : opp.Competitive_DB_Records__r) {
                        competitorVendorSet.add(eachCompetitor.Competitive_Vendor__c);
                    }
                    if(!competitorVendorSet.contains(opp.Incumbent_Lookup__c)) {
                        CompetitiveDB__c compt = new CompetitiveDB__c();
                        compt.Competitive_Vendor__c = opp.Incumbent_Lookup__c;
                        compt.Related_Opportunity__c = opp.Id;
                        competitorsForInsert.add(compt);
                    }
                }
            }
            
            
            //198 competitorsForUpdate records for insertion in UAT
            
            System.debug('competitorsForInsert size = '+competitorsForInsert.size());
            //29468 competitors records for insertion in UAT
            if(!competitorsForInsert.isEmpty() && dmlPerform){
                insert competitorsForInsert;
            }
        }
        else if(batchClassName == 'ManufacturerAwardedCompetitorBatch'){
            List<Opportunity> opportunityList = new List<Opportunity>();
            if(scope != null) opportunityList = (List<Opportunity>) scope;
            for(Opportunity opp : opportunityList){
                Set<Id> competitiveVendorsSet = new Set<Id>();
                if(opp.Competitive_DB_Records__r.isEmpty()){
                    CompetitiveDB__c newCompetitor = new CompetitiveDB__c();
                    newCompetitor.Competitive_Vendor__c = opp.Primary_Competitor_Account__c;
                    newCompetitor.Related_Opportunity__c = opp.Id; 
                    competitorsForInsert.add(newCompetitor);
                } else {
                    for(CompetitiveDB__c eachCompetitor : opp.Competitive_DB_Records__r) {
                        competitiveVendorsSet.add(eachCompetitor.Competitive_Vendor__c);
                    }
                    if(!competitiveVendorsSet.contains(opp.Primary_Competitor_Account__c)) {
                        CompetitiveDB__c newCompetitor = new CompetitiveDB__c();
                        newCompetitor.Competitive_Vendor__c = opp.Primary_Competitor_Account__c;
                        newCompetitor.Related_Opportunity__c = opp.Id; 
                        competitorsForInsert.add(newCompetitor);
                    }
                    
                }
            }
            System.debug('competitorsForInsert size = '+competitorsForInsert.size());
            if(!competitorsForInsert.isEmpty() && dmlPerform){
                insert competitorsForInsert;
            }
        }
        //92 records for upsertion
        else if(batchClassName == 'UpdatePrimaryCompetitorValueBatch') {
            Map<String,Id> competitorValWithVendor = new Map<String,Id>();
            
            //Preparing a map with XCompetitor Picklist value and Account Id to do comparison (217-310)
            competitorValWithVendor.put('CEIEC','0012H00001a5QCwQAM');
            competitorValWithVendor.put('SAP','0012H00001a5QqmQAE');
            competitorValWithVendor.put('Johnson','0012H00001a5QqNQAU');
            competitorValWithVendor.put('Beifeng','0012H00001YKugTQAT');
            competitorValWithVendor.put('Honeywell','0012H00001YKvZKQA1');
            competitorValWithVendor.put('NEC','0012H00001Z1Q50QAF');
            competitorValWithVendor.put('AFARIA','0012H00001a5QqmQAE');
            competitorValWithVendor.put('Ericsson','0013400001M26v4AAB');
            competitorValWithVendor.put('Ericcson','0013400001M26v4AAB');
            competitorValWithVendor.put('Fujitsu','0013400001M26v5AAB');
            competitorValWithVendor.put('Frequentis','0013400001M26vdAAB');
            competitorValWithVendor.put('Alinco','0013400001M26vDAAR');
            competitorValWithVendor.put('Avaya','0013400001M26vhAAB');
            competitorValWithVendor.put('Alvarion','0013400001M26vIAAR');
            competitorValWithVendor.put('Apple','0013400001M26vNAAR');
            competitorValWithVendor.put('Thales','0013400001M26vPAAR');
            competitorValWithVendor.put('Aviat Networks','0013400001M26vrAAB');
            competitorValWithVendor.put('Artevea','0013400001M26vSAAR');
            competitorValWithVendor.put('Aruba','0013400001M26vXAAR');
            competitorValWithVendor.put('Cleartone','0013400001M26waAAB');
            competitorValWithVendor.put('Damm','0013400001M26wkAAB');
            competitorValWithVendor.put('Aerohive','0013400001M26wNAAR');
            competitorValWithVendor.put('Enterasys','0013400001M26wNAAR');
            competitorValWithVendor.put('Extreme Networks','0013400001M26wNAAR');
            competitorValWithVendor.put('Ceragon Networks','0013400001M26wQAAR');
            competitorValWithVendor.put('Huawei','0013400001M26wRAAR');
            competitorValWithVendor.put('Maxon','0013400001M26wvAAB');
            competitorValWithVendor.put('Cisco','0013400001M26wVAAR');
            competitorValWithVendor.put('Sepura','0013400001M26wXAAR');
            competitorValWithVendor.put('Teltronic','0013400001M26wYAAR');
            competitorValWithVendor.put('RADWIN','0013400001M26x1AAB');
            competitorValWithVendor.put('Redline Communications','0013400001XDL4RAAX');
            competitorValWithVendor.put('EADS','0013400001M2HhqAAF');
            competitorValWithVendor.put('Harris','0013400001M26xdAAB');
            competitorValWithVendor.put('ETELM','0013400001M26xOAAR');
            competitorValWithVendor.put('R&S','0013400001M26xtAAB');
            competitorValWithVendor.put('HYT','0013400001M26xxAAB');
            competitorValWithVendor.put('HYTERA','0013400001M26xxAAB');
            competitorValWithVendor.put('IBM','0013400001M26y2AAB');
            competitorValWithVendor.put('ICOM','0013400001M26y7AAB');
            competitorValWithVendor.put('Impinj','0013400001M26yCAAR');
            competitorValWithVendor.put('InfiNet Wireless','0013400001M26yHAAR');
            competitorValWithVendor.put('Kenwood','0013400001M26yqAAB');
            competitorValWithVendor.put('Kirisun','0013400001M26yvAAB');
            competitorValWithVendor.put('iTron','0013400001M26yWAAR');
            competitorValWithVendor.put('M/A Com','0013400001M26xdAAB');
            competitorValWithVendor.put('Proxim Wireless','0013400001M26zaAAB');
            competitorValWithVendor.put('Alcatel','0013400001M26zeAAB');
            competitorValWithVendor.put('Mobilitec','0013400001M26zeAAB');
            competitorValWithVendor.put('NOKIA','0013400001M26zeAAB');
            competitorValWithVendor.put('Nortel','0013400001M26zoAAB');
            competitorValWithVendor.put('No Competitor','0013400001M26zZAAR');
            competitorValWithVendor.put('Other','0013400001M26zZAAR');
            competitorValWithVendor.put('Panasonic','0013400001M2703AAB');
            competitorValWithVendor.put('Sensormatic','0012H00001a5QqNQAU');
            competitorValWithVendor.put('Simoco','0013400001UMvgJAAT');
            competitorValWithVendor.put('Rohill','0013400001M270IAAR');
            competitorValWithVendor.put('Ruckus','0013400001M270NAAR');
            competitorValWithVendor.put('Trimble','0013400001M270OAAR');
            competitorValWithVendor.put('Azteca','0013400001M270OAAR');
            competitorValWithVendor.put('Unier','0013400001M270PAAR');
            competitorValWithVendor.put('Suicom','0013400001M270rAAB');
            competitorValWithVendor.put('Samsung','0013400001M270SAAR');
            competitorValWithVendor.put('Tait','0013400001M270wAAB');
            competitorValWithVendor.put('Taite','0013400001M270wAAB');
            competitorValWithVendor.put('Selex','0013400001M270XAAR');
            competitorValWithVendor.put('Trapeze','0013400001M270YAAR');
            competitorValWithVendor.put('Vertex','0013400001M271fAAB');
            competitorValWithVendor.put('TYT','0013400001M271GAAR');
            competitorValWithVendor.put('Ubiquiti Networks','0013400001M271LAAR');
            competitorValWithVendor.put('Vocollect','0013400001M271MAAR');
            competitorValWithVendor.put('Weierwei','0013400001M271pAAB');
            competitorValWithVendor.put('Uniden','0013400001M271QAAR');
            competitorValWithVendor.put('Unimo','0013400001M271VAAR');
            competitorValWithVendor.put('Daniels','0013400001M2GAOAA3');
            competitorValWithVendor.put('AT&T','0013400001M2HgJAAV');
            competitorValWithVendor.put('General Dynamics','0013400001M2HgnAAF');
            competitorValWithVendor.put('Airbus','0013400001M2HhqAAF');
            competitorValWithVendor.put('Airwave','0013400001M2HiAAAV');
            competitorValWithVendor.put('Zetron','0013400001M2HohAAF');
            competitorValWithVendor.put('Siemens','0013400001M2IcLAAV');
            competitorValWithVendor.put('Verizon','0013400001M2IWwAAN');
            competitorValWithVendor.put('ACS','0013400001NbouGAAR');
            competitorValWithVendor.put('Avtec','0013400001NbozVAAR');
            competitorValWithVendor.put('Eastcom','0013400001Nbp4iAAB');
            competitorValWithVendor.put('InterAct','0013400001Y42RrAAJ');
            competitorValWithVendor.put('Intrado','0013400001Nbp7SAAR');
            competitorValWithVendor.put('Raytheon','0013400001NbpJgAAJ');
            competitorValWithVendor.put('Versaterm','0013400001NbpL3AAJ');
            competitorValWithVendor.put('Motorola','0013400001OZitRAAT');
            competitorValWithVendor.put('Sprint PCS','0013400001UMvfkAAD');
            competitorValWithVendor.put('Relm','0013400001M2GAJAA3');
            //End
            
            List<Opportunity> opportunityList = new List<Opportunity>();
            List<String> allowedOppRecTypes = new List<String>{'Government_Standard','New_Business_Development','Account_Management','Channel_Partner_Sales'};
                Map<Id,List<CompetitiveDB__c>> oppWithRelatedCompetitorsMap = new Map<Id,List<CompetitiveDB__c>>();
            //To store opportunity Id with its corresponding primary competitor value
            Map<Id,String> oppAndPrimaryCompMap = new Map<Id,String>();
            Map<Id,CompetitiveDB__c> oppCompMap = new Map<Id,CompetitiveDB__c> ();
            
            if(scope != null) opportunityList = (List<Opportunity>) scope;
            List<Opportunity> oppWithCompetitors = [SELECT ID,Primary_Competitor__c,RecordType.DeveloperName,(SELECT Id,Primary_Competitor__c,Related_Opportunity__c,
                                                                                                              Related_Opportunity__r.Primary_Competitor__c,Competitive_Vendor__c FROM 
                                                                                                              Competitive_DB_Records__r) FROM Opportunity
                                                    WHERE ID IN :opportunityList];
            
            
            for(Opportunity opp : oppWithCompetitors) {
                if(competitorValWithVendor.containsKey(opp.Primary_Competitor__c) && allowedOppRecTypes.contains(opp.RecordType.DeveloperName)) {
                    if(opp.Competitive_DB_Records__r.isEmpty()) {
                        CompetitiveDB__c newCompetitor = new CompetitiveDB__c();
                        newCompetitor.Competitive_Vendor__c = competitorValWithVendor.get(opp.Primary_Competitor__c);
                        newCompetitor.Primary_Competitor__c = true;
                        newCompetitor.Related_Opportunity__c = opp.Id;
                        competitorsForInsert.add(newCompetitor);
                    }  else {
                        for(CompetitiveDB__c eachComp : opp.Competitive_DB_Records__r) {
                            if(competitorValWithVendor.get(opp.Primary_Competitor__c) == eachComp.Competitive_Vendor__c) {
                                eachComp.Primary_Competitor__c = true; 
                                competitorsForUpdate.add(eachComp);
                            }
                        }
                    }
                }
            }
            System.debug('competitorsForUpdate size = '+competitorsForUpdate.size());
            if(!competitorsForUpdate.isEmpty() && dmlPerform) {
                update competitorsForUpdate;
            }
            System.debug('competitorsForInsert size = '+competitorsForInsert.size());
            if(!competitorsForInsert.isEmpty() && dmlPerform) {
                insert competitorsForInsert;
            }
        }
        
        else if(batchClassName == 'CreateCompetitorRecordsBatch') {
            List<Opportunity> oppList = new List<Opportunity>();
            if(scope != null) oppList = (List<Opportunity>)scope;
            Map<String,Id> oppCompAndVendorMap = new Map<String,Id>();
            oppCompAndVendorMap.put('Airbus Group','0013400001M2HhqAAF');
            oppCompAndVendorMap.put('Axon (Vievu)','0013400001NcLpqAAF');
            oppCompAndVendorMap.put('AGT International','0012H00001a5QCcQAM');
            oppCompAndVendorMap.put('BK Technologies (Relm)','0013400001M2GAJAA3');
            oppCompAndVendorMap.put('CEIEC','0012H00001a5QCwQAM');
            oppCompAndVendorMap.put('L3','0012H00001YKvaVQAT');
            oppCompAndVendorMap.put('Sepura Group','0013400001M26wXAAR');
            oppCompAndVendorMap.put('Government Outreach','0012H00001a5QqDQAU');
            oppCompAndVendorMap.put('IPMobileNet','0012H00001a5QqIQAU');
            oppCompAndVendorMap.put('SAP','0012H00001a5QqmQAE');
            oppCompAndVendorMap.put('Team Simoco','0013400001UMvgJAAT');
            oppCompAndVendorMap.put('Tekk','0012H00001a5RB6QAM');
            oppCompAndVendorMap.put('Cassidian (EADS)','0013400001XEBlVAAX');
            oppCompAndVendorMap.put('BK Technologies (Relm)','0013400001M2GAJAA3');
            oppCompAndVendorMap.put('Vesta Solutions,Inc.','0013400001XEBlVAAX');
            oppCompAndVendorMap.put('LensLock','0013400001XdfH8AAJ');
            oppCompAndVendorMap.put('5 points','0012H00001YKug4QAD');
            oppCompAndVendorMap.put('911eye','0012H00001YKtvbQAD');
            oppCompAndVendorMap.put('ACS','0013400001NbouGAAR');
            oppCompAndVendorMap.put('Active Networks','0013400001UMvfQAAT');
            oppCompAndVendorMap.put('Airwave (Cassidian)','0013400001M2HiAAAV');
            oppCompAndVendorMap.put('Alcatel Lucent','0013400001M26zeAAB');
            oppCompAndVendorMap.put('Amag','0012H00001YKtvgQAD');
            oppCompAndVendorMap.put('Ambra Solutions','0013400001XDL4qAAH');
            oppCompAndVendorMap.put('ARES','0012H00001YKtvhQAD');
            oppCompAndVendorMap.put('Artevea','0013400001M26vSAAR');
            oppCompAndVendorMap.put('Assa Abloy','0012H00001YKtviQAD');
            oppCompAndVendorMap.put('AT&T','0013400001M2HgJAAV');
            oppCompAndVendorMap.put('Atos','0013400001W5apKAAR');
            oppCompAndVendorMap.put('Avtec','0013400001NbozVAAR');
            oppCompAndVendorMap.put('Comtech (Solacom)','0013400001M2IaeAAF');
            oppCompAndVendorMap.put('Azavea','0012H00001YKtvjQAD');
            oppCompAndVendorMap.put('Azetti','0012H00001YKtvkQAD');
            oppCompAndVendorMap.put('Azteca','0013400001M270OAAR');
            oppCompAndVendorMap.put('Baofeng','0012H00001YKugTQAT');
            oppCompAndVendorMap.put('Bell Canada','0013400001XDL5ZAAX');
            oppCompAndVendorMap.put('BodyWorn','0013400001S1dMbAAJ');
            oppCompAndVendorMap.put('Brivo','0012H00001YKugUQAT');
            oppCompAndVendorMap.put('CallWorks','0013400001M2Hq4AAF');
            oppCompAndVendorMap.put('Callyo','0012H00001YKugVQAT');
            oppCompAndVendorMap.put('Carbyne','0012H00001YKugWQAT');
            oppCompAndVendorMap.put('Carmenta AB','0013400001NcIWVAA3');
            oppCompAndVendorMap.put('Catalyst','0012H00001YKugXQAT');
            oppCompAndVendorMap.put('CenturyLink','0012H00001Z1i77QAB');
            oppCompAndVendorMap.put('CGI','0012H00001YKugYQAT');
            oppCompAndVendorMap.put('Cisco','0013400001M26wVAAR');
            oppCompAndVendorMap.put('Cleartone','0013400001M26waAAB');
            oppCompAndVendorMap.put('CNL Software Ltd.','0013400001XDL8JAAX');
            oppCompAndVendorMap.put('Coban Tech','0012H00001YKugZQAT');
            oppCompAndVendorMap.put('CommSys','0012H00001YKugaQAD');
            oppCompAndVendorMap.put('Convergint Technologies','0012H00001YKugbQAD');
            oppCompAndVendorMap.put('Corona Solutions','0012H00001YKugcQAD');
            oppCompAndVendorMap.put('CrimeTeller','0012H00001YKugdQAD');
            oppCompAndVendorMap.put('Crosscall','0013400001XGe92AAD');
            oppCompAndVendorMap.put('CSAM Health AS','0013400001NcIXEAA3');
            oppCompAndVendorMap.put('Cybertech','0012H00001YKugeQAD');
            oppCompAndVendorMap.put('Dallmeier','0012H00001YKugkQAD');
            oppCompAndVendorMap.put('Damm','0013400001M26wkAAB');
            oppCompAndVendorMap.put('Daniels','0013400001M2GAOAA3');
            oppCompAndVendorMap.put('DataMax','0012H00001YKuglQAD');
            oppCompAndVendorMap.put('EADS','0013400001M2HhqAAF');
            oppCompAndVendorMap.put('Dataworks Plus','0012H00001YKugmQAD');
            oppCompAndVendorMap.put('Diga-Talk','0012H00001YKugnQAD');
            oppCompAndVendorMap.put('Digital Ally','0013400001UNTPKAA5');
            oppCompAndVendorMap.put('Earphone Connection','0012H00001YKugoQAD');
            oppCompAndVendorMap.put('Eastcom','0013400001Nbp4iAAB');
            oppCompAndVendorMap.put('Eastcom (PDT)','0013400001Nbp4iAAB');
            oppCompAndVendorMap.put('Eastcom (TETRA)','0013400001Nbp4iAAB');
            oppCompAndVendorMap.put('Edge360','0012H00001YKugpQAD');
            oppCompAndVendorMap.put('EF Johnson','0013400001M26yqAAB');
            oppCompAndVendorMap.put('Emergent Communications','0012H00001YKugqQAD');
            oppCompAndVendorMap.put('Ericsson','0013400001M26v4AAB');
            oppCompAndVendorMap.put('ESChat','0012H00001YKugrQAD');
            oppCompAndVendorMap.put('Esri','0012H00001YKugsQAD');
            oppCompAndVendorMap.put('Etelm','0013400001M26xOAAR');
            oppCompAndVendorMap.put('Eventide','0013400001OGKDmAAP');
            oppCompAndVendorMap.put('Everbridge','0012H00001YKugtQAD');
            oppCompAndVendorMap.put('Exacq','0012H00001YKuguQAD');
            oppCompAndVendorMap.put('Numerica','0012H00001YKvZmQAL');
            oppCompAndVendorMap.put('Feenics','0012H00001YKuhFQAT');
            oppCompAndVendorMap.put('FileOnQ','0012H00001YKuhGQAT');
            oppCompAndVendorMap.put('Flock Safety','0012H00001YKuhHQAT');
            oppCompAndVendorMap.put('Foray','0012H00001YKuhIQAT');
            oppCompAndVendorMap.put('ForensicLogic','0012H00001YKuhJQAT');
            oppCompAndVendorMap.put('Frequentis','0013400001M26vdAAB');
            oppCompAndVendorMap.put('Frontier Communications','0012H00001Z1i7CQAR');
            oppCompAndVendorMap.put('Fusus','0012H00001YKuhKQAT');
            oppCompAndVendorMap.put('Genaker','0012H00001YKuhLQAT');
            oppCompAndVendorMap.put('General Dynamics','0013400001M2HgnAAF');
            oppCompAndVendorMap.put('Genesis Pulse','0012H00001YKuhMQAT');
            oppCompAndVendorMap.put('Genetec','0013400001OxCBRAA3');
            oppCompAndVendorMap.put('Geoshield','0012H00001YKuhNQAT');
            oppCompAndVendorMap.put('Geutebrueck','0012H00001YKuhOQAT');
            oppCompAndVendorMap.put('Hanwha','0012H00001YKvZHQA1');
            oppCompAndVendorMap.put('Harris','0013400001M26xdAAB');
            oppCompAndVendorMap.put('Harris (M/A Com)','0013400001M26xdAAB');
            oppCompAndVendorMap.put('Haystax','0012H00001YKvZIQA1');
            oppCompAndVendorMap.put('Hitachi','0012H00001YKvZJQA1');
            oppCompAndVendorMap.put('Honeywell','0012H00001YKvZKQA1');
            oppCompAndVendorMap.put('Huawei','0013400001M26wRAAR');
            oppCompAndVendorMap.put('Hunchlab','0012H00001YKvZLQA1');
            oppCompAndVendorMap.put('HYT','0013400001M26xxAAB');
            oppCompAndVendorMap.put('Hytera','0013400001M26xxAAB');
            oppCompAndVendorMap.put('Hytera (PDT)','0013400001M26xxAAB');
            oppCompAndVendorMap.put('Hytera (TETRA)','0013400001M26xxAAB');
            oppCompAndVendorMap.put('IBM','0013400001M26y2AAB');
            oppCompAndVendorMap.put('ICOM','0013400001M26y7AAB');
            oppCompAndVendorMap.put('INdigital','0012H00001Z1i7vQAB');
            oppCompAndVendorMap.put('Indigovision','0012H00001YKvZWQA1');
            oppCompAndVendorMap.put('INDRA Argentina S.A.','0013400001M2IdiAAF');
            oppCompAndVendorMap.put('Infor','0013400001Y42SaAAJ');
            oppCompAndVendorMap.put('Inmer S.A. de C.V.','0013400001OyTnKAAV');
            oppCompAndVendorMap.put('Innovative Business Software A/S','0013400001XKWzaAAH');
            oppCompAndVendorMap.put('Instant Connect','0012H00001YKvZXQA1');
            oppCompAndVendorMap.put('Integraph','0013400001Nbp7DAAR');
            oppCompAndVendorMap.put('Intergraph','0013400001Nbp7DAAR');
            oppCompAndVendorMap.put('Intertalk','0012H00001YKvZYQA1');
            oppCompAndVendorMap.put('Intrado','0013400001Nbp7SAAR');
            oppCompAndVendorMap.put('Intrepid Network','0012H00001YKvZZQA1');
            oppCompAndVendorMap.put('Iowa Communications Network (ICN)','0013400001SwOoEAAV');
            oppCompAndVendorMap.put('IP Wireless','0013400001M2HgnAAF');
            oppCompAndVendorMap.put('InterAct','0013400001Y42RrAAJ');
            oppCompAndVendorMap.put('Juvare','0012H00001YKvZgQAL');
            oppCompAndVendorMap.put('Komutel','0012H00001YKvZhQAL');
            oppCompAndVendorMap.put('Kustom Signals','0012H00001YKvZiQAL');
            oppCompAndVendorMap.put('Kyocera','0012H00001YKvZjQAL');
            oppCompAndVendorMap.put('L3 Mobile-Vision','0012H00001YKvaVQAT');
            oppCompAndVendorMap.put('Lagan','0013400001Nbp8QAAR');
            oppCompAndVendorMap.put('LeadsOnline','0012H00001YKvZkQAL');
            oppCompAndVendorMap.put('LenelS2','0012H00001YKvZlQAL');
            oppCompAndVendorMap.put('LexisNexis','0012H00001YKvZmQAL');
            oppCompAndVendorMap.put('Live Earth','0012H00001YKvZnQAL');
            oppCompAndVendorMap.put('Locus Public Safety AS','0013400001NcIXnAAN');
            oppCompAndVendorMap.put('M/A Com','0013400001M26xdAAB');
            oppCompAndVendorMap.put('MapNimbus','0012H00001YKvZoQAL');
            oppCompAndVendorMap.put('Mark43,Inc','0013400001VeRVQAA3');
            oppCompAndVendorMap.put('MicroAutomation','0012H00001YKvZpQAL');
            oppCompAndVendorMap.put('Microsoft','0013400001UMvgYAAT');
            oppCompAndVendorMap.put('Midland','0012H00001YKvZqQAL');
            oppCompAndVendorMap.put('Mindshare','0012H00001YKvZrQAL');
            oppCompAndVendorMap.put('Minuteman Security','0012H00001YKvZsQAL');
            oppCompAndVendorMap.put('Mobile Tornado','0012H00001YKvZtQAL');
            oppCompAndVendorMap.put('Mobilitec','0013400001M26zeAAB');
            oppCompAndVendorMap.put('Motorola Solutions Inc','0013400001OZitRAAT');
            oppCompAndVendorMap.put('Municipal Emergency Services (MES)','0012H00001YKvZuQAL');
            oppCompAndVendorMap.put('Mutualink','0012H00001YKvZvQAL');
            oppCompAndVendorMap.put('NC4','0012H00001YKugtQAD');
            oppCompAndVendorMap.put('NDI Recognition Systems','0012H00001YKvZxQAL');
            oppCompAndVendorMap.put('Kenwood','0013400001M26yqAAB');
            oppCompAndVendorMap.put('Nexgen Public Safety Solutions','0013400001Uq8XlAAJ');
            oppCompAndVendorMap.put('NGA 911','0012H00001Z1i80QAB');
            oppCompAndVendorMap.put('NICE','0012H00001YKvZyQAL');
            oppCompAndVendorMap.put('Nokia','0013400001M26zeAAB');
            oppCompAndVendorMap.put('Northrop Grumman','0013400001M2IWhAAN');
            oppCompAndVendorMap.put('New World','0013400001SwFqxAAF');
            oppCompAndVendorMap.put('OnSolve','0012H00001YKvaBQAT');
            oppCompAndVendorMap.put('OpenOptions','0012H00001YKvaCQAT');
            oppCompAndVendorMap.put('Opentext','0012H00001YKvaDQAT');
            oppCompAndVendorMap.put('Oracle','0013400001UMvg9AAD');
            oppCompAndVendorMap.put('Orion Labs','0012H00001YKvaEQAT');
            oppCompAndVendorMap.put('Other','0013400001M26zZAAR');
            oppCompAndVendorMap.put('OTTO Communications','0012H00001YKvaFQAT');
            oppCompAndVendorMap.put('P3 (TipSoft)','0012H00001YKvaGQAT');
            oppCompAndVendorMap.put('Palantir','0012H00001YKvaHQAT');
            oppCompAndVendorMap.put('Panasonic','0013400001M2703AAB');
            oppCompAndVendorMap.put('Peak PTT','0012H00001YKvaIQAT');
            oppCompAndVendorMap.put('Pelco','0012H00001YKvaJQAT');
            oppCompAndVendorMap.put('PIPS','0012H00001YKvaKQAT');
            oppCompAndVendorMap.put('Platesmart Technologies','0012H00001YKvaLQAT');
            oppCompAndVendorMap.put('Predpol','0012H00001YKvaMQAT');
            oppCompAndVendorMap.put('Priority 5','0012H00001YKvaNQAT');
            oppCompAndVendorMap.put('Qognify Ltd.','0013400001XDL7pAAH');
            oppCompAndVendorMap.put('ProPhoenix','0013400001W5V35AAF');
            oppCompAndVendorMap.put('Pryme','0012H00001YKvaOQAT');
            oppCompAndVendorMap.put('Public Engines,Inc.','0013400001XEBphAAH');
            oppCompAndVendorMap.put('QueTel','0012H00001YKvaPQAT');
            oppCompAndVendorMap.put('RapidDeploy','0012H00001YKvaQQAT');
            oppCompAndVendorMap.put('Raytheon','0013400001NbpJgAAJ');
            oppCompAndVendorMap.put('RCA Communications','0012H00001YKvaRQAT');
            oppCompAndVendorMap.put('Redline Communications','0013400001XDL4RAAX');
            oppCompAndVendorMap.put('Superion (OSSI,SunGard)','0013400001VeMBAAA3');
            oppCompAndVendorMap.put('Resolver','0012H00001YKvaSQAT');
            oppCompAndVendorMap.put('Reveal Media','0013400001YNG6CAAX');
            oppCompAndVendorMap.put('VieVu','0013400001NcLpqAAF');
            oppCompAndVendorMap.put('Rogers Communications Inc.','0013400001XDL6SAAX');
            oppCompAndVendorMap.put('Rohill','0013400001M270IAAR');
            oppCompAndVendorMap.put('RS2','0012H00001YKvaTQAT');
            oppCompAndVendorMap.put('Saab AB','0013400001XKWwMAAX');
            oppCompAndVendorMap.put('SafeCity GIS','0012H00001YKvaUQAT');
            oppCompAndVendorMap.put('Safefleet (includes L-3 and Coban)','0012H00001YKvaVQAT');
            oppCompAndVendorMap.put('Safety Vision','0013400001S1d8PAAR');
            oppCompAndVendorMap.put('Saltus Technologies','0012H00001YKvaZQAT');
            oppCompAndVendorMap.put('Samhoo','0012H00001YKvaWQAT');
            oppCompAndVendorMap.put('SAS','0012H00001YKvaXQAT');
            oppCompAndVendorMap.put('Savox','0012H00001YKvaYQAT');
            oppCompAndVendorMap.put('SchoolCast (Highground Solutions)','0012H00001YKvaaQAD');
            oppCompAndVendorMap.put('Selex','0013400001M270XAAR');
            oppCompAndVendorMap.put('- None -','0013400001YMBZOAA5');
            oppCompAndVendorMap.put('Shezhen Dachengwei','0012H00001YKvabQAD');
            oppCompAndVendorMap.put('Shotspotter','0012H00001YKvacQAD');
            oppCompAndVendorMap.put('Siemens','0013400001M2IcLAAV');
            oppCompAndVendorMap.put('SLA Corporation','0013400001XDL5tAAH');
            oppCompAndVendorMap.put('Soflex','0013400001W5apjAAB');
            oppCompAndVendorMap.put('Softwarehouse','0012H00001a5QqNQAU');
            oppCompAndVendorMap.put('Soma Global','0012H00001YKvajQAD');
            oppCompAndVendorMap.put('Sopra Steria','0013400001XKWu1AAH');
            oppCompAndVendorMap.put('Spatialitics','0012H00001YKvakQAD');
            oppCompAndVendorMap.put('Spillman','0013400001M2IgNAAV');
            oppCompAndVendorMap.put('Spok','0012H00001YKvalQAD');
            oppCompAndVendorMap.put('SS8 Networks','0012H00001YKvamQAD');
            oppCompAndVendorMap.put('Strax Intelligence','0012H00001YKvanQAD');
            oppCompAndVendorMap.put('StreamWIDE','0012H00001YKvaoQAD');
            oppCompAndVendorMap.put('SureView Systems','0012H00001YKvapQAD');
            oppCompAndVendorMap.put('Synergem Technologies','0012H00001Z1i85QAB');
            oppCompAndVendorMap.put('Synergen','0012H00001Z1i85QAB');
            oppCompAndVendorMap.put('Tablet Command','0012H00001YKvaqQAD');
            oppCompAndVendorMap.put('Tait','0013400001M270wAAB');
            oppCompAndVendorMap.put('TAIT (P25)','0013400001M270wAAB');
            oppCompAndVendorMap.put('TAIT (PDT)','0013400001M270wAAB');
            oppCompAndVendorMap.put('TalkPod','0012H00001YKvarQAD');
            oppCompAndVendorMap.put('TASSTA','0012H00001YKvasQAD');
            oppCompAndVendorMap.put('TBD','0013400001M26zZAAR');
            oppCompAndVendorMap.put('TCS','0013400001M2IaeAAF');
            oppCompAndVendorMap.put('Airwave','0013400001M2HiAAAV');
            oppCompAndVendorMap.put('Telefonica de Argentina S.A.','0013400001YOszZAAT');
            oppCompAndVendorMap.put('Alcatel','0013400001M26zeAAB');
            oppCompAndVendorMap.put('Teltronic','0013400001M26wYAAR');
            oppCompAndVendorMap.put('Thales','0013400001M26vPAAR');
            oppCompAndVendorMap.put('Thomson Reuters','0012H00001YKvatQAD');
            oppCompAndVendorMap.put('Tiburon','0013400001YPdO8AAL');
            oppCompAndVendorMap.put('Aruba','0013400001M26vXAAR');
            oppCompAndVendorMap.put('TriTech','0013400001NbpKKAAZ');
            oppCompAndVendorMap.put('Tyco Traffic & Transportation','0012H00001a5QqNQAU');
            oppCompAndVendorMap.put('Tyler Technologies','0013400001SwFqxAAF');
            oppCompAndVendorMap.put('Uniden','0013400001M271QAAR');
            oppCompAndVendorMap.put('Unimo','0013400001M271VAAR');
            oppCompAndVendorMap.put('Uniview','0012H00001YKvavQAD');
            oppCompAndVendorMap.put('Unknown','0013400001M26zZAAR');
            oppCompAndVendorMap.put('Vanderbilt Industries','0012H00001YKvawQAD');
            oppCompAndVendorMap.put('Veoci','0012H00001YKvaxQAD');
            oppCompAndVendorMap.put('Verizon','0013400001M2IWwAAN');
            oppCompAndVendorMap.put('Verkada','0012H00001YKvayQAD');
            oppCompAndVendorMap.put('Versaterm','0013400001NbpL3AAJ');
            oppCompAndVendorMap.put('Vertex','0013400001M271fAAB');
            oppCompAndVendorMap.put('AT','0013400001M2HgJAAV');
            oppCompAndVendorMap.put('Capita','0012H00001YJcADQA1');
            oppCompAndVendorMap.put('Vivotek','0012H00001YKvazQAD');
            oppCompAndVendorMap.put('Voxer','0012H00001YKvb0QAD');
            oppCompAndVendorMap.put('WatchGuard','0013400001S1d5VAAR');
            oppCompAndVendorMap.put('West Corporation','0013400001Nbp7SAAR');
            oppCompAndVendorMap.put('Wolfcom','0012H00001YKvb1QAD');
            oppCompAndVendorMap.put('Xenium Solutions','0013400001S2BMqAAN');
            oppCompAndVendorMap.put('Zebra Technologies','0013400001NcXLJAA3');
            oppCompAndVendorMap.put('Zello','0012H00001YKvb2QAD');
            oppCompAndVendorMap.put('Zetron','0013400001M2HohAAF');
            oppCompAndVendorMap.put('ZTE','0013400001UMvSfAAL');
            oppCompAndVendorMap.put('TELEX - BOSCH','0012H00001YwXobQAF');
            oppCompAndVendorMap.put('HYT (Hytera)','0013400001M26xxAAB');
            oppCompAndVendorMap.put('Johnson','0012H00001a5QqNQAU');
            oppCompAndVendorMap.put('Maxon','0013400001M26wvAAB');
            oppCompAndVendorMap.put('No Competitor','0013400001YMBZOAA5');
            oppCompAndVendorMap.put('Relm BK','0013400001M2GAJAA3');
            oppCompAndVendorMap.put('Samsung','0013400001M270SAAR');
            oppCompAndVendorMap.put('Serco','0012H00001YJcAIQA1');
            oppCompAndVendorMap.put('Standard Horizon','0012H00001a5QczQAE');
            oppCompAndVendorMap.put('Taite','0013400001M270wAAB');
            oppCompAndVendorMap.put('Telent','0012H00001YJcANQA1');
            oppCompAndVendorMap.put('Telus/Telex','0012H00001a5RBLQA2');
            oppCompAndVendorMap.put('Titan','0012H00001a5QcqQAE');
            oppCompAndVendorMap.put('Utility Associates,Inc.','0012H00001Z1aYFQAZ');
            oppCompAndVendorMap.put('Viper','0013400001Nbp7SAAR');
            oppCompAndVendorMap.put('Watson','0013400001M26y2AAB');
            oppCompAndVendorMap.put('Yaesu','0012H00001a5QczQAE');
            //End */
            List<CompetitiveDB__c> competitorsLst = new List<CompetitiveDB__c>();
            List<Opportunity> oppWithCompetitorsList = [SELECT Id,Competition__c,RecordType.DeveloperName,(SELECT Id,Related_Opportunity__c,Related_Opportunity__r.Competition__c,
                                                                                                           Competitive_Vendor__c FROM Competitive_DB_Records__r)FROM Opportunity WHERE ID IN :oppList];
            
            List<String> allowedOppRecTypes = new List<String>{'Government_Standard','New_Business_Development','Account_Management','Channel_Partner_Sales'};
                
                for(Opportunity opp : oppWithCompetitorsList) {
                    List<String> competitionValues = opp.Competition__c.split(';');
                    for(String compValue : competitionValues) {
                        if(oppCompAndVendorMap.containsKey(compValue) && allowedOppRecTypes.contains(opp.RecordType.DeveloperName)) {
                            if(opp.Competitive_DB_Records__r.isEmpty()) {
                                CompetitiveDB__c newCompetitor = new CompetitiveDB__c();
                                newCompetitor.Competitive_Vendor__c = oppCompAndVendorMap.get(compValue) ;
                                newCompetitor.Related_Opportunity__c = opp.Id;
                                competitorsForInsert.add(newCompetitor);  
                            } else {
                                for(CompetitiveDB__c competitor : opp.Competitive_DB_Records__r) {
                                    if(oppCompAndVendorMap.get(compValue) != competitor.Competitive_Vendor__c) {
                                        CompetitiveDB__c newCompetitor = new CompetitiveDB__c();
                                        newCompetitor.Competitive_Vendor__c = oppCompAndVendorMap.get(compValue) ;
                                        newCompetitor.Related_Opportunity__c = opp.Id;
                                        competitorsForInsert.add(newCompetitor);
                                    }
                                }
                            }  
                        }
                    }
                }
            System.debug('competitorsForInsert size = '+competitorsForInsert.size());
            if(!competitorsForInsert.isEmpty() && dmlPerform) {
                insert competitorsForInsert;
            }
        }
        else if(batchClassName == 'UpdateSearchHelper') {  
            List<SObject> incomingSobjectRecs = new List<SObject>();
            List<SObject> newRecsToBeUpdated = new  List<SObject>();
            if(scope!=NULL) incomingSobjectRecs = (List<SObject>)scope;
            for(SObject sobjRec : incomingSobjectRecs) {
                String sobjType = sobjRec.Id.getSObjectType().getDescribe().getName();
                if(sobjType == 'Account') {
                    SObject record = sobjRec.Id.getSObjectType().newSObject(sobjRec.Id);
                    record.put('Search_Helper_for_MCNs__c', 'All');
                    newRecsToBeUpdated.add(record);
                }if(sobjType == 'CompetitiveDB__c') {
                    SObject record = sobjRec.Id.getSObjectType().newSObject(sobjRec.Id);
                    record.put('Search_Helper__c', 'All');
                    newRecsToBeUpdated.add(record);
                }
                
            }
            System.debug('newRecsToBeUpdated size = '+newRecsToBeUpdated.size());
            if(!newRecsToBeUpdated.isEmpty()) {
                update newRecsToBeUpdated;
            }
        }
        else if(batchClassName == 'UpdateUniqueCompetitor') {
            List<CompetitiveDB__c> competitorsList = new List<CompetitiveDB__c>();
            if(scope!=null) competitorsList=(List<CompetitiveDB__c>) scope;
            Map<Id,String> uniqueCompetitorValueMap = new Map<Id,String>();
            String uniqueValue;
            for(CompetitiveDB__c comp : competitorsList) {
                if(comp.Account_ID__c == NULL) { 
                    uniqueValue = comp.Competitive_Vendor__c + ',' + comp.Related_Opportunity__r.Account.Id + ',' +comp.Related_Opportunity__c;
                }else {
                    uniqueValue = comp.Competitive_Vendor__c + ',' + comp.Account_ID__c + ',' +comp.Related_Opportunity__c;
                }
                uniqueCompetitorValueMap.put(comp.Id , uniqueValue) ;
            }
            if(!uniqueCompetitorValueMap.isEmpty()) {
                for(Id compId : uniqueCompetitorValueMap.keyset()) {
                    competitorsForUpdate.add(new CompetitiveDB__c(Id=compId,Unique_Competitor__c = uniqueCompetitorValueMap.get(compId)));
                }
                
            }
            System.debug('competitorsForUpdate size = '+competitorsForUpdate.size());
            if(!competitorsForUpdate.isEmpty()) {
                update competitorsForUpdate;
            }
        }
    }
    
    global void finish(Database.BatchableContext BC) {}   
}