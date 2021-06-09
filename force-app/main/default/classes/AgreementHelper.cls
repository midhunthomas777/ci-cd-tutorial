public class AgreementHelper {
    Id agreeRecTypeId = GlobalUtility.recordTypeId('Apttus__APTS_Agreement__c','Sales');
    Id accMotEntRecTypeId = GlobalUtility.recordTypeId('Account','Motorola Entity');
    
    public void insertAgreement(List<PreSales__c> preSaleList,Map<Id,Opportunity> oppMap){
        System.debug('Entered Agreement Insertion');
        List<Apttus__APTS_Agreement__c> agreementsToBeInserted = new List<Apttus__APTS_Agreement__c>();
        String motSolCanadaId = NULL;
        String motSolId = NULL;
        
        Map<Id,String> oppIdLineItemNames = getOppLineItemNames(oppMap.keySet());
        Map<Id,Boolean> oppLinematureproduct = getOppLineMatureProduct(oppMap.keySet());
        for(Account entity:[SELECT Id,Name FROM Account WHERE Name IN ('Motorola Solutions Canada Inc.','Motorola Solutions, Inc.') AND RecordTypeId =: accMotEntRecTypeId]){ 
            if(entity.Name == 'Motorola Solutions Canada Inc.'){
                motSolCanadaId = entity.Id;
            } else if (entity.Name == 'Motorola Solutions, Inc.'){
                motSolId = entity.Id;
            } 
        }
        
        for(PreSales__c incoming: preSaleList) {
            Opportunity relatedOpp = oppMap.get(incoming.Opportunity__c);
            String technologyName = '';
            Boolean matureproduct = FALSE;
            if(String.isNotBlank(oppIdLineItemNames.get(incoming.Opportunity__c))){
                technologyName = oppIdLineItemNames.get(incoming.Opportunity__c);
            }
            
            if(oppLinematureproduct.containsKey(incoming.Opportunity__c)){
                matureproduct = TRUE;
            }
            
            Apttus__APTS_Agreement__c agreement = prepareAgreementRecord
                (incoming,relatedOpp,technologyName,motSolCanadaId,motSolId,matureproduct);
            agreementsToBeInserted.add(agreement);
        }
        
        System.debug('agreementsToBeInserted###=>'+agreementsToBeInserted);
        if(!agreementsToBeInserted.isEmpty()){
            insert agreementsToBeInserted;   
        }
    }
    
    public void updateAgreement(List<Apttus__APTS_Agreement__c> allExistingAgreements,Map<Id,Opportunity> 
                                oppMap,Map<Id,PreSales__c> oppNewPresaleMap){
                                    System.debug('Entered Update Agreements Method');
                                    List<Apttus__APTS_Agreement__c> agreementsToBeUpdated = new List<Apttus__APTS_Agreement__c>();
                                    String motSolCanadaId = NULL;
                                    String motSolId = NULL;
                                    for(Account entity:[SELECT Id,Name FROM Account WHERE Name IN ('Motorola Solutions Canada Inc.','Motorola Solutions, Inc.') AND RecordTypeId =: accMotEntRecTypeId]){ 
                                        if(entity.Name == 'Motorola Solutions Canada Inc.'){
                                            motSolCanadaId = entity.Id;
                                        } else if (entity.Name == 'Motorola Solutions, Inc.'){
                                            motSolId = entity.Id;
                                        }
                                    }
                                    
                                    Map<Id,String> oppIdLineItemNames = getOppLineItemNames(oppMap.keySet());
                                    Map<Id,Boolean> oppLinematureproduct = getOppLineMatureProduct(oppMap.keySet());
                                    for(Apttus__APTS_Agreement__c existingAgree:allExistingAgreements) {
                                        
                                        Opportunity relatedOpp = oppMap.get(existingAgree.Apttus__Related_Opportunity__c);
                                        PreSales__c newPresale = oppNewPresaleMap.get(existingAgree.Apttus__Related_Opportunity__c);
                                        String technologyName = '';
                                        Boolean matureproduct = FALSE;
                                        if(String.isNotBlank(oppIdLineItemNames.get(existingAgree.Apttus__Related_Opportunity__c))){
                                            technologyName = oppIdLineItemNames.get(existingAgree.Apttus__Related_Opportunity__c);
                                        }
                                        
                                        if(oppLinematureproduct.containsKey(existingAgree.Apttus__Related_Opportunity__c)){
                                            matureproduct = TRUE;
                                        }
                                        Apttus__APTS_Agreement__c agreement = prepareAgreementRecord(newPresale,relatedOpp,
                                                                                                     technologyName,motSolCanadaId,
                                                                                                     motSolId,matureproduct);
                                        agreement.Id = existingAgree.Id;
                                        agreementsToBeUpdated.add(agreement);
                                        
                                    }   
                                    System.debug('agreementsToBeUpdated###=>'+agreementsToBeUpdated);
                                    if(!agreementsToBeUpdated.isEmpty()){
                                        update agreementsToBeUpdated;   
                                    }
                                    
                                }
    
    public Apttus__APTS_Agreement__c prepareAgreementRecord(PreSales__c incoming,Opportunity relatedOpp,String technologyName,String motSolCanadaId,String motSolId,Boolean matureproduct){
        Apttus__APTS_Agreement__c agreement = new Apttus__APTS_Agreement__c(RecordTypeId = agreeRecTypeId);
        agreement.Apttus__Status__c = 'Request';
        agreement.Apttus__Status_Category__c= 'Request';
        agreement.m_Technology__c = technologyName;
        agreement.Mature_Products__c = matureproduct;                                                    
        agreement.Business_Contact__c = relatedOpp.OwnerId;
        agreement.Standard_Non_Standard__c = 'Standard Terms on Motorola’s Paper'; 
        agreement.Additional_Approvers_c__c = relatedOpp.Owner.ManagerId; 
        agreement.Gross_Margin_Total_Contract__c = 99.90;
        agreement.Target_Margin_Total_Contract__c = 199.9;
        agreement.Strategic_Project__c = relatedOpp.Mega_Indicator__c;
        agreement.Procurement_Manager__c = incoming.Bid_Quote_N__c;
        agreement.Apttus__Related_Opportunity__c =incoming.Opportunity__c ;
        agreement.Related_Presales_Resource_Request__c = incoming.id;
        agreement.Apttus__Account__c = relatedOpp.AccountId;
        agreement.m_Responsible_Attorney__c=incoming.Contracts_Legal1__c ;  
        agreement.Finance_Approver_c__c = incoming.Finance1__c; 
        agreement.m_GTM_Region__c = 'North America' ;                       
        agreement.Payment_Terms__c = '16-30 Days';  
        agreement.Downpayment__c = 10;                
        agreement.Detail_Design_Review_DDR_Payment__c = 10; 
        agreement.Shipment_Infrastructure__c = 60;
        agreement.Installment__c = 15;                      
        agreement.Conditional_Acceptance__c = 0;           
        agreement.Final_Acceptance__c = 5;
        agreement.m_Business_Unit__c = relatedOpp.MSI_Business_Group__c ;
        agreement.Apttus__Total_Contract_Value__c = relatedOpp.Amount ;
        agreement.Proposal_Due_Date__c = incoming.RFx_Proposal_Due_Date__c;
        agreement.Apttus__Subtype__c = 'Product (with or without Services)';
        agreement.Background_Information__c = relatedOpp.Description;
        agreement.Expected_Award_Date__c = relatedOpp.CloseDate;
        agreement.New_Country_of_Deployment__c = relatedOpp.Country__c;
        agreement.Frame_Agreements_Contract_for_Discount__c=incoming.State_Local_Contract__c;  
        agreement.Competitive_Call_Needed__c =incoming.Competitive_call_needed__c; 
        agreement.Proposal_Resource_Needed__c=incoming.Proposal_Resource_Needed__c;
        agreement.m_State_and_Local_Territory__c = relatedOpp.Territory__c;  
        agreement.OwnerId = UserInfo.getUserId();
        //Setting Agreement Type
        if(incoming.Proposal_Type_N__c == 'Firm Budgetary' || incoming.Proposal_Type_N__c == 'Budgetary') {
            agreement.Agreement_Type__c = 'RFI/Non-binding proposal'; 
        } else if(incoming.Proposal_Type_N__c == 'Sole Source/Negotiated (Unsolicited, Firm)' || 
                  incoming.Proposal_Type_N__c == 'Request for Proposal (RFP, RFB, ITB, IFB)') {
                      agreement.Agreement_Type__c = 'Sales Proposal or RFP (Stand Alone)';
                  }
        
        //Setting Agreement Title and Project Type
        if(incoming.Proposal_Type_N__c == 'Firm Budgetary' || 
           incoming.Proposal_Type_N__c == 'Sole Source/Negotiated (Unsolicited, Firm)') {
               agreement.Project_Type__c = 'Sole Source';
               agreement.Agreement_Title__c = 'SOLE ' + relatedOpp.Name;
               system.debug('Agg title is### '+agreement.Agreement_Title__c);
               
               if(agreement.Agreement_Title__c.Length() > 39) {
                   agreement.Agreement_Title__c=agreement.Agreement_Title__c.substring(0,38);
               }
           } 
        //Added by Vineela as a part of SF-1511
        else if(incoming.Proposal_Type_N__c == 'Budgetary') {
            agreement.Project_Type__c = 'Budgetary';
            agreement.Agreement_Title__c = 'BUDG ' + relatedOpp.Name;
            if(agreement.Agreement_Title__c.Length() > 39){
                agreement.Agreement_Title__c=agreement.Agreement_Title__c.substring(0,38);
            }               
        }
        //Ended by Vineela as a part of SF-1511
        else if(incoming.Proposal_Type_N__c == 'Request for Proposal (RFP, RFB, ITB, IFB)') {
            agreement.Project_Type__c = 'Competitive';
            agreement.Agreement_Title__c = 'COMP ' +  relatedOpp.Name;
            
            if(agreement.Agreement_Title__c.Length() > 39) {
                agreement.Agreement_Title__c=agreement.Agreement_Title__c.substring(0,38);
                System.debug('Agree Title' +agreement.Agreement_Title__c);
            }
        }
        else if(incoming.Proposal_Type_N__c == 'Federal ROM') {
            agreement.Agreement_Title__c= relatedOpp.Name;
            if(agreement.Agreement_Title__c.Length() > 39) {
                agreement.Agreement_Title__c=agreement.Agreement_Title__c.substring(0,38);
                System.debug('Agree Title' +agreement.Agreement_Title__c); 
            }
        }
        
        //Setting Country and Entity Account
        if(relatedOpp.Territory__c == 'T1') {
            agreement.New_Country_of_Deployment__c = 'Canada';
            agreement.Motorola_Entity_Account__c = motSolCanadaId;
        } else {
            agreement.New_Country_of_Deployment__c = 'United States';
            agreement.Motorola_Entity_Account__c = motSolId;
        }
        
        //Setting Reason for Cancellation
        if(relatedOpp.StageName == 'Lost') {
            agreement.Reason_for_Cancellation__c= 'Lost Bid';
        }
        else if(relatedOpp.StageName == 'Execute & Expand / Won') {
            agreement.Reason_for_Cancellation__c= 'Contract Awarded';
        }
        else if(relatedOpp.StageName == 'No Pursuit') {
            agreement.Reason_for_Cancellation__c= 'No Bid';
        }
        
        //Setting Geographical State of Agreement
        if(relatedOpp.Territory__c == 'DOD-East' || relatedOpp.Territory__c == 'DOD-West' || relatedOpp.Territory__c == 'Civil' || relatedOpp.Territory__c == 'Civil LEA'){
            agreement.m_State_Name__c='US Federal';
        } else {
            agreement.m_State_Name__c = relatedOpp.State__c;
        }
        return agreement;
    }
    
    public Map<Id,String> getOppLineItemNames(Set<Id> oppIds){
        Map<Id,String> oppIdLineItemNames = new Map<Id,String>();
        
        for(OpportunityLineItem OLI:[SELECT Id, product_name__c,OpportunityId 
                                     FROM OpportunityLineItem WHERE OpportunityId IN :oppIds]){
                                         if(!oppIdLineItemNames.containsKey(OLI.OpportunityId)){
                                             oppIdLineItemNames.put(OLI.OpportunityId,OLI.product_name__c);
                                         } else{
                                             String tempName = oppIdLineItemNames.get(OLI.OpportunityId);
                                             if(!tempName.contains(OLI.Product_Name__c)){
                                                 String updatedLineItemName = tempName+';'+OLI.Product_Name__c;
                                                 oppIdLineItemNames.put(OLI.OpportunityId,updatedLineItemName);
                                             }
                                         }
                                     }
        
        return oppIdLineItemNames;
    }
    public MAp<Id,Boolean> getOppLineMatureProduct(Set<Id> oppIds) { 
        Map<Id,Boolean> oppIdLineItemNames = new Map<Id,Boolean>();
        Boolean matureproduct = FALSE;       
        for(OpportunityLineItem TempLI: [SELECT Id,OpportunityId ,PricebookEntry.Product2Id,PricebookEntry.Product2.Name,
                                         PricebookEntry.Product2.Mature_Technology__c,
                                         PricebookEntry.Product2.IsActive  
                                         FROM  OpportunityLineItem WHERE PricebookEntry.Product2.Mature_Technology__c = true
                                         AND OpportunityId  IN :oppIds] ) {
                                             if(!oppIdLineItemNames.containsKey(TempLI.OpportunityId)){
                                                 oppIdLineItemNames.put(TempLI.OpportunityId,TempLI.PricebookEntry.Product2.Mature_Technology__c);
                                             } 
                                         }        
        return oppIdLineItemNames;
        
    }
    
    public static void agreeAccessforoppty(Set<Id> agreeIds) {
        Database.SaveResult[] shareInsertResults;
        List<Apttus__APTS_Agreement__Share> toBeInserted = new List<Apttus__APTS_Agreement__Share>();
        for(Apttus__APTS_Agreement__c eachagree : [SELECT Id,Related_Presales_Resource_Request__r.Opportunity__r.OwnerId
                                                   FROM Apttus__APTS_Agreement__c WHERE ID IN : agreeIds]) {
                                                       Id oppOwnr = eachagree.Related_Presales_Resource_Request__r.Opportunity__r.OwnerId;
                                                       toBeInserted.add(new Apttus__APTS_Agreement__Share
                                                                        (ParentId = eachagree.Id,
                                                                         AccessLevel = 'read',
                                                                         UserOrGroupId = oppOwnr,
                                                                         RowCause = Schema.Apttus__APTS_Agreement__Share.RowCause.PreSale_Owner_Access__c));
                                                       System.debug('toBeInserted' +toBeInserted);
                                                   }
        
        if(!toBeInserted.isEmpty()) {
            shareInsertResults = Database.insert(toBeInserted,false);
            for(Database.SaveResult result : shareInsertResults){
                if (!result.isSuccess()){
                    for(Database.Error err : result.getErrors()){
                        System.debug('Error in Sharing###'+err);
                    }
                }
            }
        }
    }
    
    
}