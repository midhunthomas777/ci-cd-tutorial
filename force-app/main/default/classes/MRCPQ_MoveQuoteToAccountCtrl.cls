public with sharing class MRCPQ_MoveQuoteToAccountCtrl {
    
    
    @AuraEnabled
    public static string isValidated(String quoteId) {
        List<BigMachines__Quote__c> lstQuote = [SELECT BigMachines__Opportunity__c,BigMachines__Status__c FROM BigMachines__Quote__c WHERE Id=:quoteId];
        map<String,String> mapMSg = new map<String,String>();
        for(Alerts_And_Messages__mdt msg : [SELECT DeveloperName,Message__c FROM Alerts_And_Messages__mdt WHERE Success_OR_Error_Messages__r.DeveloperName = 'MRCPQ_MoveQuote']){
            mapMSg.put(msg.DeveloperName,msg.Message__c);
        }
        system.debug('lstQuote'+lstQuote.get(0).BigMachines__Opportunity__c);
        Set<String> excludeStatus = new Set<String>{'Approval Pending','Order Creation In Progress','Order Creation Successful','Completed'};
            if(!lstQuote.isEmpty() && !excludeStatus.contains(lstQuote.get(0).BigMachines__Status__c)){
                if(lstQuote.get(0).BigMachines__Opportunity__c!=null){
                    return mapMSg.get('Already_Have_Opportunity');
                }else{
                    return 'Success';
                }
            }else{
                return mapMSg.get('Not_Allowed_Status');
            }
    }
    
    @AuraEnabled
    public static List <Account> fetchAccount(String searchKeyWord) {
        String searchKey = '%' + searchKeyWord + '%';
        return [SELECT Id,Name,MCN_Account_Number__c from account
                where Name LIKE: searchKey AND Recordtype.Name IN ('Customer')];
    }
    
    @AuraEnabled
    public static List <Account> fetchMCNAccount(String searchKeyWord) {
        return [SELECT Id,Name,Motorola_Customer_Number__c,RecordType.Name,
                MCN_Account_Number__c from Account WHERE ParentId =: searchKeyWord 
                AND Recordtype.Name IN ('Motorola Customer Number') AND Motorola_Customer_Number__c!='' 
                AND Customer_or_Prospect_Account__c!=''];
    }
    
    @AuraEnabled
    public static String updateQuote(String quoteId, String accId,String mcnNumber) {
        String  partnerId;
        BigMachines__Quote__c toBeUpdated = new BigMachines__Quote__c();
        toBeUpdated.Id = quoteId;
        toBeUpdated.BigMachines__Account__c = accId;
        toBeUpdated.Motorola_Customer_Number__c = mcnNumber;
        //update toBeUpdated;
        List<User> users = [Select AccountId from User where Id =: UserInfo.getUserId() and AccountId != NULL];
        if(!users.isEmpty()){
            partnerId=users.get(0).AccountId;
        }
        //String  partnerId = [SELECt Id,createdBy.AccountID FROM BigMachines__Quote__c WHERE Id=:quoteId].createdBy.AccountID;
        String responseFromCPQ = updateQuoteDetailsInCPQ(quoteId,mcnNumber,partnerId);
        if(responseFromCPQ == 'Ok'){
            update toBeUpdated;
            return 'Ok';
        }
        else{
            return 'FAIL' ;
        }
        
    }
    
    public static string updateQuoteDetailsInCPQ(String quoteId,String mcnNumber,String partnerAccountId){
        BigMachines__Quote__c  quoteDetail = [SELECT Id,BigMachines__Transaction_Id__c,MR_ID__c,Effective_Commission_Dollars__c, 
                                              Order_Type__c,BigMachines__Account__c FROM BigMachines__Quote__c WHERE Id=:quoteId];
        
        Http httpProtocol = new Http();
        HttpResponse response = new HttpResponse();       
        HttpRequest request= new HttpRequest();     
        //RequestBodyAtt ds = new RequestBodyAtt(mcnNumber,'',quoteDetail.MR_ID__c,0.0,quoteDetail.Order_Type__c,0.0);
        RequestBodyAtt ds = new RequestBodyAtt(quoteDetail.Id,mcnNumber,'',quoteDetail.MR_ID__c,0.0,'Box',0.0,quoteDetail.BigMachines__Account__c,partnerAccountId);
        RequestWrapper requestWrap = new RequestWrapper();
        requestWrap.documents = ds;
        String authorizationHeader;
        String endPoint;
        map<String,Oracle_CPQ_API_Details__mdt> cpqAPI = new map<String,Oracle_CPQ_API_Details__mdt>();
        for(Oracle_CPQ_API_Details__mdt apiDetail : [SELECT Instance__c,authorizationHeader__c,endPoint__c FROM Oracle_CPQ_API_Details__mdt WHERE MasterLabel=:'updateQuoteDetailsInCPQ'] ){
            cpqAPI.put(apiDetail.Instance__c,apiDetail);
        }
        if(GlobalUtility.runningInASandbox()){
            //  authorizationHeader = 'Basic cHJpY2luZ19hcGk6ZElGNTM0KjNOcw==';
            //  endPoint = 'https://msicpq-ffosandbox1.bigmachines.com/rest/v6/commerceDocumentsOraclecpqoTransaction/'+quoteDetail.BigMachines__Transaction_Id__c+'/actions/changeCustomer_t';              
            authorizationHeader = cpqAPI.get('Sandbox').authorizationHeader__c;
            system.debug('authorizationHeader is***'+authorizationHeader);
            endPoint = cpqAPI.get('Sandbox').endPoint__c+quoteDetail.BigMachines__Transaction_Id__c+'/actions/changeCustomer_t';
            system.debug('endPoint is***'+endPoint);
            
        } else {
            authorizationHeader = cpqAPI.get('Production').authorizationHeader__c;
            endPoint = cpqAPI.get('Production').endPoint__c+quoteDetail.BigMachines__Transaction_Id__c+'/actions/changeCustomer_t';
        }
        String body = JSON.serialize(requestWrap);
        request.setMethod('POST');        
        request.setHeader('Authorization', authorizationHeader);        
        request.setHeader('Content-type','application/json');        
        request.setTimeout(50000);  
        request.setEndpoint(endPoint);   
        request.setBody(body);
        
        try{
            System.debug('request###'+request);
            System.debug('request###'+request.getBody());
            response = httpProtocol.send(request);
            System.debug('response##'+response);
            System.debug('response Body##'+response.getBody());
            if(response.getStatusCode() == 200){
                return 'Ok';    
            }else{
                return 'FAIL';
            }
        }catch(System.calloutException e){
            System.debug('#####Http request Callout Exception: '+e);
            String responseMessageException= '\nresponse.getStatusCode(): '+response.getStatusCode()+ '\n response.getStatus(): '+response.getStatus()+'\n response.getBody(): '+response.getBody();
            System.debug('#####responseMessageException: '+responseMessageException);
            return 'FAIL';
        }        
    }
    
    public class RequestWrapper{
        RequestBodyAtt documents;
    }
    
    public class RequestBodyAtt{
        public String sfaTransactionID_t;
        public String customerNumber_t;
        public String salesChannel_t;
        public String mrId_t;
        public Decimal mrCommission_t;
        public String mrOrderType_t;
        public Decimal mRCommissionOM_t;
        public Boolean isProspectQuote_t;
        
        RequestBodyAtt(String sfaTransactionID_t,String customerNumber_t,String salesChannel_t,String mrId_t,Decimal mrCommission_t,
                       String mrOrderType_t,Decimal mRCommissionOM_t,String CustomerID, String partnerAccountId){
                           System.debug('RequestBodyAtt OrderType####>' + mrOrderType_t + 'MRID###>' + mrId_t );
                           String accountId;  
                           if(String.isNotBlank(partnerAccountId)){
                               accountId = partnerAccountId;
                               System.debug('RequestBodyAtt accountId####>' +accountId);
                               System.debug('RequestBodyAtt CustomerID####>' + CustomerID);
                               System.debug('RequestBodyAtt customerNumber_t####>' + customerNumber_t);
                               CPQUtility.SpecAndCTypeWrapper specTypeWrapper = CPQUtility.fetchSpecAndCType(customerNumber_t, accountId,CustomerID);
                               mrCommission_t = CPQUtility.fetchPartnerTerritoryCommission(accountId,'Box',specTypeWrapper.mrTierLevel,specTypeWrapper.mrCommunityType); 
                           }else{
                               mrCommission_t =0.00;
                           }    
                           this.sfaTransactionID_t = sfaTransactionID_t;       
                           this.customerNumber_t = customerNumber_t;
                           this.salesChannel_t = salesChannel_t;
                           this.mrId_t = mrId_t;
                           this.mrCommission_t = mrCommission_t;
                           this.mrOrderType_t = mrOrderType_t;
                           this.mRCommissionOM_t = mrCommission_t;
                           this.isProspectQuote_t  = false;
                       }
    }
    
}