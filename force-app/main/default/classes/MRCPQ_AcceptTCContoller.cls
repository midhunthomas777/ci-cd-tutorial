/************************************************************************************************ *
* Description: 
* 1.To fetch the details from contact if contact user had accepted the Terms and conditions and Document NA MR Digital AddendumID
* 2.To Update the contact once user accept the terms and conditions.
* Author : Adilraza Shaikh
* Date :  1st Aug 2018
**********************************************************************************************/
public class MRCPQ_AcceptTCContoller {
    
    @AuraEnabled
    public static List<MR_Digitization_Settings__mdt> fetchTermsCondition(){
        return [SELECT Long_Text_Area__c,Values__c from MR_Digitization_Settings__mdt WHERE 
                DeveloperName IN ('MR_Terms_Conditions')];
    }
    @AuraEnabled
    public static Boolean showReviewButton(){
        List<User> lstUser =[SELECT Id,ContactId FROM User WHERE Id =: UserInfo.getUserId()];
        List<Applications_Access__c> lstApplicationAccess = [SELECT Id,App_Access_Status__c FROM Applications_Access__c WHERE App_Name__c =:'CPQ' AND Contact__c =: lstUser.get(0).ContactId];
        if(lstApplicationAccess.size()>0 && lstApplicationAccess.get(0).App_Access_Status__c == 'T&C'){
            return true;
        }else{
            return false;
        } 
    }
    @AuraEnabled
    public static void termsAccepted(){
        CPQUtilityWithoutSharing.updateTC();
    }
}