public class APTPS_CloneApprovalResubmit{

Apttus__APTS_Agreement__c agreement;
id agrid;
public APTPS_CloneApprovalResubmit(Apexpages.StandardController controller)
{
agrid=controller.getrecord().id;
 
}

public pagereference cloneagreement()
{

//Instance class
APTPS_CloneApprovalResubmittedAgreement agrmtclone=new APTPS_CloneApprovalResubmittedAgreement();
                          agrmtclone.mainmethod(agrid);
    system.debug('*****agreementId***********'+agrid);                      
   pagereference newPageRef = new pagereference('/'+agrid);
   return  newPageRef;
   }
 }