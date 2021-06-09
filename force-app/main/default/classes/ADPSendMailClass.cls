/*  
* File Name     : ADPSendMailClass
* Description   : Class used to send mail to the respective team when a Error/Exception occurs during the ADP Http callout to OAG/GIT
* Modification Log
* =============================================================================
*   Ver     Date         Author                      Modification
*------------------------------------------------------------------------------
*   1.0     24-Dec-16    Poongodi V                  Initial Creation
*/
public class ADPSendMailClass{

   public void sendEmail(string emailcontentbody,string[] useremail,string subject){

      Messaging.singleEmailMessage email1 = new Messaging.singleEmailMessage();
      email1.setSubject(subject);
      email1.setToaddresses(useremail);
      email1.setPlainTextBody(emailcontentbody);
      Messaging.sendEmailResult[] res = Messaging.sendEmail(new Messaging.singleEmailMessage[]{email1});
   }
}