public class MRAccountAccessclass {

@future
  public static void provideaccess(List <Id> accids, List<id> usrids, Map<Id,Id> usrandaccMap) {
  List<Account> Acclist;
  List<AccountShare> accountShareInsertList=new list<AccountShare>();
   system.debug('madhavitest'+ usrids);
 
   system.debug('madhavitest1'+ Acclist);
  
   for(Id usr : usrids)
   {
   Acclist=[select id,name,Assigned_MR__c from Account where Assigned_MR__c =:usrandaccMap.get(usr)];
   
            for(Account Acc: Acclist)
            {
                AccountShare actShr = new AccountShare();
                actShr.AccountAccessLevel = 'Read';
                actShr.OpportunityAccessLevel='none';
                actShr.AccountId = Acc.Id;
                actShr.UserOrGroupId = usr;
                accountShareInsertList.add(actShr);   
            }
    Acclist.Clear();
   }
   if(accountShareInsertList.size()>0) {
       System.Debug('Harish Final List'+accountShareInsertList);
       insert accountShareInsertList;
   }
   }

 }