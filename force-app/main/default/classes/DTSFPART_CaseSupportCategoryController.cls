public with sharing class DTSFPART_CaseSupportCategoryController {
  @AuraEnabled(cacheable=true)
  public static List<Case_Support_Category__mdt> getSupportCategories() {
    return [
      SELECT Case_Type__c, Category_Name__c, Category_Settings__c, Order__c
      FROM Case_Support_Category__mdt
      ORDER BY Order__c ASC
    ];
  }
}