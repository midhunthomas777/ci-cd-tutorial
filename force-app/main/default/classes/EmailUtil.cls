/*******************************************************************************
* Description : Util class for sending Email to Vesta Support and Customer
* Date : 04th Mar 2020
* Author: Accenture
******************************************************************************/

public class EmailUtil {
    /*******************************************************************************************************
    * @description Util to send the email   
    * @param rfwRecord RMARequestFormWrapper object
    * @return NA
    */
    public static void sendRMAEmail(RMARequestFormWrapper rfwRecord, String uniqueNumber) {
      
       // Constructing HTML body for Email                
       string body = 'Hello '+rfwRecord.userDetails.contact.name+'<br/>'+'Thank you for submitting repair request.Your confirmation number is ' + uniqueNumber +  ' .You will receive another email with your RMA number once the repair ticket has been created.<br/>For any questions or support please respond to Vesta.peirma@motorolasolutions.com or contact our Repair Department at 1-800-491-1734, option 3<br/><p style="background-color:black;color:white" >Company Information</p>'+
                      '<div>'+'<b>Motorola Solutions Customer Account Number: </b>'+rfwRecord.userenDetails.customerAccountNumber+'<br/>'+
                                '<b>PO#:</b>'+rfwRecord.userenDetails.po+'<br/>'+
                                '<b>Company Name: </b>'+rfwRecord.userDetails.companyName+'<br/>'+
                                '<b>Billing Address: </b>'+rfwRecord.userDetails.Contact.MailingStreet+'<br/>'+
            '<b>City:</b>'+rfwRecord.userDetails.city+'<br/>'+
            '<b>State:</b>'+rfwRecord.userDetails.state+'<br/>'+
            '<b>ZIP:</b>'+rfwRecord.userDetails.Contact.MailingPostalCode+'<br/>'+
            '<b>Contact Name:</b>'+rfwRecord.userDetails.contact.name+'<br/>'+
            '<b>Contact E-mail#:</b>'+rfwRecord.userDetails.Contact.Email+'<br/>'+
            '<b>Contact Phone Number:</b>'+rfwRecord.userDetails.Phone+'<br/>'+
            '<b>Fax Number:</b>'+rfwRecord.userenDetails.faxNumber+'<br/>'+'</div>';
        
        
       if(!rfwRecord.lineItemWrapList.IsEmpty())
       {
            body += '<br/><p style="background-color:black;color:white" >Parts Information</p>';
           body += '<table style="width:100%"><tr><th><p style="text-align: unset !important;">Part Number</P></th><th><p style="text-align: unset !important;">Serial#</P></th><th><p style="text-align: unset !important;">Manufacturer Date</P></th><th><p style="text-align: unset !important;">Problem Description</P></th></tr>';
           for(RMARequestFormWrapper.LineItemWrapper liwRec: rfwRecord.lineItemWrapList)
           {
               body +='<tr><td><p style="text-align: center;">'+liwRec.partNumber+'</p></td><td><p style="text-align: center;">'+liwRec.serial+'</p></td><td><p style="text-align: center;">'+liwRec.manfactureDate.format()+'</p></td><td><p style="text-align: center;">'+liwRec.problemDescription+'</p></td></tr>';
           }
           body +='</table>';
       }
         body += '<br/><p style="background-color:black;color:white" >Shipping Information</p>'+
                      '<div>'+
            '<b>Company Name:</b>'+rfwRecord.ShipToAddress.companyName+'<br/>'+
            '<b>Site Name:</b>'+rfwRecord.userenDetails.siteName+'<br/>'+
            '<b>Attn:</b>'+rfwRecord.ShipToAddress.attn+'<br/>'+
            '<b>Address:</b>'+rfwRecord.ShipToAddress.shipAddress+'<br/>'+
            '<b>City:</b>'+rfwRecord.ShipToAddress.city+'<br/>'+
            '<b>State:</b>'+rfwRecord.ShipToAddress.state+'<br/>'+
            '<b>Preferred Shipping Method:</b>'+rfwRecord.userenDetails.preferredShippingMethod+'<br/>'+'</div>';
        //Querying for OrgWideEmailAddressId of VestaSupportEmail
       OrgWideEmailAddress[] orgWideAddressID= [select Id from OrgWideEmailAddress where DisplayName ='VestaSupportEmail'];
       List<String> toaddress = new List<String>();
       toaddress.add(Label.RMA_Email);
       Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
       Id contactID=rfwRecord.userDetails.ContactId;
       mail.setTargetObjectId(contactID); 
       mail.setHtmlBody(body);
       mail.setOrgWideEmailAddressId(orgWideAddressID.get(0).Id);
       mail.setSubject(' Your repair request is submitted ');
       mail.setToAddresses(toaddress);
       Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        
    }
}