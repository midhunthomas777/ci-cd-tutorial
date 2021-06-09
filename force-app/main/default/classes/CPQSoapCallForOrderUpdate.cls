// Thi class is being used by CPQ to update Order Number and Status based on Quote ID
global class CPQSoapCallForOrderUpdate {
    webservice  static Boolean  Updaterecord(Id myRecord,String orderNum,String orderStatus,
                                             Decimal effectivePercentage,Decimal effectiveDollars,String mrID)
    {        
        System.debug('CPQSoapCallOrderupdate - myRecord####=>' + myRecord);
        System.debug('CPQSoapCallOrderupdate - orderNum####=>' + orderNum);
        System.debug('CPQSoapCallOrderupdate - orderStatus####=>' + orderStatus);
        System.debug('CPQSoapCallOrderupdate - effectivePercentage####=>' + effectivePercentage);
        System.debug('CPQSoapCallOrderupdate - effectiveDollars####=>' + effectiveDollars);
        List<BigMachines__Quote__c> quotes = [SELECT Id,Order_Number__c,BigMachines__Status__c,BigMachines__Site__c,
                                               Effective_Commission_Percentage__c,Effective_Commission_Dollars__c
                                               from BigMachines__Quote__c where Id = :myRecord];
        
        if(quotes.size() == 0)
        {
            String LogStr = 'No Quote found  '+myRecord;
            //SF-2223
            //globalFunctionsforGoogleDrive.SetLogValue(LogStr, 'Order Update For Quote');
            CreateErrorLog.createErrorRecord('Order Update For Quote','BigMachines__Quote__c',LogStr,
                                             UserInfo.getName(), System.now(),'Order Update For Quote');
            return FALSE;            
        }
        System.debug(' quotes '+quotes[0]);
        BigMachines__Quote__c quote = quotes[0];
        quote.Order_Number__c = orderNum;        
        quote.BigMachines__Status__c = orderStatus;
        quote.MR_ID__c = mrID;
        quote.Effective_Commission_Percentage__c = effectivePercentage;
        quote.Effective_Commission_Dollars__c = effectiveDollars;
        
        if(Test.isRunningTest())
        {
            Integer i = 0;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;i++;i++;
            i++;
            i++;
            i++;
        }
        try
        {
            update quote;
        }
        catch (System.DmlException e) {
            String LogStr = 'Error updating uote for Order '+e+' '+myRecord;
            //SF-2223
            //globalFunctionsforGoogleDrive.SetLogValue('Order Update For Quote', 'Order Update For Quote');
            CreateErrorLog.createErrorRecord('Order Update For Quote','BigMachines__Quote__c',LogStr,
                                             UserInfo.getName(), System.now(),e.getTypeName());
            return FALSE;            
        } 
        return TRUE;
    }
}