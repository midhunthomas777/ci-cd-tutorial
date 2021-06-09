/*  
* File Name     : CreateErrorLog
* Description   : This class is used to capture error messages in ErrorLog Table.
*                 
* @author       : Jude Voss
*
* Modification Log
* =============================================================================
*   Ver     Date         Author          Modification
*------------------------------------------------------------------------------
*   1.0     25-Jan-12    Jude Voss       Initial Creation
*/
global class CreateErrorLog{
     public static void createErrorRecord(String exceptionMessage,String objName, String exceptionCause, String uName,DateTime currentDate, String exceptionType){
             InternalError__c iError = new InternalError__c();
             iError.Error_Message__c=exceptionMessage;
             iError.Object_type__c=objName;
             iError.Exception_Cause__c=exceptionCause;
             iError.User_Info__c=uName;
             iError.Date_Capture__c=currentDate;
             iError.Exception_Type__c=exceptionType;
             Database.insert(iError,false);
         
     }
}