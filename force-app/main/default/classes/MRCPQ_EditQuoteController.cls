/************************************************************************************************
* Description : This class is used for "Edit Quote" button on Quote layout on community.
* Author : Adilraza Shaikh
* Date :  29th Aug 2018
**********************************************************************************************/
public class MRCPQ_EditQuoteController {
    @AuraEnabled
    public static String fetchCPQSiteId(){
        return CPQUtility.fetchCPQSiteId();
    }
    @AuraEnabled
    public static String getPageUrl(String parentAccID){
        return CPQUtility.getPageUrl(parentAccID);
    }
}