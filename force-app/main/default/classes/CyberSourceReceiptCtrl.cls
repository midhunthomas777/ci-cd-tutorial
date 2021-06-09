public without sharing class CyberSourceReceiptCtrl {
    public String currentCartId{get;set;}
    private String decision{get;set;}
    public void init() {
        try {
            Map<String, String> params = ApexPages.currentPage().getParameters();
            this.currentCartId = params.get('quoteId');
            String authTime = 'N/A';
            String paymentToken = 'N/A';
            String authCode = 'N/A';
            Double authAmount;
            decision = params.get('decision');
            if(params.get('decision') == 'ACCEPT') {
                authTime = params.get('auth_time').substring(0,10) + ' 00:00:00';
                paymentToken = params.get('payment_token');
                authAmount = Double.valueOf(params.get('auth_amount'));
                authCode = params.get('auth_code');
            }
            Quote_Payment__c quotePayment = new Quote_Payment__c(
                Credit_Card_Approval_Code__c = authCode,
                Credit_Card_Approval_Date__c = authTime,
                Credit_Card_Code__c = 'UNKNOWN',
                Credit_Card_Expiration_Date__c = lastDayOfMonthDate(params.get('req_card_expiry_date')),
                Credit_Card_Holder_Name__c = params.get('req_bill_to_forename') + ' ' 
                + params.get('req_bill_to_surname') + ' ' 
                + translateCardType(params.get('req_card_type')) + ' ' 
                + params.get('req_card_number').right(4),
                Credit_Card_Number__c = paymentToken,
                Decision__c = params.get('decision'),
                Oracle_Quote__c = currentCartId,
                Payment_Amount__c = authAmount,
                Payment_Type_Code__c = 'CREDIT_CARD',
                Cyber_Request_Id__c = params.get('transaction_id'),
                Message__c = params.get('message')
            );
            system.debug('####quotePayment##### => ' + quotePayment);
            insert quotePayment;
            if(quotePayment.Decision__c == 'ACCEPT') {
                update new BigMachines__Quote__c(
                    Id = currentCartId,
                    Credit_Card_Number__c = quotePayment.Credit_Card_Number__c,
                    Credit_Card_Code__c = quotePayment.Credit_Card_Code__c,
                    Credit_Card_Expiration_Date__c = quotePayment.Credit_Card_Expiration_Date__c,
                    Credit_Card_Holder_Name__c = quotePayment.Credit_Card_Holder_Name__c,
                    Credit_Card_Approval_Code__c = quotePayment.Credit_Card_Approval_Code__c,
                    Credit_Card_Approval_Date__c = quotePayment.Credit_Card_Approval_Date__c,
                    Payment_Type_Code__c = quotePayment.Payment_Type_Code__c,
                    Cyber_Request_Id__c = quotePayment.Cyber_Request_Id__c,
                    CyberSource_Decision__c = 'ACCEPTED',
                    CyberSource_Payment_Amount__c = quotePayment.Payment_Amount__c
                );
            } else {
                system.debug(currentCartId + '<= ##########quotePayment.Decision__c########### => ' + quotePayment.Decision__c);
                update new BigMachines__Quote__c(
                    Id = currentCartId,
                    CyberSource_Decision__c = 'DECLINED'
                );                
            }
            
        } catch(Exception ex) {
            system.debug('##########ex########### => ' + ex.getLineNumber());
        }
    }
    
    public String lastDayOfMonthDate(String expDate) {
        String[] expDateStr = expDate.split('-');
        Integer myIntMonth = Integer.valueOf(expDateStr[0]);
        Integer myIntYear = Integer.valueOf(expDateStr[1]);
        Integer numberOfDays = Date.daysInMonth(myIntYear, myIntMonth);
        DateTime DT = DateTime.newInstance(myIntYear, myIntMonth, numberOfDays, 00, 00, 00);
        //Date lastDayOfMonth = Date.newInstance(myIntYear, myIntMonth, numberOfDays);
        return String.valueOf(DT);
    }
    
    private String translateCardType(String cardType) {
        if (cardType == '001') return 'Visa';
        else if (cardType == '002') return 'Mastercard';
        else if (cardType == '003') return 'American Express';
        else if (cardType == '004') return 'Discover';
        else return cardType;
    }
    
    public PageReference processResults() {
        init();
        String url = CPQUtility.getPageUrl(currentCartId);
        String siteId = CPQUtility.fetchCPQSiteId();
        
        if(decision == 'ACCEPT') {
            return new PageReference(url + '&siteId=' + siteId + '&Id=' + currentCartId);
        }
        if(GlobalUtility.isLoggedinPartnerUser()) {
            return new PageReference(System.URL.getSalesforceBaseUrl().toExternalForm() + '/NA/s/quote/' + currentCartId);   
        }
        return new PageReference(System.URL.getSalesforceBaseUrl().toExternalForm() + '/apex/BigMachines__QuoteEdit?Id='+currentCartId);
    }
}