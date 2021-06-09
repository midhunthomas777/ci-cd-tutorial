/************************************************************************************************
* Description : This class is used for "Clone Quote" button on Quote layout on community.
* Author : Adilraza Shaikh
* Date :  29th Aug 2018
**********************************************************************************************/
public class MRCPQ_CloneQuoteController {
    @AuraEnabled
    public static String getPageUrl(String parentAccID){
        return CPQUtility.getPageUrl(parentAccID);
    }
}