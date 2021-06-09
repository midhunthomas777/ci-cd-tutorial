/**
* @author Gurditta Garg,Swarupa
* @date Sep 2020
* @description Controller for CreateAPBLineItems Component 
* @group Utilities
* @group-content ../../Utility/JWT.htm
*
* @description Utility to Generate JTW token based on https://jwt.io/, right now this supports only HS256/HMAC256
*		To support RS256, we will have to use rsa-sha256 with the Certificate or P12
*
*/
public Without Sharing class DTSFPART_CreateAPBLineItemsCtrl {
    
    @AuraEnabled
    public static Boolean isLoggedInFromCommunity() {
        return GlobalUtility.isLoggedinPartnerUser();
    }
    
    @AuraEnabled(cacheable=true)
    public static String generateAuthToken(String recId) {
        Map<String,Object> payload = new Map<String,Object>();
        //String privateKey = System.Label.Secret_Key_for_OCC_Integration;
        String callbackUrl = CPQUtility.fetchSitePrefix() + '/s/above-price-book/' + recId;
        ApexClass classObj = [SELECT ApiVersion FROM ApexClass ORDER BY ApiVersion DESC LIMIT 1];
        Id currentRecId = Id.valueOf(recId);
        String occLineItemsURL = URL.getOrgDomainUrl().toExternalForm()+'/services/data/v'+classObj.ApiVersion+'/composite/tree/OCC_Line_Item__c';
        String updateBackAPB = URL.getOrgDomainUrl().toExternalForm()+'/services/data/v'+classObj.ApiVersion+ '/sobjects/'+currentRecId.getSObjectType().getDescribe().getName() + '/'+currentRecId;
        Above_Price_Book__c apbRecord = [SELECT Id,Name,Approval_Status__c,ARZM__c,
                                         Customer_Account__r.Motorola_Customer_Number__c,Partner_MCN__c FROM Above_Price_Book__c WHERE Id=:currentRecId];
        
        if(apbRecord.Approval_Status__c == 'Approved') {
            payload.put('status',apbRecord.Approval_Status__c);
            payload.put('updateBackAPBURL', updateBackAPB);
        } else {
            payload.put('occLineItemsURL', occLineItemsURL);
            payload.put('recordId', recId);
        }
        
        payload.put('arzm', apbRecord.ARZM__c);
        payload.put('endCustomerNumber', apbRecord.Customer_Account__r.Motorola_Customer_Number__c);
        payload.put('partnerCustomerNumber', apbRecord.Partner_MCN__c);
        payload.put('exp',DateTime.now().addHours(4).getTime()/1000);
        payload.put('sessionId', UserInfo.getOrganizationId()+''+UserInfo.getSessionId().substring(15));
        payload.put('callBackURL', callbackUrl);
        payload.put('apbName', apbRecord.Name);
        String authToken = JWT.generateAuthToken(payload, System.Label.Secret_Key_for_OCC_Integration);
        System.debug('payload..'+payload);
        return authToken;
    }
}