public class AccountRoleCreatedUpdate{
    public static void updateRoleCreated(List<Account> accountList) {
        List<Account> accountUpdateList = new List<Account>();
        try {
            for(Account acc : accountList){
                acc.Role_Created__c = true;
                accountUpdateList.add(acc);
            }
            update accountUpdateList;
        }
        catch(Exception e) {
            system.debug('Exception x = ' +e);
        }
    }
}