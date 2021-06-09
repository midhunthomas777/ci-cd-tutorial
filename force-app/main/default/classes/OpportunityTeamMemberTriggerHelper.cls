/*******************************************************************************
* Description : Helper class for Opportunity Team Member
* Author : Anand Sengunthar
* Date : 24th March 2020
******************************************************************************/
public class OpportunityTeamMemberTriggerHelper {
    public void addNewShare(Map<Id,OpportunityTeamMember> mapOpptyOTM){
        List<BigMachines__Quote__Share> quoteAddShares = new List<BigMachines__Quote__Share>();
        for(BigMachines__Quote__c qte : [select Id,BigMachines__Opportunity__c,ownerid from BigMachines__Quote__c where BigMachines__Opportunity__c=:mapOpptyOTM.keyset()]){
            BigMachines__Quote__Share quoteShare = new BigMachines__Quote__Share();
            quoteShare.ParentId=qte.Id; 
            quoteShare.UserOrGroupId=mapOpptyOTM.get(qte.BigMachines__Opportunity__c).userid; 
            quoteShare.AccessLevel=mapOpptyOTM.get(qte.BigMachines__Opportunity__c).OpportunityAccessLevel;  
            if(qte.OwnerId != mapOpptyOTM.get(qte.BigMachines__Opportunity__c).userid){
            	quoteAddShares.add(quoteShare);
            }    
            system.debug('@@quoteshare@@'+quoteAddShares);
        }
        if(!quoteAddShares.isEmpty()){
            insert quoteAddShares;
        }
    }
    public void deleteShare(Map<Id,OpportunityTeamMember> mapOpptyOTM){
        List<Id > delquoteList = new List<Id>();
        List<Id> usrIds = new List<Id>();
        List<BigMachines__Quote__Share> quoteDelShares = new List<BigMachines__Quote__Share>();
        for(OpportunityTeamMember otm : mapOpptyOTM.values()){
            usrIds.add(otm.UserId);
        }
        for(BigMachines__Quote__c qte : [select Id from BigMachines__Quote__c where BigMachines__Opportunity__c=:mapOpptyOTM.keyset()]){
            delquoteList.add(qte.Id);           
        }
        for(BigMachines__Quote__Share  quoteShare : [Select id from BigMachines__Quote__Share where ParentId in:delquoteList AND UserOrGroupId in :usrIds and RowCause = 'Manual']){
            quoteDelShares.add(quoteShare);
        }
        if(!quoteDelShares.isEmpty()){
            delete quoteDelShares;
        }  
    }
}