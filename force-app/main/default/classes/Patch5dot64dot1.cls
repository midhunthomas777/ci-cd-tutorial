/**
    Apttus Approvals Management
    Patch5dot64dot1 - Upgrade script for patch release 5.64.1

    @2008-2012 Apttus Inc. All rights reserved.
*/
public with sharing class Patch5dot64dot1 {
    
    public PageReference runFix() {
        
        Set<String> stsList = new Set<String>();
        stsList.add('Assigned');
        stsList.add('Reassigned');
        Integer itemCount = 0;
        List<Apttus_Approval__Approval_Request__c> updReqList = new List<Apttus_Approval__Approval_Request__c>();
        
        for (List<Apttus_Approval__Approval_Request__c> reqList : [select Id 
                                            , Name
                                            , OwnerId
                                            , Owner.Name
                                            , Apttus_Approval__Object_Type__c
                                            , Apttus_Approval__Object_Id__c
                                            , Apttus_Approval__Assigned_To_Id__c
                                            , Apttus_Approval__Approval_Status__c
                                            , Apttus_Approval__Assigned_To_Type__c
                                            , Apttus_Approval__Assigned_To_Name__c
                                            , Apttus_Approval__Backup_From_User__c
                                            , Apttus_Approval__Backup_From_User__r.Name
                                        from Apttus_Approval__Approval_Request__c
                                        where Apttus_Approval__Approval_Status__c IN :stsList
                                        and Apttus_Approval__Backup_From_User__c != null
                                        and Apttus_Approval__Assigned_To_Type__c = 'User']) {
                                            
            for (Apttus_Approval__Approval_Request__c ar : reqList) {
                if (ar.Apttus_Approval__Assigned_To_Id__c != ar.OwnerId) {
                    itemCount ++;

                    System.debug('RequestID: ' + ar.Id);
                    System.debug(ar.Apttus_Approval__Object_Type__c + ' = ' + ar.Apttus_Approval__Object_Id__c);
                    System.debug('Status: ' + ar.Apttus_Approval__Approval_Status__c);
                    
                    System.debug('Name(O) = ' + ar.Owner.Name);
                    System.debug('Name(B) = ' + ar.Apttus_Approval__Backup_From_User__r.Name);  
                    System.debug('Name(A) = ' + ar.Apttus_Approval__Assigned_To_Name__c);   
                    System.debug('Id(O) = ' + ar.OwnerId);
                    System.debug('Id(B) = ' + ar.Apttus_Approval__Backup_From_User__c);
                    System.debug('Id(A) = ' + ar.Apttus_Approval__Assigned_To_Id__c);   
                    System.debug('\n');

                    ar.OwnerId = ar.Apttus_Approval__Assigned_To_Id__c;
                    updReqList.add(ar);
                }

                if (System.Test.isRunningTest() && (itemCount > 0)) {
                    continue;
                }
            }
            update updReqList;
            if (System.Test.isRunningTest() && (itemCount > 0)) {
                continue;
            }
            
        }
        System.debug('Total Mismatched Approval Request: ' + itemCount);
        return (new PageReference('/home/home.jsp'));
    }
}