/*******************************************************************************
* Class Name : CampaignInfluenceTriggerHandler
* Description : Handler class for CampaignInfluenceTrigger
* Author : Sai Harish Thammana
* Date : 8th Jan 2019
*******************************************************************************/

public class CampaignInfluenceTriggerHandler implements ITriggerHandler{
    
    public Boolean isDisabled(){
        if (TriggerSettings__c.getValues('CampaignInfluenceTriggerDisabled').IsActive__c){
            return true;
        } else{
            return false;
        }
    }
    
    public void BeforeInsert(List<SObject> newItems){}
    
    
    public void BeforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems){}
    
    public void BeforeDelete(Map<Id, SObject> oldItems){}
    
    public void AfterInsert(Map<Id, SObject> newItems){
        Set<Id> oppIds = new Set<Id>();
        for(CampaignInfluence incoming:[SELECT Id,CampaignId,ContactId,OpportunityId FROM CampaignInfluence WHERE Id IN:newItems.keySet() AND Model.DeveloperName like '%Even%']){
            oppIds.add(incoming.OpportunityId);
        }
        
        if(!oppIds.isEmpty()){
            reCalculateEvenInfluence(oppIds);
        }
    }
    
    public void AfterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems){}
    
    public void AfterDelete(Map<Id, SObject> oldItems){}
    
    public void AfterUndelete(Map<Id, SObject> oldItems){}
    
    /*
    public void insertOtherModelInfluences(List<CampaignInfluence> defaultInfluences){
        System.debug('Entered Influence Mechanism');
        Map<Id,Integer> oppCampInfluenceCount= new Map<Id,Integer>();
        List<CampaignInfluence> campInfluenceLst = new List<CampaignInfluence>();
        
        for(CampaignInfluence eachCam:defaultInfluences){
            if(!oppCampInfluenceCount.keySet().contains(eachCam.OpportunityId)){
                oppCampInfluenceCount.put(eachCam.OpportunityId,0);
            }
            
            Integer tempCount = oppCampInfluenceCount.get(eachCam.OpportunityId);
            oppCampInfluenceCount.put(eachCam.OpportunityId,tempCount+1);
        }
        
        System.debug('oppCampInfluenceCount###=>'+oppCampInfluenceCount);
        System.debug('defaultInfluences###=>'+defaultInfluences);
        
        for(campaignInfluenceModel eachModel:[SELECT Id,DeveloperName,MasterLabel FROM campaignInfluenceModel WHERE IsActive=TRUE AND IsDefaultModel=FALSE]){
            for(CampaignInfluence campInfluence:defaultInfluences){
                if(eachModel.DeveloperName == 'Even_Touch_Model'){
                    campInfluenceLst.add(new CampaignInfluence(
                        modelId=eachModel.Id,
                        campaignId = campInfluence.CampaignId,
                        opportunityId=campInfluence.OpportunityId,
                        ContactId = campInfluence.ContactId,
                        Influence=100/oppCampInfluenceCount.get(campInfluence.OpportunityId)));    
                }
            }    
        }
        
        Database.SaveResult[] influenceResult = Database.insert(campInfluenceLst,false);
        
        for(Database.SaveResult finalResult:influenceResult){
            if(!finalResult.isSuccess()){
                for(Database.Error error:finalResult.getErrors()){
                    System.debug('Error Message is###==>'+error.getMessage());
                }
            }
        }
    }
    */
    @future
    public Static void reCalculateEvenInfluence(Set<Id> oppIds){
        List<CampaignInfluence> allCampaignInfluences = [SELECT Id,CampaignId,ContactId,OpportunityId FROM CampaignInfluence WHERE OpportunityId IN:oppIds AND Model.DeveloperName='Even_Touch_Model' ];
        List<CampaignInfluence> toBeUpdated = new List<CampaignInfluence>();
        Map<Id,Decimal> oppCampInfluenceCount= new Map<Id,Decimal>();
        
        for(CampaignInfluence eachCam:allCampaignInfluences){
            if(!oppCampInfluenceCount.keySet().contains(eachCam.OpportunityId)){
                oppCampInfluenceCount.put(eachCam.OpportunityId,0);
            }
            
            Decimal tempCount = oppCampInfluenceCount.get(eachCam.OpportunityId);
            oppCampInfluenceCount.put(eachCam.OpportunityId,tempCount+1);
        }
        
        for(CampaignInfluence eachCam:allCampaignInfluences){
            Decimal count = oppCampInfluenceCount.get(eachCam.OpportunityId);
            if(count>0){
                eachCam.Influence = 100/count;
                toBeUpdated.add(eachCam);
            }
        }
        
        if(!toBeUpdated.isEmpty()){
            Database.update(toBeUpdated,false);
        }
    }
    
    public void insertEvenDistributonInfluences(Set<Id> oppIds,Set<Id> contactIds){
        List<CampaignInfluence> campInfluenceLst = new List<CampaignInfluence>();
        List<CampaignMember> campMemberList = [Select Id,CampaignId, CompanyOrAccount,LeadId,ContactId from CampaignMember WHERE ContactId IN:contactIds];
        List<campaignInfluenceModel> campaignInfluenceModelList = [SELECT Id,DeveloperName FROM campaignInfluenceModel WHERE IsActive=TRUE];
        Map<Id,List<Id>> contCampMap = new Map<Id,List<Id>>();
        Map<Id,Set<Id>> contOppMap = new Map<Id,Set<Id>>();
        
        System.debug('campMemberList###=>'+campMemberList);
        System.debug('campaignInfluenceModelList###=>'+campaignInfluenceModelList);
        
        for(CampaignMember campMember:campMemberList){
            if(!contCampMap.containsKey(campMember.ContactId)){
                contCampMap.put(campMember.ContactId,new List<Id>());
            }
            contCampMap.get(campMember.ContactId).add(campMember.CampaignId);
        }
        
        System.debug('contCampMap###=>'+contCampMap);
        
        List<OpportunityContactRole> existingRoles = [SELECT Id,ContactId,OpportunityId FROM OpportunityContactRole WHERE OpportunityId IN:oppIds];
        System.debug('existingRoles###=>'+existingRoles);
        
        for(OpportunityContactRole oppConRole:existingRoles){
            if(!contOppMap.containsKey(oppConRole.ContactId)){
                contOppMap.put(oppConRole.ContactId,new Set<Id>());
            }
            contOppMap.get(oppConRole.ContactId).add(oppConRole.OpportunityId);
        }
        System.debug('contOppMap###=>'+contOppMap);
        
        if(!contOppMap.isEmpty()){
            for(CampaignMember campMember:campMemberList){
                Decimal numberOfCampsAssociatedToContact = contCampMap.get(campMember.ContactId).size();
                for(Id oppId:contOppMap.get(campMember.ContactId)){
                    for(campaignInfluenceModel eachModel:campaignInfluenceModelList){
                        if(eachModel.DeveloperName.contains('Even') && numberOfCampsAssociatedToContact != 0){
                            campInfluenceLst.add(new CampaignInfluence(
                                modelId=eachModel.Id,
                                campaignId=campMember.CampaignId,
                                opportunityId=oppId,Influence=100.00/numberOfCampsAssociatedToContact,
                                contactId=campMember.ContactId));    
                        }
                    }
                }
            }
        }
        System.debug('campInfluenceLst###=>'+campInfluenceLst);
        if(!campInfluenceLst.isEmpty()){
            Database.SaveResult[] influenceResult = Database.insert(campInfluenceLst,false);
            
            for(Database.SaveResult finalResult:influenceResult){
                if(!finalResult.isSuccess()){
                    for(Database.Error error:finalResult.getErrors()){
                        System.debug('Error Message is###==>'+error.getMessage());
                    }
                }
            }
        }
    }    
}