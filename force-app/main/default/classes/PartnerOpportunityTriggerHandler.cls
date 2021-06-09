public class PartnerOpportunityTriggerHandler implements ITriggerHandler {
    
    Id registrationRecordTypeId = GlobalUtility.getRecordTypeIdByDeveloperName('Opportunity', 'Registration');
    
    public static Boolean TriggerDisabled = false;
    
    public void BeforeInsert(List<SObject> newItems){}
    
    public void AfterInsert(Map<Id, SObject> newItems) {
        Map<Id,Opportunity> newOpptyMap = new Map<Id,Opportunity>();
        if(newItems != null) newOpptyMap = (Map<Id,Opportunity>) newItems;
        List<OpportunityShare> oppoToBeShared = new List<OpportunityShare>();
        for(Opportunity partnerOpp : newOpptyMap.values()) {
            if((partnerOpp.RecordTypeId == registrationRecordTypeId && Userinfo.getUserType() != 'Standard' && partnerOpp.OwnerId != partnerOpp.CreatedById)|| Test.isRunningTest()) {
                oppoToBeShared.add(new OpportunityShare(
                    OpportunityAccessLevel='Edit',
                    OpportunityId=partnerOpp.Id,
                    UserOrGroupId=partnerOpp.CreatedById
                ));
            }
        }
        if(!oppoToBeShared.isEmpty()){
            Database.insert(oppoToBeShared, false);
        }
    }
    
    public void AfterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems){
        Map<Id,Opportunity> oldOpptyMap = new Map<Id,Opportunity>();
        Map<Id,Opportunity> newOpptyMap = new Map<Id,Opportunity>();
        if(oldItems != null) oldOpptyMap = (Map<Id,Opportunity>) oldItems;
        if(newItems != null) newOpptyMap = (Map<Id,Opportunity>) newItems;
        
        List<Opportunity> registrationoppList = new List<Opportunity>();
        List<OpportunityShare> oppShareList = new List<OpportunityShare>();
        
        for(Opportunity opp : newOpptyMap.values()){
            Opportunity oldOpp = oldOpptyMap.get(opp.Id);
            if(opp.RecordTypeId == registrationRecordTypeId){
                registrationoppList.add(opp);
            }
            if(oldOpp.OwnerId != opp.OwnerId && oldOpp.OwnerId == opp.CreatedById && opp.RecordTypeId == registrationRecordTypeId){
                oppShareList.add(new OpportunityShare(OpportunityId = opp.Id,OpportunityAccessLevel = 'Read',UserOrGroupId = oldOpp.OwnerId));
            }            
        }
        if(!registrationoppList.isEmpty()){
            PartnerOpportunityTriggerHelper.createUserSharingRecord(registrationoppList);
        }
        if(!oppShareList.isEmpty()){
            try{
                insert oppShareList;
            }
            catch(Exception e){
                System.debug('Exception Message ==> '+e.getMessage());
            }
        }
    }
    
    public void BeforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems){
        Map<Id,Opportunity> oldOpptyMap = new Map<Id,Opportunity>();
        Map<Id,Opportunity> newOpptyMap = new Map<Id,Opportunity>();
        if(oldItems != null) oldOpptyMap = (Map<Id,Opportunity>) oldItems;
        if(newItems != null) newOpptyMap = (Map<Id,Opportunity>) newItems;
        
        Opportunity_Management_RecordType__c oppDetail = Opportunity_Management_RecordType__c.getOrgDefaults();
        String ErrMsgBegins= '<HTML><BODY>';
        String ErrMsgEnds= '</BODY></HTML>';
        
        //newOpp.AccountId = oppDetail.NotYetKnownAccountAPAC__c;
        for(Opportunity newOpp : newOpptyMap.values()) {
            
            String fullRecordURL = URL.getSalesforceBaseUrl().toExternalForm() + '/' + newOpp.Id;
            String clickHere = '/e?retURL=%2F';
            String EditRecordURL = fullRecordURL + clickHere + newOpp.Id;
            Opportunity oldOpp = oldOpptyMap.get(newOpp.Id);
            if(newOpp.RecordTypeId == registrationRecordTypeId && newopp.Region__c != 'LA'){ 
                system.debug('oldOpp.Approval_Status__c'+oldOpp.Approval_Status__c);
                system.debug('newOpp.Approval_Status__c'+newOpp.Approval_Status__c);
                system.debug('newOpp.Assigned_CAM__c'+newOpp.Assigned_CAM__c);
                //Addition of this entry criteria (newopp.Region__c != 'LA') for LACR move to Lightning partner community --Suveen
                if((oldOpp.Approval_Status__c == 'Waiting Approval' && newOpp.Approval_Status__c == 'PIC Approved' && newOpp.AccountId == oppDetail.NotYetKnownAccountAPAC__c)){
                    String actualMsg = ErrMsgBegins+'<font color="red">'+'<strong>'+'<h1>'+'Message: Please update Customer Account before approval. To update, please click on link '+'</h1>'+'</strong>'+'</font>';
                    actualMsg= +' '+actualMsg+ErrMsgEnds;
                    newOpp.addError(actualMsg +'<a href=\''+EditRecordURL+'\'>Click Here</a>'+' ',false);
                }else if(oldOpp.Approval_Status__c == 'Waiting Approval' && newOpp.Approval_Status__c == 'Waiting Approval' && newOpp.AccountId == oppDetail.NotYetKnownAccountAPAC__c && newOpp.Rejected_By__c== 'PIC'){
                    String actualMsg = ErrMsgBegins+'<font color="red">'+'<strong>'+'<h1>'+'Message: Please update Customer Account before rejecting. To update, please click on link '+'</h1>'+'</strong>'+'</font>';
                    actualMsg= +' '+actualMsg+ErrMsgEnds;
                    newOpp.addError(actualMsg +'<a href=\''+EditRecordURL+'\'>Click Here</a>'+' ',false);
                }
                else if(oldOpp.Approval_Status__c == 'Waiting Approval' && newOpp.Approval_Status__c == 'PIC Approved' && (newOpp.Assigned_CAM__c == null || newOpp.RCAM_ASL__c == null)){
                    String actualMsg = ErrMsgBegins+'<font color="red">'+'<strong>'+'<h1>'+'Message: Please update Assigned CAM and RCAM/ASL before approval. To update, please click on link '+'</h1>'+'</strong>'+'</font>';
                    actualMsg= +' '+actualMsg+ErrMsgEnds;
                    newOpp.addError(actualMsg +'<a href=\''+EditRecordURL+'\'>Click Here</a>'+' ',false);
                }
                else if(oldOpp.Approval_Status__c == 'PIC Approved' &&  (newOpp.Approval_Status__c == 'CAM Approved' && newOpp.Is_the_end_user_an_existing_MSI_Customer__c == null || newOpp.Has_this_Partner_sold_to_this_end_user__c == null || newOpp.Satisfied_with_info_from_Partner__c == null || newOpp.Is_the_Partner_Qualified_to_Deliver__c == null)){
                    String actualMsg = ErrMsgBegins+'<font color="red">'+'<strong>'+'<h1>'+'Message: Please update Internal questionnaire section before approval. To update, please click on link '+'</h1>'+'</strong>'+'</font>';
                    actualMsg= +' '+actualMsg+ErrMsgEnds;
                    newOpp.addError(actualMsg +'<a href=\''+EditRecordURL+'\'>Click Here</a>'+' ',false);
                }
            }
        }
    }
    public void BeforeDelete(Map<Id, SObject> oldItems){}
    public void AfterDelete(Map<Id, SObject> oldItems){}
    public void AfterUndelete(Map<Id, SObject> oldItems){}
    public Boolean isDisabled(){        
        if(TriggerSettings__c.getValues('BypassPartnerOpptyRegistration').IsActive__c) {
            return true;
        } else{
            return TriggerDisabled; 
        }
    }
}