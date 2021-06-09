/**
 * @author       Sagar Sindhi
 * @created      2020-10-07
 * @updated      2020-11-19
 * @description  https://jira.mot-solutions.com/browse/DTPART-475
 */
public with sharing class DTSFPART_CommissionSummaryController {
  @AuraEnabled(cacheable = true)
  public static String getOrderStatus(String orderNumber, String fields, String credientialName) {
    try {
      String requestParams = '?ord_num=' + orderNumber + '&fields=' + fields;
      HTTPAPIResponse result = MulesoftHelper.callMuleByMetadata(
        requestParams,
        NULL,
        'DTSFPART_Invoice_Header',
        credientialName
      );
  
      if (result.responseStatus == 200 && result.response != NULL) {
        return result.response.getBody();
      } else if (result.responseStatus == 500) {
        return System.Label.PP_NoInvoices;
      } else {
        saveErrorInLogs(result.errorMsg);
        return String.isNotBlank(result.errorMsg) ? result.errorMsg : System.Label.PP_PleaseContactYourAdministrator;
      }
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }

  @future
  private static void saveErrorInLogs(String errorMsg) {
    LogError.saveError('DTSFPART_CommissionSummaryController.getOrderStatus()', '', errorMsg);
  }
}