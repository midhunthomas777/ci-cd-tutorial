public class MRCommissionCalcDetailsCtrl {
    
    @AuraEnabled
    public static CPQUtility.AccountDetailsWrapper fetchAccountDetails(String motoNum,String accId,String partnerAccountID){
        System.debug('MRCommCalc motoNum###' +motoNum);
        System.debug('MRCommCalc accId###' +accId);
        System.debug('MRCommCalc partnerAccountID###' +partnerAccountID);
        if(String.isBlank(partnerAccountID)){
            if(userinfo.getusertype() == 'PowerPartner'){
                partnerAccountID = [SELECT AccountId FROM User WHERE Id =: Userinfo.getUserId()].AccountId;
            }
        }         
        return CPQUtility.fetchAccountDetails(motoNum, partnerAccountID,accId);
    }
    
   /* @AuraEnabled
    public static CommissionWrapper calculateCommission(String mcn, String partnerId, String orderTypesResponses, String custOrProsId){
        Map<String, Map<String, String>> questionsResponses = new Map<String, Map<String, String>>();
        Map<String, Object> firstMap = (Map<String, Object>)JSON.deserializeUntyped(orderTypesResponses);
        for(String orderType : firstMap.keySet()) {
            Map<String, Object> secondMap  = (Map<String, Object>)firstMap.get(orderType);
            Map<String, String> questionsTempMap = new Map<String, String>();
            for(String questionKey : secondMap.keySet()) {
                if(questionKey != 'sobjectType') {
                    String answer  = String.valueOf(secondMap.get(questionKey));                    
                    if(answer!='None' && answer!='false' && answer!='No' && String.isNotBlank(answer)){                       
                        questionsTempMap.put(questionKey, answer);
                        system.debug('Output val of map'+questionsTempMap.get(questionKey));
                        questionsResponses.put(orderType, questionsTempMap);
                    }
                }
            }
        }
        system.debug('###########questionsResponses############ => '+ questionsResponses);
        return null;
    }*/
    
}