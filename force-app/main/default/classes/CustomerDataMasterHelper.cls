// Test Class - AccountTriggerHandler_Test

public class CustomerDataMasterHelper {
    
    Id prosRecordtypeId = GlobalUtility.recordTypeId('Account','Prospect');
    Id partRecordtypeId = GlobalUtility.recordTypeId('Account','Partner');
    Id custRecordtypeId = GlobalUtility.recordTypeId('Account','Customer');
    Id mcnRecordtypeId = GlobalUtility.recordTypeId('Account','Motorola Customer Number');
    
    
    public void clearPrimaryFlag(Map<Id,Id> primaryMap){
        System.debug('primaryMap## =>'+primaryMap);
        List<Account> mcnsToBeUpdated = new List<Account>();
        
        List<Account> mcnsToBeCleared = [SELECT Id,Name,Is_Primary__c FROM Account WHERE
                                             ParentId IN:primaryMap.keyset() AND Is_Primary__c =TRUE AND ID NOT IN:primaryMap.values()];
        
        System.debug('mcnsToBeCleared ## =>'+mcnsToBeCleared);
        
        for(Account acc:mcnsToBeCleared){
        	acc.Is_Primary__c = FALSE;
            mcnsToBeUpdated.add(acc);
        }
        
        if(mcnsToBeUpdated.size()>0){
            update mcnsToBeUpdated;
        }
    }
    
    public void setPrimaryFlag(Map<Id,Id> primaryMap){
        System.debug('Set Primary Flag for ## =>'+primaryMap);
        List<Account> toBeUpdated = new List<Account>();
        
        List<Account> mcnsToBeUpdated = [SELECT Id,Name,Is_Primary__c FROM Account WHERE
                                             Is_Primary__c = FALSE AND ID IN:primaryMap.values()];
        
        for(Account acc:mcnsToBeUpdated){
            acc.Is_Primary__c = TRUE;
            toBeUpdated.add(acc);
        }
        
        if(toBeUpdated.size()>0){
			update toBeUpdated;            
        }
         System.debug('Set Primary Flag for toBeUpdated ## =>'+toBeUpdated);
    }
   
}