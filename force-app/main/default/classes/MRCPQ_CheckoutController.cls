public without sharing class  MRCPQ_CheckoutController {
   
    public String postUrl{get;set;}
    private CyberSource__mdt cyberSource{get;set;}
    private MR_Digitization_Settings__mdt mRSettings{get;set;}
   @TestVisible  private final BigMachines__Quote__c quote;

    @TestVisible 
    public MRCPQ_CheckoutController(ApexPages.StandardController stdController) {
        this.quote = (BigMachines__Quote__c)stdController.getRecord();
        List<CyberSource__mdt> cyberSources = new List<CyberSource__mdt>();
        if(GlobalUtility.runningInASandbox()) {
            cyberSources = [Select Accesskey__c,ProfileId__c,SecKey1__c,SecKey2__c,End_Point_URL__c from CyberSource__mdt where DeveloperName = 'Sandbox'];
        } else {
            cyberSources = [Select Accesskey__c,ProfileId__c,SecKey1__c,SecKey2__c,End_Point_URL__c from CyberSource__mdt where DeveloperName = 'Production'];
        }
        if(!cyberSources.isEmpty()) {
            cyberSource = cyberSources.get(0);
            postUrl = cyberSource.End_Point_URL__c;
        }        
    }
    
    @AuraEnabled
    public static String getPageURL(String quoteId) {
        system.debug('#####quoteId###### => ' + quoteId);
        if(!Test.isRunningTest() && GlobalUtility.isLoggedinPartnerUser()){
            return URL.getSalesforceBaseUrl().toExternalForm() 
                + '/' 
                + [SELECT UrlPathPrefix FROM Network WHERE Id =: Network.getNetworkId()].UrlPathPrefix
                +'/apex/CyberSourceFormPage?qid=' + quoteId;
        } else {
            return URL.getSalesforceBaseUrl().toExternalForm() + '/apex/CyberSourceFormPage?qid=' + quoteId;
        }
    }
    
    public class CheckoutValidation{
        @AuraEnabled
        @TestVisible Boolean hasCheckoutAccess {get;set;}
        @AuraEnabled
        @TestVisible Boolean paymentAlreadyDone {get;set;}
    }
    
    @AuraEnabled
    public static CheckoutValidation checkoutValidations(String quoteId) {
        CheckoutValidation validations = new CheckoutValidation();
        Map<String,String> mRSettingsMap = new Map<String,String>();
        List<Id> recordTypes = new List<Id>{GlobalUtility.recordTypeId('BigMachines__Quote__c','Partner')};
        if(!GlobalUtility.isLoggedinPartnerUser()) {
            recordTypes.add(GlobalUtility.recordTypeId('BigMachines__Quote__c','Standard'));
        }
        for(MR_Digitization_Settings__mdt setting : [Select Values__c,DeveloperName from MR_Digitization_Settings__mdt where 
                                                     DeveloperName IN ('CPQ_Cybersource_Quote_Status', 'CPQ_Quote_Payment_Term_CC')]) {
                                                         mRSettingsMap.put(setting.DeveloperName, setting.Values__c);
                                                     }        
        List<BigMachines__Quote__c> lstQuote = new List<BigMachines__Quote__c>();
        if(String.isNotBlank(mRSettingsMap.get('CPQ_Cybersource_Quote_Status')) && String.isNotBlank(mRSettingsMap.get('CPQ_Quote_Payment_Term_CC'))) {
            lstQuote = [SELECT Id, Payment_Term__c, Quote_Type__c, BigMachines__Status__c 
                        from BigMachines__Quote__c WHERE Id =: quoteId 
                        AND Payment_Term__c IN : mRSettingsMap.get('CPQ_Quote_Payment_Term_CC').split(',')
                        AND BigMachines__Status__c =: mRSettingsMap.get('CPQ_Cybersource_Quote_Status') AND RecordTypeId IN : recordTypes];
        }
        if(!lstQuote.isEmpty()){
            validations.hasCheckoutAccess = true;
        }
        List<BigMachines__Quote__c> lstQuoteDecision =[SELECT Id, CyberSource_Decision__c from BigMachines__Quote__c 
                                                       WHERE Id =: quoteId AND CyberSource_Decision__c = 'ACCEPTED'];
        if(!lstQuoteDecision.isEmpty()){
            validations.paymentAlreadyDone = true;
        }
        system.debug('validations are###'+validations);
        return validations;
    }
    
    public Map<String,String> getCartDetails() {
        String quoteId = ApexPages.currentPage().getParameters().get('qid');
        if(String.isBlank(quoteId)) {
            quoteId = quote.Id;
        }
        BigMachines__Quote__c quoteObj = [select Id,BigMachines__Total_Amount__c from BigMachines__Quote__c where Id =:quoteId];
        Map<String,String> oPassedParams = new Map<String,String>();
        //Included by Harish - override_custom_cancel_page for SF-1924
        oPassedParams.put('signed_field_names','signed_field_names,access_key,signed_date_time,profile_id,locale,'+
                          'transaction_uuid,transaction_type,reference_number,currency,ignore_avs,payment_method,amount,override_custom_receipt_page,override_custom_cancel_page,bill_to_email');
        oPassedParams.put('access_key',cyberSource.Accesskey__c);
        oPassedParams.put('profile_id',cyberSource.ProfileId__c);
        oPassedParams.put('transaction_uuid',String.valueOf(System.currentTimeMillis())+Userinfo.getUserId());
        oPassedParams.put('signed_date_time',DateTime.now().format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'', 'GMT'));
        oPassedParams.put('locale','en-us');
        oPassedParams.put('transaction_type','authorization,create_payment_token');
        oPassedParams.put('reference_number',String.valueOf(System.currentTimeMillis()));
        oPassedParams.put('currency','USD');
        if(!Test.isRunningTest() && GlobalUtility.isLoggedinPartnerUser()){
            oPassedParams.put('override_custom_receipt_page', URL.getSalesforceBaseUrl().toExternalForm()+ '/' +
                              [SELECT UrlPathPrefix FROM Network WHERE Id =: Network.getNetworkId()].UrlPathPrefix +'/apex/CyberSourceReceipt?quoteId='+quoteId);
            oPassedParams.put('override_custom_cancel_page', URL.getSalesforceBaseUrl().toExternalForm()+ '/NA/apex/BigMachines__QuoteEdit?Id='+quoteId);
        } else {
            oPassedParams.put('override_custom_receipt_page', URL.getSalesforceBaseUrl().toExternalForm()+ '/apex/CyberSourceReceipt?quoteId='+quoteId);
            oPassedParams.put('override_custom_cancel_page', URL.getSalesforceBaseUrl().toExternalForm()+ '/apex/BigMachines__QuoteEdit?Id='+quoteId);
        }
        oPassedParams.put('amount',String.valueOf(quoteObj.BigMachines__Total_Amount__c + quoteObj.BigMachines__Total_Amount__c*.1));
        oPassedParams.put('ignore_avs','true');
        oPassedParams.put('payment_method','card');
        oPassedParams.put('bill_to_email','null@cybersource.com');
        oPassedParams.put('signature', sign(oPassedParams,cyberSource.SecKey1__c+cyberSource.SecKey2__c));
        return oPassedParams;
    }
    
    private static String sign(Map<String,String> paramsArray, String secretKey) {
        String result = EncodingUtil.base64Encode(Crypto.generateMac('HMAC-SHA256', Blob.valueOf(buildDataToSign(paramsArray)), Blob.valueOf(secretKey)));
        return result;
    }
    
    private static String commaSeparate(List<String> dataToSign) {
        String result = '';
        for(String Str : dataToSign) {
            result += (result==''?'':',')+Str;
        }
        return result;                         
    }
    private static String buildDataToSign(Map<string,string> paramsArray) {
        String[] signedFieldNames = paramsArray.get('signed_field_names').split(',');
        List<string> dataToSign = new List<string>();
        
        for (String oSignedFieldName : signedFieldNames){
            dataToSign.Add(oSignedFieldName + '=' + paramsArray.get(oSignedFieldName));
        }
        return commaSeparate(dataToSign);
    }    
}