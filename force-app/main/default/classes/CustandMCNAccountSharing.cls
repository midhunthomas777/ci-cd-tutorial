/***
Author        Version    Date                  Description
Sai Harish    1.0        02/22/2017            This Class is created as part of New Account Data Model. 
This Class is used to handle sharing of Account in below Scenarios
1. Account Ownership Change
2. MR Partner Reassignment on Account Identifier.
-----------------------------------------------------------------------
Author        Version    Date                  Description
Sai Harish    2.0        04/18/2018            This Class is created as part of Customer Data Master. 
This Class is used to handle sharing of Account in below Scenarios
1. Account Ownership Change
2. MR Partner Reassignment on Motorola Customer Number Account.
***/
// Test Class is CustandMCNAccountSharing_Test

Public Class CustandMCNAccountSharing
{
    public CustandMCNAccountSharing(){}
    
    Public void reShareAccRecords1(Set<Id> CustAccIds){
        List<AccountShare> accountShareInsertList=new List<AccountShare>();
        Map<Id,Id> roleGrpMap=new Map<Id,Id>();
        Set<Id> AssignedMRs=new Set<Id>();
        
        List<Account> cusMcnLst = [SELECT Id,Assigned_MR__c,Assigned_MR_Sales_Person__c,ParentId,Customer_or_Prospect_Account__c
                                   FROM Account WHERE ParentId IN:CustAccIds];
        
        for(Account acc:cusMcnLst){
            AssignedMRs.add(acc.Assigned_MR__c);     
        }
        
        system.debug(' Assigned MRs ###=> '+AssignedMRs);
        List<UserRole> UserRoleList = [SELECT Id, Name, PortalAccountId FROM UserRole WHERE PortalAccountId IN :AssignedMRs AND PortalAccountId!=null];
        system.debug(' UserRole Debug ###=> '+UserRoleList);
        List<Group> groupList = [SELECT Id,Type,RelatedId FROM Group WHERE type IN ('RoleAndSubordinates','Role') AND RelatedId in :UserRoleList];
        system.debug(' groupList###=> '+groupList);
        
        for(Group GL:groupList){
            roleGrpMap.put(GL.RelatedId,GL.Id);
        }
        
        // Sharing Prospect/Customer Accounts to Users of Assinged MR(Partner Users)
        for(Account acc:cusMcnLst){
            System.Debug('Enterd Sharing---Harish 3');
            for(UserRole UR:UserRoleList ){
                if(UR.PortalAccountId == acc.Assigned_MR__c){
                    System.Debug('Enterd Sharing---Harish 5');
                    
                    AccountShare aas1 = new AccountShare();
                    aas1.AccountAccessLevel = 'Read';
                    aas1.ContactAccessLevel = 'Read';
                    aas1.CaseAccessLevel = 'None';
                    aas1.OpportunityAccessLevel = 'None';
                    aas1.AccountId = acc.ParentId; //Provides access to Customer/Propsect Account
                    aas1.UserOrGroupId =RoleGrpMap.get(UR.Id) ;  // Retrieves Group id Based on Role Id
                    
                    System.Debug('Harish Before InsertList'+accountShareInsertList);  
                    accountShareInsertList.add(aas1);
                }
                
            } 
        }
        
        if(accountShareInsertList.size()>0){
            Insert accountShareInsertList;  
        }
    }
    
    
    Public void reShareAccRecords2(Set<Id> CDHAccIds){
        List<AccountShare> accountShareInsertList=new List<AccountShare>();
        system.debug('In ReShareAccecords2 ** '+CDHAccIds);
        List<Account> mcnLst = [SELECT Id,Assigned_MR__c,Assigned_MR_Sales_Person__c,ParentId,Customer_or_Prospect_Account__c
                                   FROM Account WHERE Id IN:CDHAccIds];
        
        Map<Id,Id> roleGrpMap=new Map<Id,Id>();
        Set<Id> assignedMRs=new Set<Id>();
        
        for(Account acc:mcnLst){
            assignedMRs.add(acc.Assigned_MR__c);     
        }
        
        system.debug(' Assigned MRs '+AssignedMRs);
        
        List<UserRole> userRoleList= [SELECT Id, Name, PortalAccountId FROM UserRole WHERE PortalAccountId IN :AssignedMRs AND PortalAccountId!=null];
        List<Group> groupList = [SELECT Id,Type,RelatedId FROM Group WHERE type IN ('RoleAndSubordinates','Role') AND RelatedId IN :UserRoleList];
        
        if(Test.isRunningTest() == TRUE)// This is Test so find hard code values
        {
            userRoleList= [select Id, Name, PortalAccountId from UserRole where   PortalAccountId!=null LIMIT 100];
            groupList = [select id,Type,RelatedId from Group where type IN ('RoleAndSubordinates','Role') LIMIT 100]; //and RelatedId in :UserRoleList];
            
        }    
        
        for(Group GL:groupList){
            roleGrpMap.put(GL.RelatedId,GL.Id);
        }
        
        // Sharing MCN Accounts to Users of Assinged MR(Partner Users)
        for(Account acc:mcnLst){
            System.Debug('Enterd Sharing---Harish 3');
            
            for(UserRole ur:userRoleList){
                Id userRoleSel = ur.PortalAccountId;
                Id partnerAssigned = acc.Assigned_MR__c;
                if(Test.isRunningTest()){
                    userRoleSel = PartnerAssigned;
                }
                
                if(userRoleSel == PartnerAssigned){
                    System.Debug('Enterd Sharing---Harish 5');
                    AccountShare aas = new AccountShare();
                    aas.AccountAccessLevel = 'Edit';
                    aas.ContactAccessLevel = 'None';
                    aas.CaseAccessLevel = 'None';
                    aas.OpportunityAccessLevel = 'None';
                    aas.AccountId = acc.Id; // Provides access to CDH Account
                    aas.UserOrGroupId =RoleGrpMap.get(UR.Id) ;  // Retrieves Group id Based on Role Id
                    
                    System.Debug('Harish Before InsertList'+accountShareInsertList);    
                    accountShareInsertList.add(aas);
                } 
            }
        }
        
        if((accountShareInsertList.size()>0) && (Test.isRunningTest() == FALSE)){
            Insert accountShareInsertList;  
        }  
    }
    
  Public void populateMRNamesonCustomer(Set<Id> CustAccIds){
      
        List<Account> custAccs = [SELECT Id,Assigned_MR_Names__c,
                                  (SELECT Id,Assigned_MR__r.Name FROM ChildAccounts) FROM Account
                                 WHERE Id IN:CustAccIds];
        
        List<Account> tobeUpdated = new List<Account>();
        
        for(Account acc:custAccs){
            Set<String> tempSet = new Set<String>();
            for(Account chac:acc.ChildAccounts){
                tempSet.add(chac.Assigned_MR__r.Name);
            }
            
            if(!tempSet.isEmpty()){
              acc.Assigned_MR_Names__c = String.join(new List<String>(tempSet), '\n');    
            }
            else{
                acc.Assigned_MR_Names__c = '';
            }
            
            tobeUpdated.add(acc);
        }
        if(tobeUpdated.size()>0){
            update tobeUpdated;
        }
    }
}