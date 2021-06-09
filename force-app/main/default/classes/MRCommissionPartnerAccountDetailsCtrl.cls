public class MRCommissionPartnerAccountDetailsCtrl {
    
    @AuraEnabled
    public static List<LookupSearchResult> fetchPartnerAccounts(String searchTerm,String accountId){
        List<LookupSearchResult> results = new List<LookupSearchResult>();
        String searchName= '%'+searchTerm+'%';
        String accIcon = 'standard:Account';
        for (Account acc : [SELECT Id,Name,Partner_Membership_Id__c,Metal_Level__c
                            FROM Account WHERE MPE_Program_Status__c = 'Active' and Recordtype.DeveloperName = 'Partner' AND Name LIKE :searchName]) {
                                results.add(new LookupSearchResult(acc.Id, 'Account', accIcon, acc.Name, acc.Partner_Membership_Id__c +' | '+ acc.Metal_Level__c));
                           }
        return results;
    }
}