/*  
* Class Name  : LeadTriggerHandler
* Description:  This class is used in Lead trigger              
* Modification Log 
* ============================================================================= 
* Ver   Date          Author        Modification 
* -----------------------------------------------------------------------------------------------------------------------------------------
* 1.1  29 June 2018     Vineela      Changed sharing rules for partner Account as a part of SF-1199
* 1.2  06 July 2018     Gurditta/Harish Refactored the Code and removed the unused code.
* 1.3  08 Oct  2018     Suveen          Added a before insert trigger for SF- 1430
* 1.4  07 Aug  2020     Martina         Added code for Leads where Track is direct SF 2468
*/
public class LeadTriggerHandler implements ITriggerHandler {
    public static Boolean triggerDisabled = false;
    public static Boolean isRouting = true;
    
    public Boolean IsDisabled(){
        if (TriggerSettings__c.getValues('LeadTriggerDisabled').IsActive__c){
            return true;
        } else{
            return triggerDisabled;
        }
    }
    public Id globalRecTypeId = GlobalUtility.recordTypeId('Lead', 'Global Lead Record');
    private LeadRoutingHelper leadRouter = new LeadRoutingHelper();
    private Map<String, String> iUsers = GlobalUtility.fetchIntegrationUsers('Lead');
    private PartnerSharingHelper partnerSharingHelper = new PartnerSharingHelper(); 
    
    /* method for Before Insert operation */
    public void BeforeInsert(List<SObject> newItems) {
        List<Lead> newGlobalLeadList = new List<Lead>();
        Set<String> domainfromLead = new Set<String>();
        List<Lead> populateTrackonLeads = new List<Lead>();
        Set<Id> userIds = new Set<Id>();
                
        /* SF-2468 - Leads where Track = 'Direct */
        List<Lead> newLeads = newItems;
        Set<String> productsOnLead = new Set<String>();
        Map<String,Lead> accountLeadMap = new Map<String,Lead>();
        Map<String,Lead> productLeadMap = new Map<String,Lead>();
        List<Lead> leadstoBeRoutedForDirect = new List<Lead>();
        /* SF-2468 - Leads where Track = 'Direct  */
        
        List<Lead> leadsForPRMGeoMap = new List<Lead>();
        List<Lead> leadsWithTrackDirect = new List<Lead>();
        
        for(Lead incomingLead:(List<Lead>) newItems){
            if(incomingLead.Track__c != 'Direct'){
                System.debug('Lead Track != Direct');
                if(incomingLead.RecordtypeId == globalRecTypeId){
                    newGlobalLeadList.add(incomingLead);
                }
                userIds.add(incomingLead.OwnerId);
                if(String.isNotBlank(incomingLead.Email)){
                    // incomingLead.EmailDomain__c = incomingLead.Email.substringBetween('@','.');
                    // incomingLead.EmailDomain__c = incomingLead.Email.substringAfter('@');
                    incomingLead.EmailDomain__c = incomingLead.Email_Domain__c;
                    if(incomingLead.Region__c == 'NA'){
                        populateTrackonLeads.add(incomingLead);
                        domainfromLead.add(incomingLead.Email_Domain__c);
                    }
                }
            }
            
            /* SF-2468 - Leads where Track = 'Direct  */
            else{
                system.debug('Lead Track = Direct');
                leadsWithTrackDirect.add(incomingLead);
                if(!String.isEmpty(incomingLead.Technology_Segment__c)){
                	productsOnLead.add(incomingLead.Technology_Segment__c);
                    productLeadMap.put(incomingLead.Technology_Segment__c,incomingLead);
                
                if(incomingLead.Account__c != null){
                    accountLeadMap.put(incomingLead.Account__c,incomingLead);
                }
                else{
                    leadstoBeRoutedForDirect.add(incomingLead);
                }
                } 
                }
            }
                
        //}
        if(!productsOnLead.isEmpty()){
            system.debug('Calling methodForTrackDirect');
                    leadstoBeRoutedForDirect = leadRouter.methodForTrackDirect(productsOnLead,accountLeadMap,productLeadMap,leadsWithTrackDirect);
    	}
        /* SF-2468 - Leads where Track = 'Direct  */  

        system.debug('leadstoBeRoutedForDirect :='+leadstoBeRoutedForDirect);
        if(!populateTrackonLeads.isEmpty()){
            methodToPopulateTrack(populateTrackonLeads,domainfromLead);
        }
        if(!userIds.isEmpty()) {
            populateOwnerQueue(newItems, userIds);
        }
        
        if(!leadstoBeRoutedForDirect.isEmpty()){
            system.debug('leadstoBeRoutedForDirect not empty, calling helper');
            
            leadRouter.leadRouting(leadstoBeRoutedForDirect);
        }
        
        
        if(!newGlobalLeadList.isEmpty()){
            leadRouter.leadRouting(newGlobalLeadList);
        }
        
        if(!leadsForPRMGeoMap.isEmpty()){             //SF-2729
            system.debug('Sending Lead for routing to PRM Geo Maps');
            leadRouter.leadRouting(leadsForPRMGeoMap);
        }
        
    }
    
    
    /* method for Before Update operation */
    public void BeforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems){
        system.debug('In BeforeUpdate');
        Map<Id,Lead> oldLeadMap = new Map<Id,Lead>();
        Map<Id,Lead> newLeadMap = new Map<Id,Lead>();
        
        //  Map<Id,Lead> nonNAoldLeadMap = new Map<Id,Lead>();
        //  Map<Id,Lead> nonNAnewLeadMap = new Map<Id,Lead>();
        List<Lead> populateTrackonLeads = new List<Lead>();
        List<Lead> leadPartnerConEmail = new List<Lead>();
        Set<String> domainfromLead = new Set<String>();
        Set<Id> userIds = new Set<Id>();
        if(oldItems != null)oldLeadMap = (Map<Id,Lead>) oldItems;
        if(newItems != null)newLeadMap = (Map<Id,Lead>) newItems;
        List<Lead> leadsToBeRouted = new List<Lead>();
        List<User> currentUser= [select id, System_Integration__c from user where id=:UserInfo.getUserId() limit 1];
        
        
        /* SF-2468 - Leads where Track = 'Direct */
        List<Lead> newLeads = newLeadMap.values();
        Set<String> productsOnLead = new Set<String>();
        Map<String,Lead> accountLeadMap = new Map<String,Lead>();
        Map<String,Lead> productLeadMap = new Map<String,Lead>();
        List<Lead> leadstoBeRoutedForDirect = new List<Lead>();
        /* SF-2468 - Leads where Track = 'Direct */
        
        
        List<Lead> leadsForPRMGeoMap = new List<Lead>();
        
        for(Lead incomingLead:newLeadMap.values()){
            Lead oldLead = oldLeadMap.get(incomingLead.Id);
            
            if(incomingLead.Track__c != 'Direct'){
                system.debug('Track != Direct in Before update');
                userIds.add(incomingLead.OwnerId);
                if(String.isNotBlank(incomingLead.Email) && incomingLead.Email != oldLead.Email){
                    // incomingLead.EmailDomain__c = incomingLead.Email.substringBetween('@','.');
                    //  incomingLead.EmailDomain__c = incomingLead.Email.substringAfter('@');
                    incomingLead.EmailDomain__c = incomingLead.Email_Domain__c;
                    if(incomingLead.Region__c == 'NA'){
                        populateTrackonLeads.add(incomingLead);
                        domainfromLead.add(incomingLead.Email_Domain__c);
                    }
                }
                //if(incomingLead.recordtypeId == globalRecTypeId && String.isNotBlank(incomingLead.Industry) && (!GlobalUtility.isPicklistValuesFromValueSet('Lead', 'Industry', incomingLead.Industry))){
                //  incomingLead.addError(system.label.Picklist_Value_Incorrect);
                //}Added code as part of SF-2108
                if(String.isNotBlank(incomingLead.Overdue_Status__c) && ((oldLead.status != incomingLead.status  && incomingLead.status!='Marketing Lead')
                                                                         ||(oldLead.Partner_Account_NA__c != incomingLead.Partner_Account_NA__c && incomingLead.status=='Marketing Lead'))){
                                                                             incomingLead.Overdue_Status__c = null ;
                                                                         }
                //Change in Partner Assigned Contact
                if(String.isNotBlank(incomingLead.Partner_Assigned_Contact_NA__c) && incomingLead.Partner_Assigned_Contact_NA__c != oldLead.Partner_Assigned_Contact_NA__c){
                    incomingLead.Partner_Assigned_Status__c = 'On time';
                    incomingLead.Partner_Assigned_Date__c = datetime.now();
                    leadPartnerConEmail.add(incomingLead);
                }else if(String.isBlank(incomingLead.Partner_Assigned_Contact_NA__c)){
                    incomingLead.Partner_Assigned_Status__c = '';
                    leadPartnerConEmail.add(incomingLead);
                }
                
                if(incomingLead.Marketing_Qualified_Lead_Date__c != oldLead.Marketing_Qualified_Lead_Date__c ){
                    incomingLead.SAL__c = true;
                }
                
                // Partner Assigned Status Change
                
                if(incomingLead.Partner_Assigned_Status__c == 'Reassign' && incomingLead.Partner_Assigned_Status__c != oldLead.Partner_Assigned_Status__c){
                    incomingLead.Partner_Assigned_Date__c = null;
                    incomingLead.Partner_Assigned_Contact_NA__c = null;
                    incomingLead.Partner_Account_NA__c = null;   
                }
                
                if( incomingLead.Region__c == 'NA' &&  incomingLead.Track__c != null && oldLead.status != incomingLead.status && incomingLead.status == 'Marketing Lead' &&  
                   ((oldLead.Track__c != incomingLead.Track__c 
                     || oldLead.Countrycode != incomingLead.Countrycode 
                     || oldLead.Statecode != incomingLead.Statecode
                     || oldLead.status != incomingLead.status
                     || oldLead.Technology_Segment__c != incomingLead.Technology_Segment__c))){
                         leadsToBeRouted.add(incomingLead);
                     }
            }
            /* SF-2468 - Leads where Track = 'Direct */
            else if(incomingLead.status == 'Marketing Lead' && oldLead.status != incomingLead.status && currentUser[0].System_Integration__c==false){
               system.debug('Lead Track = Direct');
                if(!String.isEmpty(incomingLead.Technology_Segment__c)){
                	productsOnLead.add(incomingLead.Technology_Segment__c);
                    productLeadMap.put(incomingLead.Technology_Segment__c,incomingLead);
                
                    if(incomingLead.Account__c != null){
                        accountLeadMap.put(incomingLead.Account__c,incomingLead);
                    }
                    else{
                        leadstoBeRoutedForDirect.add(incomingLead);
                    }
                }
                else{
                    system.debug('Leads with no product');
                    incomingLead.OwnerId = UserInfo.getUserId();
                }
                
            }
                
        }
        if(!productsOnLead.isEmpty()){
                    leadstoBeRoutedForDirect = leadRouter.methodForTrackDirect(productsOnLead,accountLeadMap,productLeadMap,newLeads);
    	}      
            /* SF-2468 - Leads where Track = 'Direct */
        
        if(!userIds.isEmpty()) {
            populateOwnerQueue(newItems.values(), userIds);
        }
        if(!populateTrackonLeads.isEmpty()){
            methodToPopulateTrack(populateTrackonLeads,domainfromLead);
        }
        
        if(!leadPartnerConEmail.isEmpty()){
            populateParterConEmailonLeads(leadPartnerConEmail);
        }
        
        
        if(!leadsToBeRouted.isEmpty()){
            leadRouter.leadRouting(leadsToBeRouted);
        }
          
        if(!leadstoBeRoutedForDirect.isEmpty()){
            leadRouter.leadRouting(leadstoBeRoutedForDirect);
        }
        
        if(!leadsForPRMGeoMap.isEmpty()){
            leadRouter.leadRouting(leadsForPRMGeoMap);
        }
        
    }
    
    /* method for After Insert operation */
    public void AfterInsert(Map<Id, SObject> newItems){
        Map<Id,Lead> newLeadMap = new Map<Id,Lead>();
        if(newItems != null){
            newLeadMap = (Map<Id,Lead>) newItems;  
        } 
        
        Set<Lead> sendLeadsForSurvey = new Set<Lead>();
        Set<Id> govWinLeads = new Set<Id>();// SF-1430
        List<Lead> govWinLeadsToBeUpdated = new List<Lead>();// SF-1430
        Map<Id,Id> accLeadMapNew = new Map<Id,Id>();
        for(Lead incomingLead:newLeadMap.values()){
            if(incomingLead.Recordtypeid == globalRecTypeId){
                if(String.isNotBlank(incomingLead.Partner_Account_NA__c)){
                    accLeadMapNew.put(incomingLead.Id,incomingLead.Partner_Account_NA__c);
                }
            }
            
            if(String.isNotBlank(incomingLead.Partner_Assigned_Contact_NA__c)){
                sendLeadsForSurvey.add(incomingLead);
            }
            //SF-1430 
            //system.debug('#####incomingLead.CreatedById##### => ' + incomingLead.CreatedById);
            if(iUsers.get('GovWin_Integration_User').equalsIgnoreCase(incomingLead.CreatedById) || Test.isRunningTest()){
                govWinLeads.add(incomingLead.Id);
            }
        }
        for(Lead govWinLead : [Select Id,Track__c,Region__c,Campaign_code__c,Delivery_Code__c,Onvia_Opportunity_Type__c from Lead where Id IN : govWinLeads]) {
            //system.debug('####GovWinLead####--->'+govWinLead);
            govWinLead.Track__c = 'Direct';
            govWinLead.Region__c = 'NA';
            if(String.isNotBlank(govWinLead.Onvia_Opportunity_Type__c) && govWinLead.Onvia_Opportunity_Type__c.equals('Bid')){
                //system.debug('####Bid govWinLead.Onvia_Opportunity_Type__c####--->'+govWinLead.Onvia_Opportunity_Type__c);
                govWinLead.Campaign_code__c = 'Onvia_Pursuits_Bid';
                govWinLead.Delivery_Code__c = 'Onvia_Pursuits_Bid';
                //System.debug('####Bid govWinLead.Campaign_code__c ####--->'+govWinLead.Campaign_code__c);
                //System.debug('####Bid govWinLead.Delivery_Code__c ####--->'+govWinLead.Delivery_Code__c );
            } else if(String.isNotBlank(govWinLead.Onvia_Opportunity_Type__c) && govWinLead.Onvia_Opportunity_Type__c.equals('Lead')){
                //system.debug('####Lead govWinLead.Onvia_Opportunity_Type__c####--->'+govWinLead.Onvia_Opportunity_Type__c);
                govWinLead.Campaign_code__c = 'Onvia_Pursuits_Project_Preview';
                govWinLead.Delivery_Code__c = 'Onvia_Pursuits_Project_Preview';
                //System.debug('####Lead govWinLead.Campaign_code__c ####--->'+govWinLead.Campaign_code__c);
                //System.debug('####Lead govWinLead.Delivery_Code__c ####--->'+govWinLead.Delivery_Code__c );
            } else if(String.isNotBlank(govWinLead.Onvia_Opportunity_Type__c) && govWinLead.Onvia_Opportunity_Type__c.equals('FBO Notice')){
                //system.debug('####FBO Notice govWinLead.Onvia_Opportunity_Type__c####--->'+govWinLead.Onvia_Opportunity_Type__c);     
                govWinLead.Campaign_code__c = 'Onvia_Pursuits_Term_Contracts';
                govWinLead.Delivery_Code__c = 'Onvia_Pursuits_Term_Contracts';
                //System.debug('####FBO Notice govWinLead.Campaign_code__c ####--->'+govWinLead.Campaign_code__c);
                //System.debug('####FBO Notice govWinLead.Delivery_Code__c ####--->'+govWinLead.Delivery_Code__c );
            }
            govWinLeadsToBeUpdated.add(govWinLead);
        } /*end of change-SF-1430*/        
        
        if(!accLeadMapNew.isEmpty()){
            partnerSharingHelper.shareToExecutiveRoles(accLeadMapNew);
        }
        
        shareLeadWithIcam(newLeadMap.values());
        onViaIntegration(newLeadMap.keySet());
        if(!sendLeadsForSurvey.isEmpty()){
            leadRouter.insertSurveyToCustomer(sendLeadsForSurvey);
        }
        Database.update(govWinLeadsToBeUpdated);
    }
    
    /* method for After Update operation */
    public void afterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems){
        Map<Id,Lead> newLeadMap = new Map<Id,Lead>();
        Map<Id,Lead> oldLeadMap = new Map<Id,Lead>();
        
        if(newItems != null){
            newLeadMap = (Map<Id,Lead>) newItems;  
        } 
        
        if(oldItems != null){
            oldLeadMap = (Map<Id,Lead>) oldItems;  
        } 
        
        Map<Id,Lead> newGlobalLeadsMap = new Map<Id,Lead>();
        
        /*Lead Sharing for Partner Executive and Partner Contact -Harish*/
        Map<Id,Id> accLeadMapNewNA = new Map<Id,Id>();  // Used For NA,EA,ME
        Map<Id,Id> accLeadMapOldNA = new Map<Id,Id>();  // Used For NA,EA,ME
        
        Map<Id,Id> accLeadMapNewNonNA = new Map<Id,Id>(); // Used For AP,LA
        Map<Id,Lead> accLeadMapOldNonNA = new Map<Id,Lead>(); // Used For AP,LA
        
        Map<Id,Id> conLeadMapNewNA = new Map<Id,Id>(); // Used For NA,EA,ME
        Map<Id,Id> conLeadMapOldNA = new Map<Id,Id>(); // Used For NA,EA,ME
        
        List<Lead> iCamChangedforLeads = new List<Lead>();
        List<Lead> ownerChangedforLeads = new List<Lead>();
        Map<Id,Lead> oldOwnerChangeMap = new Map<Id,Lead>();
        Set<Id> partnerAcc = new Set<Id>(); //SF-1844            
        Id leadId;//SF-1844
        
        Set<Lead> sendLeadsForSurvey = new Set<Lead>();
        
        for(Lead leadObject : newLeadMap.values()) {
            Lead oldlead =  oldLeadMap.get(leadObject.Id);
            if(leadObject.Recordtypeid == globalRecTypeId){            
                newGlobalLeadsMap.put(leadObject.Id, leadObject);
                // Change in Assigned Partner
                if(leadObject.Partner_Account_NA__c != oldlead.Partner_Account_NA__c) {
                    if(leadObject.Region__c == 'NA' || leadObject.Region__c == 'EA' || leadObject.Region__c == 'ME'){
                        if(String.isNotBlank(leadObject.Partner_Account_NA__c)){
                            accLeadMapNewNA.put(leadObject.Id,leadObject.Partner_Account_NA__c);   
                        }
                        if(String.isNotBlank(oldlead.Partner_Account_NA__c)){
                            accLeadMapOldNA.put(leadObject.Id,oldlead.Partner_Account_NA__c);    
                        }  
                    }else if(leadObject.Region__c == 'AP' || leadObject.Region__c == 'LA'){
                        if(String.isNotBlank(leadObject.Partner_Account_NA__c)){
                            accLeadMapNewNonNA.put(leadObject.Id,leadObject.Partner_Account_NA__c);   
                        }
                        accLeadMapOldNonNA.put(leadObject.Id,oldlead);    
                    }
                    /*
if(oldlead.Partner_Account_NA__c != leadObject.Partner_Account_NA__c && String.isNotBlank(leadObject.Partner_Account_NA__c)t){
sendLeadsForSurvey.add(leadObject);
}*/
                }
                // Change in Assigned Partner Contact
                if(leadObject.Partner_Assigned_Contact_NA__c != oldlead.Partner_Assigned_Contact_NA__c){
                    if(leadObject.Region__c == 'NA' || leadObject.Region__c == 'EA' || leadObject.Region__c == 'ME'){
                        if(String.isNotBlank(leadObject.Partner_Assigned_Contact_NA__c)){
                            conLeadMapNewNA.put(leadObject.Id, leadObject.Partner_Assigned_Contact_NA__c);   
                        }
                        if(String.isNotBlank(oldlead.Partner_Assigned_Contact_NA__c)){
                            conLeadMapOldNA.put(leadObject.Id, oldlead.Partner_Assigned_Contact_NA__c);    
                        }  
                    }
                    
                    if(String.isNotBlank(leadObject.Partner_Assigned_Contact_NA__c)){
                        sendLeadsForSurvey.add(leadObject);
                    }
                }
                
                // Change in Ownership
                if(leadObject.OwnerId != oldlead.OwnerId){
                    oldOwnerChangeMap.put(oldlead.Id,oldlead);
                    
                    //Sharing upon Owner Change
                    if(String.isNotBlank(leadObject.Partner_Account_NA__c)){
                        if(leadObject.Region__c == 'NA' || leadObject.Region__c == 'EA' || leadObject.Region__c == 'ME'){
                            accLeadMapNewNA.put(leadObject.Id, leadObject.Partner_Account_NA__c);       
                        } else if(leadObject.Region__c == 'AP' || leadObject.Region__c == 'LA'){
                            accLeadMapNewNonNA.put(leadObject.Id, leadObject.Partner_Account_NA__c);   
                        }  
                    }
                    if(String.isNotBlank(leadObject.Partner_Assigned_Contact_NA__c)){
                        if(leadObject.Region__c == 'NA' || leadObject.Region__c == 'EA' || leadObject.Region__c == 'ME'){
                            conLeadMapNewNA.put(leadObject.Id, leadObject.Partner_Assigned_Contact_NA__c);       
                        }
                    }
                    ownerChangedforLeads.add(leadObject);
                    //Sharing upon Owner Change
                }
                
                //Change in CAM- API Name is Indirect_CAM__C
                if(leadObject.Indirect_CAM__c != oldlead.Indirect_CAM__c && String.isNotBlank(leadObject.Indirect_CAM__c)){
                    iCamChangedforLeads.add(leadObject);
                }
            }
        }
        /* Revoke Access to Old Partner Contacts and Old Executive Roles*/
        if(!conLeadMapOldNA.isEmpty()){
            partnerSharingHelper.revokeAccessToPartnerUsers(conLeadMapOldNA);
        }
        if(!accLeadMapOldNA.isEmpty()){
            partnerSharingHelper.revokeAccessToPartnerExecs(accLeadMapOldNA);
        }        
        if(!accLeadMapNewNA.isEmpty()){
            partnerSharingHelper.shareToExecutiveRoles(accLeadMapNewNA);
        }
        if(!conLeadMapNewNA.isEmpty()){
            partnerSharingHelper.shareToPartnerUser(conLeadMapNewNA);
        }
        
        if(!accLeadMapOldNonNA.isEmpty()){
            partnerSharingHelper.removeLeadSharingOfAPandLALeads(accLeadMapOldNonNA);
        }
        
        if(!accLeadMapNewNonNA.isEmpty()){
            partnerSharingHelper.leadSharingOfAPandLALeads(accLeadMapNewNonNA);
        }
        
        
        if(!iCamChangedforLeads.isEmpty() || !ownerChangedforLeads.isEmpty()){
            Set<Lead> allLeadSet = new Set<Lead>();
            allLeadSet.addAll(iCamChangedforLeads);
            allLeadSet.addAll(ownerChangedforLeads);
            
            List<Lead> allLeadstoBeShared = new List<Lead>();
            allLeadstoBeShared.addAll(allLeadSet);
            
            shareLeadWithIcam(allLeadstoBeShared);
            apacLeadShare(allLeadSet);
        }
        
        if(!oldOwnerChangeMap.isEmpty()){
            shareLeadWithOldOwner(oldOwnerChangeMap);
        }
        
        if(UserInfo.getUserType() == 'Standard' || Schema.sObjectType.Opportunity.isCreateable()) {
            afterConvertLead(newGlobalLeadsMap, oldLeadMap);
            insertPartnersOnOppo(newGlobalLeadsMap.values());
        }
        
        if(!sendLeadsForSurvey.isEmpty()){
            leadRouter.insertSurveyToCustomer(sendLeadsForSurvey);
        } 
        
        if((UserInfo.getUserType() != 'Standard') || Test.isRunningTest()){
            GenericWithoutSharing leadConvert = new GenericWithoutSharing();
            if(!Schema.sObjectType.Opportunity.isCreateable()){
                leadConvert.convertLeadWithoutSharing(newLeadMap);   
            }
            
            leadConvert.updateConvertedConRecTypeId(newLeadMap);
            
        }
    }
    
    // Inserts Campaign Members based on the Campaign for the Leads created by Onvia Integration
    public void onviaIntegration(Set<Id> leadIdList){
        List<Campaign> campaingsList = [Select Id,Name from Campaign where Name IN ('Onvia_Pursuits_Term_Contracts','Onvia_Pursuits_Bid','Onvia_Pursuits_Project_Preview') LIMIT 10000];
        Map<String,Id> campaingsMap = new Map<string,Id>();
        for(Campaign CL : campaingsList){
            campaingsMap.put(CL.Name, CL.Id);
        }
        
        List<Lead> leadListToBeUpdated = new List<Lead>();
        List<CampaignMember> campaignMembersToBeInserted = new List<CampaignMember>();
        
        for(Lead leadObject : [Select Id,OwnerId,Owner.Name,Campaign_Code__c from Lead where id IN:leadIdList and Owner.Name = 'Onvia Integration']) {
            String campaignId = campaingsMap.get(leadObject.Campaign_Code__C);
            if(String.isNotBlank(campaignId)) {
                CampaignMember cmObject = new CampaignMember();
                cmObject.CampaignId = campaignId;
                cmObject.LeadId = leadObject.Id;
                campaignMembersToBeInserted.add(cmObject);
            }
            Database.DMLOptions dmo = new Database.DMLOptions();
            dmo.assignmentRuleHeader.useDefaultRule = true; 
            leadObject.setOptions(dmo);
            leadListToBeUpdated.add(leadObject);
        }
        
        if(leadListToBeUpdated.size()>0){
            update leadListToBeUpdated;   
        }
        
        if(campaignMembersToBeInserted.size()>0) {
            insert campaignMembersToBeInserted;   
        }
    }
    
    // Inserts records to Partners related list of Opportunity upon Lead Conversion
    public void insertPartnersOnOppo(List<Lead> newleadList) {
        for(Lead leadObject : newleadList){
            if(leadObject.isConverted){
                List<Partners2__c> newPartners = new List<Partners2__c>();
                if(leadObject.ConvertedOpportunityId != null && leadObject.Channel_Partner__c != null ){
                    newPartners.add(new Partners2__c(
                        Opportunity__c=leadObject.ConvertedOpportunityId,
                        Account__c=leadObject.Channel_Partner__c,
                        Role__c='Primary Channel Partner'
                    ));
                }
                if(leadObject.ConvertedOpportunityId != null && leadObject.Distributor__c != null){
                    newPartners.add(new Partners2__c(
                        Opportunity__c=leadObject.ConvertedOpportunityId,
                        Account__c=leadObject.Distributor__c,
                        Role__c='Primary Distributor'));
                }
                if(newPartners.size()>0){
                    insert newPartners;
                }
            }
        }
    }
    
    /*
*Description         : On conversion of lead,trigger to update the Leadid field on Account and Contact Object
* @author            : Shahanawaz Akhtar - Trigger Consolidation
: Sai Harish Thammana - Extended the functionality to Partner User to use Standard Lead Conversion Process
*/
    public void afterConvertLead(Map<Id, Lead> newleadMap, Map<Id, Lead> oldleadMap){        
        List<Id> convertedContactsList = new List<Id>();      
        List<Id> convertedAccountsList = new List<Id>();   
        
        Map<Id,Id> leadOppoIdsMap = new Map<Id,Id>();      
        //Map<Id,Id> leadAccountIdsMap = new Map<Id,Id>();      
        Set<String> productNamesSet = new Set<String>();         
        Set<String> currenciesSet = new Set<String>();
        Set<String> customerNumbers = new Set<String>();
        
        for(Lead leadObj : newleadMap.values()) {
            if(!Test.isRunningTest()){
                if (!oldleadMap.get(leadObj.Id).IsConverted && leadObj.isConverted){
                    if (String.isNotBlank(leadObj.Lead_Type__c) && leadObj.Region__c == 'NA' && leadObj.Track__c == 'Indirect' && UserInfo.getUserType() != 'Standard'){
                        leadObj.addError('This is a Lead Type that doesn\'t need to be converted, please exit the Screen'); 
                        return;          
                    }
                    
                    if(leadObj.Close_Date__c == null || leadObj.Lead_Value__c == null){
                        leadObj.addError('Please enter Expected Close Date & Amount before converting a Lead'); 
                        return;          
                    }
                    
                    if (String.isBlank(leadObj.Region__c)) {
                        leadObj.addError('Please Enter Region Value'); 
                        return;                   
                    }   
                    if (String.isBlank(leadObj.Country)) {
                        leadObj.addError('Please Enter Country value in Address Information');
                        return;                    
                    }    
                    //SF-1565 - Region->Territory->Country->State Alignment -SF-2043 -Start - Modified by Anitha
                    List<AddressCtrl.AddressDef> lstStates = new List<AddressCtrl.AddressDef>();                    
                    lstStates.addAll(AddressCtrl.fetchStates(leadObj.Countrycode,true));
                    //System.debug('State Size==>' + lstStates.size());
                    if(!lstStates.isEmpty()){
                        if (String.isBlank(leadObj.State) && leadObj.Region__c == 'NA'){
                            leadObj.addError('Please Enter State Value in Address Information'); 
                            return;          
                        }
                    }
                    //SF-1565 - End 
                    if (String.isBlank(leadObj.Territory__c) && (leadObj.Region__c == 'NA' || leadObj.Region__c == 'LA' || leadObj.Region__c == 'ME' || leadObj.Region__c == 'EA')){
                        leadObj.addError('Please Enter Territory Value');     
                        return;                
                    }
                    //Below validations added for Lead conversion for NA communities -- satish
                    if (String.isBlank(leadObj.City) && leadObj.Region__c == 'NA'){
                        leadObj.addError('Please Enter City Value in Address Information'); 
                        return;          
                    }
                    if (String.isBlank(leadObj.Email) && leadObj.Region__c == 'NA'){
                        leadObj.addError('Please Enter Email Value'); 
                        return;          
                    }
                    if (leadObj.Lead_Value__c == null && leadObj.Region__c == 'NA'){
                        leadObj.addError('Please Enter Amount Value'); 
                        return;          
                    }
                    if (String.isBlank(leadObj.Technology_Segment__c) && leadObj.Region__c == 'NA'){
                        leadObj.addError('Please Enter Product Family Value'); 
                        return;          
                    }
                    
                } 
            }
            
            
            if(leadObj.ConvertedOpportunityId != null && (!oldleadMap.get(leadObj.Id).isConverted && leadObj.isConverted)){
                leadOppoIdsMap.put(leadObj.Id, leadObj.ConvertedOpportunityId);   
            }
            //System.debug('leadObj.SAL__c####=>'+leadObj.SAL__c);
            if (!oldleadMap.get(leadObj.Id).isConverted && leadObj.isConverted && 
                leadObj.Company != null && (leadObj.Phone != null || leadObj.Email != null) && leadObj.City != null
                && leadObj.Street != null && leadObj.Country != null && leadObj.SAL__c) {
                    if (leadObj.ConvertedAccountId != null) {
                        convertedAccountsList.add(leadObj.ConvertedAccountId);
                    } 
                    if (leadObj.ConvertedContactId != null) {
                        convertedContactsList.add(leadObj.ConvertedContactId);
                    }
                }   
            
            productNamesSet.add(leadObj.Technology_Segment__c);
            currenciesSet.add(leadObj.CurrencyIsoCode);
            if(String.isNotBlank(leadObj.Customer_Number__c)){
                customerNumbers.add(leadObj.Customer_Number__c);    
            }
        } 
        
        List<Account> accountsListDB = new List<Account>();
        List<Contact> contactsListDB =new List<Contact>();
        Map<Id,Account> accMap =new Map<Id,Account>();
        Set<String> mcnLstDB = new Set<String>();
        
        if(convertedAccountsList.size()>0) {
            for(Account mcnAcc:[SELECT Id,Motorola_Customer_Number__c FROM Account WHERE Motorola_Customer_Number__c IN:customerNumbers AND Motorola_Customer_Number__c != NULL
                                AND Recordtype.name='Motorola Customer Number']){
                                    mcnLstDB.add(mcnAcc.Motorola_Customer_Number__c);
                                }
            Map<Id,Account> tempMap =new Map<Id,Account>([Select Id,Name,LeadId__c,Owner.ContactId,(SELECT Id,Name,Motorola_Customer_Number__c FROM ChildAccounts) from Account where Id IN : convertedAccountsList]);
            accountsListDB = tempMap.values();
            accMap = tempMap;
        }
        
        for(Lead leadObj : newleadMap.values()) {
            //System.debug('#######leadObj.ConvertedAccountId####=>'+leadObj.ConvertedAccountId); 
            //System.debug('#######accMap####=>'+accMap);
            
            if(String.isNotBlank(leadObj.ConvertedAccountId) && accMap.containsKey(leadObj.ConvertedAccountId)){
                //System.debug('#######leadObj.Customer_Number__c####=>'+leadObj.Customer_Number__c); 
                if(String.isNotBlank(leadObj.Customer_Number__c) && mcnLstDB.contains(leadObj.Customer_Number__c)){
                    Set<String> motorolaCustomerNumbers = new Set<String>();
                    List<Account> mcnsOnCustomer = new List<Account>();
                    mcnsOnCustomer = accMap.get(leadObj.ConvertedAccountId).ChildAccounts;
                    
                    for(Account acc:mcnsOnCustomer){
                        motorolaCustomerNumbers.add(acc.Motorola_Customer_Number__c);
                    }
                    //System.debug('#######mcnsOnCustomer####=>'+mcnsOnCustomer); 
                    //System.debug('#######motorolaCustomerNumbers####=>'+motorolaCustomerNumbers); 
                    
                    if(!motorolaCustomerNumbers.contains(leadObj.Customer_Number__c)){
                        leadObj.addError('Before convert, please choose an existing customer by searching with customer number('+leadObj.Customer_Number__c+')');
                        return;
                    }
                }
                String accOwnerContact  = accMap.get(leadObj.ConvertedAccountId).Owner.ContactId;
                if(String.isNotBlank(accOwnerContact)){
                    leadObj.addError('Lead owner cannot be changed,please exit the screen');
                    return;
                }
            }
        }
        
        if(convertedContactsList.size()>0) {
            contactsListDB = [Select Id,LeadId__c,Name from Contact where Id IN : convertedContactsList];   
        }
        List<Opportunity> convertedOppsDB = [Select Id,Name,Business_Group__c,Channel_Opportunity__c,Region__C,Industry__c from Opportunity where Id IN : leadOppoIdsMap.values()];
        List<note> notesListToBeInserted = new List<note>();
        List<OpportunityLineItem> oppLineItemsToBeInserted = new List<OpportunityLineItem>();
        Map<String,Id> priceBookEntryMap = new Map<String,Id>();
        for(PriceBookEntry priceBookEntryDB : [Select Id,Product2.Name,CurrencyIsoCode from PriceBookEntry where Product2.Name IN : productNamesSet and 
                                               Pricebook2.Name='Standard Price Book' and CurrencyIsoCode IN : currenciesSet and IsActive = true limit 500]) 
        {
            priceBookEntryMap.put(priceBookEntryDB.Product2.Name+priceBookEntryDB.CurrencyIsoCode, priceBookEntryDB.Id);
        }
        
        List<Account> accountsToBeUpdated = new List<Account>();
        List<Contact> contactsToBeUpdated = new List<Contact>();
        List<Opportunity> oppsToBeUpdated = new List<Opportunity>();
        
        //System.debug('newleadMap.values - ' + newleadMap.values());
        
        for(Lead convertedLead : newleadMap.values()) {
            for(Account convertedAccount : accountsListDB) {
                if (convertedLead.ConvertedAccountId != null) {
                    if(convertedLead.ConvertedAccountId == convertedAccount.Id){
                        convertedAccount.LeadId__c = convertedLead.Id;
                        convertedAccount.Region__c = convertedLead.Region__c;
                        accountsToBeUpdated.add(convertedAccount);
                    }
                }
            }
            for(Contact convertedContact : contactsListDB) {
                if (convertedLead.ConvertedContactId != null) {
                    if(convertedLead.ConvertedContactId == convertedContact.Id){
                        convertedContact.LeadId__c = convertedLead.Id;
                        contactsToBeUpdated.add(convertedContact);
                    }
                }
            }
            
            if (oldleadMap.get(convertedLead.Id).isConverted == false && convertedLead.isConverted == true) {
                Set<String> listOfOppStates = new Set<String>(GlobalUtility.fetchPicklistsByObjectAndFieldMap('Opportunity', 'State__c').values()); //SF-2097
                Map<String,List<AddressCtrl.AddressDef>> mapTerrandCountry = AddressCtrl.getFieldDependencies('Opportunity','Territory__c','Country__c',false);//SF-2097
                
                for(Opportunity convertedOpp : convertedOppsDB) {
                    if(convertedOpp.Id == leadOppoIdsMap.get(convertedLead.Id))
                    {
                        if(convertedLead.Budget_Value__c != Null){
                            convertedOpp.Customer_Budget__c = convertedLead.Budget_Value__c ;  // VESTA_SPILLMAN_INT-267
                        }
                        
                        if(convertedLead.Region__c == 'EA' && String.isBlank(convertedOpp.Business_Group__c)){
                            convertedOpp.Business_Group__c ='EMEA Government System Project';
                        }
                        
                        if(convertedLead.Partner_Account_NA__c == null && String.isBlank(convertedOpp.Channel_Opportunity__c)) {
                            convertedOpp.Channel_Opportunity__c = 'Direct';
                        } else if(String.isBlank(convertedOpp.Channel_Opportunity__c) && String.isBlank(convertedOpp.Business_Group__c)) {
                            convertedOpp.Channel_Opportunity__c = 'Partner';
                        }
                        if(String.isNotBlank(convertedLead.Description)){
                            Note noteObj = new Note(Title= 'Lead Description', Body = convertedLead.Description, ParentId = convertedOpp.id);
                            notesListToBeInserted.add(noteObj);
                        }
                        if(String.isNotBlank(convertedLead.Region__c) || String.isNotBlank(convertedLead.State) ||
                           String.isNotBlank(convertedLead.Territory__c) || String.isNotBlank(convertedLead.Country)){
                               if(String.isBlank(convertedOpp.Region__c)){
                                   convertedOpp.Region__c = convertedLead.Region__c ;
                               }
                               //system.debug('**********convertedOpp.Region__c***'+convertedLead.Region__c);
                               
                               //system.debug('**********convertedOpp.Territory__c***'+convertedLead.Territory__c);
                               convertedOpp.Territory__c = convertedLead.Territory__c ;
                               List<String> dependentCountry = new List<String>(); //SF-2097 starts
                               for(AddressCtrl.AddressDef depCountry : mapTerrandCountry.get(convertedLead.Territory__c)){
                                   dependentCountry.add(depCountry.label);
                               }
                               // if(!listOfOppCountries.contains(convertedLead.Country)){
                               if(!dependentCountry.contains(convertedLead.Country)){
                                   convertedOpp.Country__c = NULL; //SF-2097 ends
                               }else{
                                   convertedOpp.Country__c = convertedLead.Country ; 
                               }
                               if(!listOfOppStates.contains(convertedLead.State) || String.isBlank(convertedOpp.Country__c)){
                                   convertedOpp.State__c = NULL; //SF-2097 ends
                               }else{
                                   convertedOpp.State__c = convertedLead.State ;
                               }
                               if(String.isBlank(convertedOpp.Industry__c)){
                                   convertedOpp.Industry__c = convertedLead.Industry;
                               }
                           }
                        oppsToBeUpdated.add(convertedOpp);
                        if (!oldleadMap.get(convertedLead.Id).isConverted && convertedLead.isConverted){
                            if(!Test.isRunningTest()) {
                                /*if(String.isNotBlank(convertedLead.Technology_Segment__c)) {
convertedLead.addError('Please Select product Family before converting a lead');     
return;
}
if(convertedLead.Lead_Value__c == null){
convertedLead.addError('Please Enter Amount before converting a lead');     
return;
}*/
                            }
                            if(priceBookEntryMap.get(convertedLead.Technology_Segment__c+convertedLead.CurrencyIsoCode) != null && convertedLead.Lead_Value__c != null) {
                                if(priceBookEntryMap.get(convertedLead.Technology_Segment__c+convertedLead.CurrencyIsoCode)!=null) {
                                    OpportunityLineItem oppLineItem = new OpportunityLineItem();                   
                                    oppLineItem.UnitPrice = convertedLead.Lead_Value__c;
                                    //oppLineItem.UnitPrice = convertedLead.Budget_Value__c;  // VESTA_SPILLMAN_INT-267
                                    oppLineItem.Quantity = 1;
                                    oppLineItem.PricebookEntryId = priceBookEntryMap.get(convertedLead.Technology_Segment__c+convertedLead.CurrencyIsoCode);
                                    oppLineItem.OpportunityId = convertedOpp.Id;
                                    oppLineItemsToBeInserted.add(oppLineItem);
                                }
                            }
                        }
                    }      
                }
            }  
        }
        
        if(accountsToBeUpdated.size()>0){
            update accountsToBeUpdated;
        }
        if(contactsToBeUpdated.size()>0){
            update contactsToBeUpdated;
        }
        if(notesListToBeInserted.size()>0){
            insert notesListToBeInserted;
        }
        if(oppLineItemsToBeInserted.size()>0){
            insert oppLineItemsToBeInserted;
        }
        if(oppsToBeUpdated.size()>0){
            update oppsToBeUpdated;
        }
        //CampaignInfluence
        if(!leadOppoIdsMap.values().isEmpty() && !convertedContactsList.isEmpty()){
            Set<Id> tempOpps = new Set<Id>();
            tempOpps.addAll(leadOppoIdsMap.values());
            
            Set<Id> tempConts = new Set<Id>();
            tempConts.addAll(convertedContactsList);
            //Commneted by Adil for lead conversion issue
            CampaignInfluenceTriggerHandler citm = new CampaignInfluenceTriggerHandler();
            citm.insertEvenDistributonInfluences(tempOpps, tempConts);
            //CampaignInfluenceTriggerHandler.insertEvenDistributonInfluences(tempOpps, tempConts);
        }
        
    }
    
    /* method for Before Delete operation */
    public void BeforeDelete(Map<Id, SObject> oldItems){}
    /* method for After Delete operation */
    public void AfterDelete(Map<Id, SObject> oldItems){}
    /* method for After Undelete operation */
    public void AfterUndelete(Map<Id, SObject> oldItems){}
    
    private void shareLeadWithIcam(List<Lead> leadList){
        List<LeadShare> leadShareList = new List<LeadShare>();
        for(Lead newLead : leadList) { 
            if(newLead.Indirect_CAM__c != null && newLead.Recordtypeid == globalRecTypeId){
                leadShareList.add(new LeadShare(
                    LeadId = newLead.id,
                    UserOrGroupId = newLead.Indirect_CAM__c,
                    LeadAccessLevel = 'Edit'
                ));
            }
        }
        if(leadShareList.size()>0){
            Database.insert(leadShareList,false);
        }
    }
    
    private void shareLeadWithOldOwner(Map<Id,Lead> oldLeadMap){
        List<LeadShare> leadShareList = new List<LeadShare>();
        for(Lead oldLead : oldLeadMap.values()) { 
            if(oldLead.OwnerId != null && oldLead.Recordtypeid == globalRecTypeId){
                leadShareList.add(new LeadShare(
                    LeadId = oldLead.id,
                    UserOrGroupId = oldLead.OwnerId,
                    LeadAccessLevel = 'Edit'
                ));
            }
        }
        if(leadShareList.size()>0){
            Database.insert(leadShareList,false);
        }
    }
    
    public void apacLeadShare(Set<Lead> updatedLeads){
        List<LeadShare> apacLeadSharing = new List<LeadShare>(); 
        Map<String,String> apacGroupsMap = new Map<String,String>();
        
        for(Group g:[SELECT Id,Name FROM Group WHERE Name IN ('APAC Call Center team')]) {
            apacGroupsMap.put(g.Name,g.Id);
        }
        
        for(Lead incomingLead : updatedLeads){
            if(String.valueOf(incomingLead.OwnerId).substring(0,3) == '00G'){
                if(incomingLead.RecordTypeId == globalRecTypeId && incomingLead.Region__c == 'AP'){
                    apacLeadSharing.add(new LeadShare(LeadAccessLevel = 'Edit',
                                                      UserOrGroupId = apacGroupsMap.get('APAC Call Center team'),
                                                      LeadId = incomingLead.Id));
                }
            }
        }
        
        if(!apacLeadSharing.isEmpty()){
            Database.insert(apacLeadSharing,false);
        }
    }
    
    public void methodToPopulateTrack(List<Lead> toBeupdated,Set<String> emailDomains){
        //System.debug('Entered Track Population');
        List<Lead_Track_Email_Domain__mdt> emailDomainMetadata =[Select Id,Track__c,Label from Lead_Track_Email_Domain__mdt WHERE Label IN:emailDomains];
        Map<String,String> domainMap = new Map<String,String>();
        
        for(Lead_Track_Email_Domain__mdt domain:emailDomainMetadata){
            domainMap.put(domain.Label,domain.Track__c);
        }
        
        for(Lead incoming:toBeupdated){
            if(String.isNotBlank(domainMap.get(incoming.Email_Domain__c))){
                incoming.Track__c = domainMap.get(incoming.Email_Domain__c);    
            }
        }
    }
    
    public void populateParterConEmailonLeads(List<Lead> toBeupdated){
        //System.debug('Entered Partner Contact Population');
        Set<Id> partnerConIds = new Set<Id>();
        
        for(Lead leadObj:toBeupdated){
            if(String.isNotBlank(leadObj.Partner_Assigned_Contact_NA__c)){
                partnerConIds.add(leadObj.Partner_Assigned_Contact_NA__c);
            }
        }
        
        Map<Id,Contact> conMap = new Map<Id,Contact>([SELECT Id,Email FROM Contact WHERE Id IN:partnerConIds]);
        //System.debug('Entered Partner Contact Population conMap###=>'+conMap);
        
        for(Lead incoming:toBeupdated){
            if(String.isNotBlank(incoming.Partner_Assigned_Contact_NA__c)){
                incoming.Partner_Assigned_Contact_Email__c = conMap.get(incoming.Partner_Assigned_Contact_NA__c).Email;
            }else{
                incoming.Partner_Assigned_Contact_Email__c='';
            } 
        }
    }
    
    public void populateOwnerQueue(List<Lead> newItems, Set<Id> userIds){
        Map<String, GroupMember> existsMap = new Map<String, GroupMember>();
        for(GroupMember member: [SELECT UserOrGroupId, Group.Name FROM GroupMember WHERE UserOrGroupId in :userIds 
                                 and Group.Type = 'Queue' and Group.Name = 'Sales - Software Enterprise']){
                                     existsMap.put(member.UserOrGroupId, member);
                                 }
        for(Lead leadRec: newItems){
            if (existsMap.get(leadRec.OwnerId) != NULL && leadRec.OwnerId.getSObjectType() == User.SObjectType){
                leadRec.Owner_Queue_Name__c = existsMap.get(leadRec.OwnerId).Group.Name;
            }
        }
        Map<String, Group> existsMapQueue = new Map<String, Group>();
        for(Group queueName : [SELECT Id,Name FROM Group WHERE Id = :userIds and Group.Name = 'Sales - Software Enterprise']){
            existsMapQueue.put(queueName.Id, queueName);
        }
        for(Lead leadRec: newItems){
            if(existsMapQueue.get(leadRec.OwnerId) != NULL && leadRec.OwnerId.getSObjectType() == Group.SObjectType){
                leadRec.Owner_Queue_Name__c = existsMapQueue.get(leadRec.OwnerId).Name; 
            }
        }
    }
        
}